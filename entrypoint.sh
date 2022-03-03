#!/bin/bash

set -euo pipefail

export ENTRYPOINT_DIR=$(dirname "$(realpath $0)")

check_torrc () {
  if [[ ! -f /etc/torrc ]]; then
    echo "No /etc/torrc config file detected, creating a blank one"
    touch /etc/torrc
  fi
}

check_startup_dir () {
  if [[ ! -d /scripts ]]; then
    echo "No /scripts directory detected, creating an empty one"
    mkdir /scripts
  fi
}

run_startup_scripts () {
  shopt -s nullglob
  for filename in /scripts/*.sh; do
    echo "Running $filename"
    source "$filename"
  done
  shopt -u nullglob
}

start_tor () {
  $ENTRYPOINT_DIR/tor -f /etc/torrc
}

init () {
  check_torrc
  check_startup_dir
  run_startup_scripts
}

init
start_tor
