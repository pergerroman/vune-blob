# Checklist UI/UX — Plataforma privada de Storage

## Objetivo

Diseñar en Figma la interfaz visual de una plataforma privada para administrar:

- proyectos;
- blobs/buckets;
- carpetas;
- archivos;
- IDs;
- códigos de referencia;
- etiquetas;
- URLs;
- tokens;
- permisos;
- usuarios;
- actividad;
- almacenamiento.

El producto debe sentirse como una herramienta digital actual, precisa y eficiente.

No debe parecer:

- cPanel;
- un FTP;
- un explorador de archivos antiguo;
- un panel de hosting;
- un dashboard genérico lleno de tarjetas;
- una plantilla SaaS sin criterio.

Referencias conceptuales de experiencia:

- Finder.
- Dropbox.
- Linear.
- Vercel.
- GitHub.
- Google Drive.

No copiar visualmente estas plataformas. Tomarlas como referencia de claridad, densidad de información, jerarquía y velocidad de interacción.

---

# Stack previsto

## Frontend

```text
HTML
CSS
JavaScript
```

Priorizar una interfaz viable en HTML/CSS/JS vanilla.

Los componentes diseñados en Figma deben poder traducirse a HTML real sin depender de comportamientos exclusivos de frameworks.

## Backend

Previsto:

```text
PHP
MySQL / MariaDB
Apache
```

La UI debe consumir una API JSON.

---

# Estado inicial del producto

Durante las primeras versiones:

- uso privado;
- pocos usuarios;
- acceso obligatorio mediante login;
- no indexado;
- sin landing pública;
- sin página comercial;
- sin SEO;
- sin sitemap público;
- sin navegación accesible sin autenticación.

La pantalla pública principal será únicamente el acceso.

---

# 1. Arquitectura general de navegación

Diseñar navegación desktop primero.

Estructura inicial:

```text
Storage
├── Overview
├── Projects
├── Files
├── Activity
└── Settings
    ├── Users
    ├── Security
    └── System
```

Dentro de un proyecto:

```text
Project
├── Overview
├── Files
├── Blobs
├── Tokens
├── Activity
└── Settings
```

Evitar tener todas las funciones disponibles simultáneamente en el sidebar global.

---

# 2. Login

## Diseñar

- [ ] Login desktop.
- [ ] Login mobile.
- [ ] Campo email/usuario.
- [ ] Campo contraseña.
- [ ] Mostrar/ocultar contraseña.
- [ ] Botón ingresar.
- [ ] Estado loading.
- [ ] Error de credenciales.
- [ ] Sesión expirada.
- [ ] Demasiados intentos.
- [ ] Recuperación de acceso, aunque pueda quedar deshabilitada en V1.
- [ ] Indicador discreto de que es una plataforma privada.

## Evitar

- Registro público.
- “Crear cuenta”.
- Social login innecesario.
- Marketing alrededor del formulario.

---

# 3. Shell principal

Diseñar el esqueleto persistente de la aplicación.

## Elementos

- [ ] Sidebar.
- [ ] Logo/nombre.
- [ ] Navegación principal.
- [ ] Área de usuario.
- [ ] Header contextual.
- [ ] Breadcrumb.
- [ ] Área principal.
- [ ] Sistema de notificaciones/toasts.
- [ ] Modal.
- [ ] Drawer lateral.
- [ ] Dropdown.
- [ ] Tooltip.

## Estados

- [ ] Sidebar normal.
- [ ] Sidebar colapsado.
- [ ] Mobile navigation.
- [ ] Contenido loading.
- [ ] Error general.
- [ ] Sin conexión/API inaccesible.

---

# 4. Overview general

No convertir la pantalla en un dashboard lleno de widgets.

Debe responder rápidamente:

1. ¿Cuánto almacenamiento usamos?
2. ¿Qué proyectos existen?
3. ¿Qué actividad reciente hubo?
4. ¿Hay algún problema?
5. ¿Qué archivos fueron cargados recientemente?

## Bloques

