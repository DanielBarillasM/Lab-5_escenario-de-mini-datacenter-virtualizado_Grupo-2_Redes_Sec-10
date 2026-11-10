# Guía completa de demostración en vivo del Laboratorio 5

## Mini datacenter virtualizado: WordPress en arquitectura de dos capas

**Curso:** Redes, Sección 10  
**Grupo:** 2  
**Integrantes:**

- Pablo Daniel Barillas Moreno - Carné 22193.
- Genser Andreé Catalán Espina - Carné 23401.
- Andrés Rafael Chivalán Marroquín - Carné 21534.

Este documento es el procedimiento completo para preparar, ensayar y ejecutar la demostración en vivo. No sustituye el informe: organiza lo que debe verse funcionando frente al docente y explica qué demuestra cada comando.

---

## 1. Estado real antes de presentar

La implementación técnica principal está terminada:

- Proxmox VE 9.2 está instalado directamente sobre la computadora de torre.
- No se utilizó virtualización anidada ni Terraform.
- Las tres VM funcionan simultáneamente.
- `lab5-cliente` usa openSUSE Leap 16.0 con KDE.
- `lab5-web` y `lab5-db` usan Ubuntu Server 26.04.1 LTS sin entorno gráfico.
- WordPress y MySQL están separados en dos VM.
- SSH y SFTP usan `22222/TCP`.
- MySQL usa `13306/TCP` y solo permite el origen `10.50.5.20`.
- UFW está activo en ambos servidores.
- WordPress responde mediante HTTPS en `laboratorio5.com`.
- El certificado fue emitido por Let's Encrypt mediante DNS-01 y Route 53.
- Las auditorías de cliente, web y DB finalizaron con cero fallos.

## 2. Objetivo de la demostración

Al finalizar, el docente debe haber visto en vivo que:

1. Proxmox es un hipervisor Tipo 1 instalado sobre hardware físico.
2. Existen una VM cliente y dos VM servidor ejecutándose simultáneamente.
3. Las dos VM servidor usan Ubuntu Server 26.04 LTS sin interfaz gráfica.
4. Toda la administración normal se origina desde openSUSE.
5. SSH funciona en `22222/TCP` y el puerto 22 no se utiliza.
6. WordPress se encuentra en la VM web y MySQL en una VM distinta.
7. La VM web puede acceder a MySQL mediante `13306/TCP`.
8. La VM cliente no puede acceder directamente a MySQL.
9. FileZilla modifica la carpeta de WordPress mediante SFTP como `wpadmin`.
10. Un usuario no autorizado no puede escribir en esa carpeta.
11. WordPress abre mediante el nombre `laboratorio5.com`.
12. HTTP redirige hacia HTTPS.
13. El certificado pertenece al dominio y fue emitido por Let's Encrypt.
14. UFW permite únicamente los flujos requeridos.
15. Los tres integrantes comprenden la arquitectura completa.

La demostración debe mostrar resultados, no solamente configuraciones. No basta con enseñar una regla de UFW: también hay que comprobar un acceso permitido y uno bloqueado.

---

## 3. Arquitectura que todos deben poder explicar

```text
Computadora física dedicada
└── Proxmox VE 9.2, Tipo 1, sin hipervisor intermedio
    └── vmbr1: 10.50.5.0/24
        ├── 10.50.5.10  lab5-cliente  openSUSE Leap 16.0 + KDE
        ├── 10.50.5.20  lab5-web      Ubuntu Server 26.04.1
        └── 10.50.5.30  lab5-db       Ubuntu Server 26.04.1
```

### 3.1 Flujos permitidos

| Origen | Destino | Puerto | Propósito |
|---|---|---:|---|
| `10.50.5.10` | `10.50.5.20` | `22222/TCP` | SSH y SFTP hacia web |
| `10.50.5.10` | `10.50.5.30` | `22222/TCP` | SSH hacia DB |
| `10.50.5.10` | `10.50.5.20` | `80/TCP` | Redirección HTTP a HTTPS |
| `10.50.5.10` | `10.50.5.20` | `443/TCP` | WordPress mediante HTTPS |
| `10.50.5.20` | `10.50.5.30` | `13306/TCP` | WordPress y cliente MySQL |

