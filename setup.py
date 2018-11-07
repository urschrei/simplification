#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
setup.py

Created by Stephan Hügel on 2016-07-25
"""

import os
import re
import io
import sys
from setuptools import setup, find_packages, Distribution, Extension
import numpy

def read(*names, **kwargs):
    with io.open(
        os.path.join(os.path.dirname(__file__), *names),
        encoding=kwargs.get("encoding", "utf8")
    ) as fp:
        return fp.read()

def find_version(*file_paths):
    version_file = read(*file_paths)
    version_match = re.search(
        r"^__version__ = ['\"]([^'\"]*)['\"]",
        version_file,
        re.M)
    if version_match:
        return version_match.group(1)
    raise RuntimeError("Unable to find version string.")

class BinaryDistribution(Distribution):
    def is_pure(self):
        return False

version=find_version("simplification/util.py")
with open('README.rst') as f:
    readme = f.read()

try:
    from Cython.Build import cythonize
    has_cython = True
except ImportError:
    has_cython = False

# If Cython is installed, use it. Otherwise, build from source
if has_cython:
    suffix = '.pyx'
else:
    suffix = '.c'

# # Set dynamic RPATH differently, depending on platform
ldirs = []
ddirs = []
if "linux" in sys.platform:
    # from http://stackoverflow.com/a/10252190/416626
    # the $ORIGIN trick is not perfect, though
    ldirs = ["-Wl,-rpath", "-Wl,$ORIGIN"]
    platform_lib = "librdp.so"
if sys.platform == 'darwin':
    # You must compile your binary with rpath support for this to work
    # RUSTFLAGS="-C rpath" cargo build --release
    platform_lib = "librdp.dylib"
    ldirs = ["-Wl,-rpath", "-Wl,@loader_path/"]
if sys.platform == "win32":
    ddirs = ['simplification/header.h']
    platform_lib = "rdp.dll"


extensions = Extension("simplification.cutil",
                    sources=["simplification/cutil" + suffix],
                    libraries=["rdp"],
                    depends=ddirs,
                    language='c',
                    include_dirs=['simplification', numpy.get_include()],
                    library_dirs=['simplification'],
                    extra_compile_args=["-O3"],
                    extra_link_args=ldirs
)

if has_cython:
    extensions = cythonize([extensions,])
else:
    extensions = [extensions,]

setup(
    name='simplification',
    version=version,
    description='Fast linestring simplification using RDP or Visvalingam-Whyatt and a Rust binary',
    author='Stephan Hügel',
    author_email='urschrei@gmail.com',
    license='MIT License',
    url='https://github.com/urschrei/simplification',
    include_package_data=True,
    distclass=BinaryDistribution,
    package_data={
        'simplification': [platform_lib],
    },
    download_url='https://github.com/urschrei/simplification/tarball/v%s' % version,
    keywords=['Geo', 'Polyline', 'Linestring', 'Ramer-Douglas-Peucker', 'Douglas-Peucker', 'Visvalingam-Whyatt'],
    classifiers=[
        'Programming Language :: Python',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'Intended Audience :: Education',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Scientific/Engineering :: GIS',
    ],
    packages=find_packages(),
    install_requires=['numpy >= 1.11.0'],
    ext_modules = extensions,
    long_description=readme
)
