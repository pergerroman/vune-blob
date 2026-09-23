# Contexto maestro para Codex — Backend e infraestructura de plataforma Storage

## Objetivo del proyecto

Desarrollar una plataforma privada para administrar archivos y almacenamiento por proyectos.

La plataforma debe permitir:

- usuarios;
- proyectos;
- miembros y roles por proyecto;
- blobs/buckets lógicos;
- carpetas y subcarpetas lógicas;
- archivos/assets;
- versiones de archivos;
- etiquetas;
- tokens de acceso;
- URLs públicas y privadas;
- permisos;
- registro de actividad;
- límites y consumo de almacenamiento;
- almacenamiento desacoplado mediante un `StorageDriver`;
- migración futura a S3, Cloudflare R2 u otro proveedor sin rehacer la aplicación.

La prioridad actual es resolver correctamente:

- arquitectura;
- backend;
- modelo de datos;
- almacenamiento;
- seguridad;
- API;
- infraestructura;
- despliegue.

La interfaz visual se desarrolla por separado.

---

# Condiciones del producto

La plataforma será inicialmente privada.

Debe cumplirse:

- acceso mediante autenticación;
- no debe existir registro público;
- no debe indexarse en buscadores;
- no debe exponerse un sitemap;
- debe utilizar `noindex`;
- debe poder enviar `X-Robots-Tag`;
- debe deshabilitarse directory listing;
- los archivos privados nunca deben ser accesibles mediante una ruta física pública;
- toda la plataforma debe funcionar mediante HTTPS.

`robots.txt` puede utilizarse como capa adicional, pero nunca debe considerarse un mecanismo de seguridad.

---

# Hosting disponible

La aplicación se desplegará inicialmente en BlueHosting, sobre un hosting compartido con cPanel.

Datos confirmados:

- Linux.
- Apache 2.4.
- cPanel.
- PHP-FPM disponible.
- PHP 8.4 activo para la aplicación.
- Selector de versión PHP disponible.
- Extensiones `pdo_mysql`, `fileinfo`, `mbstring`, `openssl` y `json` activas bajo PHP 8.4.
- MariaDB 10.6.24.
- phpMyAdmin disponible.
- SSL activo en el dominio principal.
- Cron disponible.
- FTP disponible.
- Node.js aparece como opción en cPanel, pero no será una dependencia del MVP.
- Disco local disponible bajo `/home/estudi76`.
- Lectura y escritura PHP fuera de `public_html` confirmadas.
- `public_html` disponible.
- `blob.estudiovune.com` creado como dominio público principal de la aplicación.
- raíz documental de la aplicación en `/home/estudi76/public_html/blob.estudiovune.com`.
- HTTPS activo en `blob.estudiovune.com` con certificado Let’s Encrypt.
- `.htaccess`, `mod_rewrite` y `Options -Indexes` confirmados mediante una prueba aislada.
- límite aproximado de 200.000 inodos.
- recursos aproximados:
  - 2 GB RAM;
  - 5 MB/s I/O;
  - 1024 IOPS;
  - 35 Entry Processes;
  - 175 procesos.

Límites PHP observados actualmente:

```text
upload_max_filesize = 512 MB
post_max_size = 1024 MB
memory_limit = 2048 MB
max_execution_time = 600
max_input_time = 400
max_file_uploads = 40
```

Pendientes de confirmar antes del despliegue definitivo:

- SSH/SFTP para la cuenta;
- política real de almacenamiento/fair use;
- política de backups;
- mantenimiento/parcheado aplicado por BlueHosting a MariaDB 10.6;
- restricciones concretas de Cron;
- cabeceras y routing definitivos del front controller mediante `.htaccess`.

No asumir capacidades no comprobadas.

---

# Stack elegido

## Frontend

Usar preferentemente:

```text
HTML5
CSS
JavaScript vanilla
ES Modules
Fetch API
```

No introducir React, Vue, Next, Nuxt u otro framework frontend salvo necesidad técnica real.

