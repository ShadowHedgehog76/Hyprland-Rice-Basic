#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Hyprland Rice Installation Script

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Hyprland Rice Installation Script${NC}                   ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Update system
echo -e "${YELLOW}[*] Updating system packages...${NC}"
sudo pacman -Syu --noconfirm
echo -e "${GREEN}[+] System updated successfully!${NC}\n"

# Install required packages
echo -e "${YELLOW}[*] Installing Hyprland ecosystem and utilities...${NC}"
sudo pacman -S --needed --noconfirm \
    hyprland \
    hyprpaper \
    hyprlock \
    hypridle \
    kitty \
    waybar \
    wofi \
    flatpak \
    git \
    nemo \
    fastfetch \
    network-manager-applet \
    blueman \
    pavucontrol \
    polkit-gnome \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    dunst \
    grim \
    slurp \
    uwsm \
    polkit-kde-agent \
    qt5-wayland \
    qt6-wayland \
    virtualbox-guest-utils \
    xf86-video-vmware

echo -e "${GREEN}[+] Core packages installed successfully!${NC}"

# Enable VirtualBox guest services if running in VirtualBox
if systemd-detect-virt -q; then
    VIRT_TYPE=$(systemd-detect-virt)
    if [ "$VIRT_TYPE" = "oracle" ] || [ "$VIRT_TYPE" = "kvm" ]; then
        echo -e "${BLUE}[*] Virtual machine detected, enabling guest services...${NC}"
        sudo systemctl enable vboxservice.service 2>/dev/null || true
        sudo systemctl start vboxservice.service 2>/dev/null || true
        echo -e "${GREEN}[+] VirtualBox guest services enabled${NC}"
    fi
fi

echo ""

# Interactive menu for additional packages
declare -A packages=(
    ["Firefox"]="pacman"
    ["Discord"]="pacman"
    ["VS Code"]="flatpak:com.visualstudio.code"
    ["Tailscale"]="pacman+trayscale"
    ["Discover"]="pacman"
    ["Krita"]="pacman"
)

declare -A package_keys=(
    ["Firefox"]="firefox"
    ["Discord"]="discord"
    ["VS Code"]="vscode"
    ["Tailscale"]="tailscale"
    ["Discover"]="discover"
    ["Krita"]="krita"
)

declare -A selected
package_list=("Firefox" "Discord" "VS Code" "Tailscale" "Discover" "Krita")
current=0

show_menu() {
    clear
    echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}  ${BOLD}Select Additional Packages${NC}                           ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}  UP/DOWN: Navigate  |  SPACE: Select  |  ENTER: Confirm${NC}"
    echo ""
    
    for i in "${!package_list[@]}"; do
        local pkg="${package_list[$i]}"
        local mark="${RED}[ ]${NC}"
        [[ ${selected[$pkg]} == "1" ]] && mark="${GREEN}[X]${NC}"
        
        local display_name="$pkg"
        [[ $pkg == "Tailscale" ]] && display_name="Tailscale ${CYAN}(includes Trayscale)${NC}"
        
        if [[ $i -eq $current ]]; then
            echo -e "  ${YELLOW}>${NC} $mark ${BOLD}$display_name${NC}"
        else
            echo -e "    $mark $display_name"
        fi
    done
    echo ""
}

while true; do
    show_menu
    read -rsn1 key
    
    case "$key" in
        A) # Up arrow
            ((current > 0)) && ((current--))
            ;;
        B) # Down arrow
            ((current < ${#package_list[@]} - 1)) && ((current++))
            ;;
        ' ') # Space
            pkg="${package_list[$current]}"
            [[ ${selected[$pkg]} == "1" ]] && selected[$pkg]="" || selected[$pkg]="1"
            ;;
        '') # Enter
            break
            ;;
    esac
done

# Install selected packages
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Installing Selected Packages${NC}                         ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

install_count=0
for pkg in "${!selected[@]}"; do
    if [[ ${selected[$pkg]} == "1" ]]; then
        ((install_count++))
    fi
done

if [[ $install_count -eq 0 ]]; then
    echo -e "${YELLOW}[!] No additional packages selected${NC}\n"
else
    current_pkg=0
    for pkg in "${!selected[@]}"; do
        if [[ ${selected[$pkg]} == "1" ]]; then
            ((current_pkg++))
            install_info="${packages[$pkg]}"
            install_method="${install_info%%:*}"
            pkg_key="${package_keys[$pkg]}"
            
            echo -e "${BLUE}[$current_pkg/$install_count]${NC} Installing ${BOLD}$pkg${NC}..."
            
            if [[ $install_method == "flatpak" ]]; then
                flatpak_id=$(echo "$install_info" | cut -d':' -f2)
                flatpak install -y flathub "$flatpak_id" 2>&1 | grep -v "^$" || true
                echo -e "${GREEN}[+] $pkg installed via Flatpak${NC}\n"
            elif [[ $install_method == "pacman+trayscale" ]]; then
                sudo pacman -S --needed --noconfirm "$pkg_key" > /dev/null 2>&1
                echo -e "${GREEN}[+] $pkg installed via pacman${NC}"
                echo -e "${BLUE}[*] Installing Trayscale...${NC}"
                flatpak install -y flathub dev.deedles.Trayscale 2>&1 | grep -v "^$" || true
                echo -e "${GREEN}[+] Trayscale installed via Flatpak${NC}\n"
            else
                sudo pacman -S --needed --noconfirm "$pkg_key" > /dev/null 2>&1
                echo -e "${GREEN}[+] $pkg installed via pacman${NC}\n"
            fi
        fi
    done
fi

echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}Installation Complete!${NC}                               ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Configuration prompt
echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║${NC}  ${BOLD}Configuration Setup${NC}                                  ${MAGENTA}║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Do you want to install the default Hyprland Rice configuration?${NC}"
echo -e "${YELLOW}${BOLD}WARNING:${NC} ${RED}This will replace your existing configuration!${NC}"
echo -e "${CYAN}It is recommended to backup your current config first.${NC}"
echo ""
echo -e "${YELLOW}Install default configuration? ${NC}${BOLD}(y/n)${NC}"
read -rsn1 config_choice

