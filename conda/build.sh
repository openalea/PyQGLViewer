#!/bin/bash

# Inspired from https://github.com/conda-forge/pyqt-feedstock/tree/main/recipe

if [ "$(uname)" == "Linux" ]; then
    #    USED_BUILD_PREFIX=${BUILD_PREFIX:-${PREFIX}}

    #    ln -s ${GXX} g++ || true
    #    ln -s ${GCC} gcc || true
    #    ln -s ${USED_BUILD_PREFIX}/bin/${HOST}-gcc-ar gcc-ar || true

    export LD=${GXX}
    export CC=${GCC}
    export CXX=${GXX}
    export QMAKE_CXX="${CXX}"
    export QMAKE_CC="${CC}"
    export PKG_CONFIG_EXECUTABLE=$(basename $(which pkg-config))

#    export PATH=${PWD}:${PATH}
fi

echo "CC=${CC}"
echo "CXX=${CXX}"
echo "GCC=${GCC}"
echo "GXX=${GXX}"

which gcc
which g++

readlink -f "$(which gcc)" || true
readlink -f "$(which g++)" || true
readlink -f "$GCC" || true
readlink -f "$GXX" || true

"${CC}" --version
"${CXX}" --version

"$GXX" -v -E -x c++ /dev/null

echo "**** BUILD"
sip-install --verbose

echo
echo "****** CHECK PYTHON LIB"

# To check if Python lib is not in the dependencies with conda-forge distribution.
# See https://github.com/conda-forge/boost-feedstock/issues/81
if [ $(uname) = "Darwin" ]; then
    otool -L $(${PYTHON} -c "import PyQGLViewer as pyqgl ; print(pyqgl.__file__)")
fi

if [ "$(uname)" == "Linux" ]; then
    ldd $(${PYTHON} -c "import PyQGLViewer as pyqgl ; print(pyqgl.__file__)")

fi
echo "****** END OF BUILD PROCESS"
