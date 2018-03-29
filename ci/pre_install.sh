#!/bin/bash
set -e -x
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    sudo pip install pip --upgrade
    sudo pip install -r dev-requirements.txt
    sudo pip install nosexcover
    sudo pip install python-coveralls
    sudo python ci/pre_install.py
fi

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    # install OSX
    brew install openssl
    brew link --force openssl
    brew install python@2 --with-brewed-openssl
    brew install pip
    source ci/travis_osx_steps.sh
    before_install
 fi
