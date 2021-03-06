# This file is part of OpenOrienteering.

# Copyright 2016, 2017 Kai Pastor
#
# Redistribution and use is allowed according to the terms of the BSD license:
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# 1. Redistributions of source code must retain the copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products 
#    derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set(version        0.7.91)
set(download_hash  SHA256=367c5a22206933d3e93b9d7a824b14ab2bfc78a426297e615beb2c48b791abaa)
set(qt_version     5.6.2)

superbuild_package(
  NAME           openorienteering-mapper
  VERSION        ${version}
  DEPENDS
    gdal
    libpolyclipping
    proj
    qtandroidextras-${qt_version}
    qtbase-${qt_version}
    qtimageformats-${qt_version}
    qtlocation-${qt_version}
    qtsensors-${qt_version}
    qttools-${qt_version}
    qttranslations-${qt_version}
    zlib
    host:doxygen
    host:qttools-${qt_version}
  
  SOURCE
    DOWNLOAD_NAME  openorienteering-mapper_${version}.tar.gz
    URL            https://github.com/OpenOrienteering/mapper/archive/v${version}.tar.gz
    URL_HASH       ${download_hash}
    PATCH_COMMAND
      sed -i -e [[ s/Mapper VERSION 0.8.0/Mapper VERSION 0.7.91/ ]] CMakeLists.txt
  
  BUILD_CONDITION [[
    if(NOT CMAKE_BUILD_TYPE MATCHES "Rel")
        message(FATAL_ERROR "Not building a release configuration")
    endif()
  ]]
  BUILD [[
    CMAKE_ARGS
      "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
      "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
      "-DBUILD_SHARED_LIBS=0"
      "-DMapper_AUTORUN_SYSTEM_TESTS=0"
      "-DMapper_BUILD_PACKAGE=1"
    $<$<BOOL:${ANDROID}>:
      "-DCMAKE_DISABLE_FIND_PACKAGE_Qt5PrintSupport=TRUE"
      "-DKEYSTORE_URL=${KEYSTORE_URL}"
      "-DKEYSTORE_ALIAS=${KEYSTORE_ALIAS}"
    >
    $<$<NOT:$<BOOL:${ANDROID}>>:
      "-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Positioning=TRUE"
      "-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Sensors=TRUE"
    >
    INSTALL_COMMAND
      "${CMAKE_COMMAND}" --build . --target install -- VERBOSE=1
      $<$<BOOL:${WIN32}>:
        # Mapper Windows installation layout is weird
        "DESTDIR=${INSTALL_DIR}/OpenOrienteering"
      >$<$<NOT:$<BOOL:${WIN32}>>:
        "DESTDIR=${INSTALL_DIR}"
      >
  $<$<NOT:$<BOOL:${CMAKE_CROSSCOMPILING}>>:
    TEST_BEFORE_INSTALL 1
  >
  ]]
  
  EXECUTABLES src/Mapper
  
  PACKAGE [[
    COMMAND "${CMAKE_COMMAND}" --build . --target package/fast
  ]]
)
