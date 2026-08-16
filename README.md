# Synthorlando's Writerdeck

Mi propio setup para convertir un computador viejo de 64 bits en un writerdeck, basado en Debian ~13~ 12.

Este pedacito de software se entrega **sin ninguna garantía**, a menos que seas mi novia.

Tus necesidades y preferencias pueden ser distintas a las mías y las de mi novia. No cubriré esas necesidades, eres libre de adaptar este setup como quieras.

No uso Debian 13 "Trixie" porque no quería configurar los backports para kmscon.

---

# Antes de empezar
En tu candidato a writerdeck, instala [Debian 12 "Bookworm"](https://www.debian.org/releases/bookworm/debian-installer/) ("netinst CD image", amd64).

Deja la cuenta de superusuario en blanco.

![pantalla de superusuario](https://github.com/synthorlando/writerdeck/blob/main/img/sudo.png?raw=true)

**Encripta el sistema con LUKS durante la instalación.](https://wiki.upv.es/confluence/spaces/MANUALES/pages/1092977295/Cifrar+el+disco+con+LUKS+en+equipos+GNU+Linux#CifrareldiscoconLUKSenequiposGNU%2FLinux-%F0%9F%94%90Cifradodeldiscodurantelainstalaci%C3%B3ndelsistema)** porque esta configuración usa la opción de _autologin._

![pantalla de encriptación](https://github.com/synthorlando/writerdeck/blob/main/img/luks.png?raw=true)

Elige solo instalar las utilidades estándar del sistema y servidor ssh. No escojas ningún escritorio.

![elección de software](https://github.com/synthorlando/writerdeck/blob/main/img/software.png?raw=true)

(Se me olvidó sacarle captura)

---

# Instalación
```
sudo apt install git -y && git clone https://github.com/synthorlando/writerdeck.git && cd writerdeck && chmod +x install.sh && ./install.sh
```

# Uso
[PENDIENTE]
