# Runbook de servidores: Ubuntu, red, SSH, UFW y MySQL

Responsable: Genser. Revisor: Andrés.

Este runbook cubre `lab5-web` y `lab5-db` desde la instalación de Ubuntu hasta la conexión web → DB por `13306`. Apache, WordPress, SFTP y HTTPS quedan fuera y los hace Andrés después.

## 0. Antes de empezar

**Lo que debe estar listo de parte de Pablo.** Proxmox instalado, `vmbr1` creado con `10.50.5.1/24`, la ISO de Ubuntu Server 26.04.1 subida y las VM `lab5-web` y `lab5-db` creadas con `net0` en `vmbr0` y `net1` en `vmbr1`. Anotar el VMID de cada una y la MAC de cada interfaz desde `Hardware` en Proxmox.

**Lo que debe estar listo en openSUSE.** `lab5-cliente` con `10.50.5.10/24` en la interfaz interna y el repositorio clonado. Sin el cliente no se puede hacer la administración remota que pide la rúbrica.

**Secretos a generar antes.** Guardarlos en un gestor de contraseñas, nunca en el repositorio ni en capturas.

| Secreto | Dónde se usa | Quién más lo necesita |
|---|---|---|
| Contraseña de `labadmin` en web | `sudo` en web | Nadie |
| Contraseña de `labadmin` en DB | `sudo` en DB | Nadie |
| Contraseña root de MySQL (si se pide) | `mysql_secure_installation` | Nadie |
| Contraseña de `wpapp` | `init-wordpress.sql` y `wp-config.php` | Andrés, por canal privado |

Para generar la contraseña de `wpapp` sin caracteres que rompan el SQL o PHP:

```bash
openssl rand -base64 32 | tr -d '/+=' | cut -c1-28
```

## 1. Instalar Ubuntu Server en ambas VM

En la consola de Proxmox de cada VM.

1. Idioma inglés o español, teclado `Spanish (Latin American)` si aplica.
2. Tipo de instalación: **Ubuntu Server**, no la versión minimizada (trae menos herramientas de diagnóstico).
3. Red: dejar la interfaz de `vmbr0` en DHCP y la de `vmbr1` como está. La IP interna se configura después con Netplan.
4. Disco: usar el disco completo, sin LVM cifrado.
5. Perfil: nombre del servidor `lab5-web` o `lab5-db`, usuario `labadmin`.
6. Marcar **Install OpenSSH server**. No importar llaves.
7. No seleccionar ningún snap.
8. Reiniciar, quitar la ISO desde `Hardware → CD/DVD → Do not use any media`.

Al entrar:

```bash
cat /etc/os-release
systemctl get-default
hostnamectl
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y ufw curl netcat-openbsd qemu-guest-agent git
sudo systemctl enable --now qemu-guest-agent
```

`systemctl get-default` debe decir `multi-user.target`. Si en Proxmox `Options → QEMU Guest Agent` está desactivado, pedirle a Pablo que lo active y reiniciar la VM.

**Punto de control.** Ambas VM muestran `VERSION_ID="26.04"` y no usan `graphical.target`.

## 2. IP estática con Netplan

En cada VM identificar las interfaces comparando la MAC con la de Proxmox:

```bash
ip -br link
ip -br address
ls /etc/netplan/
```

La interfaz de `vmbr0` tiene IP por DHCP. La de `vmbr1` aparece sin IP.

El instalador deja `50-cloud-init.yaml`. Para que no compita con nuestra configuración se desactiva la red de cloud-init y se guarda el original:

```bash
echo 'network: {config: disabled}' | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo mv /etc/netplan/50-cloud-init.yaml /root/50-cloud-init.yaml.bak
```

Crear el archivo con los nombres reales en lugar de `ens18` y `ens19`:

```bash
sudo nano /etc/netplan/50-lab5.yaml
sudo chmod 600 /etc/netplan/50-lab5.yaml
```

Contenido para web (en DB cambiar a `10.50.5.30/24`):

```yaml
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: true
      dhcp6: false
    ens19:
      dhcp4: false
      dhcp6: false
      addresses:
        - 10.50.5.20/24
      optional: true
```

