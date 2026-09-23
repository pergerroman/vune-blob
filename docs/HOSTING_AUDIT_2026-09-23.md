# Auditoría de hosting — 23 de septiembre de 2026

## Alcance

Revisión de solo lectura realizada sobre cPanel para validar requisitos previos del backend y del despliegue de la plataforma.

Durante la auditoría no se crearon dominios, archivos, tareas Cron ni configuraciones; tampoco se modificaron versiones de PHP, extensiones, permisos o contenido existente.

No se registran en este documento credenciales, identificadores de sesión, direcciones IP ni otros datos sensibles observados en el panel.

## Actualización posterior

Después de finalizar la revisión de solo lectura, el usuario confirmó:

- la creación de `blob.estudiovune.com` con raíz documental en `/home/estudi76/public_html/blob.estudiovune.com`;
- la activación de PHP 8.4;
- la activación de `pdo_mysql`, `fileinfo`, `mbstring`, `openssl` y `json` bajo PHP 8.4.

Estas confirmaciones son posteriores a la auditoría original y no fueron verificadas nuevamente desde cPanel.

## Entorno confirmado

- Usuario de hosting: `estudi76`.
- Directorio principal: `/home/estudi76`.
- Dominio principal de la cuenta: `estudiovune.com`.
- cPanel 134.0.57.
- El dominio principal tiene un certificado SSL activo.
- La plataforma utilizará `blob.estudiovune.com` como dominio público principal.

## Resultados

| Requisito | Estado | Evidencia observada |
| --- | --- | --- |
| PHP 8.4 | Activado, según confirmación del usuario | Durante la auditoría original estaba activo PHP 7.4; PHP 8.4 fue seleccionado posteriormente. |
| `pdo_mysql` | Activado en PHP 8.4, según confirmación del usuario | La extensión también estaba habilitada en la configuración PHP 7.4 observada originalmente. |
| `fileinfo` | Activado en PHP 8.4, según confirmación del usuario | La extensión también estaba habilitada en la configuración PHP 7.4 observada originalmente. |
| `mbstring` | Activado en PHP 8.4, según confirmación del usuario | La extensión también estaba habilitada en la configuración PHP 7.4 observada originalmente. |
| `openssl` | Activado en PHP 8.4, según confirmación del usuario | Estaba disponible como extensión integrada/habilitada en PHP 7.4 durante la revisión original. |
| `json` | Activado en PHP 8.4, según confirmación del usuario | La extensión también estaba habilitada en la configuración PHP 7.4 observada originalmente. |
| PHP CLI | Confirmado | cPanel muestra `/usr/local/bin/php` como ejemplo de ejecución. Una tarea Cron existente utiliza `/usr/bin/php`. |
| Cron | Confirmado | La interfaz de administración de tareas Cron está disponible. |
| `.htaccess` | Disponible | Existe `/home/estudi76/public_html/.htaccess`, con tamaño de 0 bytes al momento de la revisión. |
| Reescritura de rutas | No confirmado | El `.htaccess` encontrado no contiene reglas y no se ejecutó una prueba para respetar el alcance de solo lectura. |
| `blob.estudiovune.com` | Creado, según confirmación del usuario | No figuraba durante la auditoría original; su creación fue informada posteriormente por el usuario. |
| Raíz documental de la aplicación | Confirmada por el usuario | `/home/estudi76/public_html/blob.estudiovune.com`. |
| HTTPS | Confirmado | `https://blob.estudiovune.com/` responde mediante HTTP/2 con estado `200`. |
| Certificado TLS | Confirmado | Certificado Let’s Encrypt válido para `blob.estudiovune.com`, emitido el 23 de septiembre de 2026 y con vencimiento el 22 de diciembre de 2026. |
| HSTS | Activo | La respuesta incluye `Strict-Transport-Security: max-age=63072000; includeSubDomains`. Esta configuración ya estaba activa y no fue modificada durante la revisión. |
| Escritura fuera de `public_html` | Confirmado previamente | El usuario confirmó que PHP puede escribir fuera de `public_html`. No se repitió una prueba durante esta auditoría. |

## Interpretación

El hosting ofrece los componentes necesarios para ejecutar el backend en PHP 8.4 y dispone de PHP CLI y Cron. La versión y las extensiones requeridas quedaron activadas después de la auditoría original, según confirmación del usuario.

La disponibilidad de `.htaccess` está confirmada, pero no el funcionamiento de `mod_rewrite`. La verificación definitiva requiere una prueba controlada con una regla temporal o con el front controller real de la aplicación.

El subdominio fue creado después de la auditoría y utiliza `/home/estudi76/public_html/blob.estudiovune.com` como raíz documental.

## Pendientes antes del despliegue

1. Confirmar que PHP-FPM y PHP CLI utilizan PHP 8.4 y zonas horarias compatibles.
2. Probar `.htaccess`, `mod_rewrite`, el front controller y `Options -Indexes`.
3. Definir y crear el almacenamiento privado fuera de `public_html`.
4. Confirmar permisos efectivos entre PHP-FPM, Cron y el mecanismo de despliegue.
5. Confirmar límites efectivos de carga y política de backups del proveedor.

## Decisiones que este registro no toma

- Ruta definitiva del almacenamiento privado.
- Configuración de Apache, PHP-FPM, base de datos o Cron.

Estas decisiones deberán registrarse cuando se realice la configuración efectiva.
