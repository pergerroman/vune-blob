# Plan de acción — Plataforma de gestión de archivos y Blob Storage

## 1. Objetivo

Desarrollar una plataforma propia para administrar los archivos utilizados en los diferentes proyectos, centralizando:

- Proyectos.
- Blobs / buckets de almacenamiento.
- Carpetas y subcarpetas.
- Imágenes.
- Videos.
- Documentos.
- Otros assets.
- IDs únicos.
- Etiquetas.
- URLs públicas y privadas.
- Tokens de acceso.
- Permisos.
- Registros de actividad.
- Consumo de almacenamiento.

La primera versión utilizará el almacenamiento disponible en BlueHosting, pero la arquitectura deberá permitir reemplazar posteriormente ese almacenamiento sin modificar el funcionamiento general de la plataforma.

---

# 2. Arquitectura conceptual

La jerarquía principal será:

```text
PLATAFORMA
│
├── Proyecto
│   │
│   ├── Blob / Bucket
│   │   │
│   │   ├── Carpeta
│   │   │   ├── Subcarpeta
│   │   │   └── Archivo
│   │   │
│   │   ├── Archivo
│   │   └── Tokens
│   │
│   └── Blob / Bucket
│
└── Proyecto
```

Ejemplo:

```text
Pragmática
│
├── Producción web
│   ├── images
│   ├── videos
│   └── documents
│
└── Material interno
    ├── brand
    └── presentations
```

Esto permite que un mismo proyecto pueda tener varios espacios independientes.

---

# 3. Diferencia entre proyecto, blob y archivo

## Proyecto

Representa un cliente, producto o desarrollo.

Ejemplos:

```text
Pragmática
Tizval Automotores
Vuné
Casa del Chevrolet
```

ID técnico:

```text
prj_01K2R7...
```

Código corto:

```text
PGM
TIZ
VUN
CHV
```

---

## Blob / Bucket

Es un contenedor de almacenamiento perteneciente a un proyecto.

Cada Blob podrá tener:

- Configuración propia.
- Visibilidad pública o privada.
- Capacidad asignada.
- Tokens propios.
- Permisos propios.
- Dominios autorizados.
- Estadísticas.

Ejemplo:

```text
Proyecto
Pragmática

Blob
Producción

Código
PGM-PROD
```

Otro:

```text
Proyecto
Pragmática

Blob
Interno

Código
PGM-INT
```

Los tokens estarán asociados al **Blob**, no globalmente a toda la plataforma.

---

# 4. Sistema de identificación

No vamos a depender del nombre del archivo.

Un archivo tendrá diferentes datos.

Por ejemplo:

```text
ID interno
obj_01K2R8H4J3...

Referencia
PGM-IMG-000142

Nombre original
hero-oil-gas-final.jpg

Nombre almacenado
01K2R8H4J3Y8Q.jpg
```

## ID interno

Será generado automáticamente y nunca cambiará.

Utilizaremos un identificador tipo ULID/UUID.

Ejemplo:

```text
obj_01K2R8H4J3N6QM1C
```

Será utilizado por:

- Base de datos.
- API.
- Relaciones.
- Logs.
- Sistema interno.

---

## Código humano

Será utilizado para gestión.

Formato:

```text
[PROYECTO]-[TIPO]-[NÚMERO]
```

Ejemplos:

```text
PGM-IMG-000001
PGM-IMG-000002

PGM-VID-000001

PGM-DOC-000001

TIZ-IMG-000001
VUN-DOC-000001
```

Tipos iniciales:

```text
IMG → Imagen
VID → Video
DOC → Documento
AUD → Audio
ARC → Archivo general
```

El código no cambia aunque posteriormente se renombre el archivo.

---

# 5. Etiquetas

Además de carpetas habrá un sistema independiente de etiquetas.

Ejemplo:

```text
Proyecto: Pragmática

Carpeta:
web/home/hero

Etiquetas:
oil-gas
home
hero
2026
producción
aprobado
```

Esto permite encontrar un archivo sin saber dónde está almacenado.

El buscador podrá localizar por:

- Código.
- Nombre.
- Proyecto.
- Blob.
- Carpeta.
- Etiqueta.
- Tipo.
- Extensión.
- Fecha.
- Usuario.
- Peso.

---

# 6. Base de datos