- [ ] Almacenamiento total utilizado.
- [ ] Cantidad de proyectos.
- [ ] Cantidad total de archivos.
- [ ] Uploads recientes.
- [ ] Proyectos recientes.
- [ ] Actividad reciente.
- [ ] Alertas de capacidad.
- [ ] Acceso rápido a “Nuevo proyecto”.
- [ ] Acceso rápido a “Subir archivos”.

## Considerar

- [ ] estado sin proyectos;
- [ ] almacenamiento cerca del límite;
- [ ] storage lleno;
- [ ] error al calcular estadísticas.

---

# 5. Pantalla Projects

## Vista principal

- [ ] Título.
- [ ] Buscador.
- [ ] Nuevo proyecto.
- [ ] Ordenamiento.
- [ ] Filtro de estado.
- [ ] Grid/lista de proyectos.

## Cada proyecto debe mostrar

- [ ] nombre;
- [ ] código corto;
- [ ] cantidad de archivos;
- [ ] almacenamiento utilizado;
- [ ] cantidad de blobs;
- [ ] actividad reciente;
- [ ] estado.

## Acciones

- [ ] abrir;
- [ ] editar;
- [ ] archivar;
- [ ] eliminar;
- [ ] menú contextual.

---

# 6. Crear proyecto

Diseñar un wizard corto.

## Paso 1 — Identidad

- [ ] Nombre.
- [ ] Código corto.
- [ ] Descripción opcional.
- [ ] Icono/color opcional.

Ejemplo:

```text
Nombre
Pragmática

Código
PGM
```

## Paso 2 — Blob inicial

- [ ] Nombre del blob.
- [ ] Código.
- [ ] Público / privado.
- [ ] Límite de almacenamiento si corresponde.

## Paso 3 — Token inicial

- [ ] Crear token ahora / después.
- [ ] Nombre.
- [ ] Permisos.

## Paso 4 — Resultado

- [ ] Proyecto creado.
- [ ] Token generado.
- [ ] Botón copiar token.
- [ ] Aviso de visualización única.
- [ ] Ir al proyecto.

---

# 7. Project Overview

Al entrar a un proyecto mostrar contexto específico.

## Header

- [ ] Volver a Projects.
- [ ] Nombre.
- [ ] Código.
- [ ] Estado.
- [ ] Acción principal Upload.
- [ ] Menú contextual.

## Información

- [ ] almacenamiento usado;
- [ ] archivos;
- [ ] blobs;
- [ ] tokens activos;
- [ ] uploads recientes;
- [ ] actividad reciente;
- [ ] alertas.

## Navegación de proyecto

- [ ] Overview.
- [ ] Files.
- [ ] Blobs.
- [ ] Tokens.
- [ ] Activity.
- [ ] Settings.

---

# 8. Explorador de archivos

Esta será una de las pantallas principales del producto.

## Toolbar

- [ ] Breadcrumb.
- [ ] Search.
- [ ] Upload.
- [ ] Nueva carpeta.
- [ ] Filtros.
- [ ] Sort.
- [ ] Toggle lista/grid.
- [ ] Selección múltiple.

## Breadcrumb

Ejemplo:

```text
Pragmática / Producción / web / home / hero
```

Debe permitir:

- [ ] volver a niveles anteriores;
- [ ] truncar rutas largas;
- [ ] mostrar ruta completa mediante tooltip o menú.

---

# 9. Vista lista

Diseñar una tabla de alta utilidad.

Columnas posibles:

- [ ] selección;
- [ ] preview/icono;
- [ ] nombre;
- [ ] código;
- [ ] tipo;
- [ ] tamaño;
- [ ] fecha;
- [ ] visibilidad;
- [ ] tags;
- [ ] usuario;
- [ ] acciones.

No todas tienen que estar visibles simultáneamente.

## Interacciones

- [ ] ordenar columna;
- [ ] seleccionar fila;
- [ ] double click/open;
- [ ] menú contextual;
- [ ] acciones múltiples;
- [ ] hover;
- [ ] keyboard focus.

---

# 10. Vista grid

Pensada especialmente para material visual.

