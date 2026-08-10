# Synthorlando's Writerdeck

Mi propio setup para convertir un computador viejo de 64 bits en un writerdeck, basado en Debian ~13~ 12.

Este pedacito de software se entrega **sin ninguna garantía**, a menos que seas mi novia.

Tus necesidades y preferencias pueden ser distintas a las mías y las de mi novia. No cubriré esas necesidades, eres libre de adaptar este setup como quieras.

**[ ¡ ADVERTENCIA ! ]** Si vas a usar la opción de *autologin*, [encripta el sistema con LUKS durante la instalación.](https://wiki.upv.es/confluence/spaces/MANUALES/pages/1092977295/Cifrar+el+disco+con+LUKS+en+equipos+GNU+Linux#CifrareldiscoconLUKSenequiposGNU%2FLinux-%F0%9F%94%90Cifradodeldiscodurantelainstalaci%C3%B3ndelsistema)** 

---

# Antes de empezar
Si no eres mi novia, me veo en la obligación de pedirte encarecidamente que leas todas las instrucciones primero, porque en ella sí confío.

En tu candidato a writerdeck, instala [Debian 12 "Bookworm"](https://www.debian.org/releases/bookworm/debian-installer/) (opción "netinst CD image", amd64).

No uso Debian 13 "Trixie" porque no tiene Tilde, el editor de texto que usa este setup, en sus repos. Tampoco pruebo todavía configurar un writerdeck de 32 bits. 


--- 

# 1. Instalación base
1. Ejecuta esta línea de comandos, que instala `git`, descarga el script de instalación de mi setup, lo vuelve ejecutable y lo instala.
```
sudo apt install git -y && git clone https://github.com/synthorlando/writerdeck.git && cd writerdeck && chmod +x install.sh && ./install.sh
```
2. Reinicia tu candidato a writerdeck.
3. Se encenderá como un writerdeck hecho y derecho, ya puedes empezar a escribir.

# 2. Configurar el autologin (opcional)
Si quieres que tu writerdeck inicie sesión automáticamente, puedes usar el siguiente script. **Solo deberías usarlo en instalaciones encriptadas**.
```
cd ~/writerdeck && chmod +x autologin.sh && sudo ./autologin.sh
```

# Sincronización (vía Syncthing) 
**[ ¡ ADVERTENCIA ! ]** Aún no pruebo este setup en Windows 11. 
1. Conecta tu writerdeck y el PC con el que quieres sincronizar las notas a la misma red de Wi-Fi.
2. Procura tener instalado `openssh-client` en tu otro PC si corre Linux, u OpenSSH si corre Windows (Puedes seguir las instrucciones de [este tutorial](https://web.archive.org/web/20250724214319/https://www.xataka.com/basics/ssh-windows-11-que-como-configurarlo-paso-a-paso) hasta "pulsar en Iniciar para simplemente lanzar el servidor SSH").
3. Ejecuta esta línea de comandos **en tu writerdeck**. 
```
cd ~/writerdeck && chmod +x sync.sh && sudo ./sync.sh
```
4. Sigue las instrucciones del script y configura las carpetas a sincronizar **desde tu otro PC**. Solo tendrás que hacerlo una vez. 

# Configuraciones extra
- Puedes usar `sudo dpkg-reconfigure console-setup` **en tu writerdeck** para configurar la fuente y su tamaño. Personalmente, uso UTF-8, Latino 1, Terminus y 11x22.

