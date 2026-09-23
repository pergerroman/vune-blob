# Fase 0 — Auditoría técnica de BlueHosting

## Objetivo

Antes de escribir código o desplegar la plataforma, necesitamos conocer con precisión qué permite la cuenta real de BlueHosting donde se alojará el sistema.

Esta fase **no implementa ni modifica nada**. Su objetivo es recopilar datos, identificar restricciones, confirmar compatibilidades y producir una decisión técnica fundamentada para la arquitectura inicial.

La plataforma prevista tendrá estas condiciones:

- Uso inicialmente privado.
- Sin indexación en buscadores.
- Acceso mediante autenticación.
- Gestión de proyectos, blobs/buckets, carpetas, archivos, etiquetas e IDs.
- Tokens independientes por blob/bucket.
- Frontend preferentemente en HTML, CSS y JavaScript vanilla.
- Backend adaptado al hosting compartido de BlueHosting.
- Base de datos MySQL/MariaDB.
- Almacenamiento inicial en BlueHosting.
- Arquitectura preparada para migrar posteriormente el almacenamiento a R2, S3 u otro proveedor sin rehacer el portal.
- Figma para diseño y prototipado.
- Codex para desarrollo.
- Vercel solamente si aporta valor durante desarrollo, preview o pruebas; no debe ser una dependencia obligatoria del entorno productivo inicial.

---

# Prompt para Codex — Ejecutar Fase 0

## Rol

Actuá como arquitecto de software y auditor técnico.

Tu trabajo en esta fase es **analizar el entorno de hosting antes de desarrollar la plataforma**.

No escribas la aplicación todavía.

No despliegues nada.

No modifiques DNS.

No crees bases de datos.

No cambies versiones de PHP.

No modifiques `.htaccess`.

No generes tokens reales.

No elimines ni muevas archivos existentes.

No hagas ningún cambio irreversible.

---

## Contexto del proyecto

Vamos a desarrollar una plataforma privada de gestión de archivos y almacenamiento.

La plataforma permitirá:

1. Crear proyectos.
2. Crear uno o más blobs/buckets dentro de cada proyecto.
3. Crear carpetas y subcarpetas lógicas.
4. Subir imágenes, documentos, videos y otros archivos autorizados.
5. Asignar un ID técnico único a cada archivo.
6. Asignar una referencia humana legible, por ejemplo:
   - `PGM-IMG-000001`
   - `PGM-DOC-000002`
   - `VUN-VID-000001`
7. Crear etiquetas.
8. Buscar y filtrar archivos.
9. Generar URLs estables.
10. Configurar archivos públicos o privados.
11. Crear múltiples tokens por blob/bucket.
12. Dar permisos específicos a cada token.
13. Revocar tokens.
14. Registrar actividad y consumo.
15. Exponer una API propia para utilizar los archivos desde otros proyectos.

La primera implementación se alojará en un hosting compartido BlueHosting con cPanel.

---

## Preferencias técnicas

### Frontend

Priorizar:

- HTML5.
- CSS moderno.
- JavaScript vanilla.
- Web Components o módulos ES únicamente si aportan una ventaja clara.
- `fetch()` para comunicación con la API.
- Sin frameworks frontend obligatorios.

Evitar React, Vue, Next, Nuxt u otros frameworks salvo que exista una razón técnica concreta y documentada que justifique incorporarlos.

El frontend debe poder compilarse o ejecutarse sin requerir un servidor Node.js permanente.

---

### Backend

Priorizar una solución compatible de forma nativa con BlueHosting.

La opción inicial preferida es:

- PHP 8.x.
- MySQL/MariaDB.
- Apache.
- API JSON propia.

Verificar la versión real de PHP habilitada en la cuenta antes de fijar requisitos definitivos.

No asumir acceso root.

No asumir procesos persistentes.

No asumir Docker.

No asumir Redis.

No asumir workers permanentes.

No asumir Node.js en producción.

No asumir que podemos cambiar configuración global de Apache/PHP.

---

## Privacidad inicial

La plataforma no debe ser indexada por ningún buscador durante las primeras versiones.

La estrategia deberá contemplar varias capas:

1. Autenticación obligatoria para acceder al panel.
2. Posible protección adicional de directorio desde cPanel o `.htaccess` durante desarrollo.
3. `robots.txt` con bloqueo general.
4. `<meta name="robots" content="noindex,nofollow,noarchive,nosnippet">`.
5. Cabecera HTTP:
   `X-Robots-Tag: noindex, nofollow, noarchive, nosnippet`.
