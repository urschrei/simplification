#!/bin/bash
# Wheel build, install, run test steps on OSX
set -e

# Get needed utilities
# MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source ci/osx_utils.sh

# NB - config.sh sourced at end of this function.
# config.sh can override any function defined here.

function before_install {
    export CC=clang
    export CXX=clang++
    get_macpython_environment $TRAVIS_PYTHON_VERSION venv
    source venv/bin/activate
    pip install --upgrade pip wheel
    pip install -r dev-requirements.txt
    python ci/pre_install.py
    pip install --install-option="--no-cython-compile" cython
    pip install python-coveralls
    pip install nosexcover
}