La información administrativa vivirá en MySQL/MariaDB.

Tablas principales:

```text
users
projects
buckets
folders
assets
tags
asset_tags
api_tokens
audit_logs
usage
```

## Assets

Cada archivo registrará como mínimo:

```text
id
project_id
bucket_id
folder_id

reference_code
original_name
stored_name

mime_type
extension
size

checksum_sha256

visibility

storage_driver
storage_path

created_at
updated_at
deleted_at
```

---

# 7. Carpetas

Las carpetas serán principalmente **lógicas**.

Es decir, la base de datos puede mostrar:

```text
images/
└── website/
    └── home/
        └── hero/
```

pero el almacenamiento físico no necesita copiar exactamente esa estructura.

Esto evita problemas cuando:

- Se mueve una carpeta.
- Se renombra.
- Cambia un proyecto.
- Migramos a otro proveedor de almacenamiento.

Mover un archivo de:

```text
/home/hero
```

a:

```text
/home/backgrounds
```

será principalmente una modificación de base de datos.

No necesitaremos modificar su identidad.

---

# 8. Sistema físico de almacenamiento

En BlueHosting crearemos una zona dedicada al almacenamiento.

Conceptualmente:

```text
/home/usuario/
│
├── public_html/
│   └── storage-app/
│
└── blob-storage/
    ├── projects/
    ├── temporary/
    └── private/
```

La aplicación estará separada de los archivos almacenados.

Nunca deberíamos tener algo como:

```text
public_html/uploads/
```

sin protección.

La ubicación definitiva dependerá de las posibilidades concretas de la cuenta de cPanel.

---

# 9. Storage Driver

Esta es una de las decisiones más importantes del proyecto.

La aplicación nunca debería decir directamente:

```text
guardar archivo en BlueHosting
```

Deberá decir:

```text
Storage.save()
```

Y el Storage Driver resolverá dónde guardarlo.

V1:

```text
Storage Driver
LocalBlueHosting
```

Futuro:

```text
Storage Driver
├── LocalBlueHosting
├── CloudflareR2
├── AmazonS3
└── Otro proveedor
```

Esto permitirá mover un Blob completo a otro proveedor sin modificar:

- La interfaz.
- Los proyectos.
- Los IDs.
- Las etiquetas.
- Los tokens.
- La API.
- La lógica de administración.

---

# 10. Tokens

Cada Blob podrá tener uno o más tokens.

Ejemplo:

```text
Pragmática
└── Producción
    ├── Token Web
    ├── Token Codex
    └── Token Administración
```

No tendremos solamente:

```text
TOKEN = xxxxxx
```

Un token tendrá configuración.

---

## Formato

Ejemplo conceptual:

```text
vbl_live_bkt_83HF..._7Hs9Dj2...
```

Separaremos:

```text
vbl
tipo de token

live
entorno

bkt_83HF...
identificador

7Hs9Dj2...
secreto
```

---

# 11. El token nunca se guardará completo

Cuando se cree un token:

```text
GENERAR TOKEN
      ↓
mostrar una vez
      ↓
guardar hash
```

La base de datos guardará:

```text
token_id
token_prefix
secret_hash
bucket_id
permissions
created_at
expires_at
last_used_at
revoked_at
```

Pero **no guardará el secreto original**.

En la interfaz aparecerá:

```text
Production Web

vbl_live_••••••••••••83HF

Creado
21/08/2026

Último uso
Hace 3 min
```

El token completo solamente podrá verse en el momento de creación.

Si se pierde:

```text
Revocar
+
Generar nuevo
```

---

# 12. Permisos de tokens

Los permisos serán independientes.

Ejemplo:

### Web pública

```text
read
```

### Sistema CMS

```text
read
write
list
```

### Administración

```text
read
write
delete
list
metadata
```

Scopes previstos:

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

Esto permitirá dar acceso solamente a lo necesario.

---

# 13. Tokens y proyectos

Un token perteneciente a:

```text
PGM / Producción
```

NO podrá acceder a:

```text
PGM / Interno
```

ni a:

```text
VUN / Producción
```

aunque conozca el ID del archivo.

El backend comprobará siempre:

```text
token
↓
bucket
↓
project
↓
resource
↓
permission
```

---

# 14. URLs

Los archivos tendrán URLs estables.

