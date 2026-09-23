# Arquitectura del backend

## Alcance

El MVP será un monolito modular desplegado sobre Apache y PHP-FPM. Servirá el frontend estático, una API JSON bajo `/api/v1/` y las URLs lógicas de archivos bajo `/f/{reference}`. MariaDB conservará toda la metadata; los bytes se almacenarán mediante un `StorageDriver` desacoplado.

```text
Navegador / integración
          |
       HTTPS
          |
       Apache
          |
     public/index.php
          |
  Router + middleware
          |
      Controllers
          |
       Services
     /     |      \
Repositories Auth StorageDriver
     |              |
  MariaDB      filesystem privado
```

## Decisiones estructurales

- PHP 8.x, sin framework completo en el MVP.
- PDO con consultas preparadas y transacciones explícitas.
- MariaDB 10.6, InnoDB, `utf8mb4` y fechas UTC.
- Sesiones PHP para usuarios humanos; Bearer tokens separados para integraciones.
- Frontend y API en el mismo origen para evitar CORS abierto.
- Un Blob es una frontera lógica de almacenamiento y permisos, no una carpeta física.
- Las carpetas son exclusivamente lógicas y se modelan mediante `parent_id`.
- Un Asset mantiene identidad estable; cada reemplazo crea una nueva versión.
- Las URLs públicas pertenecen a la aplicación, no al driver de almacenamiento.
- Las operaciones filesystem + DB usan una saga recuperable; no existe atomicidad distribuida real.

## Módulos

```text
app/
├── Auth/            sesiones, contraseñas y tokens
├── Controllers/     adaptación HTTP
├── Database/        conexión PDO y transacciones
├── Http/            router, request, response y errores
├── Middleware/      auth, CSRF, permisos y rate limit
├── Repositories/    acceso persistente
├── Security/        IDs, hashing, MIME y validación
├── Services/        casos de uso y reglas de negocio
├── Storage/         contrato e implementaciones de storage
└── Validation/      schemas y errores de entrada

config/              configuración no secreta versionada
database/            schema y futuras migraciones
docs/                decisiones y contratos
public/              único document root
storage/             logs locales no públicos (desarrollo)
bin/                 comandos CLI y cron
```

En producción, secretos y objetos deben quedar fuera de `public/`.

## Capas y dependencias

1. Los controllers sólo interpretan HTTP y delegan.
2. Los services controlan autorización, transacciones y reglas.
3. Los repositories encapsulan SQL.
4. `StorageDriver` recibe claves opacas y streams; desconoce proyectos y permisos.
5. Ningún controller utiliza PDO o rutas físicas directamente.
6. Ningún repository manipula archivos.

## Multi-proyecto y Blob por defecto

Todo asset y carpeta pertenece a un Blob, y todo Blob a un proyecto. Para que el frontend inicial no tenga que exponer este concepto, al crear un proyecto se crea transaccionalmente un Blob privado llamado `Principal`. La API puede incorporar selección de Blob sin migrar datos.

## Consistencia y concurrencia

- Las modificaciones de varias filas utilizan transacciones.
- La cuota se reserva bloqueando la fila de uso correspondiente con `SELECT ... FOR UPDATE`.
- Las referencias humanas se asignan con una fila de secuencia bloqueada por proyecto y tipo.
- Cada creación susceptible de reintento acepta `Idempotency-Key`.
- Las escrituras de bytes se realizan primero en temporal y luego se promueven.
- Un reconciliador compara metadata, checksums y objetos físicos.

## Estados importantes

```text
Upload: pending -> uploading -> processing -> completed
             \-> failed / cancelled / expired

Asset: pending -> ready -> deleted -> purged
            \-> failed

Version: pending -> ready
              \-> failed / deleted
```

El contenido sólo se sirve cuando Asset y versión actual están en estado `ready`.

## Observabilidad

- Un `request_id` se genera o propaga por request.
- Los errores se registran con contexto técnico, nunca con secretos.
- Los eventos relevantes se guardan en `activity_logs`.
- Los logs de aplicación deben rotarse y quedar fuera del document root.
- Las tareas de Cron registran inicio, fin, duración y resultado.

## Entregas del MVP

1. Bootstrap, configuración y migraciones.
2. Autenticación y sesión.
3. Proyectos, miembros, Blob principal y permisos.
4. Carpetas lógicas y listado.
5. Upload transaccional, assets y versiones.
6. Descarga privada y URL pública lógica.
7. Límites, uso y reconciliación.
8. Tokens, auditoría, papelera y purga.

