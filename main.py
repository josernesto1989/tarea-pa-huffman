
import os
from huffman import CompresorHuffman
import argparse

def main():
    parser = argparse.ArgumentParser(description="Compresor/Empaquetador binario personalizado sin librerías externas.")
    
    # Creamos un grupo exclusivo para que el usuario deba elegir obligatoriamente entre comprimir o descomprimir
    grupo = parser.add_mutually_exclusive_group(required=True)
    
    grupo.add_argument(
        '--comprimir', 
        nargs=2, 
        metavar=('ARCHIVO_ORIGEN', 'ARCHIVO_DESTINO'), 
        help='Comprime/empaqueta un archivo de texto en formato binario.'
    )
    grupo.add_argument(
        '--descomprimir', 
        nargs=2, 
        metavar=('ARCHIVO_ORIGEN', 'ARCHIVO_DESTINO'), 
        help='Descomprime/recupera el archivo binario a texto plano.'
    )
    
    args = parser.parse_args()
    
    
    if args.comprimir:
        origen, destino = args.comprimir
        compresor = CompresorHuffman(origen)
        compresor.comprimir( destino)
    elif args.descomprimir:
        origen, destino = args.descomprimir
        descomprimir = CompresorHuffman()
        descomprimir.descomprimir(origen, destino)

# Ejemplo de uso:
if __name__ == "__main__":
    main()
  # Crear archivo de prueba
#   with open("salida/origen.txt", "w", encoding="utf-8") as f:
#     f.write("este es un texto de prueba para el algoritmo de huffman clase de programacion 20 de octubre del 2026 10 a 12 am")

#   compresor = CompresorHuffman("salida/origen.txt")
#   codigos, raiz = compresor.comprimir("salida/archivo.bin")
#   compresor.descomprimir("salida/archivo.bin", "salida/recuperado.txt")