Aplicar con red de seguridad. `netplan try` revierte solo si no se confirma en 120 segundos.

```bash
sudo netplan generate
sudo netplan try
ip -br address
ip route
```

Debe existir una sola ruta `default` y debe salir por la interfaz de `vmbr0`.

**Punto de control.** Desde openSUSE responden las dos:

```bash
ping -c 4 10.50.5.20
ping -c 4 10.50.5.30
```

## 3. Llaves SSH desde openSUSE

Todo lo que sigue se hace desde openSUSE. La consola de Proxmox queda solo para recuperación.

```bash
ssh-keygen -t ed25519 -a 64 -f ~/.ssh/lab5_admin -C "labadmin@lab5-cliente"
ssh-copy-id -i ~/.ssh/lab5_admin.pub labadmin@10.50.5.20
ssh-copy-id -i ~/.ssh/lab5_admin.pub labadmin@10.50.5.30
ssh -i ~/.ssh/lab5_admin labadmin@10.50.5.20 hostname
ssh -i ~/.ssh/lab5_admin labadmin@10.50.5.30 hostname
```

Cada comando debe imprimir el hostname sin pedir contraseña de SSH.

Para no escribir puerto y llave en cada comando durante la demo, agregar en openSUSE `~/.ssh/config`:

```text
Host lab5-web
    HostName 10.50.5.20
    User labadmin
    Port 22222
    IdentityFile ~/.ssh/lab5_admin
    IdentitiesOnly yes

Host lab5-db
    HostName 10.50.5.30
    User labadmin
    Port 22222
    IdentityFile ~/.ssh/lab5_admin
    IdentitiesOnly yes
```

Estas entradas funcionan después del paso 4. Hasta entonces se usa el comando completo.

## 4. Mover SSH al puerto 22222

En cada VM, con una sesión SSH abierta que **no se cierra** hasta terminar el paso 5.

Traer el repositorio a la VM para tener las plantillas a mano:

```bash
git clone https://github.com/DanielBarillasM/Lab-5_escenario-de-mini-datacenter-virtualizado_Grupo-2_Redes_Sec-10.git ~/lab5
cp ~/lab5/configuraciones/lab5.env.example ~/lab5/configuraciones/lab5.env
```

Preparar la regla de firewall antes del cambio. UFW sigue inactivo, así que la regla solo queda guardada:

```bash
sudo ufw allow from 10.50.5.10 to any port 22222 proto tcp comment 'SSH desde cliente'
```

Copiar la plantilla que corresponde y sustituir `__ADMIN_USER__` por `labadmin`:

```bash
# En web
sudo cp ~/lab5/configuraciones/ssh/99-lab5.conf.example /etc/ssh/sshd_config.d/99-lab5.conf
# En DB
sudo cp ~/lab5/configuraciones/ssh/99-lab5-db.conf.example /etc/ssh/sshd_config.d/99-lab5.conf

sudo sed -i 's/__ADMIN_USER__/labadmin/' /etc/ssh/sshd_config.d/99-lab5.conf
sudo cat /etc/ssh/sshd_config.d/99-lab5.conf
sudo sshd -t
```

`sshd -t` no debe imprimir nada. Si imprime un error, corregirlo antes de seguir.

En web la línea `AllowUsers labadmin wpadmin` hace que `wpadmin` aún no exista. No es un error, Andrés lo crea después y queda habilitado automáticamente.

Aplicar. Ubuntu activa SSH por socket, por eso hace falta `daemon-reload`:

```bash
sudo systemctl daemon-reload
if systemctl is-active --quiet ssh.socket; then
    sudo systemctl restart ssh.socket
else
    sudo systemctl restart ssh.service
fi
sudo ss -lntp | grep -E ':22 |:22222 '
```

Desde **otra terminal** de openSUSE:

```bash
ssh lab5-web hostname
ssh lab5-db hostname
```

**Punto de control.** Las dos conexiones funcionan por `22222` y `ss` ya no muestra `:22`.

## 5. Activar UFW

