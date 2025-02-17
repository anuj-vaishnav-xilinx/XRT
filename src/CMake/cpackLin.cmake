# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2019-2021 Xilinx, Inc. All rights reserved.
#
# Custom variables imported by this CMake stub which should be defined by parent CMake:
# XRT_VERSION_MAJOR
# XRT_VERSION_MINOR
# XRT_VERSION_PATCH
# LINUX_FLAVOR


SET(CPACK_SET_DESTDIR ON)
SET(CPACK_PACKAGE_VERSION_RELEASE "${XRT_VERSION_RELEASE}")
SET(CPACK_PACKAGE_VERSION_MAJOR "${XRT_VERSION_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${XRT_VERSION_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH "${XRT_VERSION_PATCH}")
SET(CPACK_PACKAGE_NAME "xrt")

SET(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
SET(CPACK_DEB_COMPONENT_INSTALL ON)
SET(CPACK_RPM_COMPONENT_INSTALL ON)

# When the rpmbuild occurs for packaging, it uses a default version of 
# python to perform a python byte compilation.  For the CentOS 7.x OS, this 
# is python2.  Being that the XRT python code is for python3, this results in 
# a bad release build. The following line overrides this default value
# and uses python3 for the RPM package builds.
# 
# Note: If a python script is placed in a directory where with a parent directory
#       is "bin" (any level of hierarchy), python byte compilation will not be performed.
SET(CPACK_RPM_SPEC_MORE_DEFINE "%define __python python3")

if (DEFINED CROSS_COMPILE)
  set(CPACK_REL_VER ${LINUX_VERSION})
else()
  execute_process(
      COMMAND lsb_release -r -s
      OUTPUT_VARIABLE CPACK_REL_VER
      OUTPUT_STRIP_TRAILING_WHITESPACE
)
endif()

SET(PACKAGE_KIND "TGZ")
if (${LINUX_FLAVOR} MATCHES "^(Ubuntu|Debian)")
  execute_process(
    COMMAND dpkg --print-architecture
    OUTPUT_VARIABLE CPACK_ARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  SET(CPACK_GENERATOR "DEB;TGZ")
  SET(PACKAGE_KIND "DEB")
  # Modify the package name for the xrt runtime and development component
  # Syntax is set(CPACK_<GENERATOR>_<COMPONENT>_PACKAGE_NAME "<name">)
  SET(CPACK_DEBIAN_XRT_PACKAGE_NAME "xrt")

  SET(CPACK_DEBIAN_XRT_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_BINARY_DIR}/postinst;${CMAKE_CURRENT_BINARY_DIR}/prerm")
  SET(CPACK_DEBIAN_AWS_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_BINARY_DIR}/aws/postinst;${CMAKE_CURRENT_BINARY_DIR}/aws/prerm")
  SET(CPACK_DEBIAN_AZURE_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_BINARY_DIR}/azure/postinst;${CMAKE_CURRENT_BINARY_DIR}/azure/prerm")
  SET(CPACK_DEBIAN_CONTAINER_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_BINARY_DIR}/container/postinst;${CMAKE_CURRENT_BINARY_DIR}/container/prerm")

  SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS "yes")

  if( (${CMAKE_VERSION} VERSION_LESS "3.6.0") AND (${CPACK_DEBIAN_PACKAGE_SHLIBDEPS} STREQUAL "yes") )
    # Fix bug in CPackDeb.cmake in use of dpkg-shlibdeps
    SET(CMAKE_MODULE_PATH ${XRT_SOURCE_DIR}/CMake/patch ${CMAKE_MODULE_PATH})
  endif()

  SET(CPACK_DEBIAN_AWS_PACKAGE_DEPENDS "xrt (>= ${XRT_VERSION_MAJOR}.${XRT_VERSION_MINOR}.${XRT_VERSION_PATCH})")
  SET(CPACK_DEBIAN_XRT_PACKAGE_DEPENDS "ocl-icd-libopencl1 (>= 2.2.0), lsb-release, dkms (>= 2.2.0), udev, python3")

  if (${XRT_DEV_COMPONENT} STREQUAL "xrt")
    # applications link with -luuid
    SET(CPACK_DEBIAN_XRT_PACKAGE_DEPENDS
      "${CPACK_DEBIAN_XRT_PACKAGE_DEPENDS},  \
      ocl-icd-opencl-dev (>= 2.2.0), \
      uuid-dev (>= 2.27.1)")
  else()
    # xrt development package
    SET(CPACK_DEBIAN_XRT-DEV_PACKAGE_NAME ${XRT_DEV_COMPONENT})
    SET(CPACK_DEBIAN_XRT-DEV_PACKAGE_DEPENDS
      "xrt (>= ${XRT_VERSION_MAJOR}.${XRT_VERSION_MINOR}.${XRT_VERSION_PATCH}), \
      ocl-icd-opencl-dev (>= 2.2.0), \
      uuid-dev (>= 2.27.1)")
  endif()

  if (DEFINED CROSS_COMPILE)
    if (${aarch} STREQUAL "aarch64")
      SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
      SET(CPACK_ARCH "aarch64")
    else()
      SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "armhf")
      SET(CPACK_ARCH "aarch32")
    endif()
    SET(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_BINARY_DIR}/postinst;${CMAKE_CURRENT_BINARY_DIR}/prerm")
    SET(CPACK_DEBIAN_PACKAGE_DEPENDS ${CPACK_DEBIAN_XRT_PACKAGE_DEPENDS})
  endif()

elseif (${LINUX_FLAVOR} MATCHES "^(RedHat|CentOS|Amazon|Fedora|SUSE)")
  execute_process(
    COMMAND uname -m
    OUTPUT_VARIABLE CPACK_ARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if (${CPACK_ARCH} MATCHES "^mips64")
    SET(CPACK_ARCH "mips64el")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "mips64el")
  endif()

  SET(CPACK_GENERATOR "RPM;TGZ")
  SET(PACKAGE_KIND "RPM")
  # Modify the package name for the xrt runtime and development component
  # Syntax is set(CPACK_<GENERATOR>_<COMPONENT>_PACKAGE_NAME "<name">)
  set(CPACK_RPM_XRT_PACKAGE_NAME "xrt")

  SET(CPACK_RPM_XRT_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/postinst")
  SET(CPACK_RPM_XRT_PRE_UNINSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/prerm")
  SET(CPACK_RPM_AWS_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/aws/postinst")
  SET(CPACK_RPM_AWS_PRE_UNINSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/aws/prerm")
  SET(CPACK_RPM_AZURE_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/azure/postinst")
  SET(CPACK_RPM_AZURE_PRE_UNINSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/azure/prerm")
  SET(CPACK_RPM_CONTAINER_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/container/postinst")
  SET(CPACK_RPM_CONTAINER_PRE_UNINSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/container/prerm")
  SET(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/usr/local" "/usr/src" "/opt" "/etc/OpenCL" "/etc/OpenCL/vendors" "/usr/lib" "/usr/lib/pkgconfig" "/usr/lib64/pkgconfig" "/lib" "/lib/firmware")
  SET(CPACK_RPM_AWS_PACKAGE_REQUIRES "xrt >= ${XRT_VERSION_MAJOR}.${XRT_VERSION_MINOR}.${XRT_VERSION_PATCH}")
  if (${LINUX_FLAVOR} MATCHES "^(SUSE)")
    SET(CPACK_RPM_XRT_PACKAGE_REQUIRES "ocl-icd-devel >= 2.2, lsb-release, dkms >= 2.2.0, python3 >= 3.6")
  else()
    SET(CPACK_RPM_XRT_PACKAGE_REQUIRES "ocl-icd >= 2.2, redhat-lsb-core, dkms >= 2.5.0, python3 >= 3.6")
  endif()

  if (${XRT_DEV_COMPONENT} STREQUAL "xrt")
    # xrt is also development package
    SET(CPACK_RPM_XRT_PACKAGE_REQUIRES "${CPACK_RPM_XRT_PACKAGE_REQUIRES}, ocl-icd-devel >= 2.2, libuuid-devel >= 2.23.2")
  else()
    # xrt development package
    SET(CPACK_RPM_XRT-DEV_PACKAGE_NAME ${XRT_DEV_COMPONENT})
    SET(CPACK_RPM_XRT-DEV_PACKAGE_REQUIRES "xrt >= ${XRT_VERSION_MAJOR}.${XRT_VERSION_MINOR}.${XRT_VERSION_PATCH}, ocl-icd-devel >= 2.2, libuuid-devel >= 2.23.2")
  endif()

  if (DEFINED CROSS_COMPILE)
    if (${aarch} STREQUAL "aarch64")
      SET(CPACK_RPM_PACKAGE_ARCHITECTURE "aarch64")
      SET(CPACK_ARCH "aarch64")
    else()
      SET(CPACK_RPM_PACKAGE_ARCHITECTURE "armv7l")
      SET(CPACK_ARCH "aarch32")
    endif()
    SET(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/postinst")
    SET(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/prerm")
    SET(CPACK_RPM_PACKAGE_REQUIRES ${CPACK_RPM_XRT_PACKAGE_REQUIRES})
  endif()

else ()
  SET (CPACK_GENERATOR "TGZ")
endif()

# On Amazon Linux CPACK_REL_VER is just '2' and it is hard to
# distinguish it as AL package, so adding CPACK_FLOVOR (eg: amzn) 
# to package name
if (${LINUX_FLAVOR} MATCHES "^Amazon")
  execute_process(
    COMMAND awk -F= "$1==\"ID\" {print $2}" /etc/os-release
    COMMAND tr -d "\""
    OUTPUT_VARIABLE CPACK_FLAVOR
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  SET(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}_${XRT_VERSION_RELEASE}.${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}_${CPACK_FLAVOR}${CPACK_REL_VER}-${CPACK_ARCH}")
else()
  SET(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}_${XRT_VERSION_RELEASE}.${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}_${CPACK_REL_VER}-${CPACK_ARCH}")
endif()

message("-- ${CMAKE_BUILD_TYPE} ${PACKAGE_KIND} package")

SET(CPACK_PACKAGE_VENDOR "Xilinx Inc")
SET(CPACK_PACKAGE_CONTACT "sonal.santan@xilinx.com")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Xilinx RunTime stack for use with Xilinx FPGA platforms")
SET(CPACK_RESOURCE_FILE_LICENSE "${XRT_SOURCE_DIR}/../LICENSE")

add_custom_target(xrtpkg
  echo "COMMAND ${CMAKE_CPACK_COMMAND}"
  COMMAND ${CMAKE_CPACK_COMMAND}
  COMMAND -mv -f ${CPACK_PACKAGE_FILE_NAME}-xrt.deb ${CPACK_PACKAGE_FILE_NAME}.deb 2> /dev/null
  COMMAND -mv -f ${CPACK_PACKAGE_FILE_NAME}-xrt.rpm ${CPACK_PACKAGE_FILE_NAME}.rpm 2> /dev/null
  COMMAND -mv -f ${CPACK_PACKAGE_FILE_NAME}-xrt.tar.gz ${CPACK_PACKAGE_FILE_NAME}.tar.gz 2> /dev/null

)

INCLUDE(CPack)