Cada card debe contemplar:

- [ ] preview;
- [ ] nombre;
- [ ] código;
- [ ] tipo;
- [ ] tamaño;
- [ ] selección;
- [ ] estado público/privado;
- [ ] menú contextual.

Diseñar cards para:

- [ ] imagen;
- [ ] video;
- [ ] PDF;
- [ ] documento;
- [ ] audio;
- [ ] archivo desconocido;
- [ ] carpeta.

---

# 11. Upload

Debe ser una experiencia central.

## Dropzone

- [ ] estado normal;
- [ ] drag over;
- [ ] archivo aceptado;
- [ ] archivo no permitido;
- [ ] varios archivos;
- [ ] límite excedido.

## Selector previo

Permitir definir:

- [ ] proyecto;
- [ ] blob;
- [ ] carpeta;
- [ ] tags;
- [ ] visibilidad.

En contexto de un proyecto/carpeta estos datos deberían venir preseleccionados.

---

# 12. Cola de uploads

Diseñar upload múltiple.

Cada archivo:

- [ ] nombre;
- [ ] tipo;
- [ ] tamaño;
- [ ] progreso;
- [ ] velocidad si se implementa;
- [ ] cancelar;
- [ ] reintentar;
- [ ] éxito;
- [ ] error.

Estados:

```text
Queued
Uploading
Processing
Completed
Failed
Cancelled
```

Contemplar upload parcial:

```text
8 archivos

6 completados
1 cargando
1 error
```

No bloquear toda la interfaz si técnicamente es posible evitarlo.

---

# 13. Resultado de upload

Luego de completar:

- [ ] cantidad subida;
- [ ] errores;
- [ ] IDs generados;
- [ ] referencias generadas;
- [ ] copiar URLs;
- [ ] ver carpeta;
- [ ] subir más.

---

# 14. Asset Drawer

Al hacer click sobre un archivo abrir un panel lateral en desktop.

Evitar mandar al usuario a una nueva página para cada consulta simple.

## Header

- [ ] preview;
- [ ] nombre;
- [ ] código;
- [ ] cerrar;
- [ ] menú.

## Información

- [ ] ID técnico;
- [ ] código;
- [ ] nombre original;
- [ ] extensión;
- [ ] MIME;
- [ ] tamaño;
- [ ] dimensiones si aplica;
- [ ] fecha de creación;
- [ ] usuario;
- [ ] ubicación;
- [ ] blob;
- [ ] visibilidad;
- [ ] checksum;
- [ ] URL.

## Acciones

- [ ] copiar URL;
- [ ] descargar;
- [ ] renombrar;
- [ ] mover;
- [ ] cambiar tags;
- [ ] cambiar visibilidad;
- [ ] reemplazar/versionar en futuro;
- [ ] enviar a papelera.

---

# 15. Preview de archivos

Diseñar preview específico para:

## Imagen

- [ ] zoom;
- [ ] dimensiones;
- [ ] transparencia;
- [ ] abrir tamaño completo.

## Video

- [ ] reproductor;
- [ ] duración;
- [ ] resolución.

## Audio

- [ ] player;
- [ ] duración.

## PDF

- [ ] thumbnail;
- [ ] abrir/visualizar.

## Otros

- [ ] icono;
- [ ] metadata;
- [ ] descargar.

---

# 16. URL del asset

Componente específico:

```text
https://storage.dominio.com/f/PGM-IMG-000142
```

Acciones:

- [ ] copiar;
- [ ] abrir;
- [ ] indicar público/privado;
- [ ] regenerar URL sólo si la arquitectura lo permite;
- [ ] feedback “Copiado”.

No mostrar URLs privadas como si fueran enlaces públicos funcionales.

---

# 17. Tags

Diseñar:

- [ ] tag;
- [ ] tag selector;
- [ ] crear tag;
- [ ] búsqueda;
- [ ] remover;
- [ ] colores opcionales;
- [ ] filtros por tags.

Ejemplo:

```text
oil-gas
hero
web
approved
2026
```

