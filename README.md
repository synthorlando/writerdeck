# writerdeck
mi propio setup para un writerdeck, basado en debian ~13~ 12

este pedacito de software se entrega sin ninguna garantía, a menos que seas mi novia 

!!! ESTE PEDACITO DE SOFTWARE TODAVÍA NO ESTÁ LISTO !!!

# instalación 
1. instala debian 12 (bookworm) sin entorno de escritorio, con utilidades estándar de sistema y el paquete de servidor ssh.
2. ejecuta esta línea de comandos, que instala git, descarga el script de instalación de mi setup, lo vuelve ejecutable y lo instala.
```
sudo apt install git -y && git clone https://github.com/synthorlando/writerdeck.git && cd writerdeck && chmod +x install.sh && ./install.sh
```
4. reinicia y a escribir :3

# configurar la sincronización
si quieres que tu writerdeck inicie sesión automáticamente, puedes usar el siguiente script. recomiendo solo usarlo en instalaciones encriptadas de debian 12.
```
cd ~/writerdeck && chmod +x autologin.sh && sudo ./autologin.sh
```

# sincronización (vía syncthing)
1. conecta tu writerdeck y el pc en el que vas a sincronizar las notas a la misma red de wifi.
2. ejecuta esta otra línea de comandos para instalar syncthing y volver ejecutable su script. Luego, sigue las 
```
sudo apt install syncthing && cd ~/writerdeck && chmod +x sync.sh && sudo ./install.sh
```
3. sigue las instrucciones del script y configura las carpetas a sincronizar desde tu otro pc.

# configuraciones opcionales
- puedes usar `sudo dpkg-reconfigure console-setup`  para configurar la fuente y su tamaño. Yo uso UTF-8, Latino 1, Terminus y 11x22.


# to-do
- configurar syncthing
