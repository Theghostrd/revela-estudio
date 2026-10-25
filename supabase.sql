-- Revela Estudio: tabla de solicitudes de cotización.
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
