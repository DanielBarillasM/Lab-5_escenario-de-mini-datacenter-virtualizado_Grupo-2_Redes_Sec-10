#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${1:-$REPO_ROOT/configuraciones/lab5.env}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  printf 'Falta %s. Copie configuraciones/lab5.env.example como lab5.env y revise sus valores.\n' "$CONFIG_FILE" >&2
  exit 2
fi

set -a
# shellcheck disable=SC1090
source "$CONFIG_FILE"
set +a
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/auditoria-comun.sh"

section "Herramientas del cliente"
for cmd in ssh sftp curl nc getent ping; do
  require_command "$cmd"
done

section "Conectividad IP"
for target in "$PVE_IP" "$WEB_IP" "$DB_IP"; do
  if ping -c 1 -W 2 "$target" >/dev/null 2>&1; then
    pass "Ping a $target"
  else
    fail "Sin respuesta ICMP de $target"
  fi
done

section "Puertos permitidos"
for target in "$WEB_IP" "$DB_IP"; do
  if tcp_open "$target" "$SSH_PORT"; then
    pass "SSH $target:$SSH_PORT accesible"
  else
    fail "SSH $target:$SSH_PORT no accesible"
  fi
done

section "Prueba negativa MySQL"
if tcp_open "$DB_IP" "$MYSQL_PORT"; then
  fail "MySQL $DB_IP:$MYSQL_PORT es accesible desde el cliente y debe estar bloqueado"
else
  pass "MySQL bloqueado desde el cliente"
fi

section "Resolución y HTTPS"
if [[ "$LAB_DOMAIN" == *.invalid ]]; then
  warn "LAB_DOMAIN continúa como dominio de ejemplo: $LAB_DOMAIN"
else
  if getent hosts "$LAB_DOMAIN" | grep -Fq "$WEB_IP"; then
    pass "$LAB_DOMAIN resuelve hacia $WEB_IP"
  else
    fail "$LAB_DOMAIN no resuelve hacia $WEB_IP"
  fi

  if curl --fail --silent --show-error --head "https://$LAB_DOMAIN/" >/dev/null; then
    pass "HTTPS válido para $LAB_DOMAIN"
  else
    fail "HTTPS no validó para $LAB_DOMAIN"
  fi
fi

finish_audit
