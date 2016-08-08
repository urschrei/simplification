#!/bin/bash
set -e -x
# run the tests!
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    mkdir -p $HOME/build/urschrei/$PROJECT_NAME/wheelhouse
    docker pull $DOCKER_IMAGE
    docker run --rm -v `pwd`:/io $DOCKER_IMAGE $PRE_CMD /io/ci/build_wheel.sh
    # clean up numpy
    sudo rm -rf wheelhouse/numpy*
fi

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    source ci/osx_utils.sh
    source venv/bin/activate
    pip wheel . -w wheelhouse
    ls wheelhouse
    mkdir to_test
    cd to_test
    pip install $PROJECT_NAME --no-index -f $HOME/build/urschrei/$PROJECT_NAME/wheelhouse
    nosetests $PROJECT_NAME
    cd $HOME/build/urschrei/$PROJECT_NAME
    rm -rf wheelhouse/numpy*
    # run delocate
    repair_wheelhouse wheelhouse
fi
