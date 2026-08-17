#!/bin/bash

# ==============COLORES PARA MENSAJES================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ==============VERIFICACIONES================
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}No ejecutes este script como root. Ejecútalo como usuario normal.${NC}"
    exit 1
fi

if ! sudo -v &>/dev/null; then
    echo -e "${RED}Necesitas permisos sudo para ejecutar este script.${NC}"
    exit 1
fi

CURRENT_USER=$(whoami)

# ====================INSTALAR UTILIDADES========================
echo -e "${GREEN}Instalando utilidades básicas...${NC}"
sudo apt update
sudo apt install -y network-manager acpi light tmux kmscon micro syncthing openssh-server

# ====================CONFIGURAR CARPETA========================
echo -e "${GREEN}Creando carpeta de trabajo...${NC}"
mkdir -p ~/writerdeck
chmod 700 ~/writerdeck

# ====================CONFIGURAR TMUX========================
echo -e "${GREEN}Configurando tmux...${NC}"
cat > ~/.tmux.conf <<'EOF'
set -g status-position top
set -g status-style bg=black,fg=white

bind -n F8 run-shell 'if command -v light &>/dev/null; then light -U 10; else echo "light no instalado"; fi'
bind -n F9 run-shell 'if command -v light &>/dev/null; then light -A 10; else echo "light no instalado"; fi'

set-window-option -g status-right "#(acpi -b | grep -m1 -o -P '.{0,2}%' || echo 'sin batería')"
EOF

# ====================CONFIGURAR MICRO========================
echo -e "${GREEN}Configurando micro...${NC}"
mkdir -p ~/.config/micro
cat > ~/.config/micro/settings.json <<'EOF'
{
    "autosave": 300,
    "fastdirty": true,
    "fileformat": "unix",
    "mkparents": true,
    "softwrap": true,
    "statusline": true,
    "tabsize": 4
}
EOF

# ====================AUTOSTART TMUX Y MICRO =======================
echo -e "${GREEN}Configurando autostart...${NC}"

if ! grep -q "tmux new-session -A -s autostart" ~/.bashrc; then
    cat >> ~/.bashrc <<'EOF'

# Iniciar tmux con micro en writerdeck
if [ -z "$TMUX" ]; then
    cd ~/writerdeck
    tmux new-session -A -s autostart -c ~/writerdeck micro
fi
EOF
    echo -e "${GREEN}Configuración completada${NC}"
fi

# ====================CONTROLES DE BRILLO =======================
if ! groups | grep -q video; then
    echo -e "${GREEN}Configurando permisos para control de brillo...${NC}"
    sudo usermod -aG video $CURRENT_USER
    echo -e "${YELLOW}Los cambios requieren reinicio para aplicarse.${NC}"
fi

# ====================AUTOLOGIN =======================
echo -e "${GREEN}Configurando autologin...${NC}"

read -p "Ingresa tu nombre de usuario para autologin (presiona Enter para usar '$CURRENT_USER'): " INPUT_USER
USERNAME="${INPUT_USER:-$CURRENT_USER}"

if ! id "$USERNAME" &>/dev/null; then
    echo -e "${RED}Error: El usuario '$USERNAME' no existe${NC}"
    exit 1
fi

OVERRIDE_DIR="/etc/systemd/system/getty@tty1.service.d"
sudo mkdir -p "$OVERRIDE_DIR"

OVERRIDE_FILE="$OVERRIDE_DIR/override.conf"
sudo tee "$OVERRIDE_FILE" > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USERNAME --noclear %I \$TERM
EOF

sudo chmod 644 "$OVERRIDE_FILE"
sudo systemctl daemon-reload

# ====================SSH =======================
echo -e "${GREEN}Configurando SSH...${NC}"
sudo systemctl enable ssh
sudo systemctl start ssh

if sudo systemctl is-active --quiet ssh; then
    echo -e "${GREEN}SSH está activo y funcionando${NC}"
else
    echo -e "${RED}Error: SSH no pudo iniciarse${NC}"
    exit 1
fi

# ====================UFW =======================
echo -e "${GREEN}Configurando UFW...${NC}"
sudo ufw allow 22/tcp
sudo ufw allow 22000/tcp
sudo ufw allow 21027/udp
sudo ufw allow 8384/tcp
sudo ufw --force enable

# ====================SYNCTHING =======================
echo -e "${GREEN}Configurando Syncthing...${NC}"

sudo tee /etc/systemd/system/syncthing@.service > /dev/null <<'EOF'
[Unit]
Description=Sincronizacion de archivos.
Documentation=man:syncthing(1)
After=network.target

[Service]
Type=simple
User=%i
Group=%i
ExecStart=/usr/bin/syncthing serve --home=/home/%i/.config/syncthing
Restart=on-failure
RestartSec=5
SuccessExitStatus=3 4

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable syncthing@$USERNAME
sudo systemctl start syncthing@$USERNAME

sudo systemctl status syncthing@$USERNAME --no-pager

rm -rf ~/writerdeck/* ~/writerdeck/.* 2>/dev/null
sleep 5

# ====================IP Y FINAL =======================
LOCAL_IP=$(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

echo -e "\n${GREEN}¡Tu writerdeck fue configurado exitosamente!${NC}"

echo -e "\n${YELLOW}¿Cómo configurar la sincronización?${NC}"
echo -e "\n${GREEN}Tienes que acceder a la interfaz web de Syncthing desde otro equipo conectado a la misma red WiFi:${NC}"
echo -e "\n${RED}[!] Si ya está corriendo Syncthing, cierra esa sesión [!]${NC}"
echo -e "${GREEN}1. Ejecuta en este segundo computador: ssh -L 8384:localhost:8384 $USERNAME@$LOCAL_IP${NC}"
echo -e "${GREEN}2. Abre en su navegador: http://localhost:8384${NC}"
echo -e "${GREEN}3. Configura las carpetas a sincronizar desde ahí${NC}"

echo -e "\n${YELLOW}Una vez leído esto (anota las direcciones, por favor), reinicia tu writerdeck con el comando 'sudo reboot' y... ¡a escribir!${NC}"
