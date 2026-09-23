# Vuné Blob

Plataforma para centralizar, organizar y administrar los archivos utilizados por distintos proyectos.

## Estado del proyecto

> Prototipo frontend en desarrollo.

El repositorio incluye una interfaz funcional en HTML, CSS y JavaScript puro. La carga de archivos y las URLs públicas son simuladas en el navegador; todavía no existe persistencia ni conexión con un proveedor de almacenamiento.

## Objetivo

Construir una plataforma que permita gestionar:

- Proyectos.
- Espacios de almacenamiento (blobs o buckets).
- Carpetas y archivos.
- URLs públicas y privadas.
- Tokens de acceso y permisos.
- Etiquetas y metadatos.
- Registros de actividad.
- Uso y capacidad de almacenamiento.

La primera implementación podrá utilizar un proveedor de almacenamiento concreto, pero el sistema deberá mantener esa dependencia aislada para poder reemplazarlo en el futuro.

## Modelo conceptual

```text
Plataforma
└── Proyecto
    └── Blob / Bucket
        ├── Carpetas
        ├── Archivos
        ├── Tokens
        └── Permisos
```

## Principios iniciales

- Los archivos se identifican mediante IDs estables, no por su nombre.
- Cada proyecto puede contener varios espacios de almacenamiento independientes.
- Los permisos y tokens pertenecen a un blob o bucket.
- El proveedor de almacenamiento debe poder cambiarse sin afectar al resto de la aplicación.
- La observabilidad, la seguridad y la trazabilidad forman parte del diseño desde el inicio.

## Alcance inicial propuesto

El primer MVP debería permitir:

1. Crear y administrar proyectos.
2. Crear blobs o buckets dentro de cada proyecto.
3. Subir, listar, descargar y eliminar archivos.
4. Organizar archivos en carpetas.
5. Configurar visibilidad pública o privada.
6. Generar y revocar tokens de acceso.
7. Consultar actividad y consumo de almacenamiento.

## Ejecutar la interfaz

No requiere instalación ni dependencias. Para evitar restricciones del navegador al abrir archivos locales, se recomienda servir la carpeta `dist/`:

```bash
cd dist
python3 -m http.server 4173
```

Luego abrí `http://localhost:4173`.

### Funcionalidades del prototipo

- Carga por selector o arrastrando archivos.
- Inicio y cierre de sesión simulados en el navegador.
- Progreso de carga simulado.
- Vista inicial de archivos recientes.
- Navegación por carpetas y subcarpetas desde la raíz del proyecto.
- Creación de carpetas en memoria.
- Resumen de almacenamiento y cantidad de elementos por proyecto.
- Configuración local del límite de almacenamiento del proyecto.
- Vistas de lista y cuadrícula.
- Búsqueda y filtros por tipo.
- Vista previa de imágenes y videos cargados.
- Generación y copia de URLs públicas de demostración.
- Diseño adaptable a escritorio y dispositivos móviles.

## Próxima etapa

- Definir la API y el proveedor inicial de almacenamiento.
- Reemplazar la simulación de carga por transferencias reales.
- Persistir archivos y metadatos.
- Implementar autenticación, permisos y URLs firmadas.

## Documentación

Las decisiones técnicas relevantes se registrarán en `docs/` mediante documentos breves o ADRs (*Architecture Decision Records*).

La arquitectura inicial del backend está documentada en:

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/DATABASE.md`](docs/DATABASE.md)
- [`docs/API.md`](docs/API.md)
- [`docs/STORAGE.md`](docs/STORAGE.md)
- [`docs/SECURITY.md`](docs/SECURITY.md)
- [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md)
- [`docs/HOSTING_AUDIT_2026-09-23.md`](docs/HOSTING_AUDIT_2026-09-23.md)
- [`docs/DECISIONS.md`](docs/DECISIONS.md)
- [`database/schema.sql`](database/schema.sql)

## Contribución

El flujo de trabajo y las convenciones del proyecto se definirán junto con el stack. Hasta entonces, se recomienda que cada cambio tenga un alcance acotado y una descripción clara.

## Licencia

Pendiente de definición.
