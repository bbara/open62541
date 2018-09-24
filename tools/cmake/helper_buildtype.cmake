# Set default build type.
if(NOT CMAKE_BUILD_TYPE)
  message(STATUS "CMAKE_BUILD_TYPE not given; setting to 'Debug'")
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build" FORCE)
endif()

# Switch to debug build if test coverage is active.
if(UA_ENABLE_COVERAGE)
  set(CMAKE_BUILD_TYPE DEBUG)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-arcs -ftest-coverage")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fprofile-arcs -ftest-coverage -lgcov")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fprofile-arcs -ftest-coverage")
endif()

# Build options for debugging
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(UA_DEBUG ON)
  # add testing?
endif()

# Build options for hardening
if(CMAKE_BUILD_TYPE STREQUAL "Hardened")
  set(UA_ENABLE_PROTECTORS ON CACHE STRING "" FORCE)
endif()

# Build options for experimental
if(CMAKE_BUILD_TYPE STREQUAL "Experimental")

endif()

# Build options for release
if(CMAKE_BUILD_TYPE STREQUAL "Release")

endif()

# Build options for fuzzing
if(CMAKE_BUILD_TYPE STREQUAL "Fuzzing")

endif()