### 3.2 Flujo que debe estar bloqueado

```text
10.50.5.10 (cliente) -X-> 10.50.5.30:13306 (MySQL)
```

La restricción de MySQL se sostiene mediante tres controles:

1. MySQL escucha en la IP interna `10.50.5.30` y no en una interfaz pública.
2. UFW permite `13306/TCP` solamente desde `10.50.5.20`.
3. El usuario es `wpapp@10.50.5.20` y solo tiene privilegios sobre `wordpress.*`.

---

## 4. Reparto sugerido entre integrantes

El docente puede preguntarle cualquier tema a cualquier integrante. El reparto mantiene el orden, pero no divide el conocimiento.

| Integrante | Parte principal | Tiempo objetivo |
|---|---|---:|
| Pablo | Introducción, Proxmox, Tipo 1, VM y red | 4 minutos |
| Genser | SSH, Ubuntu, MySQL, UFW y pruebas de red | 6 minutos |
| Andrés | SFTP, permisos, WordPress, dominio y HTTPS | 6 minutos |
| Los tres | Conclusiones y preguntas | 2 a 4 minutos |

Duración recomendada: **18 minutos**, sin incluir preguntas. Si el docente limita el tiempo a 10 minutos, utilizar la ruta abreviada de la sección 16.

### 4.1 Transiciones sugeridas

- Pablo: “Ya comprobamos la infraestructura física y las tres VM; ahora Genser mostrará cómo se administran y cómo se comunica la capa web con la base de datos”.
- Genser: “La red y la base de datos ya están verificadas; Andrés demostrará el control de archivos y la publicación segura del sitio”.
- Andrés: “Con HTTPS, SFTP y permisos demostrados, cerramos mostrando que todas las pruebas automáticas terminan sin fallos”.

---

## 5. Preparación el día anterior

### 5.1 Torre Proxmox

- [ ] La torre enciende sin USB de instalación conectado.
- [ ] Proxmox inicia directamente desde el disco físico.
- [ ] El cable Ethernet está conectado al router correcto.
- [ ] La interfaz web de Proxmox responde.
- [ ] El nodo `pve` no muestra alertas críticas.
- [ ] Hay espacio libre suficiente en `local` y `local-lvm`.
- [ ] Las VM 101, 102 y 103 pueden encenderse simultáneamente.

### 5.2 Máquinas virtuales

- [ ] VM 101 `lab5-web`: encendida.
- [ ] VM 102 `lab5-db`: encendida.
- [ ] VM 103 `lab5-cliente`: encendida.
- [ ] Las IP internas continúan siendo `.20`, `.30` y `.10`.
- [ ] No hay una actualización o reinicio pendiente ejecutándose.
- [ ] La fecha y hora son correctas.

### 5.3 Cliente openSUSE

Desde Konsole:

```bash
hostname
ip -br address
ip route
date
```

Se espera ver `lab5-cliente`, la dirección `10.50.5.10/24` y la fecha correcta.

### 5.4 Llaves, sin mostrar su contenido

```bash
ls -l ~/.ssh/lab5_admin ~/.ssh/lab5_admin.pub \
      ~/.ssh/lab5_wpadmin ~/.ssh/lab5_wpadmin.pub
stat -c '%a %n' ~/.ssh/lab5_admin ~/.ssh/lab5_wpadmin
```

Las llaves privadas deben tener permiso `600`. Nunca ejecutar `cat` sobre una llave privada.

### 5.5 Ejecutar las tres auditorías

En openSUSE:

```bash
cd ~/lab5
bash scripts/auditar-cliente.sh
```

En web, entrando desde openSUSE:

```bash
ssh -i ~/.ssh/lab5_admin -p 22222 labadmin@10.50.5.20
cd ~/lab5
bash scripts/auditar-web.sh
exit
```