Evitar que los tags se transformen en decoración excesiva.

---

# 18. Filtros

Diseñar filtros para:

- [ ] tipo;
- [ ] blob;
- [ ] carpeta;
- [ ] visibilidad;
- [ ] tags;
- [ ] tamaño;
- [ ] fecha;
- [ ] usuario;
- [ ] estado.

## UX

- [ ] filtros activos claramente visibles;
- [ ] limpiar uno;
- [ ] limpiar todos;
- [ ] combinación de filtros;
- [ ] contador de resultados.

---

# 19. Búsqueda

Debe admitir conceptualmente:

```text
PGM-IMG-000142
hero
oil-gas
.webp
```

Diseñar:

- [ ] búsqueda normal;
- [ ] loading;
- [ ] resultados;
- [ ] sin resultados;
- [ ] error;
- [ ] historial reciente opcional.

---

# 20. Selección múltiple

Cuando existen archivos seleccionados cambiar la toolbar.

Acciones:

- [ ] mover;
- [ ] agregar tags;
- [ ] cambiar visibilidad;
- [ ] descargar;
- [ ] enviar a papelera;
- [ ] cancelar selección.

Mostrar:

```text
8 selected
```

Evitar esconder las acciones principales en menús innecesarios.

---

# 21. Carpetas

## Crear

- [ ] nombre;
- [ ] ubicación;
- [ ] validaciones.

## Acciones

- [ ] abrir;
- [ ] renombrar;
- [ ] mover;
- [ ] eliminar;
- [ ] copiar ruta.

## Estados especiales

- [ ] vacía;
- [ ] contiene archivos;
- [ ] contiene subcarpetas;
- [ ] eliminación no permitida.

---

# 22. Mover archivos

Diseñar un modal/drawer para:

```text
Move 4 files
```

Debe mostrar:

- [ ] árbol/ruta;
- [ ] breadcrumb;
- [ ] carpeta destino;
- [ ] crear carpeta;
- [ ] confirmar;
- [ ] cancelar.

---

# 23. Papelera

Pantalla o filtro específico.

Mostrar:

- [ ] archivo;
- [ ] proyecto;
- [ ] ubicación anterior;
- [ ] eliminado por;
- [ ] fecha;
- [ ] fecha de eliminación definitiva.

Acciones:

- [ ] restaurar;
- [ ] eliminar definitivamente.

Diseñar confirmación especialmente clara para eliminación definitiva.

---

# 24. Blobs/Buckets

Pantalla dentro de proyecto.

Cada blob debe mostrar:

- [ ] nombre;
- [ ] código;
- [ ] público/privado;
- [ ] almacenamiento;
- [ ] archivos;
- [ ] tokens;
- [ ] estado;
- [ ] driver de storage si posteriormente existe más de uno.

## Acciones

- [ ] abrir;
- [ ] editar;
- [ ] crear;
- [ ] archivar;
- [ ] eliminar, con restricciones.

---

# 25. Crear Blob

Campos:

- [ ] nombre;
- [ ] código;
- [ ] descripción;
- [ ] público/privado;
- [ ] cuota opcional;
- [ ] storage driver, oculto o fijo en V1;
- [ ] crear token inicial.

---

# 26. Tokens

Esta pantalla necesita especial claridad.

## Lista

Mostrar:

- [ ] nombre;
- [ ] prefijo;
- [ ] blob;
- [ ] permisos;
- [ ] creado;
- [ ] último uso;
- [ ] expiración;
- [ ] estado;
- [ ] usuario creador.

Nunca mostrar el secreto completo de tokens existentes.

Ejemplo:

```text
Production Web
vbl_live_••••••••83HF
READ
Active
Last used: 3 min ago
```

---

# 27. Crear Token

## Campos

- [ ] nombre;
- [ ] descripción opcional;
- [ ] blob;
- [ ] entorno;
- [ ] permisos;
- [ ] expiración opcional.

## Permisos

Diseñar selección de:

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

Evitar un listado visualmente caótico.

Agrupar scopes por categoría.

---

# 28. Token creado

