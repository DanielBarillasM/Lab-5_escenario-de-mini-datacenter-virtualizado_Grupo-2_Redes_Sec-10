# Perfil SFTP de FileZilla

Configurar desde la VM openSUSE:

- Protocolo: SFTP.
- Host: `10.50.5.20`.
- Puerto: `22222`.
- Usuario: `wpadmin`.
- Autenticación: llave SSH del usuario.
- Directorio remoto: `/var/www/wordpress`.

La contraseña o llave privada no se guarda en este repositorio ni aparece en capturas.

Prueba recomendada:

1. Subir `evidencia-sftp.txt`.
2. Abrir `https://__LAB_DOMAIN__/evidencia-sftp.txt`.
3. Modificar el archivo en FileZilla.
4. Recargar el navegador.
5. Repetir como usuario no autorizado y conservar el error de permisos.