En DB, entrando desde openSUSE:

```bash
ssh -i ~/.ssh/lab5_admin -p 22222 labdb@10.50.5.30
cd ~/lab5
bash scripts/auditar-db.sh
exit
```

Cada auditoría debe terminar con `Fallos: 0`.

Si falta `configuraciones/lab5.env`, copiar localmente el ejemplo y cambiar `LAB_DOMAIN` a `laboratorio5.com`. El archivo real está ignorado por Git y no debe publicarse.

### 5.6 Comprobar el sitio

```bash
getent hosts laboratorio5.com
curl --connect-timeout 3 --max-time 10 -I http://laboratorio5.com/
curl --connect-timeout 3 --max-time 10 -I https://laboratorio5.com/
```

Resultados esperados:

- El dominio resuelve hacia `10.50.5.20`.
- HTTP responde `301` o `302` y redirige a HTTPS.
- HTTPS responde `200 OK`.

### 5.7 Ensayar FileZilla

- [ ] Protocolo SFTP, no FTP.
- [ ] Host `10.50.5.20`.
- [ ] Puerto `22222`.
- [ ] Usuario `wpadmin`.
- [ ] Llave `lab5_wpadmin`.
- [ ] Ruta remota `/var/www/wordpress`.
- [ ] Ninguna contraseña visible.

### 5.8 Congelar cambios

Después de un ensayo exitoso:

- No ejecutar `apt upgrade`, `zypper dup` ni actualizaciones de Proxmox.
- No cambiar IP, llaves, UFW, permisos ni certificado.
- No instalar complementos innecesarios de WordPress.

---

## 6. Preparación 30 minutos antes

### 6.1 Orden de encendido

1. Encender router y equipo de red.
2. Encender la torre Proxmox.
3. Esperar que la interfaz web responda.
4. Encender `lab5-db` y esperar aproximadamente un minuto.
5. Encender `lab5-web` y esperar aproximadamente un minuto.
6. Encender `lab5-cliente`.
7. Iniciar sesión en openSUSE.

DB se inicia antes que web para que WordPress encuentre MySQL desde el primer acceso.

### 6.2 Ventanas preparadas en openSUSE

1. Firefox con la interfaz de Proxmox.
2. Firefox con `https://laboratorio5.com`.
3. Pestaña preparada para detalles del certificado.
4. Konsole, pestaña **CLIENTE**.
5. Konsole, pestaña **WEB**.
6. Konsole, pestaña **DB**.
7. FileZilla listo para abrirse.

Titular las pestañas y ejecutar `clear` evita confundir contextos o mostrar información anterior.

### 6.3 Presentación HTML

Abrir `presentacion/index.html` o servirla desde Windows:

```powershell
node .\scripts\servir-presentacion.mjs
```

Comprobar navegación, pantalla completa e imágenes. La presentación puede mostrarse desde la laptop, pero las acciones técnicas deben originarse en openSUSE.

---

## 7. Inicio de la exposición

### Paso 1. Portada y propósito

**Responsable:** Pablo. **Tiempo:** 45 segundos.

> “Implementamos un mini datacenter virtualizado para publicar WordPress en una arquitectura de dos capas. La infraestructura corre sobre Proxmox VE instalado directamente en una computadora física. Separamos Apache, PHP y WordPress de MySQL, y administramos ambas VM remotamente desde una tercera VM openSUSE”.

Mencionar tres integrantes, dos capas, una VM cliente, Proxmox Tipo 1, sin Terraform y sin virtualización anidada.

### Paso 2. Tipo 1 frente a Tipo 2

> “Un hipervisor Tipo 1 se instala sobre el hardware. En un Tipo 2, como VirtualBox, primero existiría un sistema operativo anfitrión. Aquí la torre arranca directamente en Proxmox, por lo que no hay Windows ni otro hipervisor debajo”.

Proxmox fue elegido porque está admitido por la guía, usa KVM/QEMU, ofrece administración web y permite construir puentes virtuales.

