#!/bin/bash
# Inspired by https://github.com/JaKooLit

set -e

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

install_logs="$HOME/.local/state/"

if [[ ! -d install_logs ]]; then
  mkdir -p install_logs
fi

show_progress() {
  local pid=$1
  local package_name=$2
  local spin_chars=("●○○○○○○○○○" "○●○○○○○○○○" "○○●○○○○○○○" "○○○●○○○○○○" "○○○○●○○○○"
    "○○○○○●○○○○" "○○○○○○●○○○" "○○○○○○○●○○" "○○○○○○○○●○" "○○○○○○○○○●")

  local i=0

  printf "\r${NOTE} Installing ${YELLOW}%s${RESET} ..." "$package_name"

  # Loop while install process runs in the background
  while ps -p $pid &>/dev/null; do
    printf "\r${NOTE} Installing ${YELLOW}%s${RESET} %s" "$package_name" "${spin_chars[i]}"
    i=$(((i + 1) % 10))
    sleep 0.3
  done

  printf "\r${NOTE} Installing ${YELLOW}%s${RESET}...!%-20s \n" "$package_name" ""
  tput cnorm
}

is_installed() {
  pacman -Q "$1" &>/dev/null
}

# Return uncommentend lines from a file with a packages list
read_packages() {
  grep '^[^#]' "$1"
}

install_package_pacman() {
  # check if installed
  if is_installed $1; then
    printf "${INFO} ${MAGENTA}$1${RESET} is already installed, skipping...\n"
  else
    # run pacman in the background, retrieve process ID and redirect logs to a file
    (
      stdbuf -oL sudo pacman -S --noconfirm "$1" 2>&1
    ) >>"$install_logs/logs.txt" 2>&1 &
    PID=$!
    show_progress $PID "$1"

    if pacman -Q "$1" &>/dev/null; then
      printf "${OK} Package ${YELLOW}$1${RESET} has been successfully installed!\n"
    else
      echo -e "\n${ERROR} ${YELLOW}$1${RESET} failed to install. Please check the $LOG. You may need to install manually.\n"
    fi
  fi
}

# I prefer  paru, so I won't check if yay is installed
install_aur_package() {
  # first check if paru is instal
  if ! is_installed "paru"; then
    printf "\n${ERROR} Paru is not installed! :p${RESET}\n"
  fi

  if paru -Q "$1" &>/dev/null; then
    printf "${INFO} ${MAGENTA}$1${RESET} is already installed, skipping...\n"

  else
    (
      stdbuf sudo paru -S --noconfirm "$1" 2>&1
    ) >>"$install_logs/logs.txt" 2>&1 &
    PID=$!
    show_progress $PID "$1"

    if paru -Q "$1" &>/dev/null; then
      printf "${OK} Package ${YELLOW}$1${RESET} has been successfully installed!\n"
    else
      echo -e "\n${ERROR} ${YELLOW}$1${RESET} failed to install. Please check the $LOG. You may need to install manually.\n"
    fi
  fi
}
