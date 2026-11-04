# Matriz de evidencias

No se debe marcar una prueba como aprobada hasta ejecutarla sobre la infraestructura real.

| ID | Prueba | Archivo esperado | Estado | Observaciones |
|---|---|---|---|---|
| T01 | Proxmox bare-metal y versión | `E01-proxmox-version.png` | Pendiente | Requiere hardware |
| T02 | Tres VM activas | `E02-proxmox-tres-vm.png` | Pendiente | Requiere hardware |
| T03 | Ubuntu 26.04 LTS web | `E04-web-ubuntu-version.png` | Pendiente |  |
| T04 | Ubuntu 26.04 LTS DB | `E05-db-ubuntu-version.png` | Pendiente |  |
| T05 | openSUSE Leap con KDE | `E03-opensuse-version.png` | Pendiente |  |
| T06 | Conectividad desde cliente | `E06-conectividad-cliente.png` | Pendiente |  |
| T07 | SSH remoto por 22222 | `E07-ssh-remoto.png` | Pendiente | Web y DB |
| T08 | Puertos no predeterminados | `E08-puertos-listening.png` | Pendiente | 22 y 3306 deben estar cerrados |
| T09 | UFW web | `E10-ufw-web.png` | Pendiente |  |
| T10 | UFW DB | `E11-ufw-db.png` | Pendiente |  |
| T11 | MySQL desde web | `E09-mysql-remoto.png` | Pendiente | Puerto 13306 |
| T12 | MySQL bloqueado desde cliente | `E09b-mysql-bloqueado.png` | Pendiente | Prueba negativa |
| T13 | Privilegios de `wpapp` | `E09c-show-grants.png` | Pendiente | Salida sanitizada |
| T14 | WordPress en dos capas | `E14-wordpress-https.png` | Pendiente |  |
| T15 | FileZilla por SFTP | `E12-filezilla-sftp.png` | Pendiente |  |
| T16 | Permiso denegado | `E13-permiso-denegado.png` | Pendiente |  |
| T17 | Certificado Let's Encrypt | `E15-certificado-letsencrypt.png` | Pendiente |  |
| T18 | Resolución local | `E16-hosts-resolucion-local.png` | Pendiente |  |
| T19 | Administración desde openSUSE | `E17-administracion-opensuse.png` | Pendiente |  |
| T20 | Informe final | `informe/output/informe-lab5.pdf` | Borrador | Falta evidencia real |

## Criterio para cada evidencia

- Debe mostrar hostname o contexto equivalente.
- Debe incluir el comando o la interfaz que produce el resultado.
- Debe ser legible dentro del PDF.
- No debe revelar contraseñas ni tokens.
- Debe coincidir con el estado real del sistema.
