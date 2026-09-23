# Almacenamiento

## Directorios iniciales

La escritura fuera de `public_html` está confirmada. La implementación local utilizará:

```text
/home/estudi76/blob-storage/
├── objects/
├── temporary/
└── quarantine/
```

Ninguno de estos directorios debe ser alcanzable por HTTP. `public_html` contiene sólo el front controller y assets del frontend.

## Contrato `StorageDriver`

```php
interface StorageDriver
{
    public function put(string $key, $stream, ?int $expectedSize = null): StoredObject;
    public function readStream(string $key, ?ByteRange $range = null): ReadableObject;
    public function exists(string $key): bool;
    public function delete(string $key): void;
    public function size(string $key): int;
    public function checksum(string $key, string $algorithm = 'sha256'): string;
    public function move(string $sourceKey, string $destinationKey): void;
    public function copy(string $sourceKey, string $destinationKey): void;
    public function metadata(string $key): ObjectMetadata;

    // Optimización opcional, nunca URL canónica del producto.
    public function temporaryUrl(string $key, int $expiresInSeconds): ?string;
}
```

Reglas:

- Las claves siempre son relativas, opacas y generadas por la aplicación.
- El driver rechaza rutas absolutas, `..`, bytes nulos y separadores inesperados.
- `put` y `readStream` trabajan con streams; no cargan el objeto completo en memoria.
- `move` dentro del mismo filesystem debe usar `rename` cuando sea seguro.
- `delete` es idempotente: un objeto inexistente se considera eliminado.
- Las excepciones del proveedor se traducen a errores internos estables.
- La URL estable `/f/{reference_code}` nunca proviene del driver.

## Claves físicas

Formato propuesto:

```text
objects/01/a8/obj_01KXXXXXXXXXXXXXXXXXXXXXXX
temporary/2026/09/upl_01KXXXXXXXXXXXXXXXXXXXXXX.part
quarantine/2026/09/obj_01KXXXXXXXXXXXXXXXXXXXXXXX
```

Los dos niveles iniciales se derivan de un hash del ID y reducen la cantidad de entradas por directorio. La extensión original no es necesaria en la clave física.

## Flujo transaccional de upload

### 1. Preparación y reserva

1. Autenticar sesión o token.
2. Autorizar `files:create` sobre el Blob.
3. Validar un solo archivo, nombre, tamaño declarado y carpeta.
4. Obtener o crear `upload_sessions` mediante el hash de `Idempotency-Key`.
5. Iniciar transacción.
6. Bloquear proyecto y Blob con `SELECT ... FOR UPDATE`.
7. Comprobar `used + reserved + expected <= limit` en ambos niveles.
8. Incrementar `storage_reserved_bytes`.
9. Crear upload `pending` con expiración.
10. Confirmar transacción.

### 2. Recepción

1. Cambiar upload a `uploading`.
2. Copiar el stream a `temporary/` contando bytes.
3. Abortar si supera el límite por tipo o el tamaño esperado tolerado.
4. Calcular SHA-256 durante el streaming.
5. Detectar MIME con `finfo` sobre el temporal.
6. Validar combinación extensión/MIME y tipos bloqueados.
7. Si existe escáner antivirus, mover primero a `quarantine/`; en el MVP no se afirma que exista.

### 3. Metadata y promoción

1. Cambiar upload a `processing`.
2. Generar `asset_id`, `version_id`, `object_id` y clave final.
3. Iniciar transacción DB.
4. Bloquear cuotas nuevamente y verificar el tamaño detectado.
5. Reservar la referencia humana mediante `project_sequences FOR UPDATE`.
6. Crear Asset `pending` y versión `pending`.
7. Confirmar la transacción de metadata provisional.
8. Promover temporal a objeto final mediante el driver.
9. Verificar existencia, tamaño y checksum.
10. Iniciar transacción de finalización.
11. Marcar versión y Asset `ready`; asignar `current_version_id`.
12. Convertir reserva en uso real y actualizar contadores.
13. Marcar upload `completed` y registrar `UPLOAD`.
14. Confirmar.

No se mantiene una transacción DB abierta durante toda la transferencia.

## Compensación de errores

- Si falla antes de crear metadata: borrar temporal y liberar reserva.
- Si DB provisional tiene éxito pero falla la promoción: marcar Asset/versión/upload `failed`, liberar reserva y conservar temporal sólo hasta diagnóstico/expiración.
- Si el objeto final existe pero falla la finalización DB: no borrarlo; el reconciliador lo identifica y reintenta o lo marca huérfano.
- Un reintento con la misma clave devuelve el resultado previo o continúa la operación recuperable.

## Descarga y streaming

```text
GET /f/{reference_code}
```

1. Resolver Asset activo y versión actual.
2. Evaluar visibilidad efectiva y autenticación/token.
3. Resolver driver y clave.
4. Aplicar `Content-Type`, `Content-Length`, `ETag` y `Content-Disposition` seguros.
5. Soportar `HEAD`, cache condicional y, para video/archivos grandes, `Range`.
6. Transmitir por bloques sin cargar el archivo completo.

Las respuestas privadas usan `Cache-Control: private, no-store`. Las públicas pueden utilizar cache control versionado, sin exponer la clave física.

## Reemplazo y versiones

Un reemplazo crea nueva versión y objeto. `current_version_id` cambia sólo después de verificar el nuevo objeto. La versión anterior queda disponible para rollback hasta su eliminación/purga.

## Papelera

Eliminar un Asset:

1. marca el Asset `deleted`;
2. establece `deleted_at`, `deleted_by`, `purge_after` y `active_slot = NULL`;
3. no resta uso físico todavía;
4. conserva versiones y objetos durante la retención.

La purga borra objetos, confirma su ausencia y luego actualiza contadores. Si falla, conserva metadata y reintenta.

## Reconciliación

Cron ejecuta lotes pequeños e idempotentes:

- uploads expirados y reservas abandonadas;
- versiones `ready` cuyo objeto falta;
- objetos físicos sin versión;
- divergencias de tamaño o checksum;
- recomputación de uso y conteos;
- purgas vencidas.

Nunca corrige destruyendo automáticamente la única copia. Genera reporte, repara contadores seguros y mueve objetos dudosos a cuarentena.