Esta pantalla/modal es crítica.

Mostrar:

```text
Token created successfully
```

y el token completo una sola vez.

## Acciones

- [ ] copiar;
- [ ] confirmación de copia;
- [ ] descargar como `.env` opcional más adelante;
- [ ] cerrar.

## Warning

Comunicar claramente:

```text
Este token no volverá a mostrarse.
Guardalo ahora en un lugar seguro.
```

Al cerrar no debe poder recuperarse.

---

# 29. Revocar Token

Diseñar confirmación.

Debe mostrar:

- [ ] nombre;
- [ ] prefijo;
- [ ] blob;
- [ ] última actividad;
- [ ] impacto.

Acción:

```text
Revoke token
```

No utilizar confirmaciones genéricas tipo “¿Estás seguro?”.

Explicar qué dejará de funcionar.

---

# 30. Actividad / Audit Log

Diseñar una vista eficiente.

Columnas:

- [ ] fecha/hora;
- [ ] usuario/token;
- [ ] acción;
- [ ] recurso;
- [ ] proyecto;
- [ ] blob;
- [ ] resultado.

Acciones registradas:

```text
LOGIN
LOGIN_FAILED
UPLOAD
DOWNLOAD
MOVE
RENAME
DELETE
RESTORE
TOKEN_CREATE
TOKEN_REVOKE
```

## Filtros

- [ ] acción;
- [ ] proyecto;
- [ ] blob;
- [ ] usuario;
- [ ] token;
- [ ] fecha;
- [ ] éxito/error.

---

# 31. Storage Usage

Diseñar una sección donde se entienda:

- [ ] uso total;
- [ ] límite recomendado;
- [ ] porcentaje;
- [ ] uso por proyecto;
- [ ] uso por blob;
- [ ] uso por tipo;
- [ ] crecimiento.

No hace falta hacer analítica compleja en V1.

Priorizar detectar:

```text
Normal
Warning
Critical
Full
```

---

# 32. Alertas

Diseñar alertas para:

- [ ] 80 % de capacidad;
- [ ] 90 %;
- [ ] 100 %;
- [ ] upload bloqueado;
- [ ] token vencido;
- [ ] token revocado;
- [ ] error de backend;
- [ ] fallo de storage;
- [ ] backup pendiente, si se implementa.

Diferenciar:

- información;
- warning;
- error;
- acción destructiva.

---

# 33. Settings de proyecto

Diseñar:

- [ ] nombre;
- [ ] código;
- [ ] descripción;
- [ ] estado;
- [ ] cuota;
- [ ] configuración por defecto de archivos;
- [ ] archivar proyecto.

Separar claramente:

```text
General
Storage
Security
Danger Zone
```

---

# 34. Danger Zone

Diseñar acciones críticas:

- [ ] archivar proyecto;
- [ ] eliminar proyecto;
- [ ] eliminar blob;
- [ ] vaciar papelera;
- [ ] revocar todos los tokens.

Usar confirmaciones específicas.

Para operaciones irreversibles evaluar requerir escribir:

```text
PGM
```

o el nombre del recurso.

---

# 35. Usuarios

Aunque V1 tenga pocos usuarios, prototipar:

- [ ] lista;
- [ ] rol;
- [ ] último acceso;
- [ ] activo/inactivo;
- [ ] invitar usuario;
- [ ] desactivar;
- [ ] cambiar rol.

Roles previstos:

```text
Owner
Admin
Editor
Viewer
```

No implementar permisos complejos en UI si todavía no existen en backend, pero dejar una estructura escalable.

---

# 36. Perfil de usuario

Diseñar:

- [ ] nombre;
- [ ] email;
- [ ] contraseña;
- [ ] sesiones activas;
- [ ] cerrar otras sesiones;
- [ ] 2FA como función futura;
- [ ] preferencias visuales si corresponden.

---

# 37. Seguridad

Pantalla futura o settings.

Contemplar:

- [ ] contraseña;
- [ ] sesiones;
- [ ] 2FA;
- [ ] historial de accesos;
- [ ] IPs;
- [ ] tokens;
- [ ] actividad sospechosa.

