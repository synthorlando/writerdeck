#!/bin/bash
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
