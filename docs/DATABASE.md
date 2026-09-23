# Modelo de datos

## Convenciones

- Motor: InnoDB.
- Charset: `utf8mb4`; IDs y hashes usan ASCII/binario.
- Zona horaria de conexión: UTC.
- Fechas: `DATETIME(6)`.
- IDs públicos: prefijo de cuatro caracteres + ULID de 26 caracteres, almacenados en `CHAR(30)`.
- Bytes: `BIGINT UNSIGNED`.
- SHA-256: 32 bytes binarios.
- Estados: `VARCHAR` con `CHECK`, evitando el acoplamiento de `ENUM` nativo.
- JSON: `LONGTEXT` con `JSON_VALID`, compatible con MariaDB.

## Relaciones

```text
users --< project_members >-- projects --< blobs
  |                                |          |
  |                                |          +--< folders --< folders
  |                                |          +--< assets --< asset_versions
  |                                |          +--< access_tokens --< token_scopes
  |                                |
  |                                +--< tags >--< asset_tags
  |
  +--< user_sessions
  +--< upload_sessions

storage_providers --< blobs
storage_providers --< asset_versions
```

## Tablas principales

### `users`

Identidad humana. `email_normalized` se utiliza para unicidad. `password_hash` recibe directamente la salida de `password_hash()`.

### `projects` y `project_members`

`projects` contiene el límite, consumo reservado/confirmado y contador de archivos. `project_members` implementa roles `owner`, `admin`, `editor` y `viewer` con una fila única por usuario/proyecto.

### `blobs`

Frontera lógica de permisos y almacenamiento. Su cuota es opcional; cuando existe, se valida además de la cuota del proyecto. Un proyecto nuevo recibe un Blob `Principal`.

### `folders`

Lista de adyacencia mediante `parent_id`. La aplicación debe recorrer ancestros dentro de una transacción antes de mover una carpeta para impedir ciclos. `parent_scope` permite unicidad también en la raíz.

### `assets` y `asset_versions`

`assets` mantiene la identidad, referencia, carpeta y visibilidad. `asset_versions` conserva cada objeto físico. `current_version_id` sólo apunta a una versión `ready` del mismo Asset; esta regla requiere validación transaccional en el servicio además de la FK.

### `project_sequences`

Contador por proyecto y tipo (`IMG`, `VID`, `AUD`, `DOC`, `ARC`, `OTH`). `OTH` cubre archivos genéricos aceptados. La fila se bloquea con `FOR UPDATE`, se incrementa y luego se forma la referencia. Los huecos son aceptables; las colisiones no.

### `upload_sessions`

Controla idempotencia, reserva de cuota, clave temporal, resultado y expiración. `idempotency_key_hash` almacena SHA-256 del valor recibido, no el valor original.

### `idempotency_records`

Conserva el resultado de creaciones reintentables distintas del upload. La combinación actor, ruta y hash de clave es única. `request_hash` impide reutilizar la misma clave con otro cuerpo.

### `access_tokens` y `token_scopes`

`prefix` identifica candidatos; `secret_hash` verifica el secreto. El token completo nunca se persiste. Revocar establece estado y `revoked_at`.

### `activity_logs`

Registro append-only de eventos relevantes. `metadata_json` debe evitar datos sensibles. Los IDs de actor usan `SET NULL` para preservar el historial.

## Soft delete y unicidad

MariaDB no ofrece índices parciales equivalentes a `WHERE deleted_at IS NULL`. Las tablas con nombres reutilizables incorporan `active_slot`:

- `1` mientras la fila está activa;
- `NULL` cuando se elimina.

Los índices únicos incluyen `active_slot`. Múltiples filas eliminadas pueden compartir nombre porque MariaDB permite varios `NULL` en un índice único.

## Contadores y cuotas

`projects` y `blobs` mantienen:

```text
storage_used_bytes
storage_reserved_bytes
file_count
folder_count
```

En el inicio del upload se reserva `expected_size_bytes` en ambas filas bajo bloqueo. Al completar:

1. se resta la reserva;
2. se suma el tamaño detectado;
3. se incrementa `file_count` sólo para un Asset nuevo;
4. una nueva versión suma su tamaño aunque la versión anterior continúe retenida.

Crear, restaurar o purgar carpetas actualiza `folder_count` bajo el mismo criterio transaccional.

La API puede reportar uso físico total y, si se desea más adelante, uso lógico de versiones actuales como una métrica separada.

## Índices principales

- email normalizado;
- código de proyecto y referencia de Asset;
- jerarquía de carpetas;
- listados de assets por Blob/carpeta/estado/fecha;
- `storage_key` y checksum;
- prefijo y estado de token;
- eventos por proyecto/fecha/acción;
- uploads por usuario, estado y expiración.

## Migraciones

`schema.sql` representa el baseline. En cuanto comience la implementación, todo cambio posterior debe vivir en una migración numerada, ejecutada una sola vez y registrada en `schema_migrations`.
