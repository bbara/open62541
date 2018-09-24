if(UA_NAMESPACE_ZERO STREQUAL "MINIMAL")
    set(UA_GENERATED_NAMESPACE_ZERO OFF)
else()
    set(UA_GENERATED_NAMESPACE_ZERO ON)
endif()

# It should not be possible to enable events without enabling subscriptions and full ns0
if((UA_ENABLE_SUBSCRIPTIONS_EVENTS) AND (NOT (UA_ENABLE_SUBSCRIPTIONS AND UA_NAMESPACE_ZERO STREQUAL "FULL")))
    message(FATAL_ERROR "Unable to enable events without UA_ENABLE_SUBSCRIPTIONS and full namespace 0")
endif()

if(UA_BUILD_FUZZING OR UA_BUILD_OSS_FUZZ OR UA_BUILD_FUZZING_CORPUS)
    # Force enable options not passed in the build script, to also fuzzy-test this code
    set(UA_ENABLE_DISCOVERY ON CACHE STRING "" FORCE)
    set(UA_ENABLE_DISCOVERY_MULTICAST ON CACHE STRING "" FORCE)
    set(UA_ENABLE_ENCRYPTION ON CACHE STRING "" FORCE)
endif()

if(UA_ENABLE_DISCOVERY_MULTICAST AND NOT UA_ENABLE_DISCOVERY)
    MESSAGE(WARNING "UA_ENABLE_DISCOVERY_MULTICAST is enabled, but not UA_ENABLE_DISCOVERY. UA_ENABLE_DISCOVERY_MULTICAST will be set to OFF")
    SET(UA_ENABLE_DISCOVERY_MULTICAST OFF CACHE BOOL "Enable Discovery Service with multicast support (LDS-ME)" FORCE)
endif()

if(UA_ENABLE_MULTITHREADING)
    set(UA_ENABLE_IMMUTABLE_NODES ON)
endif()

if(UA_ENABLE_PUBSUB_INFORMATIONMODEL)
    if(NOT UA_ENABLE_PUBSUB)
    message(FATAL_ERROR "PubSub information model representation cannot be used with disabled PubSub function.")
    endif()
endif()

if(UA_ENABLE_PUBSUB_INFORMATIONMODEL_METHODS)
    if(NOT UA_ENABLE_PUBSUB_INFORMATIONMODEL)
        message(FATAL_ERROR "PubSub information model methods cannot be used with disabled PubSub information model.")
    endif()
endif()

if(UA_ENABLE_PUBSUB_ETH_UADP)
    if (NOT CMAKE_SYSTEM MATCHES "Linux")
    message(FATAL_ERROR "UADP over Ethernet is only available on Linux.")
	endif()
endif()

if(UA_BUILD_FUZZING)
    # oss-fuzz already defines this by default
    add_definitions(-DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION)
endif()

if(UA_BUILD_FUZZING_CORPUS)
    add_definitions(-DUA_DEBUG_DUMP_PKGS_FILE)
    set(UA_ENABLE_TYPENAMES ON CACHE STRING "" FORCE)
    set(UA_DEBUG_DUMP_PKGS ON CACHE STRING "" FORCE)
endif()

if(UA_PACK_DEBIAN)
    remove_definitions(-Wno-static-in-inline)
endif()

# Force compilation with as C++
if (UA_COMPILE_AS_CXX)
    # We need the UINT32_C define
    add_definitions(-D__STDC_CONSTANT_MACROS)
endif()

# Advanced Build Targets

# Building shared libs (dll, so). This option is written into ua_config.h.
set(UA_DYNAMIC_LINKING OFF)
if(BUILD_SHARED_LIBS)
  set(UA_DYNAMIC_LINKING ON)
  if (UA_ENABLE_DISCOVERY_MULTICAST)
      set(MDNSD_DYNAMIC_LINKING ON)
  endif()
endif()

if(UA_ENABLE_EXPERIMENTAL_HISTORIZING)
    if(NOT UA_ENABLE_HISTORIZING)
        message(FATAL_ERROR "UA_ENABLE_EXPERIMENTAL_HISTORIZING cannot be used with disabled UA_ENABLE_HISTORIZING.")
    endif()
endif()

if(UA_BUILD_FUZZING OR UA_BUILD_OSS_FUZZ)
    add_definitions(-DUA_malloc=UA_memoryManager_malloc)
    add_definitions(-DUA_free=UA_memoryManager_free)
    add_definitions(-DUA_calloc=UA_memoryManager_calloc)
    add_definitions(-DUA_realloc=UA_memoryManager_realloc)
endif()

# Warn if experimental features are enabled
if(UA_ENABLE_SUBSCRIPTIONS_EVENTS)
    MESSAGE(WARNING "UA_ENABLE_SUBSCRIPTIONS_EVENTS is enabled. The feature is under development and marked as EXPERIMENTAL")
endif()

if(UA_ENABLE_MULTITHREADING)
    MESSAGE(WARNING "UA_ENABLE_MULTITHREADING is enabled. The feature is under development and marked as EXPERIMENTAL")
endif()
