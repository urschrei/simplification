#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
setup.py

Created by Stephan Hügel on 2016-07-25
"""

import sys
from setuptools import setup, Extension
import numpy
from Cython.Build import cythonize


# Set dynamic RPATH differently, depending on platform
ldirs = []
ddirs = []
if "linux" in sys.platform:
    # from http://stackoverflow.com/a/10252190/416626
    # the $ORIGIN trick is not perfect, though
    ldirs = ["-Wl,-rpath", "-Wl,$ORIGIN"]
    platform_lib = "librdp.so"
if sys.platform == "darwin":
    # You must compile your binary with rpath support for this to work
    # RUSTFLAGS="-C rpath" cargo build --release
    platform_lib = "librdp.dylib"
    ldirs = ["-Wl,-rpath", "-Wl,@loader_path/"]
if sys.platform == "win32":
    ddirs = ["simplification/header.h"]
    platform_lib = "rdp.dll"


extensions = Extension(
    "simplification.cutil",
    sources=["simplification/cutil.pyx"],
    libraries=["rdp"],
    depends=ddirs,
    language="c",
    include_dirs=["simplification", numpy.get_include()],
    library_dirs=["simplification"],
    extra_compile_args=["-O3"],
    extra_link_args=ldirs,
)

extensions = cythonize(
    [
        extensions,
    ],
    compiler_directives={"language_level": "3"},
)

setup(
    package_data={
        "simplification": [platform_lib],
    },
    ext_modules=extensions,
)
