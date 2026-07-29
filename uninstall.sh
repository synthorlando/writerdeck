#!/bin/bash

# colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Este script eliminará la configuación del writerdeck${NC}"
echo -e "\n${GREEN}[1/7] Deteniendo servicios...${NC}"

# Detener servicio de tmux
systemctl --user stop tmux.service 2>/dev/null
systemctl --user disable tmux.service 2>/dev/null

# matar sesiones de tmux existentes
tmux kill-session -t default 2>/dev/null
tmux kill-server 2>/dev/null

echo -e "\n${GREEN}[2/7] Eliminando archivos de configuración...${NC}"

# Eliminar configuración de tmux
rm -f ~/.tmux.conf
rm -f ~/.tmux.conf.local 2>/dev/null

# Eliminar configuración de micro
rm -rf ~/.config/micro

# Eliminar servicio de systemd
rm -f ~/.config/systemd/user/tmux.service

echo -e "${GREEN}✓ Archivos de configuración eliminados${NC}"

echo -e "\n${GREEN}[3/7] Desinstalando paquetes...${NC}"

# desinstalar todo menos network-manager
sudo apt remove acpi light tmux micro syncthing
sudo apt purge acpi light tmux micro syncthing
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean

echo -e "\n${GREEN}[7/7] Recargando systemd...${NC}"
systemctl --user daemon-reload

echo -e "${GREEN}Desinstalación realizada con éxito, reinicia para aplicar los cambios :D${NC}"
