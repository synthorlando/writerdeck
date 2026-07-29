#!/bin/bash

# colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
sudo apt install network-manager acpi light tmux micro syncthing -y

# añadir el repositorio de backports para para debian 13
cat <<EOF | sudo tee /etc/apt/sources.list.d/debian-backports.sources
Types: deb
URIs: https://deb.debian.org/debian
Suites: trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

# actualizar la lista de paquetes e instalar kmscon 
sudo apt update
sudo apt install -t trixie-backports kmscon -y

# configurar tmux
echo -e "${GREEN}Configurando escritorio..${NC}"
mkdir -p ~/.config/systemd/user

# configurar servicio de systemd para tmux (con micro dentro)
cat > ~/.config/systemd/user/tmux.service <<EOF
[Unit]
Description=tmux with micro
After=multi-user.target

[Service]
Type=forking
ExecStart=/usr/bin/tmux new -s default -n micro /usr/bin/micro
ExecStop=/usr/bin/tmux kill-session -t default
Restart=on-failure
RestartSec=5s
Environment=TERM=xterm-256color

[Install]
WantedBy=default.target
EOF

# recargar systemd y habilitar el servicio
systemctl --user daemon-reload
systemctl --user enable tmux.service
systemctl --user start tmux.service

# configurar tmux
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

# configurar ruta de micro por defecto
echo -e "${GREEN}Configurando editor de texto...${NC}"
mkdir -p ~/.config/micro ~/notas

cat > ~/.config/micro/settings.json <<EOF
{
    "savefile.defaultpath": "$HOME/notas"
}
EOF

# Configurar permisos para light (control de brillo)
if ! groups | grep -q video; then
    echo -e "${YELLOW}Configurando permisos para controlar el brillo...${NC}"
    sudo usermod -aG video $USER
fi

echo -e "${GREEN}Reinicia tu computador para usarlo como writerdeck.${NC}"