---

# 38. Empty States

Diseñarlos deliberadamente.

Necesitamos como mínimo:

- [ ] sin proyectos;
- [ ] proyecto sin blobs;
- [ ] blob vacío;
- [ ] carpeta vacía;
- [ ] sin tokens;
- [ ] sin actividad;
- [ ] sin resultados;
- [ ] papelera vacía.

Cada empty state debe ofrecer la siguiente acción lógica.

Ejemplo:

```text
No files yet

Upload your first file
```

No llenar estas pantallas con ilustraciones decorativas innecesarias.

---

# 39. Loading States

Diseñar:

- [ ] carga de pantalla;
- [ ] carga de tabla;
- [ ] carga de preview;
- [ ] carga de drawer;
- [ ] creación de proyecto;
- [ ] creación de token;
- [ ] upload;
- [ ] búsqueda.

Decidir cuándo usar:

- spinner;
- skeleton;
- progress;
- estado inline.

---

# 40. Error States

Diseñar:

- [ ] 400;
- [ ] 401;
- [ ] 403;
- [ ] 404;
- [ ] 409/conflicto;
- [ ] 413 archivo demasiado grande;
- [ ] 429 demasiadas solicitudes;
- [ ] 500;
- [ ] storage unavailable;
- [ ] network error.

Los mensajes deben explicar qué puede hacer el usuario.

---

# 41. Confirmaciones

Definir patrón común.

Acciones que pueden requerir confirmación:

- [ ] eliminar;
- [ ] eliminar definitivamente;
- [ ] revocar token;
- [ ] eliminar blob;
- [ ] eliminar proyecto;
- [ ] cerrar sesión global;
- [ ] sobrescribir archivo.

No confirmar acciones reversibles y cotidianas sin necesidad.

---

# 42. Toasts

Diseñar:

- [ ] success;
- [ ] error;
- [ ] warning;
- [ ] info.

Ejemplos:

```text
URL copied
File moved
3 tags updated
Token revoked
Upload failed
```

Evitar mensajes largos.

---

# 43. Menús contextuales

Definir un patrón consistente.

Ejemplo Asset:

```text
Open
Copy URL
Download
Rename
Move
Tags
---
Move to trash
```

Evitar que cada pantalla tenga un orden diferente para acciones equivalentes.

---

# 44. Atajos de teclado

No son obligatorios para V1, pero diseñar pensando que puedan incorporarse.

Ejemplos futuros:

```text
/
Search

U
Upload

N
New folder

Esc
Close drawer/modal

Cmd/Ctrl + A
Select all
```

No hacer que ninguna función dependa exclusivamente del teclado.

---

# 45. Responsive

Prioridad:

```text
Desktop
↓
Tablet
↓
Mobile
```

La gestión avanzada será principalmente desktop.

Mobile debe permitir como mínimo:

- [ ] login;
- [ ] overview;
- [ ] navegar proyectos;
- [ ] navegar archivos;
- [ ] preview;
- [ ] copiar URL;
- [ ] cargar archivos;
- [ ] acciones básicas;
- [ ] revisar tokens.

No es necesario replicar la densidad de una tabla desktop en mobile.

---

# 46. Breakpoints a prototipar

Como mínimo:

```text
1440 desktop
1024 tablet/desktop reducido
390 mobile
```

Opcional:

```text
1920 wide
768 tablet
```

No diseñar componentes con dimensiones rígidas que sólo funcionen en un frame.

---

# 47. Design System — Foundations

Definir en Figma:

- [ ] color background;
- [ ] surface;
- [ ] elevated surface;
- [ ] text primary;
- [ ] text secondary;
- [ ] border;
- [ ] accent;
- [ ] success;
- [ ] warning;
- [ ] danger;
- [ ] focus;
- [ ] disabled.

También:

- [ ] escala tipográfica;
- [ ] line heights;
- [ ] spacing;
- [ ] radii;
- [ ] border widths;
- [ ] icon sizes;
- [ ] control heights;
- [ ] shadows, si son necesarias;
- [ ] motion tokens.

