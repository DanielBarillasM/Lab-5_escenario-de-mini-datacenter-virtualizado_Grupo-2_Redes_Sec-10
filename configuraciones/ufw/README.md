# Reglas UFW

Ejecutar manualmente y revisar cada origen. Estas instrucciones asumen la red interna propuesta.

## VM web

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.50.5.10 to any port 22222 proto tcp comment 'SSH-SFTP desde cliente'
sudo ufw allow from 10.50.5.10 to any port 80 proto tcp comment 'HTTP redireccion'
sudo ufw allow from 10.50.5.10 to any port 443 proto tcp comment 'HTTPS desde cliente'
sudo ufw enable
sudo ufw status verbose
```

## VM base de datos

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.50.5.10 to any port 22222 proto tcp comment 'SSH desde cliente'
sudo ufw allow from 10.50.5.20 to any port 13306 proto tcp comment 'MySQL desde web'
sudo ufw enable
sudo ufw status verbose
```

## Pruebas negativas

- Desde openSUSE, `10.50.5.30:13306` debe estar bloqueado.
- Desde la VM web, `10.50.5.30:13306` debe aceptar conexión.
- Ningún servidor debe escuchar SSH en el puerto 22.

No habilitar UFW antes de permitir y probar SSH en 22222.
