#!/bin/bash
set -e -x

PYBINS=(
  # "/opt/python/cp27-cp27m/bin"
  "/opt/python/cp27-cp27mu/bin"
  # "/opt/python/cp33-cp33m/bin"
  # "/opt/python/cp34-cp34m/bin"
  # "/opt/python/cp35-cp35m/bin"
  "/opt/python/cp36-cp36m/bin"
  "/opt/python/cp37-cp37m/bin"
  "/opt/python/cp38-cp38/bin"
  )

mkdir -p /io/wheelhouse
# ls -la /io

echo $LD_LIBRARY_PATH
mkdir -p /usr/local/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export DOCKER_BUILD=true
cp /io/simplification/librdp.so /usr/local/lib

# Compile wheels
for PYBIN in ${PYBINS[@]}; do
    ${PYBIN}/pip install -r /io/dev-requirements.txt
    ${PYBIN}/pip wheel /io/ -w wheelhouse/ --no-deps
done

# output possibly-renamed wheels to new dir
mkdir /io/wheelhouse_r

# Show dependencies, then bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel show $whl
    auditwheel repair $whl -w /io/wheelhouse_r/
done

# remove the 2010 wheels, since we're manylinux1-compatible
rm wheelhouse/*.whl
rm /io/wheelhouse_r/*20*
cp /io/wheelhouse_r/*.whl wheelhouse
FILES=wheelhouse/*
for f in $FILES
do
  auditwheel show $f
done

# Install packages and test
for PYBIN in ${PYBINS[@]}; do
    ${PYBIN}/pip install simplification --no-index -f wheelhouse
    (cd $HOME; ${PYBIN}/nosetests simplification)
done
cp wheelhouse/* /io/wheelhouse
