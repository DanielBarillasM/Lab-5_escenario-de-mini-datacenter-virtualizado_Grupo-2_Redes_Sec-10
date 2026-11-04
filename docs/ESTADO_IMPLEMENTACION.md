# Estado de implementación

Actualizado: 3 de noviembre de 2026.

## Preparado en el repositorio

- [x] Arquitectura y direccionamiento propuestos.
- [x] Plantillas de red para Proxmox y Ubuntu.
- [x] Plantilla de SSH en puerto no predeterminado.
- [x] Plantilla de MySQL restringida a la red interna.
- [x] VirtualHosts HTTP y HTTPS para Apache.
- [x] Plantilla sanitizada de `wp-config.php`.
- [x] Procedimiento de UFW con reglas por origen.
- [x] Procedimiento DNS-01 para Let's Encrypt.
- [x] Script seguro para permisos de WordPress.
- [x] Scripts de auditoría para cliente, web y base de datos.
- [x] Fuente del informe LaTeX.
- [x] Presentación HTML local.
- [x] Matriz de evidencias y runbook de demostración.

## Pendiente de hardware o decisiones reales

- [ ] Computadora física dedicada a Proxmox.
- [ ] Verificación de Intel VT-x o AMD-V.
- [ ] Interfaces físicas y nombres reales de NIC.
- [ ] Instalación bare-metal de Proxmox.
- [ ] Creación manual de las tres VM.
- [ ] Confirmación de que `10.50.5.0/24` no se superpone con otra red.
- [ ] Instalación de Ubuntu Server 26.04.1 LTS en ambas VM servidor.
- [ ] Instalación de openSUSE Leap 16.0 KDE en la VM cliente.
- [ ] Dominio o subdominio real controlado por el equipo.
- [ ] Proveedor DNS y método de automatización DNS-01.
- [ ] Versiones reales de Apache, PHP, MySQL y WordPress.
- [ ] Evidencias y resultados de las pruebas T01 a T20.
- [ ] Problemas reales encontrados y soluciones aplicadas.
- [ ] Conclusiones basadas en la implementación.

## Regla de actualización

Una casilla solo puede marcarse como completada después de ejecutar la acción y conservar evidencia. Las plantillas no demuestran que el requisito funciona.