---

## 8. Proxmox y las tres VM

### Paso 3. Mostrar el equipo físico

Señalar la torre como host Proxmox. La laptop no es el host del laboratorio.

### Paso 4. Mostrar Proxmox desde openSUSE

En Firefox dentro de `lab5-cliente`, mostrar el nodo `pve` y las VM 101, 102 y 103 encendidas.

> “La interfaz se abre desde la VM cliente. Las tres VM corren en el mismo host Tipo 1 y están conectadas por `vmbr1`”.

Si está disponible la Shell del nodo desde la interfaz web:

```bash
hostname
pveversion
systemd-detect-virt
```

Se espera `pve`, Proxmox VE 9.2 y ausencia de un hipervisor superior. No administrar Ubuntu desde sus consolas de Proxmox.

### Paso 5. Mostrar `vmbr1`

Abrir **pve > System > Network** y señalar `vmbr0`, `vmbr1` y `10.50.5.1/24`.

> “El direccionamiento estático permite escribir reglas por origen y hace reproducibles las pruebas”.

---

## 9. Cliente openSUSE

### Paso 6. Sistema, GUI e IP

```bash
hostname
cat /etc/os-release | grep -E '^(NAME|VERSION|VERSION_ID)='
echo "$XDG_CURRENT_DESKTOP"
ip -br address
```

Se espera `lab5-cliente`, openSUSE Leap 16.0, KDE/Plasma y `10.50.5.10/24`.

> “Elegimos openSUSE Leap porque es una distribución distinta de Ubuntu, ofrece KDE y dispone de SSH, FileZilla, navegador, curl y netcat”.

### Paso 7. Conectividad IP

```bash
ping -c 2 10.50.5.1
ping -c 2 10.50.5.20
ping -c 2 10.50.5.30
```

Se espera cero pérdida. Aclarar que ping prueba IP, pero no la disponibilidad de cada aplicación.

---

## 10. Administración remota por SSH

### Paso 8. Entrar a web

```bash
ssh -i ~/.ssh/lab5_admin -p 22222 labadmin@10.50.5.20
hostname
cat /etc/os-release | grep -E '^(PRETTY_NAME|VERSION_ID)='
systemctl get-default
who
```

Se espera `lab5-web`, Ubuntu 26.04.1, `multi-user.target` y una sesión procedente de `10.50.5.10`.

### Paso 9. SSH y Apache en web

```bash
systemctl is-active ssh
systemctl is-active apache2
sudo ss -lntp | grep -E ':(22222|80|443)\b'
sudo ufw status verbose
sudo ss -lntp | grep -E ':22\b' || echo 'OK: puerto SSH 22 cerrado'
```

Se espera SSH y Apache activos, escucha en 22222/80/443, UFW activo y puerto 22 cerrado. Mantener esta sesión abierta.

### Paso 10. Entrar a DB en otra pestaña

```bash
ssh -i ~/.ssh/lab5_admin -p 22222 labdb@10.50.5.30
hostname
cat /etc/os-release | grep -E '^(PRETTY_NAME|VERSION_ID)='
systemctl get-default
systemctl is-active mysql
```

Se espera `lab5-db`, Ubuntu 26.04.1, `multi-user.target` y MySQL activo.

> “Las dos sesiones se originaron desde openSUSE, usan llaves y el puerto 22222; no usamos la consola del hipervisor”.

---

## 11. MySQL como segunda capa

### Paso 11. Escucha y firewall en DB

```bash
sudo ss -lntp | grep -E ':(22222|13306|22|3306|33060)\b'
sudo ufw status verbose
sudo mysql -NBe "SHOW VARIABLES LIKE 'bind_address'; SHOW VARIABLES LIKE 'port';"
```

Se espera SSH en 22222, MySQL en `10.50.5.30:13306`, ausencia de 22/3306/33060 y UFW permitiendo 13306 solamente desde `10.50.5.20`.

### Paso 12. Privilegios de WordPress

