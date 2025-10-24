cmake_minimum_required(VERSION 3.15...3.27)
project(${SKBUILD_PROJECT_NAME} LANGUAGES C)

# Find Python
find_package(
  Python
  COMPONENTS Interpreter Development.Module NumPy
  REQUIRED)

# Get NumPy include directory
message(STATUS "NumPy include directory: ${Python_NumPy_INCLUDE_DIRS}")

# Cythonize the .pyx file to .c
add_custom_command(
  OUTPUT cutil.c
  COMMENT "Cythonizing ${CMAKE_CURRENT_SOURCE_DIR}/src/simplification/cutil.pyx"
  COMMAND Python::Interpreter -m cython
          "${CMAKE_CURRENT_SOURCE_DIR}/src/simplification/cutil.pyx"
          --output-file cutil.c
          -I "${CMAKE_CURRENT_SOURCE_DIR}/src/simplification"
  DEPENDS src/simplification/cutil.pyx src/simplification/rdp_p.pxd
  VERBATIM)

# Create the extension module
python_add_library(cutil MODULE cutil.c WITH_SOABI)

# Set include directories
target_include_directories(cutil PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src/simplification
  ${Python_NumPy_INCLUDE_DIRS}
)

# Link against the rdp library
# The library is pre-built and located in src/simplification/
find_library(RDP_LIBRARY
  NAMES rdp librdp
  PATHS ${CMAKE_CURRENT_SOURCE_DIR}/src/simplification
  NO_DEFAULT_PATH
  REQUIRED
)
message(STATUS "Found RDP library: ${RDP_LIBRARY}")

target_link_libraries(cutil PRIVATE ${RDP_LIBRARY})

# Set RPATH for different platforms
if(APPLE)
  set_target_properties(cutil PROPERTIES
    INSTALL_RPATH "@loader_path"
    BUILD_WITH_INSTALL_RPATH TRUE
  )
elseif(UNIX)
  set_target_properties(cutil PROPERTIES
    INSTALL_RPATH "$ORIGIN"
    BUILD_WITH_INSTALL_RPATH TRUE
  )
endif()

# Install the extension module
install(TARGETS cutil DESTINATION simplification)

# Install the shared library
if(APPLE)
  set(RDP_LIB_NAME "librdp.dylib")
elseif(UNIX)
  set(RDP_LIB_NAME "librdp.so")
elseif(WIN32)
  set(RDP_LIB_NAME "rdp.dll")
endif()

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/simplification/${RDP_LIB_NAME}
        DESTINATION simplification)

# Install header file
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/simplification/header.h
        DESTINATION simplification)