En web:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.50.5.10 to any port 80 proto tcp comment 'HTTP desde cliente'
sudo ufw allow from 10.50.5.10 to any port 443 proto tcp comment 'HTTPS desde cliente'
sudo ufw show added
sudo ufw enable
sudo ufw status verbose
```

En DB:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.50.5.20 to any port 13306 proto tcp comment 'MySQL desde web'
sudo ufw show added
sudo ufw enable
sudo ufw status verbose
```

`ufw show added` debe listar la regla de `22222` creada en el paso 4 antes de ejecutar `enable`. Si no aparece, no habilitar.

Abrir una sesión nueva desde openSUSE (`ssh lab5-web`, `ssh lab5-db`). Solo entonces se pueden cerrar las sesiones viejas.

**Punto de control.** Cada servidor muestra `Status: active`, entrada por defecto `deny` y solo las reglas de la tabla.

| Servidor | Puerto | Origen |
|---|---:|---|
| web | 22222/TCP | 10.50.5.10 |
| web | 80/TCP | 10.50.5.10 |
| web | 443/TCP | 10.50.5.10 |
| DB | 22222/TCP | 10.50.5.10 |
| DB | 13306/TCP | 10.50.5.20 |

## 6. MySQL en lab5-db

```bash
sudo apt install -y mysql-server
sudo systemctl enable --now mysql
mysql --version
sudo mysql_secure_installation
```

Respuestas sugeridas en `mysql_secure_installation`: activar `VALIDATE PASSWORD` en nivel `MEDIUM`, eliminar usuarios anónimos, prohibir login remoto de root, eliminar la base `test` y recargar privilegios. En Ubuntu root usa `auth_socket`, así que `sudo mysql` sigue funcionando sin contraseña.

Configuración de puerto y escucha:

```bash
sudo cp ~/lab5/configuraciones/mysql/99-lab5.cnf.example /etc/mysql/mysql.conf.d/99-lab5.cnf
sudo mysqld --validate-config
sudo systemctl restart mysql
sudo ss -lntp | grep mysqld
```

Debe aparecer únicamente `10.50.5.30:13306`. No debe aparecer `3306`, `33060` ni `0.0.0.0`.

Base y usuario. La copia con la contraseña vive solo unos segundos:

```bash
install -m 600 ~/lab5/configuraciones/mysql/init-wordpress.sql.example ~/init-wordpress.sql
nano ~/init-wordpress.sql
sudo mysql < ~/init-wordpress.sql
shred -u ~/init-wordpress.sql
```

En `nano` sustituir las dos apariciones de `__REPLACE_WITH_STRONG_PASSWORD__` por la contraseña de `wpapp`.

Verificación:

```bash
sudo mysql -e "SHOW DATABASES; SELECT User, Host FROM mysql.user WHERE User='wpapp'; SHOW GRANTS FOR 'wpapp'@'10.50.5.20';"
```

**Punto de control.** Existe la base `wordpress`, `wpapp` solo tiene host `10.50.5.20` y sus privilegios son `USAGE ON *.*` más `ALL PRIVILEGES ON wordpress.*`.

## 7. Conexión desde lab5-web

Solo se instala el cliente. Apache y PHP los instala Andrés.

```bash
sudo apt install -y mysql-client
mysql --version
mysql --host=10.50.5.30 --port=13306 --user=wpapp --password wordpress \
  --execute="SELECT CURRENT_USER(), DATABASE(), @@hostname, @@port;"
```

La contraseña se escribe cuando la pide, no en la línea de comando.

Resultado esperado: `wpapp@10.50.5.20`, `wordpress`, `lab5-db`, `13306`.

Prueba de que `wpapp` no es administrador:

```bash
mysql --host=10.50.5.30 --port=13306 --user=wpapp --password \
  --execute="CREATE DATABASE prueba_no_permitida;"
```

Debe fallar con `ERROR 1044 ... Access denied`.

## 8. Pruebas negativas y auditorías

Desde openSUSE:

```bash
nc -vz -w 3 10.50.5.30 13306
nc -vz -w 3 10.50.5.20 22
nc -vz -w 3 10.50.5.30 22
nc -vz -w 3 10.50.5.30 3306
```

Las cuatro deben fallar por tiempo de espera.

Desde web:

```bash
nc -vz -w 3 10.50.5.30 13306
```

