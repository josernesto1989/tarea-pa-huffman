# Tarea PA - Algoritmo de Huffman

Proyecto de compresión y descompresión de texto UTF-8 utilizando el algoritmo de Huffman.

## Descripción

Este proyecto implementa una versión básica del algoritmo de Huffman para:

- calcular frecuencias de caracteres,
- construir un árbol de Huffman,
- generar códigos binarios para cada símbolo,
- comprimir un archivo de texto,
- descomprimirlo recuperando el contenido original.

## Estructura del proyecto

```text
.
├── main.py
├── requirements.txt
├── huffman/
│   ├── __init__.py
│   └── NodoHuffman.py
└── README.md
```

## Archivos importantes

- `huffman/NodoHuffman.py`: define la estructura del nodo usado por el árbol de Huffman.
- `main.py`: contiene la lógica principal del compresor y la ejecución de ejemplo.

## Requisitos

- Python 3.x
- Dependencias del proyecto (si aplica):

```bash
pip install -r requirements.txt
```

## Ejecución

Desde la raíz del proyecto, puedes ejecutar el programa con los siguientes comandos:

### Comprimir

```bash
python main.py --comprimir origen.txt salida/archivo.bin
```

### Descomprimir

```bash
python main.py --descomprimir salida/archivo.bin salida/recuperado.txt
```


## Funcionamiento

1. Se lee el contenido del archivo de texto.
2. Se cuentan las frecuencias de cada carácter.
3. Se construye el árbol de Huffman.
4. Se generan los códigos binarios para cada símbolo.
5. Se codifica el texto y se guarda en formato binario.
6. Se descomprime el archivo y se recupera el texto original.

## Nota

Este es un ejemplo didáctico de compresión con Huffman y está pensado para fines académicos y de aprendizaje.
