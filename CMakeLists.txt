cmake_minimum_required(VERSION 3.21)
project(${SKBUILD_PROJECT_NAME} LANGUAGES C)

# Define source directory
set(SIMPLIFICATION_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/simplification")

# Find Python
find_package(
  Python
  COMPONENTS Interpreter Development.Module NumPy
  REQUIRED)
include(UseCython)

# Get NumPy include directory
message(STATUS "NumPy include directory: ${Python_NumPy_INCLUDE_DIRS}")

cython_transpile(
  "${SIMPLIFICATION_SRC_DIR}/cutil.pyx"
  LANGUAGE C
  OUTPUT_VARIABLE cutil
  CYTHON_ARGS -I "${SIMPLIFICATION_SRC_DIR}"
)

# Create the extension module
python_add_library(cutil MODULE "${cutil}" WITH_SOABI)

# Set include directories
target_include_directories(cutil PRIVATE
  ${SIMPLIFICATION_SRC_DIR}
  ${Python_NumPy_INCLUDE_DIRS}
)

# Link against the rdp library
# The library is pre-built and located in src/simplification/
find_library(RDP_LIBRARY
  NAMES rdp librdp
  PATHS ${SIMPLIFICATION_SRC_DIR}
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

install(FILES ${SIMPLIFICATION_SRC_DIR}/${RDP_LIB_NAME}
        DESTINATION simplification)

# Install header file
install(FILES ${SIMPLIFICATION_SRC_DIR}/header.h
        DESTINATION simplification)
