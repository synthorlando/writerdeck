# writerdeck
mi propio setup para un writerdeck, basado en debian ~13~ 12

este pedacito de software se entrega sin ninguna garantía, a menos que seas mi novia 

[ ! ] si vas a usar la opción de **autologin**, encripta el sistema con luks durante la instalación.

# instalación 
1. instala debian 12 (bookworm) sin entorno de escritorio, con utilidades estándar de sistema y el paquete de servidor ssh.
2. ejecuta esta línea de comandos, que instala git, descarga el script de instalación de mi setup, lo vuelve ejecutable y lo instala.
```
sudo apt install git -y && git clone https://github.com/synthorlando/writerdeck.git && cd writerdeck && chmod +x install.sh && ./install.sh
```
4. reinicia y a escribir. 

# configurar el autologin
si quieres que tu writerdeck inicie sesión automáticamente, puedes usar el siguiente script. **solo usarlo en instalaciones encriptadas**.
```
cd ~/writerdeck && chmod +x autologin.sh && sudo ./autologin.sh
```

# sincronización (vía syncthing) 
1. conecta tu writerdeck y el pc en el que vas a sincronizar las notas a la misma red de wifi.
2. procura tener instalado `openssh-client` en tu otro pc si corre Linux, u OpenSSH si corre windows (Puedes seguir las instrucciones de [este tutorial](https://web.archive.org/web/20250724214319/https://www.xataka.com/basics/ssh-windows-11-que-como-configurarlo-paso-a-paso) hasta "pulsar en Iniciar para simplemente lanzar el servidor SSH").
3. ejecuta esta otra línea de comandos en tu writerdeck. 
```
cd ~/writerdeck && chmod +x sync.sh && sudo ./sync.sh
```
4. sigue las instrucciones del script y configura las carpetas a sincronizar desde tu otro pc. solo tendrás que hacerlo una vez. 

# configuraciones extra
- puedes usar `sudo dpkg-reconfigure console-setup` en tu writerdeck para configurar la fuente y su tamaño. Yo uso UTF-8, Latino 1, Terminus y 11x22.


# to-do
- testear