```bash
sudo mysql -NBe "SHOW GRANTS FOR 'wpapp'@'10.50.5.20';"
```

Debe mostrar privilegios sobre `wordpress.*`, no `*.*`.

> “El usuario de la aplicación no es administrador: está ligado a la IP web y solo opera la base `wordpress`”.

### Paso 13. Prueba positiva desde web

En la pestaña SSH de `lab5-web`:

```bash
nc -vz -w 3 10.50.5.30 13306
mysql -h 10.50.5.30 -P 13306 -u wpapp -p \
  -e "SELECT @@hostname AS servidor, @@port AS puerto, DATABASE() AS base_actual; SHOW TABLES;" \
  wordpress
```

Escribir la contraseña cuando la solicite; nunca colocarla en el comando. Se esperan `lab5-db`, 13306, `wordpress` y tablas `wp_`.

### Paso 14. Prueba negativa desde openSUSE

Fuera de cualquier sesión SSH:

```bash
hostname
nc -vz -w 3 10.50.5.30 13306
```

Debe fallar.

> “El mismo puerto que funcionó desde web está bloqueado desde el cliente. La política depende del origen”.

---

## 12. SFTP y permisos

### Paso 15. Crear el archivo de prueba

```bash
printf 'Laboratorio 5 - Grupo 2 - carga SFTP - %s\n' "$(date -Iseconds)" \
  > ~/evidencia-sftp.txt
cat ~/evidencia-sftp.txt
```

### Paso 16. Conectar FileZilla

Mostrar:

- Protocolo SFTP.
- Host `10.50.5.20`.
- Puerto `22222`.
- Usuario `wpadmin`.
- Llave `~/.ssh/lab5_wpadmin`.

Conectar, abrir `/var/www/wordpress` y subir `evidencia-sftp.txt`.

### Paso 17. Comprobar por HTTPS

Abrir en Firefox:

```text
https://laboratorio5.com/evidencia-sftp.txt
```

Debe aparecer la línea con la fecha actual.

> “La transferencia viajó cifrada dentro de SSH. No abrimos FTP ni puertos adicionales”.

### Paso 18. Mostrar `chown` y `chmod`

En web:

```bash
sudo stat -c '%U %G %a %n' \
  /var/www/wordpress \
  /var/www/wordpress/index.php \
  /var/www/wordpress/evidencia-sftp.txt
```

Se esperan directorios `wpadmin:www-data 750` y archivos `wpadmin:www-data 640`.

- 750: propietario `rwx`, grupo `r-x`, otros sin acceso.
- 640: propietario `rw-`, grupo `r--`, otros sin acceso.
- Apache lee como `www-data`; solo `wpadmin` escribe normalmente.

### Paso 19. Prueba negativa de escritura

```bash
sudo -u wpviewer touch /var/www/wordpress/no-debe-crearse.txt
test ! -e /var/www/wordpress/no-debe-crearse.txt \
  && echo 'OK: el usuario no autorizado no pudo escribir'
```

El primer comando debe responder `Permission denied` y el segundo confirmar que no existe el archivo. Nunca usar `chmod 777`.

### Paso 20. Limpieza

Después de que el docente vea el resultado, `wpadmin` puede borrar `evidencia-sftp.txt` desde FileZilla.

---

## 13. Nombre local, WordPress y HTTPS

### Paso 21. Resolución local

```bash
grep -n 'laboratorio5.com' /etc/hosts
getent hosts laboratorio5.com
```

Se espera `10.50.5.20 laboratorio5.com`.

> “Route 53 demuestra control del dominio durante DNS-01. `/etc/hosts` lleva el navegador a la IP privada dentro del laboratorio. Cumplen funciones diferentes”.

### Paso 22. Redirección HTTP

```bash
curl --connect-timeout 3 --max-time 10 -sS -o /dev/null -D - \
  http://laboratorio5.com/ | grep -Ei '^(HTTP/|Location:)'
```

Se espera 301/302 y `Location: https://laboratorio5.com/...`.

