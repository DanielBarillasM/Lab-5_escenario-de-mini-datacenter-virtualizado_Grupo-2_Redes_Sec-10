#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${1:-$REPO_ROOT/configuraciones/lab5.env}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  printf 'Falta %s. Prepare una copia revisada de lab5.env.example.\n' "$CONFIG_FILE" >&2
  exit 2
fi

set -a
# shellcheck disable=SC1090
source "$CONFIG_FILE"
set +a
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/auditoria-comun.sh"

section "Sistema operativo"
if grep -q '^VERSION_ID="\?26\.04' /etc/os-release 2>/dev/null; then
  pass "Ubuntu 26.04 detectado"
else
  fail "No se detectó Ubuntu 26.04"
fi

if [[ "$(systemctl get-default 2>/dev/null)" == "graphical.target" ]]; then
  fail "El servidor usa graphical.target"
else
  pass "El servidor no usa graphical.target"
fi

section "Servicios"
for cmd in sshd mysql ss ufw; do
  require_command "$cmd"
done

if systemctl is-active --quiet mysql; then
  pass "MySQL activo"
else
  fail "MySQL inactivo"
fi

section "Puertos"
if ss -lnt | grep -Eq "${DB_IP}:${MYSQL_PORT}[[:space:]]"; then
  pass "MySQL escucha en $DB_IP:$MYSQL_PORT"
else
  fail "MySQL no escucha en $DB_IP:$MYSQL_PORT"
fi

if ss -lnt | grep -Eq ':3306[[:space:]]'; then
  fail "MySQL todavía escucha en 3306"
else
  pass "Puerto MySQL 3306 cerrado"
fi

if ss -lnt | grep -Eq ":${SSH_PORT}[[:space:]]"; then
  pass "SSH escucha en $SSH_PORT"
else
  fail "SSH no escucha en $SSH_PORT"
fi

if ss -lnt | grep -Eq ':22[[:space:]]'; then
  fail "SSH todavía escucha en 22"
else
  pass "Puerto SSH 22 cerrado"
fi

section "Firewall y privilegios"
if sudo -n ufw status 2>/dev/null | grep -q '^Status: active'; then
  pass "UFW activo"
else
  warn "No se pudo confirmar UFW activo sin interacción"
fi

if sudo -n mysql -NBe "SHOW GRANTS FOR 'wpapp'@'${WEB_IP}';" >/dev/null 2>&1; then
  pass "Existe wpapp restringido a $WEB_IP"
else
  warn "No se pudo comprobar SHOW GRANTS sin interacción"
fi

finish_audit
