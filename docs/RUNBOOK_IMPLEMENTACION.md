# Runbook de implementación manual

Este documento define el orden para aplicar las plantillas cuando el hardware esté disponible. No sustituye la investigación ni la revisión de cada archivo.

## 0. Condiciones previas

- Proxmox debe instalarse directamente sobre una computadora física.
- No se permite Proxmox dentro de VirtualBox, VMware o Hyper-V.
- No se utilizará Terraform.
- Debe existir un respaldo del disco que se borrará.
- Debe confirmarse que la red `10.50.5.0/24` está libre.
- Las contraseñas y tokens se crean fuera del repositorio.

## 1. Proxmox

1. Instalar Proxmox bare-metal.
2. Registrar `pveversion -v`.
3. Confirmar el nombre real de la interfaz física.
4. Revisar `configuraciones/proxmox/interfaces.vmbr1.example`.
5. Crear `vmbr1` manualmente desde la interfaz web o la configuración nativa.
6. No aplicar la plantilla sin sustituir todos los marcadores `__...__`.
7. Subir las ISO oficiales de Ubuntu y openSUSE.
8. Crear manualmente las tres VM con los recursos documentados.

## 2. VM cliente

1. Instalar openSUSE Leap 16.0 con KDE.
2. Configurar `10.50.5.10/24` en la interfaz interna.
3. Instalar navegador, OpenSSH Client, FileZilla, cliente MySQL, `curl` y `netcat`.
4. Agregar la entrada de dominio únicamente después de decidir el nombre real.
5. Ejecutar `scripts/auditar-cliente.sh`.

## 3. Ubuntu Server base

1. Instalar Ubuntu Server 26.04.1 LTS sin entorno gráfico.
2. Registrar `/etc/os-release`.
3. Confirmar los nombres reales de las interfaces con `ip -br link`.
4. Adaptar las plantillas de `configuraciones/netplan/`.
5. Aplicar Netplan desde consola únicamente durante la fase inicial.
6. Crear usuarios administrativos y llaves SSH.
7. Mantener una sesión abierta mientras se cambia SSH al puerto 22222.
8. Probar una segunda sesión antes de cerrar el puerto 22.

## 4. UFW

1. Revisar `configuraciones/ufw/README.md`.
2. Crear primero la regla para SSH 22222.
3. Habilitar UFW.
4. Probar una sesión nueva.
5. Aplicar las demás reglas por IP de origen.
6. Guardar `ufw status verbose` como evidencia.

## 5. MySQL

1. Instalar MySQL en `lab5-db`.
2. Adaptar `configuraciones/mysql/99-lab5.cnf.example`.
3. Validar que escuche en `10.50.5.30:13306`.
4. Sustituir manualmente el marcador de contraseña en una copia local no rastreada de `init-wordpress.sql.example`.
5. Crear la base y el usuario.
6. Ejecutar `SHOW GRANTS`.
7. Probar acceso desde la VM web y rechazo desde la VM cliente.

## 6. Apache, PHP y WordPress

1. Instalar Apache, PHP, extensiones requeridas y cliente MySQL en `lab5-web`.
2. Elegir el dominio real.
3. Adaptar los VirtualHosts de `configuraciones/apache/`.
4. Descargar WordPress desde la fuente oficial.
5. Copiar y adaptar `configuraciones/wordpress/wp-config.php.example` fuera del repositorio.
6. Validar sintaxis antes de recargar Apache.
7. Completar la instalación desde openSUSE.

## 7. Permisos y SFTP

1. Crear `wpadmin` y el usuario de prueba.
2. Ejecutar primero `scripts/aplicar-permisos-wordpress.sh` sin `--apply`.
3. Revisar la ruta y la vista previa.
4. Ejecutar con `--apply` únicamente después de confirmar la ruta.
5. Probar FileZilla por SFTP.
6. Probar que el usuario sin privilegios recibe permiso denegado.

## 8. HTTPS

1. Confirmar control del dominio real.
2. Seleccionar el complemento DNS compatible con el proveedor.
3. Crear credenciales de alcance mínimo fuera del repositorio.
4. Seguir `configuraciones/certbot/DNS01.md`.
5. Adaptar el VirtualHost HTTPS.
6. Validar emisor, nombre y vigencia en el navegador.

## 9. Cierre

1. Ejecutar las tres auditorías.
2. Completar `docs/MATRIZ_EVIDENCIAS.md`.
3. Sustituir marcadores del informe y la presentación.
4. Compilar y revisar el PDF.
5. Ejecutar el runbook de demostración completo.
