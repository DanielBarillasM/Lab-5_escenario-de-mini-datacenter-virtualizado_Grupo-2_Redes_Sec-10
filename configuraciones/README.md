# Plantillas de configuración

Estas plantillas no se aplican automáticamente. Cada archivo contiene valores propuestos o marcadores que deben validarse contra el sistema real.

## Orden

1. `lab5.env.example`: referencia común para scripts de auditoría.
2. `proxmox/`: puente interno de Proxmox.
3. `netplan/`: red estática de los dos Ubuntu Server.
4. `ssh/`: puerto y endurecimiento de OpenSSH.
5. `ufw/`: reglas por origen.
6. `mysql/`: escucha y usuario de WordPress.
7. `apache/`: VirtualHosts HTTP y HTTPS.
8. `wordpress/`: plantilla sanitizada de `wp-config.php`.
9. `opensuse/`: resolución local de nombres.
10. `certbot/`: emisión DNS-01.

## Marcadores

Los valores con formato `__NOMBRE__` deben sustituirse antes de aplicar una copia. El dominio `lab5.example.invalid` nunca producirá un certificado real y se usa para impedir aplicaciones accidentales.

## Validación mínima

- Proxmox: revisar la interfaz física y conservar acceso antes de reiniciar red.
- Netplan: usar `netplan try` antes de `netplan apply`.
- SSH: usar `sshd -t` y mantener una sesión abierta.
- Apache: usar `apache2ctl configtest`.
- MySQL: revisar logs y `ss -lntp` después de reiniciar.
- UFW: crear la regla SSH antes de habilitarlo.

No guardar secretos en esta carpeta.
