# writerdeck
mi propio setup para un writerdeck, basado en debian ~13~ 12

este pedacito de software se entrega sin ninguna garantía, a menos que seas mi novia 

!!! ESTE PEDACITO DE SOFTWARE TODAVÍA NO ESTÁ LISTO !!!

# instalación 
1. instala debian 12 (bookworm) sin entorno de escritorio, con utilidades estándar de sistema y el paquete de servidor ssh
2. ejecuta este pedacito de código, que instala git, descarga el script de instalación de mi setup, lo vuelve ejecutable y lo instala.
```
sudo apt install git -y && git clone https://github.com/synthorlando/writerdeck.git && cd writerdeck && chmod +x install.sh && ./install.sh
```
3. si quieres que se inicie sesión automáticamente (solo recomendado para instalaciones encriptadas), ejecuta:
```
cd ~/writerdeck && chmod +x autologinl.sh && ./autologin.sh
```
4. reinicia y a escribir :3

# configuraciones opcionales
- puedes usar `sudo dpkg-reconfigure console-setup`  para configurar la fuente y su tamaño. Yo uso UTF-8, Latino 1, Terminus y 11x22.


# to-do
- configurar syncthing
