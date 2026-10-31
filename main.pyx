import argparse
import time

from huffman.CompresorHuffman cimport CompresorHuffman


cpdef void main():
    cdef object parser
    cdef object grupo
    cdef object args
    cdef str origen
    cdef str destino
    cdef double inicio
    cdef double tiempo_transcurrido
    cdef CompresorHuffman compresor

    parser = argparse.ArgumentParser(
        description=(
            "Compresor/Empaquetador binario personalizado "
            "sin librerías externas."
        )
    )

    grupo = parser.add_mutually_exclusive_group(required=True)
    grupo.add_argument(
        "--comprimir",
        nargs=2,
        metavar=("ARCHIVO_ORIGEN", "ARCHIVO_DESTINO"),
        help="Comprime/empaqueta un archivo de texto en formato binario.",
    )
    grupo.add_argument(
        "--descomprimir",
        nargs=2,
        metavar=("ARCHIVO_ORIGEN", "ARCHIVO_DESTINO"),
        help="Descomprime/recupera el archivo binario a texto plano.",
    )

    args = parser.parse_args()

    if args.comprimir is not None:
        origen, destino = args.comprimir
        compresor = CompresorHuffman(origen)
        inicio = time.perf_counter()
        compresor.comprimir(destino)
        tiempo_transcurrido = time.perf_counter() - inicio
        print(
            f"Tiempo de compresión en Cython: "
            f"{tiempo_transcurrido:.6f} segundos"
        )
    elif args.descomprimir is not None:
        origen, destino = args.descomprimir
        compresor = CompresorHuffman()
        inicio = time.perf_counter()
        compresor.descomprimir(origen, destino)
        tiempo_transcurrido = time.perf_counter() - inicio
        print(
            f"Tiempo de descompresión en Cython: "
            f"{tiempo_transcurrido:.6f} segundos"
        )


if __name__ == "__main__":
    main()