6. No publicar sitemap.
7. No enlazar públicamente el portal desde otros sitios.
8. Deshabilitar directory listing.
9. Impedir acceso directo a archivos privados.

Aclaración:

`robots.txt` no debe considerarse una medida de seguridad. La privacidad real depende de autenticación y autorización.

---

# Trabajo a realizar

Usá exclusivamente la información real que se entregue debajo de este prompt y cualquier inspección no destructiva disponible.

Si un dato no está confirmado, marcá:

`PENDIENTE DE CONFIRMACIÓN`

No inventes valores.

No completes datos con supuestos.

---

## 1. Auditar entorno general

Determinar:

- Plan contratado.
- Tipo de hosting.
- Dominio principal.
- Dominios adicionales.
- Posibilidad de crear subdominios.
- Posibilidad de asignar un document root independiente.
- cPanel disponible.
- Versión de cPanel.
- Apache disponible y versión.
- PHP disponible.
- Versión PHP activa.
- Versiones PHP seleccionables.
- MySQL/MariaDB y versión.
- SSL/TLS disponible.
- Let's Encrypt disponible.
- Acceso SSH.
- SFTP.
- FTP.
- Cron.
- Backups.
- WAF.
- Bloqueo de IP.
- Protección de directorios.
- Edición de `.htaccess`.
- Edición de variables/opciones de PHP.

---

## 2. Auditar límites de PHP

Registrar como mínimo:

```text
upload_max_filesize
post_max_size
memory_limit
max_execution_time
max_input_time
max_file_uploads
max_input_vars
```

Indicar:

- Valor actual.
- Si puede modificarse desde cPanel.
- Máximo permitido si puede determinarse.
- Impacto sobre la plataforma.

---

## 3. Auditar almacenamiento

Registrar:

- Espacio total informado.
- Espacio utilizado.
- Espacio libre o disponible.
- Cantidad actual de inodos si está disponible.
- Límite de inodos si está disponible.
- Tamaño aproximado de backups existentes.
- Directorios que más espacio consumen.
- Restricciones contractuales aplicables al almacenamiento de archivos/media.
- Restricciones para backups almacenados dentro de la propia cuenta.
- Transferencia/ancho de banda.
- Límites de uso de CPU.
- Límites de RAM.
- Límites de I/O.
- Límites de procesos/entry processes si cPanel los muestra.

No interpretar la palabra “ilimitado” como ausencia de políticas de uso.

---

## 4. Auditar filesystem

Determinar si podemos crear una estructura similar a:

```text
/home/USUARIO/
├── public_html/
│   └── storage-app/
│
└── blob-storage/
    ├── projects/
    ├── temporary/
    └── private/
```

Confirmar especialmente:

- Si el usuario puede crear carpetas fuera de `public_html`.
- Si PHP puede leer/escribir allí.
- Qué permisos poseen esos directorios.
- Qué usuario ejecuta PHP.
- Si se puede impedir completamente el acceso HTTP directo al storage privado.
- Si el subdominio puede apuntar solamente al directorio público de la aplicación.

No crear esta estructura todavía.

---

## 5. Auditar base de datos

Determinar:

- Motor disponible.
- Versión.
- Cantidad de bases permitidas.
- Cantidad de usuarios permitidos.
- Tamaño máximo por base si existe.
- phpMyAdmin disponible.
- Charset/collation recomendados.
- Posibilidad de utilizar `utf8mb4`.
- Soporte de índices.
- Soporte de transacciones InnoDB.
- Zona horaria del servidor/base de datos.
- Posibilidad de realizar backups/exportaciones.

La propuesta inicial debe asumir una base exclusiva para esta plataforma.

---

## 6. Auditar SSH/SFTP y despliegue

Determinar:

- SSH disponible: sí/no.
- SFTP disponible: sí/no.
- Puerto.
- Shell disponible.
- Git disponible desde shell.
- Composer disponible.
- PHP CLI disponible.
- Posibilidad de ejecutar scripts PHP por CLI.
- Posibilidad de utilizar claves SSH.
- Restricciones del shell.

No guardar credenciales en el informe.

Si SSH no está habilitado, determinar el flujo alternativo más conveniente mediante:

- SFTP.
- FTP seguro si corresponde.
- Administrador de archivos de cPanel.
- Git local + upload de build.

---

## 7. Auditar Cron

Registrar:

- Disponibilidad.
- Frecuencia mínima permitida.
- Cantidad máxima de tareas.
- PHP CLI disponible para cron.
- Restricciones.

Evaluar si cron puede utilizarse para:

- vaciar papelera;
- generar estadísticas;
- limpiar temporales;
- realizar mantenimiento;
- preparar backups;
- detectar archivos huérfanos.

La arquitectura no debe depender de ejecuciones cada pocos segundos o de workers permanentes.

---

## 8. Auditar dominio y SSL

Analizar la posibilidad de utilizar un subdominio como:

```text
storage.DOMINIO.com
```

o:

```text
assets.DOMINIO.com
```

Registrar:

- dominio elegido;
- DNS actual;
- posibilidad de crear registro/subdominio;
- document root;
- SSL;
- redirección HTTP → HTTPS;
- HSTS, si corresponde;
- acceso a configuración de headers mediante `.htaccess`.

No modificar DNS todavía.

---

## 9. Auditar privacidad y seguridad

Verificar disponibilidad de:

- Directory Privacy / protección por contraseña.
- `.htaccess`.
- `Options -Indexes`.
- Headers personalizados.
- HTTPS obligatorio.
- WAF.
- bloqueo de IP.
- hotlink protection.
- logs de acceso.
- logs de errores.
- gestión de sesiones PHP.

Analizar si durante las primeras versiones conviene utilizar:

```text
Protección de directorio
+
Login propio de la aplicación
```

como doble barrera.

---

## 10. Auditar exposición de archivos

Determinar una estrategia para separar:

### Público

Archivos que eventualmente podrían ser consumidos por una web mediante URL.

### Privado

Archivos que sólo deben entregarse luego de verificar permisos.

No asumir que todos los archivos estarán dentro de una carpeta web pública.

Analizar si la descarga privada puede resolverse mediante PHP haciendo streaming del archivo después de autorizar al usuario/token.

---

# Evaluación técnica requerida

Al terminar la auditoría, producir:

## A. Resumen ejecutivo

Máximo 15 puntos.

Debe indicar si BlueHosting es:

- APTO
- APTO CON LIMITACIONES
- NO RECOMENDADO

para la primera versión.

---

## B. Matriz de compatibilidad

Usar:

```text
REQUISITO | ESTADO | DATO REAL | IMPACTO | ACCIÓN
```

Estados:

- OK
- LIMITADO
- BLOQUEADO
- PENDIENTE

---

## C. Riesgos

Clasificar cada riesgo:

- BAJO
- MEDIO
- ALTO
- CRÍTICO

Analizar especialmente:

- almacenamiento;
- inodos;
- uploads grandes;
- ejecución PHP;
- límites de memoria;
- privacidad;
- exposición accidental de archivos;
- backups;
- cron;
- rendimiento;
- API;
- escalabilidad.

---

## D. Arquitectura recomendada para V1

Proponer una arquitectura utilizando preferentemente:

```text
Frontend
HTML + CSS + JavaScript

Backend
PHP

API
JSON sobre HTTPS

Database
MySQL/MariaDB

Storage V1
Filesystem de BlueHosting

Server
Apache
```

Separar:

```text
Public application
Private storage
Database
API
```

Si esta arquitectura no es viable con la cuenta real, explicar exactamente por qué.

---

## E. Dependencias externas

Indicar cuáles son:

### Obligatorias

Necesarias para funcionar.

### Opcionales

Pueden aportar valor pero no son necesarias.

Vercel debe ser considerado inicialmente opcional.

---

## F. Decisión sobre Storage Driver

Confirmar si es viable implementar desde V1 una interfaz abstracta:

```text
StorageDriver
├── LocalStorageDriver
└── FutureObjectStorageDriver
```

para poder migrar posteriormente a:

- Cloudflare R2.
- Amazon S3.
- Backblaze B2.
- otro almacenamiento S3-compatible.

---

## G. Recomendación de límites para V1

A partir de los datos reales, proponer:

- tamaño máximo por imagen;
- tamaño máximo por documento;
- tamaño máximo por video;
- tamaño máximo genérico;
- almacenamiento máximo recomendado por bucket;
- almacenamiento máximo recomendado total;
- cantidad máxima inicial de archivos;
- cantidad recomendada de uploads simultáneos.

No inventar estos valores si faltan datos del hosting.

---

## H. Checklist de habilitación

Crear una lista concreta de todo lo que deberá configurarse antes de comenzar la Fase 1.

Todavía no ejecutar ninguna configuración.

---

# Archivo de salida

Crear:

```text
docs/PHASE-0-HOSTING-AUDIT.md
```

El documento debe contener:

1. Datos recibidos.
2. Datos faltantes.
3. Compatibilidad.
4. Restricciones.
5. Riesgos.
6. Arquitectura recomendada.
7. Decisión sobre BlueHosting.
8. Configuración requerida.
9. Límites recomendados.
10. Preguntas pendientes.

