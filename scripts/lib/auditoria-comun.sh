#!/usr/bin/env bash

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

section() {
  printf '\n== %s ==\n' "$1"
}

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf '[OK] %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '[FALLO] %s\n' "$1" >&2
}

warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  printf '[AVISO] %s\n' "$1"
}

require_command() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "Comando disponible: $1"
  else
    fail "Falta el comando: $1"
  fi
}

tcp_open() {
  local host="$1"
  local port="$2"
  nc -z -w 3 "$host" "$port" >/dev/null 2>&1
}

finish_audit() {
  section "Resumen"
  printf 'Correctas: %d\nAvisos: %d\nFallos: %d\n' "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"
  if (( FAIL_COUNT > 0 )); then
    return 1
  fi
  return 0
}
