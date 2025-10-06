#!/bin/bash

# Colors - Windows 11 inspired palette
BG_BLUE='\033[48;5;27m'
BG_DARK='\033[48;5;235m'
BG_LIGHT='\033[48;5;255m'
BLUE='\033[38;5;75m'
CYAN='\033[38;5;87m'
GREEN='\033[38;5;48m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
PURPLE='\033[38;5;141m'
ORANGE='\033[38;5;214m'
WHITE='\033[38;5;255m'
GRAY='\033[38;5;250m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Function to print centered text
print_center() {
    local text="$1"
    local color="$2"
    local width=80
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%${padding}s" ""
    echo -e "${color}${text}${NC}"
}

# Function to print box
print_box() {
    local text="$1"
    local color="$2"
    local width=80
    echo -e "${color}╔$(printf '═%.0s' $(seq 1 78))╗${NC}"
    print_center "$text" "$color"
    echo -e "${color}╚$(printf '═%.0s' $(seq 1 78))╝${NC}"
}

# Function to print menu item
print_menu_item() {
    local number="$1"
    local icon="$2"
    local title="$3"
    local desc="$4"
    echo -e "  ${BG_DARK}${BOLD}${BLUE} $number ${NC} ${CYAN}$icon${NC} ${BOLD}${WHITE}$title${NC}"
    echo -e "     ${DIM}${GRAY}$desc${NC}"
    echo ""
}

# Function for loading animation
loading_animation() {
    local text="$1"
    local pid=$!
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %10 ))
        printf "\r${CYAN}${spin:$i:1}${NC} ${text}"
        sleep 0.1
    done
    printf "\r${GREEN}✓${NC} ${text}\n"
}

# Function for progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r${CYAN}["
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "]${NC} ${BOLD}${WHITE}%d%%${NC}" $percentage
}

# Function for success message
success_msg() {
    echo ""
    echo -e "${GREEN}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${NC} ${BOLD}${GREEN}✓ $1${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Function for info message
info_msg() {
    echo -e "${CYAN}ℹ${NC} ${WHITE}$1${NC}"
}

# Function for input prompt
input_prompt() {
    local prompt="$1"
    local var_name="$2"
    echo -e "${YELLOW}▶${NC} ${WHITE}${prompt}${NC}"
    printf "  ${CYAN}└─➤${NC} "
    read $var_name
}

# Clear screen and show header
clear
echo ""
print_box "VPSFREE.ES" "${BOLD}${BLUE}"
echo ""
print_center "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "${CYAN}"
print_center "Windows 11 Style Setup Menu" "${BOLD}${WHITE}"
print_center "Copyright © 2022-2023 VPSFREE.ES" "${DIM}${GRAY}"
print_center "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "${CYAN}"
echo ""
echo ""

# Display menu
echo -e "${BOLD}${WHITE}  Available Options:${NC}"
echo ""
print_menu_item "1" "🖥️ " "LXDE Desktop - XRDP" "Install lightweight desktop environment with Remote Desktop"
print_menu_item "2" "🎮" "PufferPanel" "Game server management panel installation"
print_menu_item "3" "📦" "Basic Packages" "Essential tools: git, curl, wget, sudo, lsof, ping"
print_menu_item "4" "⚡" "Node.js" "Install Node.js runtime (versions 12.x to 20.x)"
echo ""
echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
echo ""

# Get user choice
echo -e -n "${BOLD}${YELLOW}▶${NC} ${WHITE}Enter your choice (1-4):${NC} "
read option

# Validate input
if ! [[ "$option" =~ ^[0-9]+$ ]]; then
    echo ""
    echo -e "${RED}✗ Error:${NC} ${WHITE}Please enter a valid number (1-4)${NC}"
    exit 1
fi

echo ""

# Option 1: LXDE - XRDP
if [ "$option" -eq 1 ]; then
    clear
    print_box "Installing LXDE Desktop & XRDP" "${BLUE}"
    echo ""
    
    info_msg "Updating system packages..."
    echo ""
    apt update && apt upgrade -y
    echo ""
    echo -e "${GREEN}✓${NC} System updated"
    echo ""
    
    info_msg "Removing sudo (if exists)..."
    export SUDO_FORCE_REMOVE=yes
    apt remove sudo -y > /dev/null 2>&1
    
    info_msg "Installing LXDE desktop environment..."
    apt install lxde -y > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} LXDE installed"
    
    info_msg "Installing XRDP server..."
    apt install xrdp -y > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} XRDP installed"
    
    echo "lxsession -s LXDE -e LXDE" >> /etc/xrdp/startwm.sh
    
    echo ""
    input_prompt "Select RDP Port (default: 3389):" selectedPort
    
    if [ -z "$selectedPort" ]; then
        selectedPort=3389
    fi
    
    sed -i "s/port=3389/port=$selectedPort/g" /etc/xrdp/xrdp.ini
    service xrdp restart > /dev/null 2>&1
    
    clear
    success_msg "RDP Server is now running on port: ${BOLD}${CYAN}$selectedPort${NC}"
    info_msg "You can now connect using Remote Desktop Connection"
    echo ""

