from .CNodoHuffman cimport NodoHuffman


cdef class CompresorHuffman:
    cdef object ruta_archivo
    cdef list heap
    cdef dict codigos
    cdef dict inverso_codigos
    cdef NodoHuffman _arbol_raiz

    cpdef dict _calcular_frecuencias(self, str texto)
    cpdef object _construir_arbol(self, dict frecuencias)
    cpdef void _generar_codigos_rec(
        self, NodoHuffman nodo, str codigo_actual
    )
    cpdef str _pad_encoded_text(self, str encoded_text)
    cpdef bytearray _get_byte_array(self, str padded_encoded_text)
    cpdef tuple comprimir(self, str ruta_salida)
    cpdef str _remover_padding(self, str padded_encoded_text)
    cpdef str descomprimir(self, str ruta_comprimido, str ruta_salida)