---

# 48. Tipografía

Necesitamos niveles como mínimo:

- [ ] Display/Page title.
- [ ] Section title.
- [ ] Card title.
- [ ] Body.
- [ ] Small.
- [ ] Label.
- [ ] Metadata.
- [ ] Code/monospace.

IDs, hashes, tokens y URLs deberían utilizar una tipografía monoespaciada.

---

# 49. Componentes base

Crear como componentes Figma:

- [ ] Button.
- [ ] Icon Button.
- [ ] Input.
- [ ] Search Input.
- [ ] Textarea.
- [ ] Select.
- [ ] Checkbox.
- [ ] Radio.
- [ ] Switch.
- [ ] Tabs.
- [ ] Badge.
- [ ] Tag.
- [ ] Tooltip.
- [ ] Dropdown.
- [ ] Modal.
- [ ] Drawer.
- [ ] Toast.
- [ ] Breadcrumb.
- [ ] Progress.
- [ ] Skeleton.
- [ ] Empty State.
- [ ] Alert.
- [ ] Table.
- [ ] Pagination, si se usa.
- [ ] Avatar.
- [ ] File Icon.
- [ ] File Preview.
- [ ] Project Card.
- [ ] Blob Card.
- [ ] File Card.
- [ ] Upload Row.
- [ ] Token Row.

---

# 50. Estados por componente

Para botones/inputs y controles diseñar:

```text
Default
Hover
Focus
Active
Disabled
Loading
Error
```

No dejar estados para resolver durante programación.

---

# 51. Accesibilidad

Incluir desde diseño:

- [ ] contraste suficiente;
- [ ] focus visible;
- [ ] targets adecuados;
- [ ] labels;
- [ ] errores no dependientes únicamente del color;
- [ ] navegación por teclado;
- [ ] iconos acompañados de tooltip cuando sean ambiguos;
- [ ] tamaños de texto legibles.

---

# 52. Iconografía

Usar una sola familia.

Necesitamos:

- [ ] folder;
- [ ] image;
- [ ] video;
- [ ] document;
- [ ] audio;
- [ ] archive;
- [ ] upload;
- [ ] download;
- [ ] copy;
- [ ] move;
- [ ] rename/edit;
- [ ] trash;
- [ ] restore;
- [ ] token/key;
- [ ] project;
- [ ] storage;
- [ ] user;
- [ ] activity;
- [ ] settings;
- [ ] search;
- [ ] filter;
- [ ] sort;
- [ ] grid;
- [ ] list;
- [ ] public;
- [ ] private.

---

# 53. Motion

Mantener movimiento funcional.

Diseñar únicamente:

- [ ] apertura/cierre de drawer;
- [ ] modal;
- [ ] dropdown;
- [ ] toast;
- [ ] progreso de upload;
- [ ] selección;
- [ ] drag & drop;
- [ ] cambio lista/grid.

Evitar animaciones de entrada decorativas.

---

# 54. Densidad

Esta plataforma administra información.

No diseñar todo con:

- cards gigantes;
- márgenes enormes;
- botones enormes;
- textos excesivamente grandes.

Debe poder mostrar muchos archivos sin sentirse comprimida ni desperdiciar espacio.

---

# 55. Dark mode

No es obligatorio para MVP.

Si se diseña:

- [ ] construirlo desde variables/tokens;
- [ ] no diseñar dos productos separados;
- [ ] conservar contraste;
- [ ] previews de archivos deben distinguirse del fondo.

Prioridad:

1. Sistema funcional.
2. Buen light mode.
3. Dark mode.

---

# 56. Pantallas mínimas para prototipo MVP

Diseñar obligatoriamente:

1. [ ] Login.
2. [ ] Overview.
3. [ ] Projects.
4. [ ] New Project.
5. [ ] Project Overview.
6. [ ] Files — lista.
7. [ ] Files — grid.
8. [ ] Upload.
9. [ ] Upload progress.
10. [ ] Asset Drawer.
11. [ ] Image Preview.
12. [ ] Folder empty state.
13. [ ] Search results.
14. [ ] Multi-select.
15. [ ] Move files.
16. [ ] Trash.
17. [ ] Blobs.
18. [ ] New Blob.
19. [ ] Tokens.
20. [ ] New Token.
21. [ ] Token created / show once.
22. [ ] Revoke Token.
23. [ ] Activity.
24. [ ] Project Settings.
25. [ ] Storage Usage.
26. [ ] Error/connection state.
27. [ ] Mobile file browser.

---

# 57. Flujos a prototipar en Figma

## Flujo A — Primer proyecto

```text
Login
→ Overview vacío
→ New Project
→ Crear Blob
→ Generar Token
→ Proyecto listo
```

## Flujo B — Upload

```text
Project
→ Files
→ Upload
→ Seleccionar archivos
→ Progreso
→ Finalizado
→ Asset Drawer
→ Copiar URL
```

## Flujo C — Organización

```text
Files
→ seleccionar archivos
→ mover
→ carpeta destino
→ confirmar
```

## Flujo D — Token

```text
Project
→ Tokens
→ New Token
→ Permisos
→ Crear
→ Copiar secreto
→ Cerrar
```

## Flujo E — Revocación

```text
Tokens
→ seleccionar token
→ Revoke
→ visualizar impacto
→ confirmar
→ token revoked
```

## Flujo F — Recuperación

```text
Files
→ Trash
→ seleccionar asset
→ Restore
→ archivo restaurado
```

---

# 58. Orden recomendado para diseñar

## Bloque 1 — Foundations

- variables;
- tipografía;
- colores;
- espaciado;
- iconos.

## Bloque 2 — Core components

- button;
- input;
- menu;
- table;
- modal;
- drawer;
- toast.

## Bloque 3 — App shell

- login;
- sidebar;
- header;
- breadcrumb.

## Bloque 4 — Projects

- overview;
- projects;
- project.

## Bloque 5 — Files

- explorer;
- list;
- grid;
- drawer;
- previews.

## Bloque 6 — Upload

- dropzone;
- queue;
- progress;
- resultados.

## Bloque 7 — Tokens

- lista;
- creación;
- visualización única;
- revocación.

## Bloque 8 — System

- activity;
- storage;
- settings;
- errores.

## Bloque 9 — Responsive

- tablet;
- mobile.

---

# 59. Prioridad funcional

## P0 — Imprescindible

- Login.
- Projects.
- Blobs.
- Files.
- Folders.
- Upload.
- IDs.
- URL.
- Tokens.
- Search.
- Asset detail.
- Delete/trash.
- Activity.

## P1 — Importante

- Tags.
- Grid/list.
- Multi-select.
- Storage usage.
- Roles.
- Filtros.
- Preview avanzado.

## P2 — Posterior

- Versionado.
- Signed URLs.
- 2FA.
- Dark mode.
- Atajos.
- Analítica.
- CDN.
- Storage drivers externos.
- Optimización automática.

---

# 60. Entrega desde Figma a Codex

Para que el diseño pueda implementarse con precisión, documentar:

- [ ] variables;
- [ ] spacing;
- [ ] tipografía;
- [ ] breakpoints;
- [ ] componentes;
- [ ] estados;
- [ ] interacciones;
- [ ] overlays;
- [ ] comportamiento responsive;
- [ ] iconografía;
- [ ] empty states;
- [ ] error states.

Evitar entregar a Codex únicamente una captura.

El prototipo debe indicar qué ocurre cuando:

- se hace click;
- se carga;
- falla;
- está vacío;
- está deshabilitado;
- se completa una acción.

---

# Criterio visual final

La plataforma tiene que sentirse:

- profesional;
- silenciosa;
- rápida;
- precisa;
- técnica sin ser áspera;
- moderna sin depender de modas;
- cómoda para uso frecuente;
- escalable.

La prioridad visual no es “hacer un dashboard bonito”.

La prioridad es que gestionar cientos o miles de archivos sea claro, rápido y difícil de romper.