### Paso 23. Respuesta HTTPS

```bash
curl --connect-timeout 3 --max-time 10 -I https://laboratorio5.com/
```

Se espera `HTTP/1.1 200 OK`.

### Paso 24. Abrir WordPress

Abrir `https://laboratorio5.com` y mostrar título “Grupo 2”, dominio e indicador seguro. No usar la IP porque el certificado pertenece al nombre.

### Paso 25. Certificado

En Firefox, abrir los detalles de seguridad y mostrar dominio, emisor Let's Encrypt y vigencia.

Comprobación opcional:

```bash
openssl s_client -connect laboratorio5.com:443 \
  -servername laboratorio5.com </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
```

### Paso 26. Explicar DNS-01

> “Let's Encrypt no podía validar una IP privada mediante HTTP desde Internet. Certbot creó temporalmente un TXT `_acme-challenge` en Route 53. El certificado instalado en Apache es real y no autofirmado”.

Nunca mostrar `/root/.aws/credentials`, Access Key ID, Secret Access Key, tokens ni `privkey.pem`.

---

## 14. Auditorías finales en vivo

Si queda tiempo, ejecutar los tres scripts; si no, mostrar sus resúmenes.

```bash
# Cliente
cd ~/lab5
bash scripts/auditar-cliente.sh

# Web, dentro de su sesión SSH
cd ~/lab5
bash scripts/auditar-web.sh

# DB, dentro de su sesión SSH
cd ~/lab5
bash scripts/auditar-db.sh
```

Los tres deben terminar con cero fallos. En conjunto comprueban SO, puertos, servicios, UFW, conectividad, bloqueo MySQL, resolución y HTTPS.

---

## 15. Cierre sugerido

> “El laboratorio cumple la arquitectura de dos capas y añade Proxmox Tipo 1 sobre hardware físico. La comunicación necesaria funciona: cliente a web por HTTPS y SSH, web a DB por 13306. Los flujos no autorizados fallan: el cliente no entra directamente a MySQL y `wpviewer` no modifica WordPress. El sitio usa un certificado real de Let's Encrypt, y toda la administración normal se realizó desde openSUSE”.

Conclusiones que cualquiera debe desarrollar:

1. Separar web y DB permite controles distintos por capa.
2. UFW no sustituye permisos, identidad ni restricciones de aplicación.
3. Las pruebas negativas demuestran seguridad mejor que una captura de configuración.
4. SFTP reutiliza SSH y evita abrir FTP.
5. DNS-01 permite emitir certificados para un servidor con IP privada.
6. Un hipervisor Tipo 1 elimina la capa de un sistema operativo anfitrión.

---

## 16. Ruta abreviada de 10 minutos

| Minuto | Acción |
|---:|---|
| 0:00-1:00 | Objetivo, arquitectura y Proxmox Tipo 1 |
| 1:00-2:00 | Tres VM y `vmbr1` |
| 2:00-3:00 | openSUSE, ping y SSH a web/DB |
| 3:00-5:00 | MySQL 13306: éxito desde web y fallo desde cliente |
| 5:00-7:00 | FileZilla: subir archivo y abrirlo por HTTPS |
| 7:00-8:00 | Permisos 750/640 y fallo de `wpviewer` |
| 8:00-9:00 | Dominio local, HTTPS y certificado |
| 9:00-10:00 | UFW, cero fallos y conclusión |

No leer las diapositivas completas. Las diapositivas orientan; las pruebas en vivo califican.

---

## 17. Relación con la rúbrica

