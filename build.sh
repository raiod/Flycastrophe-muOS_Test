#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
ROOT=$PWD
REF=aa6b3800f49a7a7155d04a3f4a15a0e47d58bbe6
PREFIX=${CROSS_PREFIX:-aarch64-linux-gnu-}
command -v "${PREFIX}g++"
if [[ ! -d source/.git ]]; then git clone --no-checkout https://github.com/Helaas/Flycastrophe.git source; fi
git -C source checkout --detach "$REF"
git -C source submodule update --init --recursive -- core/deps/asio core/deps/libchdr core/deps/rcheevos core/deps/tinygettext
export CC="${PREFIX}gcc" CXX="${PREFIX}g++"
export PKG_CONFIG_LIBDIR=${TARGET_PKG_CONFIG_LIBDIR:-/usr/aarch64-linux-gnu/lib/pkgconfig}
cmake -S source -B build -G Ninja \
 -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
 -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" \
 -DCMAKE_FIND_ROOT_PATH="${TARGET_ROOT:-/usr/aarch64-linux-gnu}" \
 -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
 -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
 -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
 '-DCMAKE_C_FLAGS_RELEASE=-O2 -DNDEBUG -mcpu=cortex-a53' \
 '-DCMAKE_CXX_FLAGS_RELEASE=-O2 -DNDEBUG -mcpu=cortex-a53' \
 '-DCMAKE_SHARED_LINKER_FLAGS=-static-libstdc++ -static-libgcc' \
 -DLIBRETRO=ON -DFLYCASTROPHE=ON -DUSE_GLES=ON -DUSE_GLES2=OFF \
 -DUSE_VULKAN=OFF -DUSE_OPENMP=OFF -DUSE_HOST_LIBZIP=OFF -DUSE_HOST_LIBCHDR=OFF \
 -DUSE_HOST_SDL=OFF -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF
cmake --build build --target flycast_libretro --parallel "${JOBS:-2}"
mkdir -p dist
mapfile -t cores < <(find build -name flycastrophe_libretro.so -type f)
[[ ${#cores[@]} == 1 ]]
cp "${cores[0]}" dist/
CORE=dist/flycastrophe_libretro.so
"${PREFIX}readelf" -h "$CORE" | tee dist/elf.txt
 grep -q AArch64 dist/elf.txt
"${PREFIX}readelf" -d "$CORE" | tee dist/dependencies.txt
if grep -Ei 'NEEDED.*(vulkan|libGL\.so)' dist/dependencies.txt; then exit 1; fi
"${PREFIX}nm" -D --defined-only "$CORE" > dist/exports.txt
for sym in retro_init retro_run retro_load_game retro_get_system_info retro_set_environment retro_api_version; do grep -Eq "[[:space:]]${sym}$" dist/exports.txt; done
"${PREFIX}readelf" -V "$CORE" > dist/abi.txt
cp flycastrophe_libretro.info source/LICENSE dist/
printf '%s\n' "$REF" > dist/source-commit.txt
(cd dist && sha256sum flycastrophe_libretro.so > SHA256SUMS)
