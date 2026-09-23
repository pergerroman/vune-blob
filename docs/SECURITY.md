# Seguridad

## Autenticación humana

- No existe registro público.
- Las cuentas las crea un administrador.
- Contraseñas con `password_hash()` y `password_verify()`; usar `PASSWORD_DEFAULT` y rehash cuando corresponda.
- Mensaje de login genérico para no revelar si el email existe.
- Rate limit por IP y por identidad normalizada.
- Regenerar la sesión al autenticar.
- Cookie con `HttpOnly`, `Secure`, `SameSite=Lax` o `Strict`, Path `/` y sin Domain amplio.
- Expiración por inactividad y absoluta; propuesta inicial: 30 minutos y 12 horas.
- Logout revoca la sesión servidor y expira la cookie.

## CSRF

Toda operación mutante autenticada por cookie requiere token CSRF asociado a la sesión, enviado en `X-CSRF-Token`. Los métodos `GET`, `HEAD` y `OPTIONS` no modifican estado. Los Bearer tokens no utilizan cookies y no requieren CSRF, pero sí scopes.

## Tokens API

Formato:

```text
vbl_live_<identifier>_<secret>
```

- Generar secreto con CSPRNG.
- Mostrar el token completo una sola vez.
- Buscar por `prefix` y verificar `secret_hash` con comparación segura.
- Registrar scopes en filas separadas.
- Admitir expiración y revocación inmediata.
- Nunca aceptar tokens en query string.
- Actualizar `last_used_at` con escritura limitada para evitar I/O en cada request.

## Roles

| Acción | owner | admin | editor | viewer |
|---|:---:|:---:|:---:|:---:|
| Ver proyecto/archivos | Sí | Sí | Sí | Sí |
| Subir y crear carpetas | Sí | Sí | Sí | No |
| Editar/mover assets | Sí | Sí | Sí | No |
| Enviar a papelera | Sí | Sí | Sí | No |
| Restaurar | Sí | Sí | Sí | No |
| Gestionar miembros | Sí | Sí | No | No |
| Gestionar tokens | Sí | Sí | No | No |
| Cambiar cuotas/proyecto | Sí | Sí | No | No |
| Eliminar proyecto/Blob | Sí | No | No | No |

`owner` no puede ser eliminado si dejaría al proyecto sin propietario.

## Seguridad de uploads

- Un archivo por request en el MVP.
- Límites administrativos: imagen 20 MB, documento 50 MB, audio 100 MB, video 250 MB, genérico 100 MB.
- No confiar en nombre, extensión, `Content-Type` ni ruta del cliente.
- Detectar MIME con `finfo` y normalizar extensiones.
- Bloquear al menos `.php`, `.phtml`, `.phar`, `.cgi`, `.sh`, `.exe` y variantes de mayúsculas/doble extensión peligrosa.
- Rechazar nombres con controles, bytes nulos o longitud excesiva.
- Usar claves físicas generadas, nunca el nombre original.
- Escribir temporal fuera del document root con permisos mínimos.
- Calcular SHA-256 y comprobar cuota con reserva.
- Aplicar `Content-Disposition` seguro al descargar.

## Autorización de contenido

- Verificar pertenencia proyecto -> Blob -> carpeta/Asset en cada operación.
- Un ID válido de otro proyecto devuelve `404` cuando conviene evitar enumeración.
- Acceso público sólo si Blob y Asset son públicos y ambos están activos.
- Archivos privados requieren sesión autorizada o token con scope.
- Las rutas físicas y claves de storage nunca salen en JSON.

## HTTP

Configuración inicial:

```text
Strict-Transport-Security: max-age=31536000
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
X-Frame-Options: DENY
X-Robots-Tag: noindex, nofollow, noarchive, nosnippet
Content-Security-Policy: default-src 'self'; img-src 'self' blob: data:; media-src 'self' blob:; object-src 'none'; base-uri 'self'; frame-ancestors 'none'; form-action 'self'
```

HSTS se activa sólo después de confirmar HTTPS estable en el subdominio.

El HTML también debe incluir `meta robots`. `robots.txt` usa `Disallow: /`, pero no es una barrera de seguridad.

## Secretos y configuración

- Archivo sugerido: `/home/estudi76/storage-config/config.php`.
- Permisos legibles únicamente por el usuario/proceso necesario.
- No registrar ni versionar credenciales.
- `configuration_reference` guarda una referencia, nunca el secreto.
- Rotar credenciales de DB, `APP_SECRET` y tokens si se sospecha exposición.

## SQL y errores

- PDO en modo excepciones, emulación de prepares deshabilitada.
- Consultas parametrizadas; listas y ordenamientos salen de allowlists.
- No mostrar SQL, stack traces, rutas ni excepciones al cliente.
- Cada error incluye `request_id` para correlación.

## Auditoría y privacidad

Registrar inicios de sesión, fallos, cambios de permisos, uploads, descargas privadas, eliminaciones, restauraciones y tokens. No registrar contraseñas, cookies, CSRF, secretos, tokens completos ni contenido de archivos.

## Backups

- Cifrar la copia fuera de BlueHosting.
- Separar dump de DB y objetos.
- Probar restauración periódicamente.
- Conservar manifest con ID, clave, tamaño y checksum.