Ejemplo:

```text
https://storage.dominio.com/f/PGM-IMG-000142
```

También podremos generar URLs más descriptivas:

```text
https://storage.dominio.com/p/pgm/PGM-IMG-000142
```

El nombre del archivo original no será necesario para localizarlo.

Esto nos permite cambiar:

```text
hero-final-2.jpg
```

por:

```text
hero-oil-gas.jpg
```

sin romper su identidad dentro del sistema.

---

# 15. Archivos públicos y privados

Cada Blob tendrá una política.

## Público

Ideal para:

- Imágenes web.
- Logos.
- Videos públicos.
- PDFs descargables.
- Assets.

La URL puede utilizarse directamente desde una web.

---

## Privado

Ideal para:

- Documentos internos.
- Material no publicado.
- Backups.
- Archivos de clientes.

Para descargarlo será necesaria autorización.

También podremos implementar más adelante:

```text
URL firmada

válida durante:
15 minutos
1 hora
24 horas
```

---

# 16. API

La plataforma tendrá una API propia desde el comienzo.

Base:

```text
/api/v1/
```

Operaciones principales:

```text
POST   /files
GET    /files
GET    /files/{id}
DELETE /files/{id}

GET    /folders
POST   /folders

GET    /projects
GET    /buckets
```

Ejemplo de carga:

```text
POST /api/v1/files

Authorization:
Bearer TOKEN
```

Respuesta:

```json
{
  "id": "obj_01K2R8H4J3",
  "reference": "PGM-IMG-000142",
  "name": "hero-oil-gas.jpg",
  "type": "image/jpeg",
  "size": 1849283,
  "url": "/f/PGM-IMG-000142"
}
```

De esta manera podremos utilizar la plataforma desde:

- Codex.
- Claude Code.
- Aplicaciones.
- Sitios web.
- CMS.
- Automatizaciones.
- Scripts.

---

# 17. Seguridad de carga

Nunca aceptaremos un archivo solamente porque termine en:

```text
.jpg
```

El servidor verificará:

- Extensión.
- MIME real.
- Tamaño.
- Firma del archivo.
- Tipo permitido.
- Proyecto.
- Blob.
- Usuario/token.
- Cuota disponible.

Bloquearemos inicialmente archivos ejecutables como:

```text
.php
.phtml
.phar
.cgi
.sh
.exe
```

Los nombres almacenados serán generados por el sistema.

El nombre enviado por el usuario será únicamente metadata.

---

# 18. Detección de duplicados

Cada archivo podrá generar:

```text
SHA-256
```

Ejemplo:

```text
sha256:
b2a99f...
```

Si se intenta subir exactamente el mismo archivo podremos avisar:

```text
Este archivo ya existe.

PGM-IMG-000132
/web/home
```

Podremos decidir:

- Utilizar existente.
- Crear copia.
- Cancelar carga.

---

# 19. Registro de actividad

Todas las operaciones importantes generarán un registro.

Ejemplo:

```text
21/08/2026 16:31

Usuario
Román

Acción
UPLOAD

Archivo
PGM-IMG-000142

Proyecto
Pragmática

Blob
Producción

IP
xxx.xxx.xxx.xxx
```

También registraremos:

```text
CREATE
UPLOAD
DOWNLOAD
MOVE
RENAME
DELETE
TOKEN_CREATE
TOKEN_REVOKE
LOGIN
LOGIN_FAILED
```

Esto será especialmente importante cuando la plataforma empiece a utilizarse mediante API.

---

# 20. Papelera

Los archivos no se eliminarán inmediatamente.

Primero:

```text
Activo
↓
Papelera
↓
Eliminación definitiva
```

Podemos establecer:

```text
30 días
```

antes de eliminación física.

Esto permitirá recuperar errores.

---

# 21. Dashboard

La interfaz no será un administrador de archivos tradicional de cPanel.

La pantalla principal mostrará:

```text
Storage

12 proyectos

842 archivos

3.82 GB utilizados

↑ 48 archivos este mes
```

Y debajo:

```text
Proyectos recientes
Actividad reciente
Uso de almacenamiento
Archivos recientes
```

---

# 22. Navegación

Desktop:

```text
┌───────────────────────────────────────┐
│ STORAGE                               │
│                                       │
│ Overview                              │
│ Projects                              │
│ Files                                 │
│ Activity                              │
│                                       │
│ ─────────────                         │
│                                       │
│ Settings                              │
│ API                                   │
│                                       │
└───────────────────────────────────────┘
```

Dentro de proyecto:

```text
← Projects

Pragmática

Overview
Files
Blobs
Tokens
Activity
Settings
```

---

# 23. Explorador de archivos

Debe sentirse más cercano a:

```text
Finder
+
Dropbox
+
Vercel
```

que a cPanel.

Tendrá:

- Drag & drop.
- Vista grilla.
- Vista lista.
- Breadcrumb.
- Buscador.
- Filtros.
- Selección múltiple.
- Acciones rápidas.
- Preview.

Ejemplo:

```text
Pragmática / Web / Images

[ + Upload ]             Search...

[ All ] [ Images ] [ Video ] [ Docs ]

──────────────────────────────────────

▣ Hero Oil Gas
  PGM-IMG-00142
  1.8 MB

▣ Equipo Cecilia
  PGM-IMG-00143
  620 KB

▣ SAP Business One
  PGM-IMG-00144
  380 KB
```

---

# 24. Panel lateral del archivo

Al seleccionar un asset aparecerá un drawer lateral.

```text
Hero Oil Gas

[ PREVIEW ]

PGM-IMG-000142

hero-oil-gas.webp

────────────────

URL

[ Copiar URL ]

────────────────

Información

WEBP
1920 × 1080
1.8 MB

────────────────

Tags

oil-gas
hero
web

────────────────

Creado
21 Ago 2026

Subido por
Román
```

Esto evitará entrar y salir de diferentes pantallas para administrar archivos.

---

# 25. Carga

La carga tendrá su propia experiencia.

```text
Drop your files here

o

Seleccionar archivos
```

Mientras sube:

```text
hero.webp      ██████████ 100%
team.jpg       ███████░░░  72%
manual.pdf     ███░░░░░░░  31%
```

Después:

```text
3 archivos cargados correctamente.
```

Se podrá definir antes de subir:

```text
Proyecto
Blob
Carpeta
Tags
Visibilidad
```

---

# 26. Creación de proyecto

Wizard corto.

### Paso 1

```text
Nombre
Pragmática

Código
PGM
```

### Paso 2

```text
Crear Blob inicial

Producción
```

### Paso 3

```text
Visibilidad

● Pública
○ Privada
```

### Paso 4

```text
Generar token inicial

☑ Read
☑ Write
☐ Delete
```

Resultado:

```text
Proyecto creado.

PGM

Token:
vbl_live_...................

Copiar ahora.

Este token no volverá a mostrarse.
```

---

# 27. Diseño visual

Antes de desarrollar la interfaz final haremos un pequeño sistema de diseño.

Definiremos:

## Foundations

- Colores.
- Tipografía.
- Escala de espacios.
- Radios.
- Bordes.
- Elevaciones.
- Iconografía.
- Estados.
- Motion.

## Componentes

- Button.
- Input.
- Search.
- Select.
- Modal.
- Drawer.
- Tooltip.
- Dropdown.
- Badge.
- File card.
- Project card.
- Table.
- Breadcrumb.
- Upload zone.
- Progress.
- Empty state.
- Toast.

La interfaz debe ser sobria, rápida y eminentemente funcional.

No tendrá apariencia de:

- Hosting.
- FTP.
- cPanel.
- Administrador técnico antiguo.

Debe sentirse como un producto SaaS actual.

---

# 28. UX antes de programación

Diseñaremos primero en Figma los flujos críticos:

```text
Login
↓
Dashboard
↓
Proyecto
↓
Carpeta
↓
Archivo
```

y:

```text
Proyecto
↓
Blob
↓
Tokens
↓
Crear token
```

y:

```text
Proyecto
↓
Upload
↓
Metadata
↓
Archivo disponible
```

Una vez validados esos recorridos construiremos los componentes.

---

# 29. Stack propuesto

## Backend

```text
PHP 8.2
```

## Base de datos

```text
MySQL / MariaDB
```

## Web server

```text
Apache
```

## Frontend

Aplicación frontend compilada localmente.

Podremos utilizar:

```text
React
+
TypeScript
```

o una interfaz JS más liviana si durante el prototipo vemos que React agrega complejidad innecesaria.

