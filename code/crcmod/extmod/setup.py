from distutils.core import Extension, setup

setup(name = 'crcfunext',
version = '1.0',
ext_modules = [
  Extension('_crcfunext', ['_crcfunext.c'])
],
)

