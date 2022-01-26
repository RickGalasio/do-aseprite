#!/bin/bash
# Rick Galasio (Ricardo Leite Gonçalves)
# 25/01/2020

AQUI=$(pwd)

#Download requisitos
sudo apt install \
  g++ \
  cmake \
  ninja-build \
  libx11-dev \
  libxcursor-dev \
  libxi-dev \
  libgl1-mesa-dev \
  libfontconfig1-dev \
  git \
  python \
  libharfbuzz-dev \
  liblua5.1-0-dev \
  liblua5.3-dev \
  libluajit-5.1-dev\
dialog

VER_ASE=$(dialog --no-ok --no-cancel --title "Aseprite Branches" --menu "Aseprite Ver."  0 0 0 $(git ls-remote --tags https://github.com/aseprite/aseprite | sed -e 's|.*refs/tags/||g' | awk '{print $1 " " $1}') --stdout)

#Downloads dos fontes
git clone -b $VER_ASE https://github.com/aseprite/aseprite.git --recurse-submodules aseprite-$VER_ASE/
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
git clone -b aseprite-m96 https://github.com/aseprite/skia.git

#Adiciona o caminho das ferramentas ao PATH
export PATH="${PWD}/depot_tools:${PATH}"

#Compilar skia
cd skia
python tools/git-sync-deps
gn gen out/Release-x64 --args="is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false"
ninja -C out/Release-x64 skia modules
cd ..

#Compilar aseprite, finalmente
cd aseprite-$VER_ASE/
mkdir build
cd build
cmake \
   -DCMAKE_BUILD_TYPE=RelWithDebInfo \
   -DLAF_BACKEND=skia \
   -DSKIA_DIR=$AQUI/skia \
   -DSKIA_LIBRARY_DIR=$AQUI/skia/out/Release-x64 \
   -DSKIA_LIBRARY=$AQUI/skia/out/Release-x64/libskia.a \
-G Ninja ..

ninja aseprite

cd ..
mv build aseprite-${VER_ASE}

tar czvf $AQUI/aseprite-${VER_ASE}_bin.tar.gz aseprite-${VER_ASE}/bin

