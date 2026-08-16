#!/bin/bash


# ==============COLORES PARA MENSAJES================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ==============VERIFICACIONES================

# Verificar si se ejecuta como root (NO permitir)
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}No ejecutes este script como root. Ejecútalo como usuario normal.${NC}"
    exit 1
fi

# Verificar que el usuario tenga permisos sudo
if ! sudo -v &>/dev/null; then
    echo -e "${RED}Necesitas permisos sudo para ejecutar este script.${NC}"
    exit 1
fi

# Guardar el usuario actual
CURRENT_USER=$(whoami)

# ====================INSTALAR DE UTILIDADES========================

echo -e "${GREEN}Instalando utilidades básicas...${NC}"
sudo apt update
sudo apt install -y network-manager acpi light tmux kmscon micro syncthing

# ====================CONFIGURANDO CARPETA========================

echo -e "${GREEN}Creando carpeta de trabajo...{NC}"
mkdir ~/writerdeck
chmod 700 ~/writerdeck

# ====================CONFIGURAR TMUX========================
echo -e "${GREEN}Configurando tmux...${NC}"
cat > ~/.tmux.conf <<'EOF'
# Posición y color de la barra
set -g status-position top
set -g status-style bg=black,fg=white

# Atajos para el brillo
bind -n F8 run-shell 'if command -v light &>/dev/null; then light -U 10; else echo "light no instalado"; fi'
bind -n F9 run-shell 'if command -v light &>/dev/null; then light -A 10; else echo "light no instalado"; fi'

# Mostrar estado batería en vez de la hora
set-window-option -g status-right "#(acpi -b | grep -m1 -o -P '.{0,2}%' || echo 'sin batería')"
EOF

# ====================AUTOSTART TMUX Y MICRO =======================

echo -e "${GREEN}Configurando autostart de tmux y tilde...${NC}"

# Añadir al .bashrc solo si no existe ya
if ! grep -q "tmux new-session -A -s autostart -c /writerdeck micro" ~/.bashrc; then
    cat >> ~/.bashrc <<'EOF'

# Iniciar tmux con micro en /writerdeck
if [ -z "$TMUX" ]; then
    tmux new-session -A -s autostart -c /writerdeck micro
fi
EOF
    echo -e "${GREEN}Configuración completada${NC}"

# ====================CONTROLES DE BRILLO =======================

if ! groups | grep -q video; then
    echo -e "${GREEN}Configurando permisos para control de brillo...${NC}"
    sudo usermod -aG video $CURRENT_USER
    echo -e "${YELLOW}Los cambios requieren reinicio para aplicarse.${NC}"
fi

# ====================CONFIGURANDO AUTOLOGIN. ELEGIR USUARIO=======================

echo -e "${GREEN}Configurando autologin...${NC}"

# Solicitar usuario para autologin
read -p "Ingresa tu nombre de usuario para autologin (presiona Enter para usar '$CURRENT_USER'): " INPUT_USER
USERNAME="${INPUT_USER:-$CURRENT_USER}"

# Verificar que el usuario existe
if ! id "$USERNAME" &>/dev/null; then
    echo -e "${RED}Error: El usuario '$USERNAME' no existe${NC}"
    exit 1
fi

# ====================AUTOLOGIN Y TMUX=======================

echo -e "${GREEN}Configurando autologin para $USERNAME...${NC}"

OVERRIDE_DIR="/etc/systemd/system/getty@tty1.service.d"
sudo mkdir -p "$OVERRIDE_DIR"

OVERRIDE_FILE="$OVERRIDE_DIR/override.conf"
sudo tee "$OVERRIDE_FILE" > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USERNAME --noclear %I \$TERM
EOF

# Dar permisos
sudo chmod 644 "$OVERRIDE_FILE"

# Recargar systemd
sudo systemctl daemon-reload

# ====================CONFIGURANDO SYNCTHING=======================

echo -e "${GREEN}Configurando Syncthing para $USERNAME...${NC}"

# Crear archivo de servicio si no existe
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

# Script para configurar UFW para Syncthing
echo "Configurando UFW para Syncthing..."

# Permitir puertos de Syncthing
sudo ufw allow 22000/tcp   # Sincronización
sudo ufw allow 21027/udp   # Descubrimiento
sudo ufw allow 8384/tcp    # Interfaz web
sudo ufw allow 22/tcp      # SSH

# Habilitar UFW
sudo ufw --force enable

# Habilitar e iniciar Syncthing
sudo systemctl enable syncthing@$USERNAME
sudo systemctl start syncthing@$USERNAME

# Verificar estado
echo -e "${GREEN}Estado de Syncthing:${NC}"
sudo systemctl status syncthing@$USERNAME --no-pager

# Reiniciar getty

echo -e "${GREEN}Reiniciando servicio getty...${NC}"
sudo systemctl restart getty@tty1

# Eliminar otros contenidos de writerdeck
rm -rf ~/writerdeck/* ~/writerdeck/.* 2>/dev/null

#Añadir carpeta writerdeck para Syncthing
syncthing cli add-folder --id=writerdeck --path=~/writerdeck --label="WriterDeck" --type=sendreceive

# ====================TODO LISTO=======================
# Obtener la IP local de la máquina (excluyendo loopback y IPv6)
LOCAL_IP=$(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

echo -e "\n${GREEN}¡Tu writerdeck fue configurado exitosamente!${NC}"
echo -e "\n${YELLOW}IMPORTANTE:${NC}"
echo "\n${RED}Primero, reinicia tu computador para aplicar todos los cambios.${NC}"
echo -e "${YELLOW}Luego, para acceder a la interfaz web de Syncthing desde otro equipo en tu red local:${NC}"
echo -e "${GREEN}1. Ejecuta en tu segundo computador: ssh -L 8384:localhost:8384 $USERNAME@$LOCAL_IP${NC}"
echo -e "${GREEN}2. Luego abre en su navegador: http://$LOCAL_IP:8384${NC}"