Debe decir `succeeded`.

En cada servidor completar `~/lab5/configuraciones/lab5.env` si hace falta y correr la auditoría:

```bash
sudo -v
bash ~/lab5/scripts/auditar-web.sh
bash ~/lab5/scripts/auditar-db.sh
```

`auditar-web.sh` reportará Apache inactivo y comandos faltantes hasta que Andrés termine su parte. Es esperado. `auditar-db.sh` debe terminar sin fallos.

Desde openSUSE:

```bash
bash scripts/auditar-cliente.sh
```

## 9. Evidencias de esta parte

Antes de cada captura ejecutar `hostname; date` para que quede el contexto. Ninguna captura debe mostrar contraseñas.

| Archivo | Carpeta | Comando o pantalla |
|---|---|---|
| `E04-web-ubuntu-version.png` | `03-servidores/` | `hostname; cat /etc/os-release; systemctl get-default` en web |
| `E05-db-ubuntu-version.png` | `03-servidores/` | Lo mismo en DB |
| `E06-conectividad-cliente.png` | `02-cliente/` | `ping -c 4` a `.1`, `.20` y `.30` desde openSUSE |
| `E07-ssh-web-22222.png` | `05-seguridad/` | `ssh lab5-web` y `sudo ss -lntp` en web |
| `E08-ssh-db-22222.png` | `05-seguridad/` | `ssh lab5-db` y `sudo ss -lntp` en DB |
| `E09-mysql-remoto.png` | `04-wordpress-mysql/` | Consulta del paso 7 desde web |
| `E09b-mysql-bloqueado.png` | `05-seguridad/` | `nc -vz` a `10.50.5.30 13306` desde openSUSE |
| `E09c-show-grants.png` | `04-wordpress-mysql/` | Verificación del paso 6 en DB |
| `E10-ufw-web.png` | `05-seguridad/` | `sudo ufw status verbose` en web |
| `E11-ufw-db.png` | `05-seguridad/` | `sudo ufw status verbose` en DB |

Al guardar cada una, cambiar su estado en `docs/MATRIZ_EVIDENCIAS.md` y anotar la fecha en `bitacora/contribuciones.md`.

## 10. Entrega a Andrés

Cuando el paso 8 pase, avisar a Andrés con:

**Contraseña de `wpapp`.** Por canal privado, nunca por el chat del grupo ni en Git.

**Datos de conexión.** `DB_NAME=wordpress`, `DB_USER=wpapp`, `DB_HOST=10.50.5.30:13306`.

**Estado de la VM web.** SSH en `22222` con `AllowUsers labadmin wpadmin`, UFW ya permite `80` y `443` desde el cliente y `mysql-client` ya está instalado.

## 11. Recuperación

**Se perdió el SSH.** Entrar por la consola de Proxmox de la VM, revisar `sudo sshd -t` y `sudo journalctl -u ssh -n 50`. Si hace falta, `sudo rm /etc/ssh/sshd_config.d/99-lab5.conf` y reiniciar SSH para volver al puerto 22. Anotar el problema en `bitacora/problemas.md`.

**UFW bloqueó el acceso.** Desde la consola de Proxmox, `sudo ufw disable`, corregir la regla y volver a habilitar.

**Netplan dejó la VM sin red.** Si `netplan try` no revirtió, desde la consola de Proxmox restaurar `sudo cp /root/50-cloud-init.yaml.bak /etc/netplan/50-cloud-init.yaml`, borrar `50-lab5.yaml` y ejecutar `sudo netplan apply`.

**MySQL no arranca.** `sudo journalctl -u mysql -n 50 --no-pager`. Si la causa es `99-lab5.cnf`, moverlo fuera de `/etc/mysql/mysql.conf.d/`, arrancar y corregir.

**La web no conecta a MySQL.** Revisar en este orden: `ping 10.50.5.30` desde web, `sudo ss -lntp` en DB, `sudo ufw status` en DB, y el host de `wpapp` en `mysql.user`. Un `ERROR 1130` indica que el host del usuario no coincide con `10.50.5.20`.

Cada incidente real se registra en `bitacora/problemas.md`. Esa tabla alimenta la sección de problemas del informe.
