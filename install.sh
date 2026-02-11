#!/usr/bin/env bash

# This script assumes that the system is already installed.
# If you missed some package during the installation it
# will install it for you.

source ./install_scripts/global_functions.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/packages"
INSTALL_SCRIPTS_DIR="$SCRIPT_DIR/install_scripts"

install_logs="$HOME/.local/state/"

if [[ ! -d install_logs ]]; then
  mkdir -p install_logs
fi

for pkg_file in ./packages/*.packages; do
  read_packages "$pkg_file" | while IFS= read -r pkg; do
    install_package_pacman "$pkg"
  done
done

execute_script() {
  local script=$1
  local script_path="$INSTALL_SCRIPTS_DIR/$1"

  if [ -f "script_path" ]; then
    chmod +x "$script_path"
    if [ -x "$script_path" ]; then
      env "$script_path"
    else
      printf "Failed to make script '$script' executable :(\n" | tee -a "$install_logs/logs.txt"
    fi
  else
    printf "Script '$script' not found in '$script_path'\n" | tee -a "$install_logs/logs.txt"
  fi
}

execute_script "paru.sh"

execute_script "utilities.sh"

execute_script "dotfiles.sh"
