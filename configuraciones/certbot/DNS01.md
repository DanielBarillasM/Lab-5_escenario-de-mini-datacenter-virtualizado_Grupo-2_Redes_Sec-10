# Certificado Let's Encrypt mediante DNS-01

## Datos pendientes

- Dominio real: `__LAB_DOMAIN__`.
- Proveedor DNS: `__DNS_PROVIDER__`.
- Complemento Certbot: `__CERTBOT_DNS_PLUGIN__`.
- Ruta local de credenciales: fuera del repositorio.

## Procedimiento

1. Confirmar que el equipo controla la zona DNS.
2. Crear un token de alcance mínimo capaz de modificar el TXT de `_acme-challenge`.
3. Instalar Certbot y el complemento oficial o mantenido para el proveedor.
4. Guardar las credenciales fuera del repositorio con modo `600`.
5. Consultar la ayuda del complemento instalado.
6. Ejecutar primero contra el entorno de staging de Let's Encrypt.
7. Solicitar el certificado de producción cuando staging funcione.
8. Configurar Apache con las rutas generadas.
9. Probar renovación con `certbot renew --dry-run`.

Ejemplo conceptual, no ejecutable hasta sustituir el complemento y la ruta:

```bash
sudo certbot certonly \
  --dns-__PROVIDER__ \
  --dns-__PROVIDER__-credentials /root/.secrets/certbot.ini \
  -d __LAB_DOMAIN__
```

No usar `--manual` como solución final si el equipo necesita renovación automática. No publicar tokens ni el contenido del archivo de credenciales.
