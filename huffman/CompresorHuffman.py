import heapq
import pickle
from collections import Counter
from .NodoHuffman import NodoHuffman


class CompresorHuffman:

  def __init__(self, ruta_archivo=None):
    self.ruta_archivo = ruta_archivo
    self.heap = []
    self.codigos = {}
    self.inverso_codigos = {}
    self._arbol_raiz=None

  def _calcular_frecuencias(self, texto):
    return Counter(texto)

  def _construir_arbol(self, frecuencias):
    self.heap = []
    self.codigos = {}
    self.inverso_codigos = {}
    for char, freq in frecuencias.items():
      nodo = NodoHuffman(char, freq)
      heapq.heappush(self.heap, nodo)

    while len(self.heap) > 1:
      nodo1 = heapq.heappop(self.heap)
      nodo2 = heapq.heappop(self.heap)

      combinado = NodoHuffman(None, nodo1.freq + nodo2.freq)
      combinado.left = nodo1
      combinado.right = nodo2

      heapq.heappush(self.heap, combinado)

    return self.heap[0] if self.heap else None


  def _generar_codigos_rec(self, nodo, codigo_actual):
    if nodo is None:
      return

    if nodo.char is not None:
      self.codigos[nodo.char] = codigo_actual
      self.inverso_codigos[codigo_actual] = nodo.char
      return

    self._generar_codigos_rec(nodo.left, codigo_actual + "0")
    self._generar_codigos_rec(nodo.right, codigo_actual + "1")

  def _pad_encoded_text(self, encoded_text):
    extra_padding = 8 - len(encoded_text) % 8
    encoded_text += "0" * extra_padding
    padded_info = "{0:08b}".format(extra_padding)
    return padded_info + encoded_text

  def _get_byte_array(self, padded_encoded_text):
    if len(padded_encoded_text) % 8 != 0:
      raise ValueError("El texto codificado no está alineado a bytes.")
    b = bytearray()
    for i in range(0, len(padded_encoded_text), 8):
      byte = padded_encoded_text[i : i + 8]
      b.append(int(byte, 2))
    return b

  def comprimir(self, ruta_salida):
    with open(self.ruta_archivo, "r", encoding="utf-8") as f:
      texto = f.read()

    frecuencias = self._calcular_frecuencias(texto)
    
    bytes_resultado = len(frecuencias).to_bytes(2, byteorder='big')
    
    for clave, valor in frecuencias.items():
        clave_bytes = str(clave).encode('utf-8')
        # Guardamos la longitud de la clave (2 bytes) y la clave en bytes
        bytes_resultado += len(clave_bytes).to_bytes(2, byteorder='big') + clave_bytes
        # Guardamos el valor/frecuencia (4 bytes para un entero)
        bytes_resultado += valor.to_bytes(4, byteorder='big')
    
    # a partir de aca se genera todo
    raiz = self._construir_arbol(frecuencias)
    self._generar_codigos_rec(raiz, "")

    texto_codificado = "".join([self.codigos[char] for char in texto])
    texto_relleno = self._pad_encoded_text(texto_codificado)
    bytes_salida = self._get_byte_array(texto_relleno)
    
    
    

    # Guardar tabla de frecuencias y bytes comprimidos (implementación básica)
    with open(ruta_salida, "wb") as salida:
      #   guardando tabla de frecuencias
      salida.write(bytes_resultado)
      # Guardar longitud de la tabla y los datos codificados
      salida.write(bytes_salida)

    self._arbol_raiz = raiz
    return self.codigos, raiz

  def _remover_padding(self, padded_encoded_text):
    padded_info = padded_encoded_text[:8]
    extra_padding = int(padded_info, 2)

    texto_codificado = padded_encoded_text[8:]
    texto_codificado = texto_codificado[
        :-extra_padding if extra_padding > 0 else None
    ]
    return texto_codificado

  def descomprimir(self, ruta_comprimido, ruta_salida):
      
      
    with open(ruta_comprimido, "rb") as f:
        # lectura de frecuencias
        num_elementos = int.from_bytes(f.read(2), byteorder='big')
        frecuencias = Counter()
        
        for _ in range(num_elementos):
            len_clave = int.from_bytes(f.read(2), byteorder='big')
            clave = f.read(len_clave).decode('utf-8')
            valor = int.from_bytes(f.read(4), byteorder='big')
            frecuencias[clave] = valor
        #fin de lectura de frecuencias
        raiz = self._construir_arbol(frecuencias)
        self._generar_codigos_rec(raiz, "")
        
        bits = []
        byte = f.read(1)
        while byte:
            byte_val = ord(byte)
            bits.append("{0:08b}".format(byte_val))
            byte = f.read(1)
        
        
    raiz_arbol =self._arbol_raiz =  raiz

    texto_bits = "".join(bits)
    texto_codificado = self._remover_padding(texto_bits)

    texto_actual = ""
    texto_decodificado = []
    nodo_actual = raiz_arbol

    for bit in texto_codificado:
      texto_actual += bit
      if bit == "0":
        nodo_actual = nodo_actual.left
      else:
        nodo_actual = nodo_actual.right

      if nodo_actual.char is not None:
        texto_decodificado.append(nodo_actual.char)
        nodo_actual = raiz_arbol

    resultado = "".join(texto_decodificado)
    with open(ruta_salida, "w", encoding="utf-8") as salida:
      salida.write(resultado)

    print(f"Archivo descomprimido exitosamente en: {ruta_salida}")
    return resultado