Vercel puede utilizarse para previews si aporta valor, pero no debe ser dependencia de producción.

---

## Backend

Usar preferentemente:

```text
PHP 8.x
Apache
REST API JSON
PDO
Sessions
```

No utilizar Node.js como runtime principal.

No utilizar Laravel de entrada.

El backend debe ser modular, mantenible y separado por responsabilidades.

Estructura orientativa:

```text
app/
├── Controllers/
├── Services/
├── Repositories/
├── Models/
├── Storage/
├── Auth/
├── Middleware/
├── Validation/
├── Security/
└── Database/

public/
├── index.php
├── assets/
└── .htaccess

config/
database/
docs/
```

Podés ajustar esta estructura si existe una razón técnica clara.

---

# Base de datos

Usar:

```text
MariaDB
PDO
InnoDB
utf8mb4
UTC
```

Crear una base exclusiva para la plataforma.

No reutilizar bases pertenecientes a WordPress ni otros proyectos.

Las fechas deben persistirse en UTC.

---

# Arquitectura de almacenamiento

La lógica de negocio no debe depender directamente del filesystem de BlueHosting.

Debe existir una abstracción:

```text
StorageDriver
```

Contrato inicial sugerido:

```text
put()
readStream()
exists()
delete()
size()
checksum()
getPublicUrl()
```

Puede agregarse:

```text
copy()
move()
metadata()
```

si resulta realmente necesario.

Implementación inicial:

```text
LocalStorageDriver
```

Implementaciones futuras:

```text
S3StorageDriver
CloudflareR2StorageDriver
BackblazeStorageDriver
```

La API, los proyectos, los assets y los tokens no deben necesitar cambios si cambia el proveedor físico.

---

# Storage físico inicial

Objetivo:

```text
/home/estudi76/blob-storage/
├── objects/
├── temporary/
└── quarantine/
```

El directorio debe estar fuera del document root siempre que la cuenta lo permita.

Antes de utilizarlo con archivos reales debe comprobarse que PHP-FPM pueda:

```text
create
read
write
delete
```

en esa ubicación.

Los archivos privados no deben poder solicitarse directamente mediante HTTP.

---

# Carpetas lógicas

Las carpetas que aparecen en la interfaz son entidades de base de datos.

Ejemplo:

```text
Pragmática
└── Producción Web
    └── Home
        └── Hero
```

Esta estructura no debe obligar a crear físicamente:

```text
/projects/pragmatica/produccion-web/home/hero/
```

El storage físico debe utilizar claves opacas.

Ejemplo:

```text
objects/
└── 01/
    └── a8/
        └── obj_01KXXXXXXXX
```

Mover o renombrar una carpeta lógica no debe implicar necesariamente mover el archivo físico.

---

# Identidad de archivos

Mantener separados:

```text
asset_id
reference_code
original_filename
storage_key
```

Ejemplo:

```text
asset_id:
ast_01KABC...

reference_code:
PGM-IMG-000142

original_filename:
hero-oil-gas.webp

storage_key:
01/a8/obj_01KXYZ...
```

Nunca utilizar el nombre original como identificador interno.

---

# IDs

Usar identificadores internos opacos y estables.

Formato conceptual:

```text
usr_...
prj_...
blb_...
fld_...
ast_...
ver_...
obj_...
tok_...
upl_...
```

Preferencia:

```text
ULID
```

o alternativa equivalente que:

- sea difícil de adivinar;
- funcione bien como identificador externo;
- no dependa de autoincrementales visibles.

---

# Referencias humanas

Cada proyecto tendrá un código corto.

Ejemplos:

```text
PGM
VUN
TIZ
CHV
```

Cada asset tendrá una referencia legible.

Formato:

```text
[PROJECT_CODE]-[TYPE]-[SEQUENCE]
```

Ejemplos:

```text
PGM-IMG-000001
PGM-DOC-000002
PGM-VID-000003
```

