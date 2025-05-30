#!/bin/bash

# This script builds the WASM module for the extra backend with CMake.

# set -x or set -o xtrace expands variables and prints a little + sign before the line.
# set -v or set -o verbose does not expand the variables before printing.
# Use set +x and set +v to turn off the above settings
#set -x

# get directory of this script relative to root
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd "${DIR}" || exit

PARALLEL=8
OUTPUT_DIR="../build/cmake-build-devenv-release/"
CONFIG="Release"
CLEAN=""

# Parse command line arguments
while [ $# -gt 0 ]; do
  case "$1" in
     --debug| -d)
         OUTPUT_DIR="../build/cmake-build-devenv-debug/"
         CONFIG="Debug"
         ;;
     --clean| -c)
         CLEAN="--clean-first"
         ;;
     *)
         echo "Unknown option: $1"
         ;;
  esac
shift
done

A319_WASM_OUT_DIR="../build-a319ceo/out/lvfr-horizonsim-airbus-a319-ceo/SimObjects/Airplanes/A319ceoCFM/panel"
if [ ! -d "$A319_WASM_OUT_DIR" ]; then
  echo "$A319_WASM_OUT_DIR directory does not exist."
  mkdir -p $A319_WASM_OUT_DIR
  echo "$A319_WASM_OUT_DIR directory created."
fi

echo "Toolchain versions:"
cmake --version
clang++ --version
wasm-ld --version
echo ""

echo "Building extra-backend with CMAKE..."
cmake -DCMAKE_TOOLCHAIN_FILE=scripts/cmake/DockerToolchain.cmake -B${OUTPUT_DIR} -DCMAKE_BUILD_TYPE=${CONFIG} ../ || (echo "CMake config failed" && exit 1)
cmake --build ${OUTPUT_DIR} --config ${CONFIG} ${CLEAN} -j ${PARALLEL} || (echo "CMake build failed" && exit 1)
echo ""

echo "WASM module built successfully!"
echo ""
exit 0
