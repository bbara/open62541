# Options
set(UA_LOGLEVEL 300 CACHE STRING "Level at which logs shall be reported")
option(UA_ENABLE_HISTORIZING "Enable server and client to provide historical access." ON)
option(UA_ENABLE_EXPERIMENTAL_HISTORIZING "Enable client experimental historical access features." OFF)
option(UA_ENABLE_METHODCALLS "Enable the Method service set" ON)
option(UA_ENABLE_NODEMANAGEMENT "Enable dynamic addition and removal of nodes at runtime" ON)
option(UA_ENABLE_SUBSCRIPTIONS "Enable subscriptions support." ON)
option(UA_ENABLE_SUBSCRIPTIONS_EVENTS "Enable the use of events. (EXPERIMENTAL)" OFF)
option(UA_ENABLE_DISCOVERY "Enable Discovery Service (LDS)" ON)
option(UA_ENABLE_DISCOVERY_MULTICAST "Enable Discovery Service with multicast support (LDS-ME)" OFF)
option(UA_ENABLE_QUERY "Enable query support." OFF)
option(UA_ENABLE_COVERAGE "Enable gcov coverage" OFF)
option(UA_ENABLE_ENCRYPTION "Enable encryption support (uses mbedTLS)" OFF)
option(BUILD_SHARED_LIBS "Enable building of shared libraries (dll/so)" OFF)
option(UA_BUILD_EXAMPLES "Build example servers and clients" OFF)
option(UA_BUILD_UNIT_TESTS "Build the unit tests" OFF)

# Namespace Zero
set(UA_NAMESPACE_ZERO "REDUCED" CACHE STRING "Completeness of the generated namespace zero (minimal/reduced/full)")
SET_PROPERTY(CACHE UA_NAMESPACE_ZERO PROPERTY STRINGS "MINIMAL" "REDUCED" "FULL")

# Advanced options
option(UA_ENABLE_MULTITHREADING "Enable multithreading (experimental)" OFF)
mark_as_advanced(UA_ENABLE_MULTITHREADING)

option(UA_ENABLE_IMMUTABLE_NODES "Nodes in the information model are not edited but copied and replaced" OFF)
mark_as_advanced(UA_ENABLE_IMMUTABLE_NODES)

option(UA_ENABLE_PUBSUB "Enable publish/subscribe" OFF)
mark_as_advanced(UA_ENABLE_PUBSUB)

option(UA_ENABLE_PUBSUB_DELTAFRAMES "Enable sending of delta frames with only the changes" OFF)
mark_as_advanced(UA_ENABLE_PUBSUB_DELTAFRAMES)

option(UA_ENABLE_PUBSUB_INFORMATIONMODEL "Enable PubSub information model twin" OFF)
mark_as_advanced(UA_ENABLE_PUBSUB_INFORMATIONMODEL)

option(UA_ENABLE_PUBSUB_INFORMATIONMODEL_METHODS "Enable PubSub informationmodel methods" OFF)
mark_as_advanced(UA_ENABLE_PUBSUB_INFORMATIONMODEL_METHODS)

option(UA_ENABLE_STATUSCODE_DESCRIPTIONS "Enable conversion of StatusCode to human-readable error message" ON)
mark_as_advanced(UA_ENABLE_STATUSCODE_DESCRIPTIONS)

option(UA_ENABLE_TYPENAMES "Add the type and member names to the UA_DataType structure" ON)
mark_as_advanced(UA_ENABLE_TYPENAMES)

option(UA_ENABLE_NODESET_COMPILER_DESCRIPTIONS "Set node description attribute for nodeset compiler generated nodes" ON)
mark_as_advanced(UA_ENABLE_NODESET_COMPILER_DESCRIPTIONS)

option(UA_ENABLE_DETERMINISTIC_RNG "Do not seed the random number generator (e.g. for unit tests)." OFF)
mark_as_advanced(UA_ENABLE_DETERMINISTIC_RNG)