Tipos iniciales:

```text
IMG
VID
AUD
DOC
ARC
```

La referencia debe permanecer estable aunque:

- cambie el nombre;
- cambie de carpeta;
- se reemplace el contenido;
- cambie el proveedor de almacenamiento.

---

# Modelo de datos

Diseñar como mínimo estas entidades:

```text
users
projects
project_members

blobs

folders

assets
asset_versions

tags
asset_tags

access_tokens
token_scopes

activity_logs

storage_providers

upload_sessions
```

Agregar otras tablas únicamente cuando exista una razón funcional clara.

---

# Users

Campos mínimos:

```text
id
name
email
password_hash
status
last_login_at
created_at
updated_at
```

No almacenar contraseñas cifradas reversiblemente.

Usar las funciones seguras de password hashing de PHP.

---

# Projects

Campos sugeridos:

```text
id
name
code
description
status
storage_limit_bytes
created_by
created_at
updated_at
deleted_at
```

El límite de almacenamiento será administrativo.

No derivarlo automáticamente del almacenamiento mostrado como ilimitado por cPanel.

---

# Project members

Relacionar:

```text
user_id
project_id
role
created_at
```

Roles iniciales:

```text
owner
admin
editor
viewer
```

Crear constraint único:

```text
user_id + project_id
```

---

# Blobs / buckets

Un Blob es una entidad lógica de almacenamiento y permisos dentro de un proyecto.

Campos sugeridos:

```text
id
project_id
name
code
description
visibility
storage_provider_id
storage_limit_bytes
status
created_by
created_at
updated_at
deleted_at
```

Estados iniciales:

```text
active
archived
deleted
```

Visibilidad:

```text
public
private
```

No asumir que un Blob equivale a una carpeta física.

---

# Folders

Campos sugeridos:

```text
id
blob_id
parent_id
name
created_by
created_at
updated_at
deleted_at
```

La jerarquía se resuelve mediante:

```text
parent_id
```

Prevenir:

- ciclos;
- mover una carpeta dentro de sí misma;
- nombres inválidos;
- conflictos de nombre cuando corresponda.

---

# Assets

Representan la identidad lógica del archivo.

Campos sugeridos:

```text
id
blob_id
folder_id
reference_code
display_name
asset_type
visibility
status
current_version_id
created_by
updated_by
created_at
updated_at
deleted_at
```

Estados sugeridos:

```text
pending
ready
failed
deleted
```

---

# Asset versions

Representan cada contenido físico asociado a un asset.

Campos sugeridos:

```text
id
asset_id
version_number
storage_provider_id
storage_key
original_filename
content_disposition_name
extension
declared_mime_type
detected_mime_type
size_bytes
checksum_sha256
etag
status
created_by
created_at
deleted_at
```

Nunca sobrescribir silenciosamente un objeto físico existente.

Si un archivo se reemplaza:

```text
asset
↓
new asset_version
↓
new storage object
```

El `asset_id` y el `reference_code` permanecen estables.

---

# Tags

Tablas:

```text
tags
asset_tags
```

`tags`:

```text
id
project_id
name
slug
created_at
```

`asset_tags`:

```text
asset_id
tag_id
```

Crear constraints para evitar tags duplicados dentro de un mismo proyecto cuando corresponda.

---

# Storage providers

Registrar la configuración lógica del proveedor.

Campos sugeridos:

```text
id
driver
name
status
configuration_reference
created_at
updated_at
```

No guardar secretos directamente en registros visibles si pueden almacenarse en configuración privada del servidor.

Inicialmente:

```text
driver = local
```

---

# Upload sessions

Usar una entidad de upload para manejar estados e idempotencia.

Campos sugeridos:

```text
id
user_id
project_id
blob_id
folder_id
idempotency_key
original_filename
expected_size_bytes
detected_size_bytes
status
temporary_storage_key
final_asset_id
error_code
error_message
expires_at
created_at
updated_at
```

