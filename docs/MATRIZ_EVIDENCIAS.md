# Matriz de evidencias

Todas las pruebas principales fueron ejecutadas sobre la infraestructura real. Las rutas son relativas a `evidencias/`.

| ID | Prueba | Archivo principal | Estado | Resultado |
|---|---|---|---|---|
| T01 | Proxmox bare-metal y versión | `01-proxmox/E01-proxmox-version.jpeg` | Aprobada | Consola `root@pve`, Proxmox VE 9.2 |
| T02 | Tres VM activas | `01-proxmox/E02-proxmox-tres-vm.png` | Aprobada | VM 101, 102 y 103 simultáneas |
| T03 | Ubuntu 26.04 LTS web | `03-servidores/E04-web-ubuntu-version.png` | Aprobada | Ubuntu 26.04.1, `multi-user.target` |
| T04 | Ubuntu 26.04 LTS DB | `03-servidores/E05-db-ubuntu-version.png` | Aprobada | Ubuntu 26.04.1, `multi-user.target` |
| T05 | openSUSE Leap con KDE | `02-cliente/E03-opensuse-version.png` | Aprobada | Leap 16.0, Plasma 6.4.2 |
| T06 | Conectividad desde cliente | `02-cliente/E06-conectividad-cliente.png` | Aprobada | Cliente alcanza `.1`, `.20` y `.30` |
| T07 | SSH remoto por 22222 | `05-seguridad/E07-ssh-web-22222.png`, `E08-ssh-db-22222.png` | Aprobada | Web y DB administrables con llave |
| T08 | Puertos no predeterminados | `05-seguridad/E08b-validacion-ssh-db-con-ufw.png` | Aprobada | 22, 3306 y 33060 cerrados |
| T09 | UFW web | `05-seguridad/E10-ufw-web.png` | Aprobada | Reglas limitadas a cliente |
| T10 | UFW DB | `05-seguridad/E11-ufw-db.png` | Aprobada | MySQL solo desde web |
| T11 | MySQL desde web | `04-wordpress-mysql/E09-mysql-remoto.png` | Aprobada | Conexión positiva por 13306 |
| T12 | MySQL bloqueado desde cliente | `05-seguridad/E09b-mysql-bloqueado.png` | Aprobada | Prueba negativa correcta |
| T13 | Privilegios de `wpapp` | `04-wordpress-mysql/E09c-show-grants.png` | Aprobada | Limitado a `wordpress.*` |
| T14 | WordPress en dos capas | `04-wordpress-mysql/E14-wordpress-https.png` | Aprobada | Sitio HTTPS operativo |
| T15 | FileZilla por SFTP | `05-seguridad/E12-filezilla-sftp.png` | Aprobada | `wpadmin` accede por 22222 |
| T16 | Permiso denegado | `05-seguridad/E13-permiso-denegado.png` | Aprobada | Usuario no autorizado bloqueado |
| T17 | Certificado Let's Encrypt | `05-seguridad/E15-certificado-letsencrypt.png` | Aprobada | CN/SAN, emisor y vigencia válidos |
| T18 | Resolución local | `02-cliente/E16-hosts-resolucion-local.png` | Aprobada | DNS local, 301 y HTTPS 200 |
| T19 | Administración desde openSUSE | `02-cliente/E17-administracion-opensuse.png` | Aprobada | SSH y servicios comprobados desde cliente |
| T20 | Informe final | `informe/output/informe-lab5.pdf` | Aprobada | PDF compilado y revisado |

## Criterios de calidad

- Mostrar hostname o contexto equivalente.
- Incluir el comando o la interfaz que produce el resultado.
- Ser legible dentro del informe y la presentación.
- No revelar contraseñas, tokens, llaves privadas ni datos personales innecesarios.
- Coincidir con el estado real del sistema.
- Mantener duplicados e históricos fuera de las rutas principales.
