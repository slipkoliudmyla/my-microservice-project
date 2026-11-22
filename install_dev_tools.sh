#!/usr/bin/env bash
set -euo pipefail

if [[ ! -r /etc/os-release ]]; then
  printf 'Цей скрипт призначений для Ubuntu або Debian.\n' >&2
  exit 1
fi

# shellcheck source=/dev/null
source /etc/os-release
case "${ID:-}" in
  ubuntu|debian) ;;
  *) printf 'Цей скрипт призначений для Ubuntu або Debian.\n' >&2; exit 1 ;;
esac

apt_updated=false

as_admin() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

update_apt() {
  if [[ "$apt_updated" == false ]]; then
    as_admin apt-get update
    apt_updated=true
  fi
}

install_package() {
  update_apt
  as_admin apt-get install -y "$@"
}

has_python() {
  "$1" -c 'import sys; sys.exit(sys.version_info < (3, 9))' 2>/dev/null
}

if ! command -v docker >/dev/null; then
  install_package docker.io
fi
docker --version

if ! docker compose version >/dev/null 2>&1 && ! docker-compose version >/dev/null 2>&1; then
  update_apt
  if apt-cache show docker-compose-v2 >/dev/null 2>&1; then
    install_package docker-compose-v2
  else
    install_package docker-compose
  fi
fi
if docker compose version >/dev/null 2>&1; then
  docker compose version
else
  docker-compose version
fi

python=python3
if ! has_python "$python"; then
  install_package python3
  python=/usr/bin/python3
fi
if ! has_python "$python"; then
  printf 'Потрібен Python 3.9+. Увімкніть репозиторій дистрибутива з цією версією.\n' >&2
  exit 1
fi
"$python" --version

if ! "$python" -m django --version 2>/dev/null; then
  script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
  venv="$script_dir/.venv"

  if [[ ! -x "$venv/bin/python" ]]; then
    if ! "$python" -c 'import ensurepip' 2>/dev/null; then
      install_package python3-venv
    fi
    "$python" -m venv "$venv"
  fi

  python="$venv/bin/python"
  if ! has_python "$python"; then
    printf 'У наявному .venv потрібен Python 3.9 або новіший.\n' >&2
    exit 1
  fi
  if ! "$python" -m django --version 2>/dev/null; then
    if ! "$python" -m pip --version >/dev/null 2>&1; then
      "$python" -m ensurepip
    fi
    "$python" -m pip install Django
    "$python" -m django --version
  fi
fi
