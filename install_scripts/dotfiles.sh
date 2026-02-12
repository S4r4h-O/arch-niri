#!/usr/bin/env bash

TEMP_DIR=$(mktemp -d)
trap "rm -rf '$TEMP_DIR'" EXIT

if ! git clone https://github.com/S4r4h-O/dotfiles.git "$TEMP_DIR/dots"; then
  printf "${ERROR} ${WARNING}Failed to clone dotfiles repository${RESET}\n"
  exit 1
fi

if [[ ! -d "$HOME/Pictures/Wallpapers/" ]]; then
  mkdir -p "$HOME/Pictures/Wallpapers/"
fi

if ! cp -r "$TEMP_DIR/dots/." ~/.config; then
  printf "${ERROR} ${WARNING}Failed to copy the dotfiles to ~/.config${RESET}\n"
  exit 1
fi

if ! cp ~/.config/wallpapers/* ~/Pictures/Wallpapers/; then
  printf "${ERROR} ${WARNING}Failed to copy wallpapers from ~/.config/wallpapers to ~/Pictures/Wallpapers, copy them manually${RESET}\n"
  # Not breaking the script in order to link the services to niri
fi

# TODO: logs file
# https://niri-wm.github.io/niri/Example-systemd-Setup.html
systemctl --user add-wants niri.service dunst.service
systemctl --user add-wants niri.service waybar.service
systemctl --user add-wants niri.service swaybg.service