No continuar con desarrollo hasta cerrar los ítems críticos de la auditoría.

---

# Información de mi hosting

Debajo de esta sección voy a completar los datos reales de mi cuenta BlueHosting.

No expongas contraseñas, claves privadas ni tokens.

---

# Información que necesito recopilar de BlueHosting / cPanel

## 1. Cuenta y plan

- [ ] Nombre exacto del plan contratado.
- [ ] Tipo de hosting: compartido / empresa / VPS / otro.
- [ ] Fecha de renovación, sólo si sirve para identificar el plan.
- [ ] Dominio principal asociado.
- [ ] Cantidad de dominios adicionales permitidos.
- [ ] Cantidad de subdominios permitidos.

### Mis datos

```text
Plan:
Tipo:
Dominio principal:
Dominios adicionales:
Subdominios:
```

---

## 2. Información del servidor

Buscar en:

`cPanel → Información del servidor`

Registrar:

- [ ] Versión de cPanel.
- [ ] Versión de Apache.
- [ ] Versión PHP.
- [ ] Versión MySQL/MariaDB.
- [ ] Sistema operativo si aparece.
- [ ] Arquitectura si aparece.

```text
cPanel:
Apache:
PHP:
MySQL/MariaDB:
Sistema operativo:
Arquitectura:
```

---

## 3. Selector de PHP

Buscar:

`cPanel → Software → Seleccionar versión PHP`

o equivalente.

Necesito:

- [ ] Versión PHP activa.
- [ ] Lista de versiones PHP disponibles.
- [ ] Si PHP 8.1 está disponible.
- [ ] Si PHP 8.2 está disponible.
- [ ] Si existe PHP 8.3 o superior.
- [ ] Captura de pantalla de módulos/extensiones disponibles.

```text
PHP activo:
PHP disponibles:
```

---

## 4. Opciones PHP

Buscar:

`cPanel → PHP Options`

Copiar estos valores:

```text
upload_max_filesize:
post_max_size:
memory_limit:
max_execution_time:
max_input_time:
max_file_uploads:
max_input_vars:
```

También indicar:

- [ ] cuáles puedo editar;
- [ ] cuáles están bloqueados;
- [ ] máximos que permite seleccionar cPanel.

---

## 5. Uso de disco

Buscar:

`cPanel → Archivos → Uso del disco`

Necesito:

- [ ] espacio utilizado;
- [ ] espacio total/límite mostrado;
- [ ] principales directorios y su peso;
- [ ] peso de `public_html`;
- [ ] peso de backups;
- [ ] peso de cuentas de correo si comparten cuota.

```text
Total:
Utilizado:
Disponible:
public_html:
Backups:
Correo:
```

---

## 6. Inodos y recursos

Buscar en:

`cPanel → Estadísticas`

y, si existe:

`Resource Usage / Uso de recursos`

Necesito:

- [ ] inodos utilizados;
- [ ] límite de inodos;
- [ ] CPU;
- [ ] RAM/memoria física;
- [ ] I/O;
- [ ] IOPS;
- [ ] Entry Processes;
- [ ] Processes;
- [ ] errores o límites alcanzados en las últimas 24 h / 7 días.

```text
Inodos:
CPU:
RAM:
I/O:
IOPS:
Entry Processes:
Processes:
```

Si un dato no aparece, escribir:

`NO DISPONIBLE EN CPANEL`

---

## 7. Estructura de archivos

Abrir:

`cPanel → Administrador de archivos`

Confirmar:

- [ ] puedo ver `/home/USUARIO/`;
- [ ] puedo crear carpetas fuera de `public_html`;
- [ ] existe una carpeta home privada;
- [ ] puedo cambiar permisos;
- [ ] puedo editar `.htaccess`;
- [ ] puedo mostrar archivos ocultos.

No necesito que me pases tu nombre de usuario si preferís ocultarlo.

Necesito saber si conceptualmente existe:

```text
/home/USUARIO/public_html
```

y si podemos crear:

```text
/home/USUARIO/blob-storage
```

---

## 8. SSH

Buscar:

`cPanel → Seguridad → Acceso SSH`

Necesito:

- [ ] opción disponible: sí/no;
- [ ] claves SSH administrables: sí/no;
- [ ] shell habilitado: sí/no;
- [ ] puerto si BlueHosting lo informa.

No compartir:

- claves privadas;
- contraseña;
- passphrase.

```text
SSH disponible:
Shell:
Puerto:
```

---

## 9. SFTP / FTP

