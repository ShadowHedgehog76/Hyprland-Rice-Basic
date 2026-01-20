# Autologin tty1..12 (attention sécurité)
for t in {1..12}; do
  sudo mkdir -p /etc/systemd/system/getty@tty${t}.service.d
  printf "[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin %s --noclear %%I \\$TERM\n" "$USER" \
    | sudo tee /etc/systemd/system/getty@tty${t}.service.d/override.conf >/dev/null
done
sudo systemctl daemon-reexec

# Paquets
sudo pacman -Syu --noconfirm \
  hyprland \
  hyprpaper \
  hyprlock \
  hypridle \
  waybar \
  pavucontrol \
  blueman \
  network-manager-applet \
  wofi \
  kitty \
  alacritty \
  firefox \
  nemo \
  fastfetch \
  swaync \
  python3 \
  python-pip

# Autostart Hyprland sur tty1 (bash)
grep -qxF '[[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]] && exec Hyprland' ~/.bash_profile 2>/dev/null \
  || echo '[[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]] && exec Hyprland' >> ~/.bash_profile

# Autostart Hyprland sur tty1 (zsh) - seulement utile si ton login shell est zsh
grep -qxF '[[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]] && exec Hyprland' ~/.zprofile 2>/dev/null \
  || echo '[[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]] && exec Hyprland' >> ~/.zprofile

# Configs
mkdir -p ~/.config/{hypr,waybar,wofi,kitty}
cp -rf ./config/hypr/* ~/.config/hypr/
cp -rf ./config/waybar/* ~/.config/waybar/
cp -rf ./config/wofi/* ~/.config/wofi/
cp -rf ./config/kitty/* ~/.config/kitty/

# Services system
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

reboot
