# Platform. This is at the beginning in case the architecture changes some UA options
set(UA_ARCHITECTURE "None" CACHE STRING "Architecture to build open62541 on")

if(UA_ENABLE_AMALGAMATION)
    if("${UA_AMALGAMATION_ARCHITECTURES}" STREQUAL "")
        if(NOT "${UA_ARCHITECTURE}" STREQUAL "None")
            set(UA_AMALGAMATION_ARCHITECTURES "${UA_ARCHITECTURE}")
        else()
            # select some default architectures which should be included
            set(UA_AMALGAMATION_ARCHITECTURES "win32;posix")
        endif()
    endif()
    message(STATUS "Architectures included in amalgamation: ${UA_AMALGAMATION_ARCHITECTURES}")
endif()

if("${UA_ARCHITECTURE}" STREQUAL "None")
    if(UNIX)
        set(UA_ARCHITECTURE "posix" CACHE STRING "" FORCE)
    elseif(WIN32)
        set(UA_ARCHITECTURE "win32" CACHE STRING ""  FORCE)
    endif(UNIX)
endif()

message(STATUS "The selected architecture is: ${UA_ARCHITECTURE}")
string(TOUPPER ${UA_ARCHITECTURE} UA_ARCHITECTURE_UPPER)
add_definitions(-DUA_ARCHITECTURE_${UA_ARCHITECTURE_UPPER})

add_subdirectory(arch)

GET_PROPERTY(architectures GLOBAL PROPERTY UA_ARCHITECTURES)
list(SORT architectures)
set_property(CACHE UA_ARCHITECTURE PROPERTY STRINGS None ${architectures})

GET_PROPERTY(ua_architecture_headers GLOBAL PROPERTY UA_ARCHITECTURE_HEADERS)

GET_PROPERTY(ua_architecture_headers_beginning GLOBAL PROPERTY UA_ARCHITECTURE_HEADERS_BEGINNING)

GET_PROPERTY(ua_architecture_sources GLOBAL PROPERTY UA_ARCHITECTURE_SOURCES)

set(ua_architecture_sources ${ua_architecture_sources}
            ${PROJECT_SOURCE_DIR}/arch/ua_network_tcp.c
)

set(ua_architecture_headers ${ua_architecture_headers}
            ${PROJECT_SOURCE_DIR}/arch/ua_network_tcp.h
            ${PROJECT_SOURCE_DIR}/arch/ua_architecture_functions.h
)

if(${UA_ARCHITECTURE} STREQUAL "None")
  message(FATAL_ERROR "No architecture was selected. Please select the architecture of your target platform")
endif(${UA_ARCHITECTURE} STREQUAL "None")

# Create a list of ifdefs for all the architectures.
# This is needed to enable a default architecture if none is selected through gcc compiler def.
# Especially if someone is using the amalgamated file on Linux/Windows he should not need to define an architecture.
set(UA_ARCHITECTURES_NODEF "1 ") #to make it easier to append later the && symbol
foreach(arch_ ${architectures})
    string(TOUPPER ${arch_} UA_ARCHITECTURE_UPPER_)
    set(UA_ARCHITECTURES_NODEF "${UA_ARCHITECTURES_NODEF} && !defined(UA_ARCHITECTURE_${UA_ARCHITECTURE_UPPER_})")
endforeach(arch_ ${architectures})

if(APPLE)
    set(CMAKE_MACOSX_RPATH 1)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_DARWIN_C_SOURCE=1")
endif()