Confirmar:

- [ ] SFTP disponible.
- [ ] FTP disponible.
- [ ] cuentas FTP adicionales.
- [ ] posibilidad de restringir una cuenta FTP a una carpeta determinada.

```text
SFTP:
FTP:
```

---

## 10. Bases de datos

Buscar:

`cPanel → Bases de datos`

Necesito:

- [ ] MySQL/MariaDB disponible;
- [ ] asistente de bases de datos;
- [ ] phpMyAdmin;
- [ ] cantidad de bases permitidas;
- [ ] cantidad actual utilizada;
- [ ] límite de almacenamiento por DB si aparece;
- [ ] posibilidad de crear usuario independiente;
- [ ] posibilidad de asignar privilegios.

```text
Motor:
Versión:
Bases permitidas:
Bases usadas:
phpMyAdmin:
```

No compartir contraseñas de base de datos.

---

## 11. Cron

Buscar:

`cPanel → Avanzada → Trabajos Cron`

Necesito:

- [ ] herramienta disponible;
- [ ] mensaje que indique restricciones;
- [ ] frecuencia mínima permitida;
- [ ] cantidad máxima de tareas si aparece;
- [ ] ruta de PHP CLI si aparece.

```text
Cron:
Frecuencia mínima:
Máximo de tareas:
PHP CLI:
```

---

## 12. Seguridad disponible

Buscar en `cPanel → Seguridad`.

Confirmar si aparecen:

- [ ] SSL/TLS.
- [ ] Let's Encrypt / AutoSSL.
- [ ] Directory Privacy / Privacidad del directorio.
- [ ] IP Blocker.
- [ ] Hotlink Protection.
- [ ] WAF o ModSecurity.
- [ ] Leech Protection.
- [ ] SSH Access.

```text
SSL:
AutoSSL:
Directory Privacy:
IP Blocker:
Hotlink Protection:
WAF/ModSecurity:
```

---

## 13. Subdominio de la plataforma

Todavía no crear nada.

Definir qué dominio base queremos utilizar.

Ejemplos:

```text
storage.midominio.com
assets.midominio.com
files.midominio.com
```

Necesito:

- [ ] dominio base elegido;
- [ ] posibilidad de crear subdominio;
- [ ] posibilidad de elegir document root independiente;
- [ ] SSL disponible para el subdominio.

```text
Dominio base:
Subdominio tentativo:
Document root configurable:
SSL:
```

---

## 14. Backups

Buscar:

`cPanel → Archivos → Copias de seguridad`

Necesito saber:

- [ ] backups automáticos incluidos;
- [ ] frecuencia;
- [ ] retención;
- [ ] posibilidad de restaurar archivos;
- [ ] posibilidad de restaurar DB;
- [ ] backups manuales;
- [ ] si los backups manuales consumen cuota del mismo hosting.

```text
Automáticos:
Frecuencia:
Retención:
Archivos:
DB:
Manual:
```

---

## 15. Logs

Confirmar disponibilidad de:

- [ ] errores PHP;
- [ ] errores Apache;
- [ ] access logs;
- [ ] raw access logs;
- [ ] métricas de tráfico.

```text
Error logs:
Access logs:
Raw logs:
```

---

# Capturas recomendadas

Para resolver esta auditoría con rapidez, guardar capturas de:

1. Inicio de cPanel.
2. Información del servidor.
3. Estadísticas.
4. Selector de versión PHP.
5. PHP Options.
6. Uso del disco.
7. Resource Usage.
8. Acceso SSH.
9. Bases de datos.
10. Trabajos Cron.
11. Seguridad.
12. Administrador de archivos mostrando únicamente la estructura de carpetas.

Ocultar antes de compartir:

- contraseñas;
- tokens;
- claves;
- claves privadas SSH;
- datos que no sean necesarios para la auditoría.

---

# Resultado esperado de la Fase 0

Al completar estos datos, Codex debe poder responder:

1. ¿BlueHosting sirve para la V1?
2. ¿Qué límites reales tendremos?
3. ¿Dónde debe vivir el backend?
4. ¿Dónde deben vivir los archivos privados?
5. ¿Qué tamaño máximo de archivo debemos aceptar?
6. ¿Cómo debemos desplegar?
7. ¿Podemos utilizar SSH/SFTP?
8. ¿Cómo manejaremos cron?
9. ¿Cómo evitaremos exposición e indexación?
10. ¿Qué restricciones condicionan la API?
11. ¿Qué debemos preparar para una futura migración a object storage?
12. ¿Existe algún bloqueo crítico antes de comenzar a desarrollar?