# Option 2: PufferPanel
elif [ "$option" -eq 2 ]; then
    clear
    print_box "Installing PufferPanel" "${PURPLE}"
    echo ""
    
    info_msg "Updating system..."
    (apt update && apt upgrade -y) > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} System updated"
    
    export SUDO_FORCE_REMOVE=yes
    apt remove sudo -y > /dev/null 2>&1
    
    info_msg "Installing dependencies..."
    apt install curl wget git python3 -y > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} Dependencies installed"
    
    info_msg "Adding PufferPanel repository..."
    curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash > /dev/null 2>&1
    apt update && apt upgrade -y > /dev/null 2>&1
    
    info_msg "Setting up systemctl..."
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py > /dev/null 2>&1
    chmod -R 777 /bin/systemctl
    
    info_msg "Installing PufferPanel..."
    apt install pufferpanel -y > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} PufferPanel installed"
    
    echo ""
    input_prompt "Enter PufferPanel Port (default: 8080):" pufferPanelPort
    
    if [ -z "$pufferPanelPort" ]; then
        pufferPanelPort=8080
    fi
    
    sed -i "s/\"host\": \"0.0.0.0:8080\"/\"host\": \"0.0.0.0:$pufferPanelPort\"/g" /etc/pufferpanel/config.json
    
    echo ""
    input_prompt "Enter admin username:" adminUsername
    echo -e -n "${YELLOW}▶${NC} ${WHITE}Enter admin password:${NC}\n  ${CYAN}└─➤${NC} "
    read -s adminPassword
    echo ""
    input_prompt "Enter admin email:" adminEmail
    
    pufferpanel user add --name "$adminUsername" --password "$adminPassword" --email "$adminEmail" --admin > /dev/null 2>&1
    systemctl restart pufferpanel > /dev/null 2>&1
    
    clear
    success_msg "PufferPanel is running on port: ${BOLD}${CYAN}$pufferPanelPort${NC}"
    info_msg "Admin user: ${BOLD}${WHITE}$adminUsername${NC}"
    info_msg "Access panel at: ${BOLD}${CYAN}http://YOUR_IP:$pufferPanelPort${NC}"
    echo ""

# Option 3: Basic Packages
elif [ "$option" -eq 3 ]; then
    clear
    print_box "Installing Basic Packages" "${GREEN}"
    echo ""
    
    packages=("git" "curl" "wget" "sudo" "lsof" "iputils-ping")
    total=${#packages[@]}
    
    info_msg "Updating system..."
    apt update && apt upgrade -y > /dev/null 2>&1 &
    wait $!
    echo -e "${GREEN}✓${NC} System updated"
    
    info_msg "Installing packages..."
    apt install git curl wget sudo lsof iputils-ping -y > /dev/null 2>&1 &
    wait $!
    echo -e "${GREEN}✓${NC} Packages installed"
    
    info_msg "Setting up systemctl..."
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py > /dev/null 2>&1
    chmod -R 777 /bin/systemctl
    echo -e "${GREEN}✓${NC} systemctl configured"
    
    clear
    success_msg "All basic packages installed successfully!"
    echo -e "${CYAN}  Installed packages:${NC}"
    for pkg in "${packages[@]}"; do
        echo -e "  ${GREEN}✓${NC} ${WHITE}$pkg${NC}"
    done
    echo ""

# Option 4: Node.js
elif [ "$option" -eq 4 ]; then
    clear
    print_box "Node.js Installation" "${ORANGE}"
    echo ""
    echo -e "${BOLD}${WHITE}  Available Node.js Versions:${NC}"
    echo ""
    
    versions=("12.x" "13.x" "14.x" "15.x" "16.x" "17.x" "18.x" "19.x" "20.x")
    for i in "${!versions[@]}"; do
        num=$((i+1))
        echo -e "  ${CYAN}$num${NC}  Node.js ${BOLD}${WHITE}${versions[$i]}${NC}"
    done
    
    echo ""
    echo -e -n "${BOLD}${YELLOW}▶${NC} ${WHITE}Enter your choice (1-9):${NC} "
    read choice

    case $choice in
        1) version="12" ;;
        2) version="13" ;;
        3) version="14" ;;
        4) version="15" ;;
        5) version="16" ;;
        6) version="17" ;;
        7) version="18" ;;
        8) version="19" ;;
        9) version="20" ;;
        *)
            echo ""
            echo -e "${RED}✗ Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    info_msg "Removing old Node.js versions..."
    apt remove --purge node* nodejs npm -y > /dev/null 2>&1
    
    info_msg "Updating system..."
    apt update && apt upgrade -y > /dev/null 2>&1 &
    wait $!
    echo -e "${GREEN}✓${NC} System updated"
    
    info_msg "Installing curl..."
    apt install curl -y > /dev/null 2>&1
    
    info_msg "Downloading Node.js ${version}.x setup..."
    curl -sL "https://deb.nodesource.com/setup_${version}.x" -o /tmp/nodesource_setup.sh
    bash /tmp/nodesource_setup.sh > /dev/null 2>&1
    
    info_msg "Installing Node.js ${version}.x..."
    apt update -y > /dev/null 2>&1
    apt install -y nodejs > /dev/null 2>&1 &
    wait $!
    
    clear
    success_msg "Node.js ${version}.x installed successfully!"
    echo -e "${CYAN}  Version Information:${NC}"
    echo -e "  ${GREEN}✓${NC} ${WHITE}Node.js:${NC} ${BOLD}${CYAN}$(node --version)${NC}"
    echo -e "  ${GREEN}✓${NC} ${WHITE}npm:${NC} ${BOLD}${CYAN}$(npm --version)${NC}"
    echo ""

else
    echo -e "${RED}✗ Invalid option selected. Please choose 1-4.${NC}"
    exit 1
fi

# Footer
echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
print_center "Thank you for using VPSFREE.ES Setup Script" "${DIM}${GRAY}"
echo ""
