# Estado de implementación

Actualizado: 10 de noviembre de 2026.

## Resultado general

La infraestructura fue implementada sobre hardware físico y las pruebas principales fueron ejecutadas. El informe y la presentación utilizan evidencia real clasificada en `evidencias/`.

## Infraestructura

- [x] Computadora física dedicada a Proxmox.
- [x] Proxmox VE 9.2 instalado como hipervisor Tipo 1.
- [x] Virtualización por hardware disponible para KVM/QEMU.
- [x] Puente interno `vmbr1` en `10.50.5.1/24`.
- [x] VM 101 `lab5-web` en `10.50.5.20`.
- [x] VM 102 `lab5-db` en `10.50.5.30`.
- [x] VM 103 `lab5-cliente` en `10.50.5.10`.
- [x] Tres VM activas simultáneamente.

## Sistemas y servicios

- [x] Ubuntu Server 26.04.1 LTS sin GUI en web y DB.
- [x] openSUSE Leap 16.0 con KDE en el cliente.
- [x] SSH/SFTP por `22222/TCP` con llaves.
- [x] Apache, PHP y WordPress en la VM web.
- [x] MySQL en VM independiente, `10.50.5.30:13306`.
- [x] Usuario `wpapp` restringido a `10.50.5.20` y `wordpress.*`.
- [x] UFW activo con reglas por origen.
- [x] Permisos `wpadmin:www-data`, directorios 750 y archivos 640.

## Dominio y HTTPS

- [x] Dominio real `laboratorio5.com`.
- [x] Zona pública administrada en Amazon Route 53.
- [x] Certbot con complemento `dns-route53`.
- [x] Certificado válido de Let's Encrypt.
- [x] HTTP redirige permanentemente a HTTPS.
- [x] Resolución local hacia `10.50.5.20`.
- [x] Renovación simulada exitosa y hook de recarga de Apache.

## Documentación y entrega

- [x] Evidencias E01--E17 organizadas por fase.
- [x] Matriz T01--T20 actualizada.
- [x] Informe LaTeX compilado en `informe/output/informe-lab5.pdf`.
- [x] Presentación HTML final con evidencia real.
- [x] README principal actualizado.
- [x] Problemas y soluciones documentados.

## Control pendiente antes de entregar

- [ ] Ensayar la exposición completa con cronómetro.
- [ ] Ejecutar la auditoría final del repositorio y revisar el último commit.
- [ ] Verificar que ninguna captura nueva muestre credenciales.

Una casilla solo se marcó como completada después de ejecutar la acción y conservar una prueba. Las plantillas por sí solas no se consideran evidencia.
