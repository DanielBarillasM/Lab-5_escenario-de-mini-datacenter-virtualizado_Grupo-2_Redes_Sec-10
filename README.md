# Laboratorio 5 de Redes - Grupo 2

Base reproducible para implementar WordPress en una arquitectura de dos capas sobre Proxmox VE instalado en hardware físico.

## Estado actual

La parte de código y configuración está preparada. La ejecución sobre Proxmox, las capturas y los resultados reales permanecen pendientes hasta disponer del hardware.

Este repositorio no contiene:

- Terraform ni aprovisionamiento automático de Proxmox.
- Virtualización anidada.
- Contraseñas, tokens DNS o llaves privadas.
- Capturas o resultados inventados.
- El PDF de instrucciones ni el plan externo.

El plan de trabajo se mantiene fuera del repositorio en `../PLAN_LAB5.md`. El PDF de la actividad también se conserva fuera del repositorio, tal como solicitó el equipo.

## Arquitectura planificada

| Nodo | Sistema | Dirección interna | Función |
|---|---|---:|---|
| `pve-lab5` | Proxmox VE 9.2 | `10.50.5.1` | Hipervisor Tipo 1 |
| `lab5-cliente` | openSUSE Leap 16.0 KDE | `10.50.5.10` | Administración y demostración |
| `lab5-web` | Ubuntu Server 26.04.1 LTS | `10.50.5.20` | Apache, PHP y WordPress |
| `lab5-db` | Ubuntu Server 26.04.1 LTS | `10.50.5.30` | MySQL |

Puertos planificados:

- SSH y SFTP: `22222/TCP`.
- MySQL: `13306/TCP`, accesible únicamente desde la VM web.
- HTTPS: `443/TCP`.
- HTTP: `80/TCP`, solo para redirección a HTTPS.

## Contenido

- `configuraciones/`: plantillas sanitizadas para Proxmox, Ubuntu, SSH, MySQL, Apache, WordPress, UFW y DNS-01.
- `scripts/`: auditorías, validación del repositorio y utilidades con modo seguro.
- `docs/`: runbooks, matriz de evidencias y estado de implementación.
- `informe/`: fuente LaTeX del informe y PDF de borrador cuando se compile.
- `presentacion/`: presentación HTML local y sin dependencias externas.
- `evidencias/`: estructura vacía para evidencia real.
- `bitacora/`: plantillas de decisiones, problemas y contribuciones.

## Uso recomendado

1. Leer `docs/ESTADO_IMPLEMENTACION.md`.
2. Confirmar direcciones, interfaces y dominio antes de aplicar cualquier plantilla.
3. Seguir `docs/RUNBOOK_IMPLEMENTACION.md` manualmente.
4. Ejecutar los scripts de auditoría desde la máquina correspondiente.
5. Guardar evidencia real según `docs/MATRIZ_EVIDENCIAS.md`.
6. Sustituir los marcadores pendientes del informe y la presentación.
7. Ensayar con `docs/RUNBOOK_DEMO.md`.

## Seguridad

Los archivos `.example` contienen marcadores y no deben copiarse sin revisión. Nunca se deben confirmar secretos en Git. Antes de cada commit se recomienda ejecutar:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\auditar-repositorio.ps1
```

## Integrantes

- Pablo Daniel Barillas Moreno - Carné 22193
- Genser Andreé Catalán Espina - Carné 23401
- Andrés Rafael Chivalán Marroquín - Carné 21534