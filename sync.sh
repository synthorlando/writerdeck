#!/bin/bash

# revisar si está en root
if [ "$(id -u)" -ne 0 ]; then
    echo "Por favor, ejecuta este script con sudo."
    exit 1
fi

# Elegir el usuario
read -p "Ingresa tu nombre de usuario: " USERNAME
if ! id "$USERNAME" &>/dev/null; then
    echo "El usuario $USERNAME no existe."
    exit 1
fi

# configurar systemd 
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