Estados:

```text
pending
uploading
processing
completed
failed
cancelled
expired
```

---

# Seguridad de uploads

Antes de aceptar un archivo:

1. autenticar usuario/token;
2. comprobar permisos;
3. validar proyecto y blob;
4. validar cuota;
5. validar tamaño;
6. validar extensión permitida;
7. detectar MIME real;
8. no confiar en `Content-Type` enviado por el cliente;
9. generar nombre físico propio;
10. almacenar inicialmente en temporal;
11. calcular checksum;
12. crear metadata;
13. mover/promover el objeto al storage definitivo;
14. registrar actividad;
15. limpiar archivos parciales si falla.

Bloquear inicialmente archivos ejecutables como:

```text
.php
.phtml
.phar
.cgi
.sh
.exe
```

No permitir que una ruta proporcionada por el cliente se concatene directamente a una ruta de filesystem.

Prevenir path traversal.

---

# Límites iniciales de upload

Utilizar inicialmente estos límites administrativos:

```text
Imagen:      20 MB
Documento:   50 MB
Audio:      100 MB
Video:      250 MB
Genérico:   100 MB
```

Usar:

```text
1 archivo por request
```

en la primera implementación.

El frontend podrá administrar una cola.

No asumir que porque PHP admite 512 MB resulta seguro aceptar 512 MB.

---

# Checksums

Calcular:

```text
SHA-256
```

por cada versión física.

Utilizarlo para:

- integridad;
- detección de duplicados;
- migraciones;
- reconciliación DB/filesystem;
- validación de backups.

No decidir automáticamente que archivos con checksum idéntico sean el mismo asset.

Puede haber duplicados intencionales.

---

# URLs públicas

La URL pública debe ser lógica y estable.

Ejemplo:

```text
https://blob.estudiovune.com/f/PGM-IMG-000142
```

Nunca exponer:

```text
/home/estudi76/blob-storage/...
```

Resolución conceptual:

```text
URL
↓
Asset
↓
Current Asset Version
↓
Storage Provider
↓
StorageDriver
↓
Contenido
```

Esto permite cambiar de proveedor sin romper URLs ya utilizadas.

---

# Archivos privados

Para archivos privados:

- requerir sesión;
- o Bearer token;
- o enlace firmado/temporal cuando se implemente.

El backend debe validar permisos antes de entregar bytes.

Nunca devolver la ruta física.

Para archivos grandes o video:

- considerar soporte de HTTP Range;
- evitar cargar el archivo completo en memoria;
- utilizar streaming;
- preparar migración temprana a object storage/CDN si el consumo aumenta.

---

# Tokens de acceso

Los tokens pertenecen a un Blob.

Un Blob puede tener múltiples tokens.

Ejemplo:

```text
PGM / Producción
├── Web Production
├── Codex
└── Integration
```

Cada token puede tener permisos diferentes.

---

# Formato de token

Formato conceptual:

```text
vbl_live_IDENTIFIER_SECRET
```

Ejemplo:

```text
vbl_live_ab12cd_XXXXXXXXXXXXXXXX
```

La parte secreta completa sólo debe mostrarse una vez.

Nunca almacenar el token completo en texto plano.

---

# Access tokens

Campos sugeridos:

```text
id
blob_id
name
description
prefix
secret_hash
environment
status
created_by
created_at
last_used_at
expires_at
revoked_at
```

Estados:

```text
active
expired
revoked
```

---

# Token scopes

No guardar permisos como un string ambiguo.

Usar:

```text
token_scopes
```

Ejemplos:

```text
files:read
files:create
files:update
files:delete

folders:read
folders:create
folders:update
folders:delete

metadata:read
metadata:update
```

Diseñar el sistema para poder agregar scopes sin alterar los tokens existentes.

---

# Usuarios vs tokens

Separar claramente:

```text
Usuario humano
→ Session cookie
```

de:

```text
Aplicación externa
→ Authorization: Bearer TOKEN
```

