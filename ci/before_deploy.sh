# `before_deploy` phase: here we package the build artifacts
set -ex

mk_tarball() {
    # create a "staging" directory
    local td=$(echo $(mktemp -d 2>/dev/null || mktemp -d -t tmp))
    local out_dir=$(pwd)
    cp $HOME/build/urschrei/$PROJECT_NAME/wheelhouse/*.whl $td

    
    if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
        TARGET="x86_64-apple-darwin"
    fi
    if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
        TARGET="x86_64-unknown-linux-gnu"
    fi
    pushd $td
    # release tarball will look like 'rust-everywhere-v1.2.3-x86_64-unknown-linux-gnu.tar.gz'
    tar czf $out_dir/${PROJECT_NAME}-${TRAVIS_TAG}-${TARGET}${RELEASE_PYTHON_VERSION}.tar.gz *

    popd
    rm -r $td
}

main() {
    mk_tarball
}

main
