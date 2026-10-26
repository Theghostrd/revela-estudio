-- Flowpixel: tabla de solicitudes de cotización.
-- Pega todo esto en Supabase → SQL Editor → New query, y pulsa Run.

create table if not exists public.solicitudes (
  id         bigint generated always as identity primary key,
  creada     timestamptz not null default now(),
  nombre     text not null check (char_length(nombre) between 1 and 120),
  contacto   text not null check (char_length(contacto) between 3 and 160),
  marca      text check (char_length(marca) <= 120),
  servicio   text not null check (char_length(servicio) <= 60),
  cantidad   integer not null default 1 check (cantidad between 1 and 1000),
  detalles   text check (char_length(detalles) <= 2000),
  estado     text not null default 'nueva' check (estado in ('nueva', 'cotizada', 'en curso', 'entregada', 'descartada'))
);

-- Seguridad: los visitantes de la página solo pueden INSERTAR solicitudes nuevas.
-- No pueden leer, cambiar ni borrar ninguna. Tú las ves desde el Table Editor de Supabase.
alter table public.solicitudes enable row level security;

revoke all on public.solicitudes from anon, authenticated;
grant insert (nombre, contacto, marca, servicio, cantidad, detalles) on public.solicitudes to anon;

drop policy if exists "Visitantes pueden enviar solicitudes" on public.solicitudes;
create policy "Visitantes pueden enviar solicitudes"
  on public.solicitudes
  for insert
  to anon
  with check (estado = 'nueva');

-- ─────────────────────────────────────────────────────────────
-- Panel de administración (admin.html)
-- 1. Crea tu usuario en Supabase → Authentication → Users → Add user
--    (marca "Auto Confirm User").
-- 2. Cambia el correo de abajo por el tuyo y ejecuta este bloque.
-- ─────────────────────────────────────────────────────────────

-- Lista de administradores. Solo quien esté aquí puede ver y cambiar solicitudes.
create table if not exists public.administradores (
  user_id uuid primary key references auth.users (id) on delete cascade,
  creado  timestamptz not null default now()
);
alter table public.administradores enable row level security;
revoke all on public.administradores from anon, authenticated;

-- Devuelve true si el usuario que inició sesión es administrador.
create or replace function public.es_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.administradores where user_id = auth.uid());
$$;
revoke all on function public.es_admin() from public, anon;
grant execute on function public.es_admin() to authenticated;

-- Los administradores pueden leer todas las solicitudes y cambiar su estado.
grant select on public.solicitudes to authenticated;
grant update (estado) on public.solicitudes to authenticated;

drop policy if exists "Admins leen solicitudes" on public.solicitudes;
create policy "Admins leen solicitudes"
  on public.solicitudes for select to authenticated
  using (public.es_admin());

drop policy if exists "Admins cambian estado" on public.solicitudes;
create policy "Admins cambian estado"
  on public.solicitudes for update to authenticated
  using (public.es_admin())
  with check (public.es_admin());

-- Dar acceso de administrador (cambia el correo por el tuyo):
insert into public.administradores (user_id)
select id from auth.users where email = 'lblanco135@gmail.com'
on conflict do nothing;