| Criterio | Puntos | Evidencia en vivo | Pasos |
|---|---:|---|---:|
| Despliegue en dos capas | 1.50 | Ping, SSH, MySQL permitido y bloqueado | 7-14 |
| Versiones apropiadas | 0.50 | Ubuntu 26.04.1 y `multi-user.target` | 8 y 10 |
| Gestión remota por SSH | 1.00 | Dos sesiones desde openSUSE por 22222 | 8-10 |
| SFTP y FileZilla | 1.50 | Carga real en `/var/www/wordpress` | 15-17 |
| Permisos y restricción | 1.50 | 750/640, escritura positiva y fallo de `wpviewer` | 18-19 |
| HTTPS y firewall | 2.00 | Certificado, redirección, UFW y pruebas por origen | 9, 11, 14, 22-26 |
| Resolución local | 0.50 | `/etc/hosts`, `getent` y acceso por nombre | 21 |
| Calidad del informe | 1.50 | PDF reproducible y coherente | Antes de exponer |
| Proxmox Tipo 1 | 4.00 extra | Torre física, Proxmox directo y cliente GUI | 3-5 |

Total posible según la rúbrica: 10 puntos base y 4 puntos extra, sujetos a la evaluación del docente.

---

## 18. Preguntas probables

### ¿Por qué MySQL está en otra VM?

Porque el objetivo es una arquitectura de dos capas. La separación permite aplicar controles diferentes y demostrar comunicación cliente-servidor.

### ¿Por qué 13306?

Para evitar el puerto conocido 3306. No reemplaza UFW ni autenticación; es una capa adicional.

### ¿Por qué no UDP para SSH o MySQL?

Ambos servicios utilizan TCP. Abrir UDP aumentaría superficie de ataque sin funcionalidad.

### ¿Por qué el cliente no entra a MySQL?

Solo WordPress necesita ese flujo. UFW permite `10.50.5.20 -> 10.50.5.30:13306` y niega otros orígenes.

### ¿Diferencia entre `wpadmin` y `wpapp`?

`wpadmin` es el usuario Linux que modifica archivos por SFTP; `wpapp` es el usuario MySQL usado por WordPress sobre `wordpress.*`.

### ¿Por qué Apache lee archivos 640?

Porque pertenecen a `wpadmin:www-data`; Apache trabaja como `www-data` y el grupo tiene lectura.

### ¿Por qué no 777?

Otorgaría acceso excesivo y violaría el requisito de que solo el administrador designado escriba.

### ¿Por qué SFTP y no FTP?

SFTP cifra autenticación y contenido mediante SSH y no necesita puertos adicionales.

### ¿Por qué Route 53 si la resolución es local?

Route 53 demuestra control para DNS-01; `/etc/hosts` dirige el nombre a la IP privada dentro del laboratorio.

### ¿Por qué Let's Encrypt confía en un servidor privado?

DNS-01 valida un TXT público y no necesita conectarse por HTTP al servidor privado.

### ¿Qué diferencia hay entre UFW y `bind-address`?

`bind-address` decide dónde escucha MySQL; UFW decide qué origen alcanza el puerto. Ambos forman defensa en profundidad.

### ¿Por qué Proxmox es Tipo 1?

La torre arranca directamente en Proxmox; no existe Windows, VirtualBox o VMware debajo.

### ¿Por qué openSUSE?

La opción extra requiere otra distribución Linux con GUI. Leap ofrece KDE y las herramientas cliente necesarias.

### ¿Usaron Terraform?

No. Las VM y redes se crearon manualmente según la aclaración del docente.

### ¿Qué pasa si DB se apaga?

Apache puede seguir activo, pero WordPress pierde los datos y muestra error de conexión, evidenciando la dependencia entre capas.

---

## 19. Contingencias

### WordPress no abre

```bash
getent hosts laboratorio5.com
ping -c 2 10.50.5.20
nc -vz -w 3 10.50.5.20 443
curl -I https://laboratorio5.com/
```

En web:

```bash
systemctl is-active apache2
sudo apache2ctl configtest
sudo ss -lntp | grep -E ':(80|443)\b'
```

Solo reiniciar Apache si `configtest` responde `Syntax OK`.

### Error de base de datos

Desde web:

```bash
nc -vz -w 3 10.50.5.30 13306
```

Desde DB:

```bash
systemctl is-active mysql
sudo ss -lntp | grep 13306
sudo ufw status verbose
```