option(UA_ENABLE_VALGRIND_INTERACTIVE "Enable dumping valgrind every iteration. CAUTION! SLOWDOWN!" OFF)
mark_as_advanced(UA_ENABLE_VALGRIND_INTERACTIVE)

option(UA_MSVC_FORCE_STATIC_CRT "Force linking with the static C-runtime library when compiling to static library with MSVC" ON)
mark_as_advanced(UA_MSVC_FORCE_STATIC_CRT)

option(UA_FILE_NS0 "Override the NodeSet xml file used to generate namespace zero")
mark_as_advanced(UA_FILE_NS0)

option(UA_ENABLE_DISCOVERY_SEMAPHORE "Enable Discovery Semaphore support" ON)
mark_as_advanced(UA_ENABLE_DISCOVERY_SEMAPHORE)

option(UA_ENABLE_UNIT_TESTS_MEMCHECK "Use Valgrind (Linux) or DrMemory (Windows) to detect memory leaks when running the unit tests" OFF)
mark_as_advanced(UA_ENABLE_UNIT_TESTS_MEMCHECK)

option(UA_ENABLE_STATIC_ANALYZER "Use static analyzer (clang-tidy, cppcheck, cpplint) if they are available" OFF)
mark_as_advanced(UA_ENABLE_STATIC_ANALYZER)

option(UA_ENABLE_UNIT_TEST_FAILURE_HOOKS
       "Add hooks to force failure modes for additional unit tests. Not for production use!" OFF)
mark_as_advanced(UA_ENABLE_UNIT_TEST_FAILURE_HOOKS)

set(UA_VALGRIND_INTERACTIVE_INTERVAL 1000 CACHE STRING "The number of iterations to wait before creating the next dump")
mark_as_advanced(UA_VALGRIND_INTERACTIVE_INTERVAL)

# is set from build type
#option(UA_DEBUG "Enable assertions and additional functionality that should not be included in release builds" OFF)
#mark_as_advanced(UA_DEBUG)

option(UA_DEBUG_DUMP_PKGS "Dump every package received by the server as hexdump format" OFF)
mark_as_advanced(UA_DEBUG_DUMP_PKGS)

option(UA_BUILD_FUZZING "Build the fuzzing executables" OFF)
mark_as_advanced(UA_BUILD_FUZZING)

option(UA_BUILD_FUZZING_CORPUS "Build the fuzzing corpus" OFF)
mark_as_advanced(UA_BUILD_FUZZING_CORPUS)

option(UA_BUILD_OSS_FUZZ "Special build switch used in oss-fuzz" OFF)
mark_as_advanced(UA_BUILD_OSS_FUZZ)

option(UA_BUILD_SELFSIGNED_CERTIFICATE "Generate self-signed certificate" OFF)
mark_as_advanced(UA_BUILD_SELFSIGNED_CERTIFICATE)

option(UA_ENABLE_AMALGAMATION "Concatenate the library to a single file open62541.h/.c" OFF)
set(UA_AMALGAMATION_ARCHITECTURES "" CACHE STRING "List of architectures to include in amalgamation")
mark_as_advanced(UA_AMALGAMATION_ARCHITECTURES)

option(UA_COMPILE_AS_CXX "Force compilation with a C++ compiler" OFF)
mark_as_advanced(UA_COMPILE_AS_CXX)

option(UA_ENABLE_PROTECTORS "Use runtime protectors" OFF)
mark_as_advanced(UA_ENABLE_PROTECTORS)

option(UA_ENABLE_PUBSUB_ETH_UADP "Enable publish/subscribe UADP over Ethernet" OFF)
mark_as_advanced(UA_ENABLE_PUBSUB_ETH_UADP)

option(UA_ENABLE_JSON_ENCODING "Enable Json encoding (EXPERIMENTAL)" OFF)
mark_as_advanced(UA_ENABLE_JSON_ENCODING)

option(UA_PACK_DEBIAN "Special build switch used in .deb packaging" OFF)
mark_as_advanced(UA_PACK_DEBIAN)
