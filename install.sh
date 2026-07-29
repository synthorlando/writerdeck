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

# configurar arranque automático de tmux PENDIENTE

# Configurar permisos para light (control de brillo)
if ! groups | grep -q video; then
    echo -e "${YELLOW}Configurando permisos para controlar el brillo...${NC}"
    sudo usermod -aG video $USER
fi

echo -e "${GREEN}Reinicia tu computador para usarlo como writerdeck.${NC}"

