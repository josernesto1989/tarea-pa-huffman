
import os
from huffman import CompresorHuffman


# Ejemplo de uso:
if __name__ == "__main__":
  # Crear archivo de prueba
  with open("salida/origen.txt", "w", encoding="utf-8") as f:
    f.write("este es un texto de prueba para el algoritmo de huffman clase de programacion 20 de octubre del 2026 10 a 12 am")

  compresor = CompresorHuffman("salida/origen.txt")
  codigos, raiz = compresor.comprimir("salida/archivo.bin")
  compresor.descomprimir("salida/archivo.bin", raiz, "salida/recuperado.txt")