cdef class NodoHuffman:
    def __init__(self, object caracter, Py_ssize_t freq):
        self.char = caracter
        self.freq = freq
        self.left = None
        self.right = None

    def __lt__(self, NodoHuffman other):
        return self.freq < other.freq

    def __str__(self) -> str:
        return f"(c={self.char}, f={self.freq})"

    def arbol_a_arreglo(self, list cola=None) -> str:
        if cola is None:
            cola = []

        if self.left is not None:
            cola.append(self.left)
        if self.right is not None:
            cola.append(self.right)

        if len(cola):
            return f"{self}"
        return f"{self},{self.arbol_a_arreglo}"