case "$config_choice" in
    y|Y)
        echo -e "\n${YELLOW}[*] Installing configuration files...${NC}"
        
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        
        if [ -d "$SCRIPT_DIR/config" ]; then
            # Backup existing configs if they exist
            for config_dir in hypr waybar wofi kitty; do
                if [ -d "$HOME/.config/$config_dir" ]; then
                    BACKUP_DIR="$HOME/.config/${config_dir}.backup.$(date +%Y%m%d_%H%M%S)"
                    echo -e "${BLUE}[*] Backing up existing $config_dir config to: ${BACKUP_DIR##*/}${NC}"
                    mv "$HOME/.config/$config_dir" "$BACKUP_DIR"
                fi
            done
            
            echo -e "${GREEN}[+] Backups created${NC}"
            echo -e "${BLUE}[*] Copying configuration files...${NC}"
            
            # Copy all config directories
            mkdir -p "$HOME/.config"
            
            for config_dir in "$SCRIPT_DIR/config/"*; do
                if [ -d "$config_dir" ]; then
                    dir_name=$(basename "$config_dir")
                    cp -r "$config_dir" "$HOME/.config/"
                    echo -e "${GREEN}  [+] $dir_name copied${NC}"
                fi
            done
            
            echo -e "${GREEN}[+] Configuration files installed successfully!${NC}\n"
        else
            echo -e "${RED}[!] Configuration directory not found in $SCRIPT_DIR/config${NC}"
            echo -e "${YELLOW}[!] Skipping configuration installation${NC}\n"
        fi
        ;;
    *)
        echo -e "\n${CYAN}[!] Configuration installation skipped${NC}"
        echo -e "${CYAN}You can manually copy the config files later from ./config/${NC}\n"
        ;;
esac

# Auto-start Hyprland prompt
echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║${NC}  ${BOLD}Auto-start Configuration${NC}                             ${MAGENTA}║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Do you want Hyprland to start automatically on login?${NC}"
echo -e "${CYAN}This will add 'start-hyprland' to your shell profile.${NC}"
echo ""
echo -e "${YELLOW}Enable auto-start? ${NC}${BOLD}(y/n)${NC}"
read -rsn1 autostart_choice

case "$autostart_choice" in
    y|Y)
        echo -e "\n${YELLOW}[*] Configuring auto-start...${NC}"
        
        # Detect shell
        SHELL_RC=""
        if [ -n "$BASH_VERSION" ]; then
            SHELL_RC="$HOME/.bashrc"
        elif [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
        else
            SHELL_RC="$HOME/.profile"
        fi
        
        # Check if auto-start is already configured
        if grep -q "start-hyprland" "$SHELL_RC" 2>/dev/null; then
            echo -e "${YELLOW}[!] Auto-start already configured in $SHELL_RC${NC}\n"
        else
            # Add auto-start to shell profile
            echo "" >> "$SHELL_RC"
            echo "# Auto-start Hyprland on TTY1" >> "$SHELL_RC"
            echo 'if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then' >> "$SHELL_RC"
            echo "  exec start-hyprland" >> "$SHELL_RC"
            echo "fi" >> "$SHELL_RC"
            
            echo -e "${GREEN}[+] Auto-start configured in $SHELL_RC${NC}"
            echo -e "${CYAN}[*] Hyprland will start automatically on TTY1${NC}\n"
        fi
        ;;
    *)
        echo -e "\n${CYAN}[!] Auto-start not configured${NC}"
        echo -e "${CYAN}You can manually run 'start-hyprland' after login${NC}\n"
        ;;
esac

# Reboot prompt
echo -e "${YELLOW}${BOLD}RECOMMENDED:${NC} ${CYAN}A reboot is required for some configurations to take effect.${NC}"
echo -e "${CYAN}This ensures all services and portals are properly loaded.${NC}"
echo ""
echo -e "${YELLOW}Do you want to reboot now? ${NC}${BOLD}(Y/n)${NC}"
read -rsn1 reboot_choice

case "$reboot_choice" in
    n|N)
        echo -e "\n${CYAN}[!] Reboot cancelled.${NC}"
        echo -e "${YELLOW}[!] Please reboot manually later and select Hyprland as your session.${NC}\n"
        ;;
    *)
        echo -e "\n${GREEN}[+] Rebooting system...${NC}"
        sleep 2
        sudo reboot
        ;;
esac