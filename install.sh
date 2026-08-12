#!/bin/bash

# colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# verificar si se ejecuta como root
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}No ejecutes este script como root. Ejecútalo como usuario normal.${NC}"
    exit 1
fi

#instalar primeras utilidades
echo -e "${GREEN}Instalando utilidades${NC}"
sudo apt update
sudo apt install network-manager acpi light tmux tilde syncthing -y

# configurar tmux
echo -e "${GREEN}Configurando utilidades${NC}"
cat > ~/.tmux.conf <<'EOF'
# Posición y color de la barra
set -g status-position top
set -g status-style bg=white,fg=black

# atajos para el brillo
bind -n F8 run-shell 'light -U 10'  # Disminuir brillo
bind -n F9 run-shell 'light -A 10'  # Aumentar brillo

# mostrar estado batería en vez de la hora
set-window-option -g status-right "#(acpi -b | grep -m1 -o -P '.{0,2}%')"
EOF

# configurar arranque automático de tmux y tilde PENDIENTE PROBAR
TMUX_TILDE_AUTOSTART='if [ -z "$TMUX" ]; then
    tmux new-session -A -s autostart tilde
fi'
echo "$TMUX_TILDE_AUTOSTART" >> ~/.bashrc
source ~/.bashrc

# Configurar permisos para light (control de brillo)
if ! groups | grep -q video; then
    echo -e "${GREEN}Configurando permisos para controlar el brillo...${NC}"
    sudo usermod -aG video $USER
fi

echo -e "${GREEN}Reinicia tu computador para usarlo como writerdeck.${NC}"

## acá empieza la segunda parte

# elegir usuario
read -p "Ingresa tu nombre de usuario: " USERNAME

# comprobar si el usuario existe
if ! id "$USERNAME" &>/dev/null; then
    echo "Error: El usuario '$USERNAME' no existe" >&2
    exit 1
fi

# crear directorio para el archivo
OVERRIDE_DIR="/etc/systemd/system/getty@tty1.service.d"
mkdir -p "$OVERRIDE_DIR"

# crear el archivo
OVERRIDE_FILE="$OVERRIDE_DIR/override.conf"
cat > "$OVERRIDE_FILE" <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USERNAME --noclear %I \$TERM
EOF

# darle permisos de ejecución
chmod 644 "$OVERRIDE_FILE"

# cargar systemd otra vez
systemctl daemon-reload

# configurar systemd para syncthing
echo "Configurando Syncthing..."
cat > /etc/systemd/system/syncthing@.service <<EOF
[Unit]
Description=Sincronizacion de archivos
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

systemctl enable syncthing@$USERNAME
systemctl start syncthing@$USERNAME

# Comprobar
echo "Revisando status de Syncthing..."
systemctl status syncthing@$USERNAME --no-pager

# reiniciar getty
systemctl restart getty@tty1

echo "Writerdeck configurado para '$USERNAME'. Reinicia para empezar a escribir."
