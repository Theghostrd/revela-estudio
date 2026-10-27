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

Solo los usuarios que estén en la tabla `administradores` pueden ver las solicitudes.

El panel tiene tres pestañas:

- **Resumen**: totales por estado, solicitudes por semana, reparto por servicio y estado, y las nuevas que llevan más tiempo esperando.
- **Solicitudes**: búsqueda, filtros por estado, servicio y fecha, orden, cambio de estado, notas internas, botones de correo/WhatsApp y exportación a CSV.
- **Equipo**: dar o quitar acceso de administrador a otros usuarios.

Para que funcionen las notas y la pestaña Equipo, ejecuta una vez en **SQL Editor** el bloque *Funciones extra del panel* de `supabase.sql`. Para dar acceso a alguien: créale el usuario en **Authentication → Users** y luego escribe su correo en la pestaña **Equipo**.
