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

-- ─────────────────────────────────────────────────────────────
-- Funciones extra del panel (notas internas y gestión de administradores).
-- Ejecuta este bloque una vez en SQL Editor.
-- ─────────────────────────────────────────────────────────────

-- Notas internas en cada solicitud (solo las ven los administradores).
alter table public.solicitudes
  add column if not exists notas text check (char_length(notas) <= 2000);
grant update (estado, notas) on public.solicitudes to authenticated;

-- Lista de administradores con su correo.
create or replace function public.listar_admins()
returns table (user_id uuid, email text, creado timestamptz)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not public.es_admin() then
    raise exception 'Sin permisos de administrador';
  end if;
  return query
    select a.user_id, u.email::text, a.creado
    from public.administradores a
    join auth.users u on u.id = a.user_id
    order by a.creado;
end;
$$;

-- Da acceso de administrador a un usuario que ya existe en Authentication → Users.
create or replace function public.agregar_admin(correo text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid;
begin
  if not public.es_admin() then
    raise exception 'Sin permisos de administrador';
  end if;
  select id into uid from auth.users where lower(email) = lower(trim(correo));
  if uid is null then
    raise exception 'No existe ningún usuario con ese correo. Créalo primero en Authentication → Users.';
  end if;
  insert into public.administradores (user_id) values (uid) on conflict do nothing;
end;
$$;

-- Quita el acceso de administrador (no puedes quitarte a ti mismo).
create or replace function public.quitar_admin(uid uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.es_admin() then
    raise exception 'Sin permisos de administrador';
  end if;
  if uid = auth.uid() then
    raise exception 'No puedes quitarte el acceso a ti mismo.';
  end if;
  delete from public.administradores where user_id = uid;
end;
$$;

revoke all on function public.listar_admins() from public, anon;
revoke all on function public.agregar_admin(text) from public, anon;
revoke all on function public.quitar_admin(uuid) from public, anon;
grant execute on function public.listar_admins() to authenticated;
grant execute on function public.agregar_admin(text) to authenticated;
grant execute on function public.quitar_admin(uuid) to authenticated;
