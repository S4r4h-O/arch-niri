#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

source "$SCRIPT_DIR/global_functions.sh"

OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

# zinit, the zsh plugins manager
# manual install (described in https://github.com/zdharma-continuum/zinit)

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

if ! cat <<'ZINIT_EOF' >>~/.zshrc; then
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
ZINIT_EOF
  echo "${ERROR} ${WARNING}Failed to write to .zshrc, fix it manually${RESET}\n"
  exit 1
else
  echo "${OK} ${GREEN}Zinit configuration added successfully${RESET}\n"
fi

# tmux
# manual install (described in https://github.com/gpakosz/.tmux)
tmux_path="$HOME/.local/share/tmux"
if ! is_installed tmux; then
  install_package_pacman "tmux"
fi

mkdir -p "$XDG_CONFIG_HOME/tmux"

TMUX_DATA_DIR="$XDG_DATA_HOME/tmux"

if [ -d "$TMUX_DATA_DIR" ]; then
  rm -rf "$TMUX_DATA_DIR"
fi

if git clone --single-branch https://github.com/gpakosz/.tmux.git "$TMUX_DATA_DIR"; then

  if [ -f "$TMUX_DATA_DIR/.tmux.conf" ]; then

    ln -sf "$TMUX_DATA_DIR/.tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"

    if [ ! -f "$XDG_CONFIG_HOME/tmux/tmux.conf.local" ]; then
      cp "$TMUX_DATA_DIR/.tmux.conf.local" "$XDG_CONFIG_HOME/tmux/tmux.conf.local"
    fi

    printf "${OK} Tmux configuration installed successfully\n"
  else
    printf "${ERROR} ${WARNING} .tmux.conf not found in cloned directory${RESET}\n"
    exit 1
  fi
else
  printf "${ERROR} ${WARNING} Failed to clone tmux configuration${RESET}\n"
  exit 1
fi
