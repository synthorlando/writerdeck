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
sudo apt install -y network-manager acpi light tmux kmscon micro syncthing openssh-server

# ====================CONFIGURANDO CARPETA========================
echo -e "${GREEN}Creando carpeta de trabajo...${NC}"
mkdir -p ~/writerdeck
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
echo -e "${GREEN}Configurando autostart de tmux y micro...${NC}"

# Añadir al .bashrc solo si no existe ya
if ! grep -q "tmux new-session -A -s autostart -c ~/writerdeck micro" ~/.bashrc; then
    cat >> ~/.bashrc <<'EOF'

# Iniciar tmux con micro en writerdeck
if [ -z "$TMUX" ]; then
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

# ====================CONFIGURANDO AUTOLOGIN =======================
echo -e "${GREEN}Configurando autologin...${NC}"

# Solicitar usuario para autologin
read -p "Ingresa tu nombre de usuario para autologin (presiona Enter para usar '$CURRENT_USER'): " INPUT_USER
USERNAME="${INPUT_USER:-$CURRENT_USER}"

# Verificar que el usuario existe
if ! id "$USERNAME" &>/dev/null; then
    echo -e "${RED}Error: El usuario '$USERNAME' no existe${NC}"
    exit 1
fi

# ====================AUTOLOGIN =======================
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

# ====================CONFIGURAR SSH =======================
echo -e "${GREEN}Configurando SSH...${NC}"

# Habilitar e iniciar SSH
sudo systemctl enable ssh
sudo systemctl start ssh

# Verificar que SSH está corriendo
if sudo systemctl is-active --quiet ssh; then
    echo -e "${GREEN}SSH está activo y funcionando${NC}"
else
    echo -e "${RED}Error: SSH no pudo iniciarse${NC}"
    exit 1
fi

# ====================CONFIGURAR UFW =======================
echo -e "${GREEN}Configurando UFW para Syncthing...${NC}"

# Permitir puertos necesarios
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 22000/tcp   # Sincronización Syncthing
sudo ufw allow 21027/udp   # Descubrimiento Syncthing
sudo ufw allow 8384/tcp    # Interfaz web Syncthing

# Habilitar UFW
sudo ufw --force enable

# ====================INICIAR SYNCTHING =======================
echo -e "${GREEN}Iniciando Syncthing...${NC}"

# Habilitar e iniciar Syncthing
sudo systemctl enable syncthing@$USERNAME
sudo systemctl start syncthing@$USERNAME

# Verificar estado
echo -e "${GREEN}Estado de Syncthing:${NC}"
sudo systemctl status syncthing@$USERNAME --no-pager

# Eliminar otros contenidos de writerdeck
rm -rf ~/writerdeck/* ~/writerdeck/.* 2>/dev/null

# Esperar un poco para que Syncthing se inicie completamente
sleep 5

# Añadir carpeta writerdeck para Syncthing
echo -e "${GREEN}Configurando carpeta writerdeck en Syncthing...${NC}"
syncthing cli add-folder --id=writerdeck --path=/home/$USERNAME/writerdeck --label="writerDeck" --type=sendreceive 2>/dev/null

# ====================TODO LISTO=======================
# Obtener la IP local
LOCAL_IP=$(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

echo -e "\n${GREEN}¡Tu writerdeck fue configurado exitosamente!${NC}"

echo -e "\n${YELLOW}¿Cómo configurar la sincronización?${NC}"

echo -e "\n${GREEN}Tienes que acceder a la interfaz web de Syncthing desde otro equipo conectado a la misma red WiFi:${NC}"
echo -e "\n${RED}[!] Si ya está corriendo Syncthing, cierra esa sesión [!]${NC}"
echo -e "${GREEN}1. Ejecuta en este segundo computador: ssh -L 8384:localhost:8384 $USERNAME@$LOCAL_IP${NC}"
echo -e "${GREEN}2. Abre en su navegador: http://localhost:8384${NC}"
echo -e "${GREEN}3. Configura las carpetas a sincronizar desde ahí${NC}"

echo -e "\n${YELLOW}Una vez leído esto (anota las direcciones, por favor), reinicia tu writerdeck con el comando 'sudo reboot' y... ¡a escribir!${NC}"