El hosting no necesitará ejecutar Node.js permanentemente.

Node se utilizaría solamente durante desarrollo/build.

---

# 30. Repositorio

El proyecto tendrá su propio repositorio GitHub.

Estructura conceptual:

```text
storage-platform/
│
├── app/
│   ├── api/
│   ├── auth/
│   ├── storage/
│   ├── projects/
│   └── tokens/
│
├── frontend/
│
├── database/
│   ├── migrations/
│   └── seeds/
│
├── public/
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DATABASE.md
│   ├── API.md
│   ├── SECURITY.md
│   └── DEPLOYMENT.md
│
└── README.md
```

La arquitectura quedará documentada para poder trabajar posteriormente con Codex o Claude Code sin tener que reconstruir contexto.

---

# 31. Implementación en BlueHosting

## Etapa A — Auditoría de hosting

Antes de instalar verificaremos en cPanel:

- PHP disponible.
- Versión activa.
- MySQL/MariaDB.
- Espacio disponible.
- Inodos.
- Ancho de banda.
- Tamaño máximo de upload.
- `post_max_size`.
- `upload_max_filesize`.
- Tiempo máximo de ejecución.
- Memory limit.
- SSH.
- Cron.
- SSL.
- Backups.
- Permisos disponibles fuera de `public_html`.

Esta auditoría determinará los límites reales de la V1.

---

## Etapa B — Subdominio

Crear:

```text
storage.dominio.com
```

o:

```text
assets.dominio.com
```

Será completamente independiente de las webs de clientes.

---

## Etapa C — Base de datos

Crear:

```text
storage_db
```

y un usuario exclusivo.

La aplicación no utilizará credenciales de otras webs instaladas en el hosting.

---

## Etapa D — Storage

Crear el directorio físico de almacenamiento.

Los archivos privados estarán fuera del directorio público siempre que la configuración de la cuenta lo permita.

---

## Etapa E — Configuración

Las claves sensibles estarán fuera del repositorio.

Nunca subiremos:

```text
.env
contraseñas
tokens
credenciales MySQL
```

a GitHub.

---

## Etapa F — SSL

Toda la plataforma funcionará exclusivamente bajo:

```text
HTTPS
```

Las llamadas API sin HTTPS serán rechazadas.

---

# 32. Backups

Debemos respaldar dos cosas diferentes:

## Base de datos

Contiene:

- Proyectos.
- Carpetas.
- Metadata.
- IDs.
- Tokens.
- Logs.

## Archivos

Contiene los assets reales.

Perder cualquiera de los dos implica un problema.

Por eso implementaremos un esquema de backups independiente para ambos.

---

# 33. Cuotas

Cada Blob podrá tener un límite.

Ejemplo:

```text
Pragmática

Producción

Uso
1.7 GB / 2 GB
```

Podremos establecer:

```text
Warning
80 %

Critical
90 %

Block upload
100 %
```

Esto será especialmente importante mientras utilicemos almacenamiento compartido.

---

# 34. Seguridad del portal

La V1 incluirá:

- Login.
- Password hashing.
- Sesiones seguras.
- CSRF.
- Control de permisos.
- Validación de archivos.
- Rate limiting básico.
- Registro de intentos de acceso.
- Tokens hasheados.
- Revocación de tokens.
- HTTPS obligatorio.
- Protección de rutas privadas.
- Bloqueo de archivos ejecutables.
- Protección frente a path traversal.
- Consultas SQL parametrizadas.
- CORS configurable.

Segunda etapa:

- 2FA.
- Alertas de accesos.
- IP allowlist.
- Tokens con expiración.
- Signed URLs.
- Roles de usuario.

---

# 35. Roles

Aunque inicialmente pueda existir un solo administrador, dejaremos preparada la arquitectura.

## Owner

Control total.

## Admin

Administra proyecto.

## Editor

Carga y organiza archivos.

## Viewer

Solo consulta.

Esto permitirá eventualmente darle acceso a:

- Equipo de Vuné.
- Colaboradores.
- Clientes.
- Desarrolladores.

sin entregar acceso al hosting.

---

# 36. MVP

La primera versión funcional deberá incluir obligatoriamente:

- Login.
- Dashboard.
- Crear proyecto.
- Crear Blob.
- Crear carpetas.
- Subir archivo.
- Arrastrar múltiples archivos.
- Código automático.
- ID técnico.
- Renombrar.
- Mover.
- Eliminar.
- Papelera.
- Tags.
- Buscador.
- Preview.
- Copiar URL.
- Público / privado.
- Tokens.
- Permisos de tokens.
- Revocación.
- API.
- Registro de actividad.
- Estadísticas de almacenamiento.
- UI responsive básica.

Esto constituye el núcleo real del producto.

---

# 37. Funciones para segunda versión

Una vez estable:

- Upload masivo avanzado.
- Versionado de archivos.
- Optimización automática de imágenes.
- Conversión JPG/PNG → WebP/AVIF.
- Generación de thumbnails.
- Compresión.
- Metadata EXIF.
- Dominio personalizado por proyecto.
- CDN.
- Cloudflare R2.
- S3.
- Signed URLs.
- Enlaces temporales.
- Usuarios invitados.
- Roles avanzados.
- 2FA.
- Webhooks.
- API keys por entorno.
- Historial de versiones.
- Papelera configurable.
- Detección avanzada de duplicados.

---

# 38. Fases de desarrollo

## Fase 0 — Auditoría

Verificar BlueHosting y documentar restricciones reales.

**Resultado:**
infraestructura confirmada.

---

## Fase 1 — Arquitectura

Definir:

- Modelo de proyectos.
- Buckets.
- IDs.
- Metadata.
- Base de datos.
- Storage Driver.
- API.
- Seguridad.

**Resultado:**
documentación técnica.

---

## Fase 2 — UX/UI

Diseñar en Figma:

- Login.
- Dashboard.
- Proyectos.
- Explorer.
- Upload.
- Asset detail.
- Tokens.
- Settings.

Crear design system.

**Resultado:**
prototipo navegable.

---

## Fase 3 — Backend

Construir:

- Auth.
- Base de datos.
- Projects.
- Buckets.
- Folders.
- Assets.
- Tokens.
- Storage Driver.
- Logs.

**Resultado:**
API funcional.

---

## Fase 4 — Storage

Implementar:

- Upload.
- Download.
- Public/private.
- Delete.
- Trash.
- Checksum.
- Quotas.

**Resultado:**
motor de archivos funcional.

---

## Fase 5 — Frontend

Conectar la interfaz diseñada con la API.

**Resultado:**
portal completamente operativo.

---

## Fase 6 — API externa

Documentar y probar:

```text
GET
POST
PATCH
DELETE
```

con tokens.

**Resultado:**
integración desde otros proyectos.

---

## Fase 7 — BlueHosting

Desplegar:

```text
storage.dominio.com
```

Configurar:

- PHP.
- DB.
- SSL.
- Storage.
- Cron.
- Backups.
- Logs.

---

## Fase 8 — Hardening

Probar:

- Acceso no autorizado.
- Manipulación de IDs.
- Tokens revocados.
- Archivos peligrosos.
- Archivos gigantes.
- MIME falso.
- Duplicados.
- Carpetas inexistentes.
- Upload interrumpido.
- API abusiva.
- Eliminaciones.
- Recuperación.
- Backups.

---

# 39. Criterio de éxito

La plataforma estará lista cuando podamos hacer este recorrido:

```text
Crear proyecto
↓
Crear Blob
↓
Generar token
↓
Crear carpeta
↓
Subir imagen
↓
Obtener ID
↓
Obtener URL
↓
Usar la URL en una web
↓
Consultar el archivo mediante API
↓
Ver la operación registrada
```

sin utilizar cPanel, FTP ni el administrador de archivos de BlueHosting.

Ese es el objetivo real:

**cPanel queda únicamente como infraestructura.**

El trabajo diario deberá hacerse completamente desde nuestra plataforma.

---

# 40. Principio de arquitectura

La plataforma debe controlar:

```text
identidad
metadata
organización
seguridad
permisos
tokens
URLs
usuarios
registros
interfaz
```

BlueHosting solamente debe proporcionar:

```text
almacenamiento
PHP
base de datos
Apache
SSL
```

De esta forma podremos pasar mañana de:

```text
BlueHosting
```

a:

```text
Cloudflare R2
```

sin cambiar la forma en la que utilizamos la plataforma.