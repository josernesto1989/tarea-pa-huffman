cimport cython
import heapq
from collections import Counter

from .CNodoHuffman cimport NodoHuffman


cdef class CompresorHuffman:
    def __init__(self, object ruta_archivo=None):
        self.ruta_archivo = ruta_archivo
        self.heap = []
        self.codigos = {}
        self.inverso_codigos = {}
        self._arbol_raiz = None

    cpdef dict _calcular_frecuencias(self, str texto):
        return dict(Counter(texto))

    cpdef object _construir_arbol(self, dict frecuencias):
        cdef object char
        cdef Py_ssize_t freq
        cdef NodoHuffman nodo1
        cdef NodoHuffman nodo2
        cdef NodoHuffman combinado

        self.heap = []
        self.codigos = {}
        self.inverso_codigos = {}

        for char, freq in frecuencias.items():
            heapq.heappush(self.heap, NodoHuffman(char, freq))

        while len(self.heap) > 1:
            nodo1 = heapq.heappop(self.heap)
            nodo2 = heapq.heappop(self.heap)
            combinado = NodoHuffman(None, nodo1.freq + nodo2.freq)
            combinado.left = nodo1
            combinado.right = nodo2
            heapq.heappush(self.heap, combinado)

        return self.heap[0] if self.heap else None

    cpdef void _generar_codigos_rec(
        self, NodoHuffman nodo, str codigo_actual
    ):
        cdef str codigo

        if nodo is None:
            return

        if nodo.char is not None:
            codigo = codigo_actual if codigo_actual else "0"
            self.codigos[nodo.char] = codigo
            self.inverso_codigos[codigo] = nodo.char
            return

        self._generar_codigos_rec(nodo.left, codigo_actual + "0")
        self._generar_codigos_rec(nodo.right, codigo_actual + "1")

    cpdef str _pad_encoded_text(self, str encoded_text):
        cdef int extra_padding = 8 - len(encoded_text) % 8
        encoded_text += "0" * extra_padding
        return "{0:08b}".format(extra_padding) + encoded_text

    cpdef bytearray _get_byte_array(self, str padded_encoded_text):
        cdef bytearray resultado
        cdef Py_ssize_t indice

        if len(padded_encoded_text) % 8 != 0:
            raise ValueError("El texto codificado no está alineado a bytes.")

        resultado = bytearray()
        for indice in range(0, len(padded_encoded_text), 8):
            resultado.append(int(padded_encoded_text[indice:indice + 8], 2))
        return resultado

    cpdef tuple comprimir(self, str ruta_salida):
        cdef str texto
        cdef dict frecuencias
        cdef bytes clave_bytes
        cdef bytes bytes_resultado
        cdef NodoHuffman raiz
        cdef str texto_codificado
        cdef list codigos_texto
        cdef bytearray bytes_salida
        cdef object clave
        cdef str char
        cdef int valor

        with open(self.ruta_archivo, "r", encoding="utf-8") as archivo:
            texto = archivo.read()

        frecuencias = self._calcular_frecuencias(texto)
        bytes_resultado = len(frecuencias).to_bytes(2, byteorder="big")

        for clave, valor in frecuencias.items():
            clave_bytes = str(clave).encode("utf-8")
            bytes_resultado += (
                len(clave_bytes).to_bytes(2, byteorder="big")
                + clave_bytes
                + valor.to_bytes(4, byteorder="big")
            )

        raiz = self._construir_arbol(frecuencias)
        self._generar_codigos_rec(raiz, "")
        codigos_texto = []
        for char in texto:
            codigos_texto.append(self.codigos[char])
        texto_codificado = "".join(codigos_texto)
        bytes_salida = self._get_byte_array(
            self._pad_encoded_text(texto_codificado)
        )

        with open(ruta_salida, "wb") as salida:
            salida.write(bytes_resultado)
            salida.write(bytes_salida)

        self._arbol_raiz = raiz
        return self.codigos, raiz

    cpdef str _remover_padding(self, str padded_encoded_text):
        cdef int extra_padding
        cdef str texto_codificado

        if len(padded_encoded_text) < 8:
            raise ValueError("El archivo comprimido no contiene padding válido.")

        extra_padding = int(padded_encoded_text[:8], 2)
        if extra_padding < 1 or extra_padding > 8:
            raise ValueError("El archivo comprimido contiene padding inválido.")

        texto_codificado = padded_encoded_text[8:]
        if extra_padding > len(texto_codificado):
            raise ValueError("El archivo comprimido contiene padding inválido.")
        return texto_codificado[:-extra_padding]

    cpdef str descomprimir(self, str ruta_comprimido, str ruta_salida):
        cdef int numero_elementos
        cdef int longitud_clave
        cdef int valor
        cdef dict frecuencias
        cdef str clave
        cdef NodoHuffman raiz
        cdef str bits
        cdef str texto_codificado
        cdef list texto_decodificado
        cdef NodoHuffman nodo_actual
        cdef str resultado
        cdef bytes byte
        cdef list bits_lista
        cdef str bit

        with open(ruta_comprimido, "rb") as archivo:
            numero_elementos = int.from_bytes(archivo.read(2), byteorder="big")
            frecuencias = {}

            for _ in range(numero_elementos):
                longitud_clave = int.from_bytes(
                    archivo.read(2), byteorder="big"
                )
                clave = archivo.read(longitud_clave).decode("utf-8")
                valor = int.from_bytes(archivo.read(4), byteorder="big")
                frecuencias[clave] = valor

            raiz = self._construir_arbol(frecuencias)
            self._generar_codigos_rec(raiz, "")
            bits_lista = []
            byte = archivo.read(1)
            while byte:
                bits_lista.append("{0:08b}".format(byte[0]))
                byte = archivo.read(1)
            bits = "".join(bits_lista)

        texto_codificado = self._remover_padding(bits)
        texto_decodificado = []

        if raiz is not None:
            if raiz.char is not None:
                for bit in texto_codificado:
                    texto_decodificado.append(raiz.char)
            else:
                nodo_actual = raiz
                for bit in texto_codificado:
                    nodo_actual = nodo_actual.left if bit == "0" else nodo_actual.right
                    if nodo_actual is None:
                        raise ValueError(
                            "El archivo comprimido contiene datos inválidos."
                        )
                    if nodo_actual.char is not None:
                        texto_decodificado.append(nodo_actual.char)
                        nodo_actual = raiz

                if nodo_actual is not raiz:
                    raise ValueError(
                        "El archivo comprimido termina con un código incompleto."
                    )

        resultado = "".join(texto_decodificado)
        with open(ruta_salida, "w", encoding="utf-8") as salida:
            salida.write(resultado)

        self._arbol_raiz = raiz
        print(f"Archivo descomprimido exitosamente en: {ruta_salida}")
        return resultado