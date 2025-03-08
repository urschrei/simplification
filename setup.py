# -*- coding: utf-8 -*-
"""
setup.py

Created by Stephan Hügel on 2016-07-25
"""

import sys

import numpy
from Cython.Build import cythonize
from setuptools import Extension, setup

# Set dynamic RPATH differently, depending on platform
ldirs = []
ddirs = []
if "linux" in sys.platform:
    # from http://stackoverflow.com/a/10252190/416626
    # the $ORIGIN trick is not perfect, though
    ldirs = ["-Wl,-rpath", "-Wl,$ORIGIN/"]
    platform_lib = "librdp.so"
if sys.platform == "darwin":
    # You must compile your binary with rpath support for this to work
    # RUSTFLAGS="-C rpath" cargo build --release
    platform_lib = "librdp.dylib"
    ldirs = ["-Wl,-rpath", "-Wl,@loader_path/"]
if sys.platform == "win32":
    ddirs = ["src/simplification/header.h"]
    platform_lib = "rdp.dll"
ddirs.append("header.h")


extension = Extension(
    "simplification.cutil",
    sources=["src/simplification/cutil.pyx"],
    libraries=["rdp"],
    depends=ddirs,
    language="c",
    include_dirs=["src/simplification", numpy.get_include()],
    library_dirs=["src/simplification"],
    extra_link_args=ldirs,
)

extensions = cythonize(
    [
        extension,
    ],
    compiler_directives={"language_level": "3"},
)

setup(
    package_data={
        "simplification": [platform_lib],
    },
    ext_modules=[extension],
)
