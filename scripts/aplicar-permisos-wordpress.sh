#!/usr/bin/env bash
set -euo pipefail

WP_ROOT="${WP_ROOT:-/var/www/wordpress}"
WP_ADMIN_USER="${WP_ADMIN_USER:-wpadmin}"
WP_WEB_GROUP="${WP_WEB_GROUP:-www-data}"
APPLY=false

if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
elif [[ -n "${1:-}" ]]; then
  printf 'Uso: %s [--apply]\n' "$0" >&2
  exit 2
fi

if [[ ! -d "$WP_ROOT" ]]; then
  printf 'No existe el directorio: %s\n' "$WP_ROOT" >&2
  exit 1
fi

RESOLVED_ROOT="$(readlink -f -- "$WP_ROOT")"
case "$RESOLVED_ROOT" in
  /var/www/*) ;;
  *)
    printf 'Ruta rechazada por seguridad: %s\n' "$RESOLVED_ROOT" >&2
    exit 1
    ;;
esac

printf 'Ruta: %s\nPropietario: %s\nGrupo web: %s\n' "$RESOLVED_ROOT" "$WP_ADMIN_USER" "$WP_WEB_GROUP"
printf 'Directorios -> 750\nArchivos -> 640\n'

if [[ "$APPLY" != true ]]; then
  printf '\nSIMULACIÓN. No se realizaron cambios. Use --apply después de revisar la ruta.\n'
  exit 0
fi

if [[ "$EUID" -ne 0 ]]; then
  printf 'La aplicación requiere root.\n' >&2
  exit 1
fi

getent passwd "$WP_ADMIN_USER" >/dev/null
getent group "$WP_WEB_GROUP" >/dev/null

chown -R "$WP_ADMIN_USER:$WP_WEB_GROUP" -- "$RESOLVED_ROOT"
find "$RESOLVED_ROOT" -type d -exec chmod 750 {} +
find "$RESOLVED_ROOT" -type f -exec chmod 640 {} +

printf 'Permisos aplicados. Verifique Apache, SFTP y la prueba de permiso denegado.\n'
