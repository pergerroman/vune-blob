# Decisiones y puntos abiertos

## Registro de decisiones

### ADR-001 — Monolito modular en PHP

**Estado:** aceptada, condicionada a confirmar PHP 8.x.

Se utilizará PHP 8.x con Apache, PDO y sesiones. El hosting compartido favorece un proceso por request y Cron; no se dependerá de Node, workers persistentes, Redis ni Laravel.

### ADR-002 — MariaDB como fuente de verdad

**Estado:** aceptada.

MariaDB conserva identidades, relaciones, permisos, estados, cuotas y auditoría. El filesystem sólo conserva bytes direccionados por claves opacas.

### ADR-003 — URL pública en la capa de aplicación

**Estado:** aceptada; corrige el contrato sugerido originalmente.

`StorageDriver` no genera la URL canónica. `/f/{reference_code}` resuelve Asset, versión y proveedor. Un driver futuro puede ofrecer una URL temporal como optimización, pero no reemplaza la URL estable.

### ADR-004 — Carpetas lógicas

**Estado:** aceptada.

Renombrar o mover carpetas sólo modifica DB. La clave física de un objeto no contiene nombres de proyectos, carpetas ni archivos.

### ADR-005 — Asset y versiones separados

**Estado:** aceptada.

El Asset representa identidad y URL. Los bytes viven en `asset_versions`. Un reemplazo nunca sobrescribe el objeto anterior.

### ADR-006 — Soft delete y purga diferida

**Estado:** aceptada.

Las operaciones normales marcan `deleted_at`, `deleted_by` y `purge_after`. Cron purga una vez vencida la retención.

### ADR-007 — Un Blob principal invisible para el MVP

**Estado:** aceptada.

Cada proyecto recibe un Blob `Principal`. El frontend actual puede operar sin selector de Blob y la estructura queda preparada para varios Blobs.

### ADR-008 — IDs opacos con prefijo + ULID

**Estado:** aceptada.

Los IDs se generan en PHP y se almacenan como `CHAR(30)` ASCII binario. Los autoincrementales se reservan para secuencias internas que nunca se exponen.

### ADR-009 — Visibilidad efectiva

**Estado:** aceptada.

Un archivo es anónimamente público sólo si el Blob y el Asset tienen `visibility = public`. Un Blob privado actúa como techo de seguridad. Los accesos autenticados y por token se evalúan aparte.

### ADR-010 — Cuotas reservadas

**Estado:** aceptada.

`storage_usage` mantiene `used_bytes` y `reserved_bytes`. Un upload reserva cuota antes de recibir bytes y la libera o convierte en uso al finalizar. Cron reconcilia los contadores.

## Contradicciones y riesgos resueltos

| Tema | Riesgo | Resolución |
|---|---|---|
| PHP 7.4 activo vs PHP 8.x requerido | Runtime incompatible | PHP 8.4 fue seleccionado y las extensiones requeridas quedaron activadas. |
| Escritura fuera de `public_html` | Los objetos privados podrían quedar expuestos | Capacidad confirmada; se usará `/home/estudi76/blob-storage/`. |
| `getPublicUrl()` en el driver | Acopla URL estable al proveedor | La URL lógica vive en la aplicación; el driver sólo puede dar URL temporal opcional. |
| DB + filesystem | No existe una transacción común | Estados `pending/failed`, temporal, promoción y reconciliación. |
| Límite por proyecto y Blob | Doble cuota ambigua | Proyecto es el techo global; Blob puede tener un límite adicional nullable. |
| Visibilidad en Blob y Asset | Reglas contradictorias | Para acceso anónimo ambos deben ser públicos. |
| Nombres únicos con soft delete | MariaDB no ofrece índices parciales | `active_slot` nullable + claves de alcance generadas. |
| Referencias secuenciales | Colisiones concurrentes | `project_sequences` con bloqueo transaccional. |
| MIME declarado | Suplantación de tipo | `finfo` determina MIME detectado; el declarado queda sólo como metadata. |
| Existe límite `Genérico`, pero no código de referencia | Archivos válidos sin tipo | Se agrega tipo `other` y código `OTH`. |

## Pruebas obligatorias en BlueHosting

- Versiones PHP 8.x disponibles y extensiones: PDO MySQL, fileinfo, mbstring, openssl, json.
- PHP-FPM y PHP CLI usando la misma versión/configuración.
- Permisos efectivos, `rename` atómico y borrado en `/home/estudi76/blob-storage` antes del primer archivo real.
- Permisos y propietario de archivos creados por PHP-FPM y Cron.
- `PATH_INFO`/rewrites, headers y `Options -Indexes` mediante `.htaccess`.
- AutoSSL para `blob.estudiovune.com`.
- Tamaño máximo real de request a través de Apache/PHP/proxy.
- Funcionamiento de streaming y `Range` con archivos grandes.
- Duración máxima y solapamiento de Cron.
- Política de espacio, inodos, backups y restauración.
- Conexiones y bloqueos de MariaDB bajo carga razonable.

## Decisiones todavía abiertas

1. Período de retención de papelera; propuesta inicial: 30 días.
2. Lista exacta de extensiones permitidas por tipo.
3. Si el antivirus estará disponible; mientras no exista, tipos ejecutables permanecen bloqueados.
4. Estrategia y destino externo de backups.
5. Límites administrativos iniciales por proyecto/Blob.
6. Política de expiración por defecto de tokens.
