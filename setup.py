from setuptools import Extension, setup
from Cython.Build import cythonize


extensions = [
    Extension("huffman.CNodoHuffman", ["huffman/CNodoHuffman.pyx"]),
    Extension("huffman.CompresorHuffman", ["huffman/CompresorHuffman.pyx"]),
    Extension("main", ["main.pyx"]),
]


setup(
    name="tarea-pa-huffman",
    ext_modules=cythonize(extensions, language_level="3"),
)
