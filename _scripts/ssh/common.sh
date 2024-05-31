#!/bin/bash

_DIR_=$(dirname "$(readlink -f "$0")")
_FILE_=$(basename $0)
_NOW_=$(date +"%Y-%m-%d__%H-%M")

# Helpers
function CONFIRM {
  read -r -p "${1:-Are you sure?} [y/N] " response
  case "$response" in
  [yY][eE][sS] | [yY])
    true
    ;;
  *)
    false
    ;;
  esac
}

function INFO {
  echo -e "\e[1;36m[${_FILE_}]\e[0m ${1}"
}

function WARNING {
  echo -e "\e[1;33m[${_FILE_}]\e[0m ${1}"
  CONFIRM && return
  exit 1
}

function ERROR {
  echo -e "\e[1;31m[${_FILE_}]\e[0m ${1}"
  exit 1
}

function SUCCESS {
  echo -e "\e[1;32m[${_FILE_}]\e[0m ${1}"
}

function TIME_START {
  t1=$(date +%s.%N)
}

function TIME_STOP {
  t2=$(date +%s.%N)
  dt=$(echo "$t2 - $t1" | bc -l)
  dt=$(echo "scale=2; $dt / 1" | bc -l)
  echo "Done in ${dt}s"
}

# Default configuration
if [ -f "$_DIR_/.env" ]; then
  source $_DIR_/.env
else
  ERROR "Config not found! Please create $_DIR_/.env"
fi

# Check required common environment variables
if [[ -z "$LOCAL_DOMAIN" || -z "$LOCAL_PATH" || -z "$LOCAL_DB_BACKUP_PATH" || -z "$LOCAL_ROOT_PATH" || -z "$REMOTE_DOMAIN" || -z "$REMOTE_USER" || -z "$REMOTE_HOST" || -z "$REMOTE_PORT" ]]; then
  ERROR "Could not determine required common environment variables. Please verify $_DIR_/.env"
fi

# Export SSHPASS if REMOTE_PASS is provided to avoid special characters issues.
if [ -n "$REMOTE_PASS" ]; then
  export SSHPASS=$REMOTE_PASS
fi

# Confirm to proceed with REMOTE_DOMAIN
INFO "Remote domain is set to: $REMOTE_DOMAIN"
CONFIRM "Do you want to proceed with this domain?"
