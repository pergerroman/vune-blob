# Despliegue en BlueHosting

## Estado

Destino previsto: `blob.estudiovune.com`, con raíz documental en `/home/estudi76/public_html/blob.estudiovune.com`, sobre hosting compartido Linux con cPanel, Apache 2.4, PHP 8.4, PHP-FPM y MariaDB 10.6. HTTPS con certificado Let’s Encrypt, las extensiones requeridas, la escritura PHP fuera de `public_html`, `.htaccess`, `mod_rewrite` y `Options -Indexes` están confirmados. Todavía no se debe desplegar contenido real.

La evidencia del entorno relevada en cPanel está registrada en [`HOSTING_AUDIT_2026-09-23.md`](HOSTING_AUDIT_2026-09-23.md).

## Layout propuesto

```text
/home/estudi76/
├── app-releases/
│   ├── 20260922-001/
│   │   ├── app/
│   │   ├── config/
│   │   ├── database/
│   │   ├── public/
│   │   └── vendor/        # si Composer es necesario
│   └── current -> 20260922-001/
├── blob-storage/
│   ├── objects/
│   ├── temporary/
│   └── quarantine/
├── storage-config/
│   └── config.php
└── public_html/
    └── blob.estudiovune.com/ # document root del subdominio
```

Si cPanel no permite symlinks, se copia únicamente el contenido de `public/` a `/home/estudi76/public_html/blob.estudiovune.com` y el front controller requiere el código mediante una ruta privada fija.

## Preflight bloqueante

Antes de implementar o desplegar:

1. Seleccionar una versión PHP 8.x compatible.
2. Confirmar extensiones PDO MySQL, fileinfo, mbstring, openssl y json.
3. Confirmar PHP CLI para migraciones y Cron.
4. Verificar que PHP-FPM y CLI usan versión y timezone compatibles.
5. Crear un archivo temporal fuera de `public_html`, leerlo, renombrarlo y borrarlo.
6. Confirmar permisos entre PHP-FPM, FTP/SFTP y Cron.
7. Probar el rewrite definitivo a `index.php` y las cabeceras de la aplicación.
8. Verificar la renovación automática del certificado Let’s Encrypt antes de su vencimiento.
9. Verificar límites efectivos de Apache y PHP con requests controlados.
10. Confirmar política de backup, espacio e inodos.

## Configuración privada

Ejemplo conceptual, nunca versionado:

```php
<?php
return [
    'app' => [
        'environment' => 'production',
        'secret' => '...',
        'base_url' => 'https://blob.estudiovune.com',
    ],
    'database' => [
        'host' => 'localhost',
        'name' => '...',
        'user' => '...',
        'password' => '...',
    ],
    'storage' => [
        'driver' => 'local',
        'path' => '/home/estudi76/blob-storage',
    ],
];
```

La aplicación debe fallar cerrada si falta configuración sensible.

## Apache

Responsabilidades de `.htaccess` o VirtualHost:

- redirección obligatoria a HTTPS;
- `Options -Indexes`;
- front controller para `/api/v1/*` y `/f/*`;
- archivos estáticos existentes servidos directamente;
- `X-Robots-Tag` y cabeceras de seguridad;
- no exponer archivos `.env`, `.git`, logs, SQL o configuración.

HSTS ya está activo con `max-age=63072000; includeSubDomains`; conservarlo sólo mientras HTTPS permanezca estable en los subdominios afectados. No usar `Access-Control-Allow-Origin: *`.

## Base de datos

1. Crear base y usuario exclusivos con privilegios sólo sobre esa base.
2. Configurar conexión `utf8mb4` y UTC.
3. Ejecutar migraciones por CLI con backup previo.
4. No ejecutar `schema.sql` automáticamente en cada request.
5. Crear el primer usuario administrador mediante comando CLI interactivo o script de un solo uso retirado inmediatamente.

## Cron

Comandos previstos:

```text
php bin/console uploads:expire
php bin/console trash:purge
php bin/console storage:reconcile
php bin/console logs:maintain
```

Cada comando:

- obtiene lock no bloqueante;
- procesa lotes acotados;
- es idempotente;
- registra resultado;
- devuelve código de salida correcto;
- no depende de intervalos inferiores a los permitidos por el hosting.

## Proceso de release

1. Ejecutar validaciones localmente.
2. Generar artefacto sin secretos, `.git`, tests ni archivos temporales.
3. Subir a un directorio de release nuevo.
4. Verificar configuración y permisos.
5. Activar modo mantenimiento para migraciones incompatibles.
6. Respaldar DB.
7. Ejecutar migraciones.
8. Cambiar release activo o copiar archivos públicos.
9. Ejecutar smoke tests de login, API, upload pequeño y descarga.
10. Desactivar mantenimiento.

Rollback de código cambia al release anterior. Rollback de DB requiere una migración inversa probada o restauración; no se debe asumir que todo cambio de esquema es reversible.

## Backups

- Dump consistente de MariaDB.
- Copia separada de `objects/` y manifest de checksums.
- Destino externo a la cuenta BlueHosting.
- Retención definida y cifrado.
- Prueba periódica de restauración completa.

## Smoke tests

- La raíz privada redirige al login.
- `robots.txt` desautoriza todo y no existe sitemap.
- Login válido/inválido y logout.
- CSRF bloquea mutaciones sin token.
- Usuario sin proyecto no enumera recursos.
- Crear carpeta y detectar nombre duplicado.
- Subir archivo permitido, bloqueado y demasiado grande.
- Cuota reserva y libera correctamente.
- URL pública sirve sólo Asset/Blob públicos.
- Archivo privado no es accesible por ruta física.
- Range funciona para un video de prueba.
- Cron no se solapa y reconciliación no destruye datos.
