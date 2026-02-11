#!/usr/bin/env bash

source ./global_functions.sh

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

export XDG_CONFIG_HOME="$HOME"
export XDG_DATA_HOME="$HOME/.local/share"

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

if [ ! -d "$XDG_CONFIG_HOME/tmux" ]; then
  mkdir -p "$XDG_CONFIG_HOME/tmux"
else
  printf "${ERROR} ${WARNING}${RESET}\n"
  exit 1
fi

if git clone --single-branch https://github.com/gpakosz/.tmux.git "$XDG_DATA_HOME/tmux"; then
  if [ -f "$XDG_DATA_HOME/tmux/oh-my-tmux/.tmux.conf" ]; then
    ln -s "$XDG_DATA_HOME/tmux/oh-my-tmux/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
    cp "$XDG_DATA_HOME/tmux/oh-my-tmux/.tmux.conf.local" "$HOME/.config/tmux/tmux.conf.local"
  else
    echo "${ERROR} ${WARNING}Failed to caopy .tmux.conf or file doesn't exist${RESET}\n"
    exit 1
  fi
else
  echo "${ERROR} ${WARNING}Failed to clone oh-my-tmux configuration${RESET}\n"
  exit 1
fi
