# Runbook de demostración

## Preflight

- [ ] Proxmox y las tres VM están encendidos.
- [ ] El reloj de todos los nodos es correcto.
- [ ] El dominio resuelve desde openSUSE.
- [ ] WordPress abre por HTTPS.
- [ ] No hay actualizaciones pendientes en ejecución.
- [ ] FileZilla tiene una entrada SFTP sin contraseña visible.
- [ ] Las terminales no muestran secretos.
- [ ] La presentación HTML abre sin Internet.

## Secuencia

1. Mostrar el equipo físico y explicar la instalación bare-metal.
2. Entrar a openSUSE.
3. Abrir Proxmox desde el navegador de openSUSE.
4. Mostrar las tres VM.
5. Ejecutar conectividad hacia web y DB.
6. Abrir SSH a ambos servidores por 22222.
7. Mostrar versiones de Ubuntu.
8. Mostrar puertos en escucha y UFW.
9. Desde la VM web, conectar a MySQL por 13306.
10. Mostrar `SHOW GRANTS` de `wpapp`.
11. Probar que el cliente no llega directamente a MySQL.
12. Conectar FileZilla por SFTP.
13. Modificar `evidencia-sftp.txt`.
14. Mostrar el cambio por HTTPS.
15. Demostrar permiso denegado para el usuario no autorizado.
16. Mostrar el certificado de Let's Encrypt.
17. Mostrar `/etc/hosts` en openSUSE.

## Recuperación

- Si falla una prueba, no afirmar que funciona.
- Registrar el error exacto.
- No desactivar UFW como solución durante la presentación.
- No cambiar permisos a `777`.
- No usar la consola de Proxmox para ocultar una falla de SSH.
