# API v1

## Convenciones

Base:

```text
/api/v1
```

- JSON UTF-8, excepto uploads multipart y respuestas de contenido.
- IDs opacos; no se exponen claves físicas.
- Timestamps ISO 8601 en UTC, por ejemplo `2026-09-22T23:45:12.123456Z`.
- Requests mutantes por sesión requieren `X-CSRF-Token`.
- Creaciones reintentables requieren `Idempotency-Key`.
- Listados utilizan cursor, `limit` entre 1 y 100 y ordenamiento allowlisted.
- El usuario sólo ve recursos de proyectos autorizados.

## Respuestas

Recurso individual:

```json
{
  "data": {
    "id": "ast_01K...",
    "type": "asset",
    "attributes": {}
  },
  "meta": {
    "request_id": "01K..."
  }
}
```

Listado:

```json
{
  "data": [],
  "meta": {
    "request_id": "01K...",
    "next_cursor": null,
    "limit": 50
  }
}
```

Error:

```json
{
  "error": {
    "code": "STORAGE_LIMIT_EXCEEDED",
    "message": "El archivo supera el espacio disponible para este proyecto.",
    "details": {},
    "request_id": "01K..."
  }
}
```

## Códigos de error iniciales

| Código | HTTP | Uso |
|---|---:|---|
| `AUTH_REQUIRED` | 401 | No existe autenticación válida. |
| `AUTH_INVALID_CREDENTIALS` | 401 | Login fallido. |
| `AUTH_RATE_LIMITED` | 429 | Demasiados intentos. |
| `CSRF_INVALID` | 403 | Token CSRF faltante o inválido. |
| `PERMISSION_DENIED` | 403 | Actor autenticado sin permiso. |
| `RESOURCE_NOT_FOUND` | 404 | Recurso inexistente o no visible. |
| `VALIDATION_FAILED` | 422 | Campos inválidos. |
| `NAME_CONFLICT` | 409 | Nombre ocupado en el mismo alcance. |
| `IDEMPOTENCY_CONFLICT` | 409 | Misma clave con otra operación. |
| `STORAGE_LIMIT_EXCEEDED` | 413 | No hay cuota disponible. |
| `FILE_TOO_LARGE` | 413 | Supera el límite por tipo. |
| `FILE_TYPE_NOT_ALLOWED` | 422 | Extensión/MIME bloqueados. |
| `UPLOAD_FAILED` | 500 | Falló el procesamiento recuperable. |
| `STORAGE_UNAVAILABLE` | 503 | Proveedor temporalmente no disponible. |

## Autenticación

```text
POST /auth/login
POST /auth/logout
GET  /auth/session
```

`POST /auth/login`:

```json
{
  "email": "persona@estudiovune.com",
  "password": "...",
  "remember": false
}
```

La respuesta crea cookie segura y devuelve usuario, proyectos permitidos y token CSRF. `logout` es idempotente.

## Proyectos

```text
GET    /projects
POST   /projects
GET    /projects/{projectId}
PATCH  /projects/{projectId}
DELETE /projects/{projectId}
GET    /projects/{projectId}/usage
```

`PATCH` admite, según rol:

```json
{
  "name": "Vuné",
  "description": "...",
  "storage_limit_bytes": 10737418240
}
```

Uso:

```json
{
  "data": {
    "used_bytes": 97844724,
    "reserved_bytes": 0,
    "limit_bytes": 10737418240,
    "remaining_bytes": 10639573516,
    "percentage": 0.91,
    "file_count": 8,
    "folder_count": 5,
    "item_count": 13
  }
}
```

## Miembros

```text
GET    /projects/{projectId}/members
POST   /projects/{projectId}/members
PATCH  /projects/{projectId}/members/{userId}
DELETE /projects/{projectId}/members/{userId}
```

No se permite remover al último `owner`.

## Blobs

```text
GET    /projects/{projectId}/blobs
POST   /projects/{projectId}/blobs
GET    /blobs/{blobId}
PATCH  /blobs/{blobId}
DELETE /blobs/{blobId}
GET    /blobs/{blobId}/usage
```

La creación de proyecto genera el Blob principal; el endpoint permite agregar otros posteriormente.

## Navegación de carpetas

```text
GET    /blobs/{blobId}/entries?folder_id=&cursor=&limit=&sort=
POST   /blobs/{blobId}/folders
GET    /folders/{folderId}
PATCH  /folders/{folderId}
DELETE /folders/{folderId}
POST   /folders/{folderId}/restore
```

`entries` devuelve carpetas y assets en una misma colección, coherente con la interfaz:

```json
{
  "data": [
    { "type": "folder", "id": "fld_...", "name": "Imágenes", "item_count": 4 },
    { "type": "asset", "id": "ast_...", "display_name": "presentacion.pdf", "size_bytes": 8200000 }
  ]
}
```

Crear carpeta:

```json
{
  "parent_id": null,
  "name": "Imágenes"
}
```

Mover/renombrar usa `PATCH` con `parent_id` y/o `name`. El servidor previene ciclos.

## Assets

```text
GET    /blobs/{blobId}/assets
GET    /assets/{assetId}
PATCH  /assets/{assetId}
DELETE /assets/{assetId}
POST   /assets/{assetId}/restore
GET    /assets/{assetId}/content
HEAD   /assets/{assetId}/content
```

Filtros iniciales: `folder_id`, `type`, `visibility`, `status`, `tag`, `search`, `updated_after`, `cursor`, `limit`, `sort`.

## Uploads y versiones

MVP, un archivo multipart por request:

```text
POST /blobs/{blobId}/uploads
GET  /uploads/{uploadId}
POST /uploads/{uploadId}/cancel
```

Campos multipart:

```text
file
folder_id (opcional)
display_name (opcional)
visibility = public|private
```

Headers:

```text
Idempotency-Key: <valor aleatorio por intento lógico>
X-CSRF-Token: <token para sesión humana>
```

Crear nueva versión:

```text
GET  /assets/{assetId}/versions
POST /assets/{assetId}/versions
GET  /assets/{assetId}/versions/{versionId}
```

## URLs públicas

```text
GET  /f/{referenceCode}
HEAD /f/{referenceCode}
```

No es un endpoint JSON. Devuelve contenido sólo con visibilidad efectiva pública. La URL permanece estable al cambiar versión o proveedor.

Un `PATCH /assets/{id}` puede cambiar `visibility`. No hace falta crear una URL distinta porque la referencia ya es estable.

## Tokens

```text
GET    /blobs/{blobId}/tokens
POST   /blobs/{blobId}/tokens
GET    /tokens/{tokenId}
PATCH  /tokens/{tokenId}
DELETE /tokens/{tokenId}
```

`POST` devuelve el secreto una sola vez. `DELETE` revoca y responde `204`.

Autenticación:

```text
Authorization: Bearer vbl_live_...
```

## Tags

```text
GET    /projects/{projectId}/tags
POST   /projects/{projectId}/tags
PATCH  /tags/{tagId}
DELETE /tags/{tagId}
PUT    /assets/{assetId}/tags/{tagId}
DELETE /assets/{assetId}/tags/{tagId}
```

## Actividad

```text
GET /projects/{projectId}/activity
```

Filtros: `action`, `actor_user_id`, `actor_token_id`, `blob_id`, `resource_type`, `resource_id`, `result`, `from`, `to`, `cursor`.