No utilizar tokens API como sesión del panel.

---

# Sesiones

Usar cookies con:

```text
HttpOnly
Secure
SameSite
```

Regenerar ID de sesión después del login.

Implementar:

- expiración;
- logout;
- protección CSRF para acciones de usuario;
- control de intentos;
- rate limiting.

---

# Rate limiting

Implementar un mecanismo compatible con hosting compartido.

Debe proteger especialmente:

```text
/auth/login
uploads
API con token
URLs privadas
```

No depender de Redis.

Puede utilizar base de datos o estrategia equivalente adecuada al entorno.

---

# API

Usar:

```text
/api/v1/
```

Respuestas JSON consistentes.

No mezclar HTML con respuestas API.

---

# Auth endpoints

```text
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
GET    /api/v1/auth/session
```

---

# Projects

```text
GET    /api/v1/projects
POST   /api/v1/projects
GET    /api/v1/projects/{id}
PATCH  /api/v1/projects/{id}
DELETE /api/v1/projects/{id}
```

---

# Project members

```text
GET    /api/v1/projects/{id}/members
POST   /api/v1/projects/{id}/members
PATCH  /api/v1/projects/{id}/members/{userId}
DELETE /api/v1/projects/{id}/members/{userId}
```

---

# Blobs

```text
GET    /api/v1/projects/{id}/blobs
POST   /api/v1/projects/{id}/blobs

GET    /api/v1/blobs/{id}
PATCH  /api/v1/blobs/{id}
DELETE /api/v1/blobs/{id}
```

---

# Folders

```text
GET    /api/v1/blobs/{id}/folders
POST   /api/v1/blobs/{id}/folders

GET    /api/v1/folders/{id}
PATCH  /api/v1/folders/{id}
DELETE /api/v1/folders/{id}
```

---

# Assets

```text
GET    /api/v1/blobs/{id}/assets
POST   /api/v1/blobs/{id}/assets

GET    /api/v1/assets/{id}
PATCH  /api/v1/assets/{id}
DELETE /api/v1/assets/{id}
```

---

# Asset content

```text
GET /api/v1/assets/{id}/content
```

---

# Versions

```text
GET    /api/v1/assets/{id}/versions
POST   /api/v1/assets/{id}/versions
GET    /api/v1/assets/{id}/versions/{versionId}
```

---

# Tokens

```text
GET    /api/v1/blobs/{id}/tokens
POST   /api/v1/blobs/{id}/tokens

GET    /api/v1/tokens/{id}
PATCH  /api/v1/tokens/{id}
DELETE /api/v1/tokens/{id}
```

DELETE de token debe significar preferentemente:

```text
revoke
```

y no eliminación del registro histórico.

---

# Tags

```text
GET    /api/v1/projects/{id}/tags
POST   /api/v1/projects/{id}/tags
PATCH  /api/v1/tags/{id}
DELETE /api/v1/tags/{id}
```

---

# Activity

```text
GET /api/v1/projects/{id}/activity
```

Permitir filtros por:

```text
action
user
token
blob
asset
date
status
```

---

# Storage usage

La API debe poder devolver:

```text
used_bytes
limit_bytes
remaining_bytes
percentage
file_count
```

por:

```text
project
blob
```

No calcular sumando todos los archivos en cada request si puede mantenerse una estrategia consistente y verificable de agregación.

Incluir un mecanismo periódico de reconciliación.

---

# Activity logs

Registrar al menos:

```text
LOGIN
LOGIN_FAILED
LOGOUT

PROJECT_CREATE
PROJECT_UPDATE

BLOB_CREATE
BLOB_UPDATE

FOLDER_CREATE
FOLDER_MOVE
FOLDER_DELETE

UPLOAD
DOWNLOAD
ASSET_UPDATE
ASSET_DELETE
ASSET_RESTORE

TOKEN_CREATE
TOKEN_REVOKE
```

Campos sugeridos:

```text
id
actor_type
actor_user_id
actor_token_id
project_id
blob_id
resource_type
resource_id
action
result
ip_address
user_agent
metadata
created_at
```

Nunca registrar:

- contraseñas;
- secretos completos;
- tokens completos.

---

# Eliminación

No realizar eliminación física inmediata en operaciones normales.

Flujo:

```text
active
↓
deleted / trash
↓
retention period
↓
physical purge
```

Guardar:

```text
deleted_at
deleted_by
purge_after
```

La purga física puede ejecutarse mediante Cron.

---

# Cron

Utilizar Cron sólo para mantenimiento.

Ejemplos:

```text
limpiar temporary vencidos
purgar papelera vencida
reconciliar uso de storage
detectar objetos huérfanos
detectar registros sin objeto
mantenimiento de logs
```

Las tareas deben ser:

- idempotentes;
- seguras ante ejecución duplicada;
- protegidas mediante lock;
- independientes de intervals muy cortos.

No depender de workers persistentes.

---

# Configuración privada

No subir secretos a Git.

Si no existe una gestión cómoda de variables de entorno, utilizar configuración fuera del document root.

Ejemplo:

```text
/home/estudi76/storage-config/config.php
```

Debe contener únicamente secretos/configuración sensible.

Ejemplos:

```text
DB_HOST
DB_NAME
DB_USER
DB_PASSWORD

APP_SECRET

STORAGE_PATH
```

Agregar el archivo correspondiente a `.gitignore`.

La aplicación debe permitir migrar posteriormente a variables de entorno sin cambiar su lógica interna.

---

# Seguridad HTTP

Preparar:

```text
HTTPS obligatorio
Options -Indexes
X-Robots-Tag
Content-Security-Policy
X-Content-Type-Options
Referrer-Policy
Permissions-Policy
```

Evaluar otras cabeceras según corresponda.

No configurar políticas tan restrictivas que rompan el frontend existente sin probarlas.

---

# No indexación

Aplicar:

```html
<meta name="robots" content="noindex,nofollow,noarchive,nosnippet">
```

Cabecera:

```text
X-Robots-Tag: noindex, nofollow, noarchive, nosnippet
```

`robots.txt`:

```text
User-agent: *
Disallow: /
```

No generar sitemap público.

La autenticación sigue siendo la barrera real.

---

# Backups

Separar siempre:

```text
Database backup
```

de:

```text
Storage backup
```

La solución definitiva debe incluir una copia fuera de la misma cuenta BlueHosting.

No asumir que la herramienta de backup del hosting es suficiente hasta confirmar:

- frecuencia;
- retención;
- alcance;
- restauración.

---

# Migración futura

La arquitectura debe soportar:

```text
LocalStorageDriver
↓
S3StorageDriver
```

sin modificar:

- asset IDs;
- reference codes;
- URLs lógicas;
- carpetas;
- proyectos;
- tokens;
- permisos.

Para migrar un objeto:

```text
1. copiar objeto
2. calcular/verificar checksum
3. registrar nuevo storage_key/provider
4. actualizar referencia transaccionalmente
5. verificar disponibilidad
6. programar borrado del origen
```

Nunca eliminar primero el original.

---

# Índices y constraints

Diseñar explícitamente:

- primary keys;
- foreign keys;
- unique constraints;
- índices para filtros frecuentes;
- índices para timestamps;
- índices para referencias humanas;
- índices para token prefixes;
- índices para `storage_key`;
- índices para `checksum_sha256` cuando corresponda;
- constraints para relaciones proyecto/blob/folder.

No confiar únicamente en validación de PHP para integridad.

La base debe reforzar las reglas importantes.

---

# Transacciones

Utilizar transacciones en operaciones que involucren varias escrituras relacionadas.

Especialmente:

- creación de asset + version;
- finalización de upload;
- reemplazo/versionado;
- actualización de contadores;
- cambios de storage provider;
- restauraciones.

