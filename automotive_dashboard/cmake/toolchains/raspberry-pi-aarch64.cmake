# Toolchain for 64-bit Raspberry Pi OS (Raspberry Pi 4).
# RPI_SYSROOT must point at a target filesystem containing the Pi's development
# headers, libraries, and Qt installation.

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

if(NOT DEFINED RPI_SYSROOT)
    if(DEFINED ENV{RPI_SYSROOT})
        set(RPI_SYSROOT "$ENV{RPI_SYSROOT}")
    else()
        message(FATAL_ERROR "Set RPI_SYSROOT to the Raspberry Pi sysroot path")
    endif()
endif()

file(TO_CMAKE_PATH "${RPI_SYSROOT}" RPI_SYSROOT)
set(CMAKE_SYSROOT "${RPI_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH "${RPI_SYSROOT}")

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Build tools such as moc and rcc run on the host. Headers, libraries, and
# packages must always come from the target sysroot.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(ENV{PKG_CONFIG_SYSROOT_DIR} "${RPI_SYSROOT}")
set(ENV{PKG_CONFIG_LIBDIR}
    "${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig:${RPI_SYSROOT}/usr/lib/pkgconfig:${RPI_SYSROOT}/usr/share/pkgconfig")
