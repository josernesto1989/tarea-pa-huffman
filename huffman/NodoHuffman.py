class NodoHuffman:

  def __init__(self, char, freq):
    self.char = char
    self.freq = freq
    self.left = None
    self.right = None

  def __lt__(self, other):
    return self.freq < other.freq
  
  def __str__(self):
    return f"(c={self.char}, f={self.freq})"
  
  def arbol_a_arreglo(self, cola=[]):
    cadena = ''
    if self.left is not None:
      cola.append(self.left)
    if self.right is not None:
      cola.append(self.right)
    if len(cola):
      return f'{self}'
    else:
      return f'{self},{self.arbol_a_arreglo}'