# Install paru (obviously)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

install_logs="$HOME/.local/state/"

if [[ ! -d "$install_logs" ]]; then
  mkdir -p "$install_logs"
fi

if command -v paru >/dev/null 2>&1; then
  printf "${INFO} paru already installed\n"
  exit 0
fi

if ! command -v rustup >/dev/null 2>&1; then
  install_package_pacman "rustup"
fi

if ! rustup default stable; then
  printf "${ERROR} ${WARNING}Failed to install rust tools, try to run\n\
  ${ORANGE}rustup default stable${RESET} manually and restart the install script${RESET}\n"
  exit 1
fi

if ! is_installed "git"; then
  printf "${INFO} ${YELLOW}Git not installed, installing now!${RESET}"
  install_package_pacman "git"
fi

if ! is_installed "base-devel"; then
  printf "${INFO} ${YELLOW}Installing base-devel${RESET}\n"
  install_package_pacman "base-devel" || {
    printf "${ERROR} ${WARNING}Failed to install base-devel${RESET}\n"
    exit 1
  }
fi

TEMP_DIR=$(mktemp -d)
trap "rm -rf '$TEMP_DIR'" EXIT

if ! git clone https://aur.archlinux.org/paru.git "$TEMP_DIR/paru"; then
  printf "${ERROR} ${WARNING}Failed to clone paru repository${RESET}\n"
  exit 1
fi

cd "$TEMP_DIR/paru" || {
  printf "${ERROR} ${WARNING}Failed to enter paru directory${RESET}\n"
  exit 1
}

if ! makepkg -si --noconfirm 2>&1 | tee -a "$install_logs/logs.txt"; then
  printf "${ERROR} ${WARNING}Failed to build/install paru${RESET}\n"
  exit 1
fi

printf "${OK} paru installed successfully${RESET}\n"

aur_pkgs=(
  # Themes and fonts
  arc-gtk-theme
  catppuccin-gtk-theme-mocha
  ttf-twemoji
  ttf-twemoji-color

  # Browsers
  brave-bin
  librewolf-bin

  # Dev
  jetbrains-toolbox
  vscodium-bin

  # Sys utils
  wlogout
)

for pkg in "${aur_pkgs[@]}"; do
  install_aur_package "$pkg"
done
