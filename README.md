# Flowpixel

Página web de un estudio de edición de fotos, anuncios para redes, portadas y piezas gráficas.

- `index.html`: la página completa (HTML, CSS y JavaScript en un solo archivo).
- `admin.html`: panel privado para ver y gestionar las solicitudes de cotización.
- `supabase.sql`: tablas y reglas de seguridad de Supabase.

## Ver la página en tu computadora

Abre `index.html` con doble clic en cualquier navegador.

## Publicación

La página se publica gratis con GitHub Pages desde la rama `main`.

## Panel de administración

Entra en `admin.html` (por ejemplo `https://<tu-usuario>.github.io/<repo>/admin.html`).
Ahí ves el resumen de solicitudes, puedes buscarlas, filtrarlas, cambiar su estado y exportarlas a CSV.

Para activarlo una sola vez:

1. En Supabase → **Authentication → Users → Add user**, crea tu usuario con correo y contraseña (marca *Auto Confirm User*).
2. En Supabase → **Authentication → Sign In / Providers**, desactiva *Allow new users to sign up* para que nadie más pueda registrarse.
3. En `supabase.sql`, cambia `tu-correo@ejemplo.com` por tu correo y ejecuta el archivo completo en **SQL Editor**.

Solo los usuarios que estén en la tabla `administradores` pueden ver las solicitudes. Para dar acceso a otra persona, crea su usuario y repite el último `insert` del SQL con su correo.
