#!/bin/bash
# APEX-SENT Installation Script
# Team: AHMED EMAD | MOHAMED NAGY | ABDALLAH NEGEADA | ABDALLAH SALMAN

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BOLD}${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║   APEX-SENT - Installer v1.0           ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════╝${NC}"
echo

# 1. Check if the main script exists
if [ ! -f "apex-sent" ]; then
    echo -e "${RED}[!] Error: 'apex-sent' file not found in current directory.${NC}"
    echo -e "${YELLOW}[*] Please make sure you are in the correct folder.${NC}"
    exit 1
fi

# 2. Make it executable
echo -e "${YELLOW}[*] Making 'apex-sent' executable...${NC}"
chmod +x apex-sent
echo -e "${GREEN}[+] Done.${NC}"

# 3. Check for required tools (optional installation prompt)
echo -e "${YELLOW}[*] Checking dependencies...${NC}"
DEPS=("aircrack-ng" "airodump-ng" "aireplay-ng" "airmon-ng" "xterm" "iw" "hcxpcapngtool" "ethtool")
MISSING=()
for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        MISSING+=("$dep")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "${YELLOW}[!] Missing tools: ${MISSING[*]}${NC}"
    read -rp "Install them now? (y/N): " install_deps
    if [[ "$install_deps" =~ ^[Yy]$ ]]; then
        sudo apt update && sudo apt install -y "${MISSING[@]}"
    else
        echo -e "${YELLOW}[!] Some features may not work without these tools.${NC}"
    fi
fi

# 4. Determine installation directories
PRIMARY_DIR="/usr/local/bin"
SECONDARY_DIR="/usr/bin"
SCRIPT_NAME="apex-sent"
SOURCE_FILE="apex-sent"

# 5. Install to primary location
echo -e "\n${GREEN}Installing APEX-SENT to $PRIMARY_DIR/$SCRIPT_NAME...${NC}"
sudo cp "$SOURCE_FILE" "$PRIMARY_DIR/$SCRIPT_NAME"
sudo chmod +x "$PRIMARY_DIR/$SCRIPT_NAME"

# 6. Create symlink in /usr/bin so sudo can find it
echo -e "${GREEN}Creating symlink in $SECONDARY_DIR/$SCRIPT_NAME...${NC}"
sudo ln -sf "$PRIMARY_DIR/$SCRIPT_NAME" "$SECONDARY_DIR/$SCRIPT_NAME"

# 7. Create capture directory
CAP_DIR="/home/owl"
if [ ! -d "$CAP_DIR" ]; then
    echo -e "${YELLOW}[*] Creating capture directory: $CAP_DIR${NC}"
    sudo mkdir -p "$CAP_DIR"
    sudo chmod 755 "$CAP_DIR"
    echo -e "${GREEN}[+] Capture directory created.${NC}"
else
    echo -e "${GREEN}[+] Capture directory already exists.${NC}"
fi

# 8. Verify installation (normal user)
if command -v apex-sent &>/dev/null; then
    echo -e "\n${GREEN}✅ APEX-SENT installed successfully!${NC}"
    echo -e "You can now run it by typing: ${YELLOW}sudo apex-sent${NC}"
else
    echo -e "\n${YELLOW}Installation completed, but 'apex-sent' may not be in your PATH.${NC}"
    echo "You can run it with: $PRIMARY_DIR/$SCRIPT_NAME"
fi

# 9. Verify sudo access
if sudo -n true 2>/dev/null; then
    if sudo command -v apex-sent &>/dev/null; then
        echo -e "${GREEN}✅ 'sudo apex-sent' will also work.${NC}"
    else
        echo -e "${YELLOW}⚠️  'sudo apex-sent' might still not work. Try: sudo /usr/bin/apex-sent${NC}"
    fi
else
    echo -e "${YELLOW}Note: If you need 'sudo apex-sent', ensure /usr/bin is in sudo's secure_path.${NC}"
fi

echo -e "\n${GREEN}Thank you for installing APEX-SENT!${NC}"
echo -e "Audit responsibly! 📡"