No mostrar `wp-config.php` porque contiene una contraseña.

### SSH falla

```bash
ping -c 2 10.50.5.20
nc -vz -w 3 10.50.5.20 22222
ssh -vv -i ~/.ssh/lab5_admin -p 22222 labadmin@10.50.5.20
```

Usar `-vv` solo para diagnóstico. No regenerar llaves durante la presentación.

### FileZilla no conecta

Revisar protocolo SFTP, puerto 22222, usuario `wpadmin`, llave `lab5_wpadmin` y `nc -vz 10.50.5.20 22222`. No cambiar a FTP.

### Dominio no resuelve

```bash
grep -n 'laboratorio5.com' /etc/hosts
getent hosts laboratorio5.com
```

Debe existir `10.50.5.20 laboratorio5.com`.

### MySQL resulta accesible desde cliente

Detener ese criterio y revisar desde DB:

```bash
sudo ufw status numbered
```

La regla 13306 debe permitir solo `10.50.5.20`. No desactivar UFW ni afirmar que el bloqueo funciona si la prueba dice lo contrario.

### Regla de honestidad

Si algo falla: leer el error, identificar la capa, ejecutar una prueba pequeña y corregir solo si se conoce la causa. No usar capturas antiguas como sustituto de una función que no opera en vivo.

---

## 20. Acciones prohibidas durante la demostración

- No mostrar contraseñas, credenciales AWS, llaves privadas ni `privkey.pem`.
- No abrir `/root/.aws/credentials` ni `wp-config.php` completo.
- No ejecutar `chmod -R 777` ni desactivar UFW.
- No abrir 3306 para “hacer que funcione”.
- No administrar Ubuntu desde la consola Proxmox salvo recuperación real y explicada.
- No presentar Proxmox dentro de VirtualBox.
- No afirmar que se utilizó Terraform.
- No instalar actualizaciones.
- No ejecutar `certbot renew --dry-run` si el tiempo o Internet son inestables; usar la evidencia ya registrada.

---

## 21. Checklist de cinco minutos antes

- [ ] El sitio responde por HTTPS y no hay información sensible visible.
- [ ] Torre, router y laptop tienen alimentación.
- [ ] Proxmox y las tres VM están activos.
- [ ] openSUSE conserva `10.50.5.10`.
- [ ] Web y DB responden en `.20` y `.30`.
- [ ] SSH funciona a ambos por 22222.
- [ ] MySQL funciona desde web y falla desde cliente.
- [ ] WordPress responde 200 por HTTPS.
- [ ] HTTP redirige a HTTPS.
- [ ] FileZilla está listo con SFTP.
- [ ] `evidencia-sftp.txt` está preparado.
- [ ] Terminales limpias y tituladas.
- [ ] No hay secretos visibles.
- [ ] La presentación HTML funciona sin Internet.
- [ ] Cada integrante sabe su primera y última frase.

---

## 22. Después de presentar

- [ ] Borrar `evidencia-sftp.txt` si ya no se necesita.
- [ ] Cerrar FileZilla y sesiones SSH.
- [ ] Guardar observaciones del docente en la bitácora.
- [ ] Apagar las VM desde sus sistemas operativos.
- [ ] Apagar Proxmox desde **pve > Shutdown** después de detener las VM.
- [ ] Esperar que la torre se apague antes de desconectar energía o red.

---

## 23. Criterio final de “listo para presentar”

1. El sitio responde por HTTPS y la evidencia utilizada no revela información sensible.
2. Las tres auditorías terminan con cero fallos.
3. Los pasos 3 al 26 pueden repetirse desde openSUSE.
4. El informe fue recompilado después de la última evidencia.
5. La presentación HTML carga todas sus imágenes.
6. Ninguna pantalla revela secretos.
7. Los tres integrantes responden las preguntas de la sección 18.
8. El ensayo completo cabe en el tiempo asignado.

Si una condición no se cumple, debe registrarse como pendiente y corregirse antes de la presentación.
