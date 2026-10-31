cdef class NodoHuffman:
    cdef public object char
    cdef public Py_ssize_t freq
    cdef public NodoHuffman left
    cdef public NodoHuffman right
