# Filtro de Sharpening y Oversharpening


### Sistema Operativo
- **Sistema Operativo Linux**. El programa de filtro fue realizado en su totalidad en un entorno linux y se desconoce la configuración del ambiente de desarrollo en otros sistemas operativos.
- **Procesador con arquitectura X86_64**. Para poder ejecutar el código sin ninguna configuración extra, verificar que la arquitectura de la computadora sea la mencionada. Para realizar la verificación, escriba el siguiente comando en la terminal.
```sh
$ uname -a
```

Se observará un mensaje similar al siguiente, donde deberíamos verificar que la parte resaltada aparezca:
```sh
Linux userpc 5.3.0-51-generic #44~18.04.2-Ubuntu SMP Thu Apr 23 14:27:18 UTC 2020 **x86_64 x86_64 x86_64** GNU/Linux
```
- **NASM Assembly**. Se utilizó NASM para el desarrollo y ejecución del filtro. Para la instalación escribir los siguientes comandos en la terminal.
 ```sh
$ sudo apt update
$ sudo apt-get install nasm
```
### Herramientas de desarrollo
- No se necesita un IDE específico para poder ver y modificar el código, cualquier editor de texto funcionará.
- Por facilidad y conveniencia, se utilizó VS Code con la extensión para reconocimiento de x86_64, la cual se puede instalar en VS Code con CTRL + P y escribir el siguiente comando:
 ```sh
ext install 13xforever.language-x86-64-assembly
```
### Visualizaciones
  - **Intalación.** Se proveen archivos .sh para instalar las dependencias si ya se tiene python o en caso contrario, otro archivo para instalar python con las dependencias. 
- Para instalar python + las bibliotecas correr los siguientes comandos en la terminal:
 ```sh
$ chmod +x python+libraries.sh
$ ./python+libraries.sh
```
- Para instalar solo las bibliotecas:
 ```sh
$ chmod +x libraries.sh
$ ./libraries.sh
```

- Para instalar bibliotecas por separado leer los siguientes pasos:

  - **Python**. Se utiliza un script de python para recibir la imagen de entrada y para visualizar los resultados producidos. Para instalar python en Linux, escriba el siguiente comando en la terminal.
 ```sh
$ sudo apt-get update
$ sudo apt-get install python3.6
```
- **Biblioteca numpy**. Se utiliza para el manejo de matrices. Instalar con el siguiente comando.
 ```sh
$ pip3 install numpy
```
- **Biblioteca matplotlib**. Se utiliza para la visualización de resultados. Instalar con el siguiente comando.
 ```sh
$ pip3 install matplotlib
```

- **Biblioteca PIL**. Se utiliza para guardar los resultados como imágenes. Instalar con el siguiente comando.
 ```sh
$ pip3 install Pillow==2.2.2
```