Diseñar qué ocurre si el filesystem tiene éxito pero la DB falla, o viceversa.

Debe existir una estrategia de reconciliación.

---

# Idempotencia

Las operaciones de creación mediante API deben evitar duplicados accidentales.

Especialmente uploads.

Utilizar:

```text
Idempotency-Key
```

o mecanismo equivalente.

Registrar el resultado de la operación para poder responder consistentemente ante reintentos.

---

# Errores API

Usar una estructura consistente.

Ejemplo:

```json
{
  "error": {
    "code": "STORAGE_LIMIT_EXCEEDED",
    "message": "El archivo supera el espacio disponible para este blob.",
    "details": {}
  }
}
```

Definir códigos internos estables.

No filtrar:

- rutas internas;
- SQL;
- stack traces;
- credenciales.

---

# Estados HTTP

Utilizar correctamente:

```text
200 OK
201 Created
204 No Content
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
409 Conflict
413 Payload Too Large
422 Unprocessable Content
429 Too Many Requests
500 Internal Server Error
503 Service Unavailable
```

---

# CORS

Como la aplicación inicial se servirá desde el mismo dominio/subdominio, utilizar una política restrictiva.

No configurar:

```text
Access-Control-Allow-Origin: *
```

por comodidad.

Cuando exista un consumidor externo, permitir únicamente orígenes necesarios o utilizar tokens de servidor a servidor según el caso.

---

# Decisiones que NO deben tomarse

No:

- usar Node sólo porque aparece en cPanel;
- usar Laravel sin demostrar necesidad;
- almacenar secretos en Git;
- utilizar nombres originales como nombres físicos;
- exponer rutas del filesystem;
- confiar sólo en extensión del archivo;
- confiar sólo en MIME declarado;
- almacenar tokens completos;
- almacenar contraseñas reversibles;
- usar `robots.txt` como seguridad;
- aceptar uploads máximos sólo porque PHP lo permite;
- acoplar buckets a carpetas físicas;
- eliminar objetos inmediatamente;
- confiar en espacio “ilimitado” como capacidad real;
- depender de workers persistentes;
- utilizar IDs incrementales como identificadores públicos;
- mezclar sesiones humanas con tokens API.

---

# Trabajo solicitado a Codex

Antes de programar endpoints completos:

1. Revisá todo este documento.
2. Identificá contradicciones, riesgos o decisiones que deban corregirse.
3. No cambies el stack sin una justificación técnica clara.
4. Diseñá el modelo relacional completo.
5. Definí tablas, columnas, tipos, claves primarias y foráneas.
6. Definí índices y constraints.
7. Definí enums/estados de forma compatible con MariaDB.
8. Diseñá cómo generar IDs y referencias humanas.
9. Diseñá el contrato de `StorageDriver`.
10. Diseñá el flujo transaccional completo de upload.
11. Diseñá autenticación de usuarios.
12. Diseñá autenticación mediante tokens.
13. Diseñá roles y permisos.
14. Diseñá estructura de errores API.
15. Diseñá logging y auditoría.
16. Diseñá papelera y ciclo de vida.
17. Diseñá estrategia de reconciliación DB/filesystem.
18. Documentá las decisiones.
19. Marcá claramente qué requiere una prueba real en BlueHosting.
20. No inventes capacidades del servidor que todavía no estén comprobadas.

---

# Entregables solicitados

Crear dentro del repositorio:

```text
docs/
├── ARCHITECTURE.md
├── DATABASE.md
├── API.md
├── STORAGE.md
├── SECURITY.md
├── DEPLOYMENT.md
└── DECISIONS.md
```

Además preparar:

```text
database/
└── schema.sql
```

Todavía no cargar datos reales ni desplegar cambios irreversibles.

El objetivo inmediato es dejar una arquitectura de backend coherente, implementable y suficientemente documentada como para comenzar a construirla sin depender de decisiones improvisadas durante el desarrollo.
