# Set default build type.
if(NOT CMAKE_BUILD_TYPE)
    message(STATUS "CMAKE_BUILD_TYPE not given; setting to 'Debug'")
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build" FORCE)
endif()

# Switch to debug build if test coverage is active.
if(UA_ENABLE_COVERAGE)
  set(CMAKE_BUILD_TYPE "Debug")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-arcs -ftest-coverage")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fprofile-arcs -ftest-coverage -lgcov")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fprofile-arcs -ftest-coverage")
endif()

# lists with default types and targets
list(APPEND COMPILE_TYPES "Debug" "Release")
foreach(TYPE ${COMPILE_TYPES})
  # Build options for examples
  if(CMAKE_BUILD_TYPE STREQUAL "${TYPE}Examples")
    ua_set_if_not_set(UA_BUILD_EXAMPLES ON)
    set(CMAKE_BUILD_TYPE "${TYPE}")
    break()
  endif()

  # Build options for tests
  if(CMAKE_BUILD_TYPE STREQUAL "${TYPE}Tests")
    ua_set_if_not_set(UA_BUILD_UNIT_TESTS ON)
    set(CMAKE_BUILD_TYPE "${TYPE}")
    break()
  endif()

  # Build options for examples and tests
  if(CMAKE_BUILD_TYPE STREQUAL "${TYPE}Full")
    ua_set_if_not_set(UA_BUILD_EXAMPLES ON)
    ua_set_if_not_set(UA_BUILD_UNIT_TESTS ON)
    set(CMAKE_BUILD_TYPE "${TYPE}")
    break()
  endif()

  # Build options for experimental
  if(CMAKE_BUILD_TYPE STREQUAL "${TYPE}Experimental")
    ua_set_if_not_set(UA_NAMESPACE_ZERO "Full")
    ua_set_if_not_set(UA_ENABLE_MULTITHREADING ON)
    ua_set_if_not_set(UA_ENABLE_PUBSUB ON)
    set(CMAKE_BUILD_TYPE "${TYPE}")
    break()
  endif()

  # Build options for CI (full)
  if(CMAKE_BUILD_TYPE STREQUAL "${TYPE}CI")
    ua_set_if_not_set(UA_NAMESPACE_ZERO "FULL")
    ua_set_if_not_set(DUA_ENABLE_SUBSCRIPTIONS ON)
    ua_set_if_not_set(DUA_ENABLE_SUBSCRIPTIONS_EVENTS ON)
    ua_set_if_not_set(DUA_ENABLE_ENCRYPTION ON)
    ua_set_if_not_set(DUA_ENABLE_JSON_ENCODING ON)
    ua_set_if_not_set(UA_ENABLE_PUBSUB ON)
    ua_set_if_not_set(UA_ENABLE_PUBSUB_DELTAFRAMES ON)
    ua_set_if_not_set(UA_ENABLE_PUBSUB_INFORMATIONMODEL ON)
    ua_set_if_not_set(UA_ENABLE_DISCOVERY_MULTICAST ON)
    ua_set_if_not_set(UA_ENABLE_UNIT_TESTS_MEMCHECK ON)
    ua_set_if_not_set(UA_ENABLE_COVERAGE ON)
    ua_set_if_not_set(UA_BUILD_EXAMPLES ON)
    ua_set_if_not_set(UA_BUILD_UNIT_TESTS ON)
    ua_set_if_not_set(UA_ENABLE_PROTECTORS ON)
    set(CMAKE_BUILD_TYPE "${TYPE}")
    break()
  endif()

endforeach()

# Build options for fuzzing
if(CMAKE_BUILD_TYPE STREQUAL "PreFuzzing")
  ua_set_if_not_set(UA_BUILD_FUZZING_CORPUS ON)
  ua_set_if_not_set(UA_BUILD_UNIT_TESTS ON)
  ua_set_if_not_set(UA_ENABLE_DISCOVERY_MULTICAST ON)
  set(CMAKE_BUILD_TYPE "Debug")
endif()
if(CMAKE_BUILD_TYPE STREQUAL "Fuzzing")
  ua_set_if_not_set(UA_BUILD_FUZZING ON)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

# Build options for minimal size
if(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
  ua_set_if_not_set(UA_NAMESPACE_ZERO "Minimal")
  ua_set_if_not_set(UA_LOGLEVEL 600)
  ua_set_if_not_set(UA_ENABLE_NODESET_COMPILER_DESCRIPTIONS OFF)
  ua_set_if_not_set(UA_ENABLE_HISTORIZING OFF)
  ua_set_if_not_set(UA_ENABLE_SUBSCRIPTIONS OFF)
  ua_set_if_not_set(UA_ENABLE_ENCRYPTION OFF)
  ua_set_if_not_set(UA_ENABLE_DISCOVERY OFF)
  ua_set_if_not_set(UA_ENABLE_TYPENAMES OFF)
endif()

# Build options for debugging
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(UA_DEBUG ON)
endif()

# Build options for release
if(CMAKE_BUILD_TYPE STREQUAL "Release")

endif()
