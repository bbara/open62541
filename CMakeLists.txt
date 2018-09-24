 cmake_minimum_required(VERSION 3.0...3.12)
project(open62541)
# set(CMAKE_VERBOSE_MAKEFILE ON)
if(${CMAKE_VERSION} VERSION_LESS 3.12)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/tools/cmake")
find_package(PythonInterp REQUIRED)
find_package(Git)
include(AssignSourceGroup)

# Set when installed via make install
set(open62541_TOOLS_DIR ${PROJECT_SOURCE_DIR}/tools)
set(open62541_NODESET_DIR ${PROJECT_SOURCE_DIR}/deps/ua-nodeset)

include(macros_internal)
include(macros_public)

#############################
# Compiled binaries folders #
#############################

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

###########
# Version #
###########

set(OPEN62541_VER_MAJOR 0)
set(OPEN62541_VER_MINOR 4)
set(OPEN62541_VER_PATCH 0)
set(OPEN62541_VER_LABEL "-dev") # Appended to the X.Y.Z version format. For example "-rc1" or an empty string

#  If a relative path is specified, it is treated as relative to the $<INSTALL_PREFIX>
set(LIB_INSTALL_DIR lib CACHE PATH "Installation path of libraries")

# Set OPEN62541_VER_COMMIT
if(GIT_FOUND)
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --always --tags
                    RESULT_VARIABLE res_var OUTPUT_VARIABLE GIT_COM_ID WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
    if(${res_var} EQUAL 0 AND NOT OPEN62541_VER_COMMIT STREQUAL "")
        string(REPLACE "\n" "" OPEN62541_VER_COMMIT ${GIT_COM_ID} )
    endif()
endif()
if(NOT OPEN62541_VER_COMMIT OR OPEN62541_VER_COMMIT STREQUAL "")
    set(OPEN62541_VER_COMMIT "undefined")
endif()

######################
# External Libraries #
######################

list(APPEND open62541_LIBRARIES "")
include(helper_external)

#################
# Build Options #
#################

# include the build type stuff
include(helper_buildtype)

# include the cmake option and option-dependent stuff
include(helper_options)
include(helper_option_dependent)

# include the arch dependent stuff
include(helper_arch)

# include the compiler dependent stuff
include(CompilerFlags)
if(MSVC)
  include(helper_compiler_msvc)
elseif(CMAKE_COMPILER_IS_GNUCC AND MINGW)
  include(helper_compiler_mingw-gcc)
elseif(CMAKE_COMPILER_IS_GNUCC)
  include(helper_compiler_gcc)
elseif("x${CMAKE_C_COMPILER_ID}" STREQUAL "xClang")
  include(helper_compiler_clang)
endif()

# include the tools stuff
include(helper_tools)

GET_PROPERTY(ua_directories_to_include GLOBAL PROPERTY UA_INCLUDE_DIRECTORIES)
include_directories(${ua_directories_to_include})

#########################
# Generate Main Library #
#########################

file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/src_generated")
configure_file("include/ua_config.h.in" "${PROJECT_BINARY_DIR}/src_generated/ua_config.h")
configure_file("include/open62541.pc.in" "${PROJECT_BINARY_DIR}/src_generated/open62541.pc" @ONLY)

if(UA_ENABLE_HISTORIZING)
    set(historizing_exported_headers
        ${PROJECT_SOURCE_DIR}/include/ua_plugin_historydatabase.h
        ${PROJECT_SOURCE_DIR}/plugins/historydata/ua_plugin_history_data_backend.h
        ${PROJECT_SOURCE_DIR}/plugins/historydata/ua_plugin_history_data_gathering.h
        )
    set(historizing_default_plugin_headers
        ${PROJECT_SOURCE_DIR}/plugins/historydata/ua_historydatabackend_memory.h
        ${PROJECT_SOURCE_DIR}/plugins/historydata/ua_historydatagathering_default.h
        ${PROJECT_SOURCE_DIR}/plugins/historydata/ua_historydatabase_default.h
        )
    set(historizing_default_plugin_sources
        ${PROJECT_SOURCE_DIR}/plugins/historydata/ua_historydatabackend_memory.c
        ${PROJECT_SOURCE_DIR}/plugins/historydata/ua_historydatagathering_default.c
        ${PROJECT_SOURCE_DIR}/plugins/historydata/ua_historydatabase_default.c
        )
endif()

if(UA_ENABLE_DISCOVERY_MULTICAST)
    set(MDNSD_LOGLEVEL 300 CACHE STRING "Level at which logs shall be reported" FORCE)
    configure_file("deps/mdnsd/libmdnsd/mdnsd_config.h.in" "${PROJECT_BINARY_DIR}/src_generated/mdnsd_config.h")
endif()

if(UA_ENABLE_DISCOVERY)
    include_directories(${PROJECT_SOURCE_DIR}/src/client)
endif()

if(UA_ENABLE_ENCRYPTION)
  include_directories(${MBEDTLS_INCLUDE_DIRS})
endif()

include_directories(${PROJECT_SOURCE_DIR}/include
                    ${PROJECT_SOURCE_DIR}/plugins
                    ${PROJECT_SOURCE_DIR}/plugins/networking
                    ${PROJECT_SOURCE_DIR}/plugins/securityPolicies
                    ${PROJECT_SOURCE_DIR}/deps
                    ${PROJECT_SOURCE_DIR}/src/pubsub
                    ${PROJECT_BINARY_DIR}
                    ${PROJECT_BINARY_DIR}/src_generated
                    ${MBEDTLS_INCLUDE_DIRS})

set(exported_headers ${exported_headers}
                     ${PROJECT_BINARY_DIR}/src_generated/ua_config.h
                     ${PROJECT_SOURCE_DIR}/arch/ua_architecture_base.h
                     ${ua_architecture_headers_beginning}
                     )

if(NOT "${UA_AMALGAMATION_ARCHITECTURES}" STREQUAL "")
    foreach(arch ${UA_AMALGAMATION_ARCHITECTURES})
        list(APPEND exported_headers ${PROJECT_SOURCE_DIR}/arch/${arch}/ua_architecture.h)
    endforeach()
else()
    list(APPEND exported_headers ${PROJECT_SOURCE_DIR}/arch/${UA_ARCHITECTURE}/ua_architecture.h)
endif()

set(exported_headers ${exported_headers}
                     ${PROJECT_SOURCE_DIR}/deps/ms_stdint.h
                     ${PROJECT_SOURCE_DIR}/arch/ua_architecture_definitions.h
                     ${PROJECT_BINARY_DIR}/src_generated/ua_statuscodes.h
                     ${PROJECT_BINARY_DIR}/src_generated/ua_nodeids.h
                     ${PROJECT_SOURCE_DIR}/include/ua_constants.h
                     ${PROJECT_SOURCE_DIR}/include/ua_types.h
                     ${PROJECT_BINARY_DIR}/src_generated/ua_types_generated.h
                     ${PROJECT_BINARY_DIR}/src_generated/ua_types_generated_handling.h
                     ${PROJECT_SOURCE_DIR}/include/ua_util.h
                     ${PROJECT_SOURCE_DIR}/include/ua_server.h
                     ${historizing_exported_headers}
                     ${PROJECT_SOURCE_DIR}/include/ua_plugin_log.h
                     ${PROJECT_SOURCE_DIR}/include/ua_plugin_network.h
                     ${PROJECT_SOURCE_DIR}/include/ua_plugin_access_control.h
                     ${PROJECT_SOURCE_DIR}/include/ua_plugin_pki.h
                     ${PROJECT_SOURCE_DIR}/include/ua_plugin_securitypolicy.h
                     ${PROJECT_SOURCE_DIR}/include/ua_server_pubsub.h
                     ${PROJECT_SOURCE_DIR}/include/ua_plugin_pubsub.h
                     ${PROJECT_SOURCE_DIR}/include/ua_plugin_nodestore.h
                     ${PROJECT_SOURCE_DIR}/include/ua_server_config.h
                     ${PROJECT_SOURCE_DIR}/include/ua_client_config.h
                     ${PROJECT_SOURCE_DIR}/include/ua_client.h
                     ${PROJECT_SOURCE_DIR}/include/ua_client_highlevel.h
                     ${PROJECT_SOURCE_DIR}/include/ua_client_subscriptions.h
                     ${PROJECT_SOURCE_DIR}/include/ua_client_highlevel_async.h)

set(internal_headers ${PROJECT_SOURCE_DIR}/deps/open62541_queue.h
                     ${PROJECT_SOURCE_DIR}/deps/ziptree.h
                     ${PROJECT_SOURCE_DIR}/deps/pcg_basic.h
                     ${PROJECT_SOURCE_DIR}/deps/libc_time.h
                     ${PROJECT_SOURCE_DIR}/deps/base64.h
                     ${PROJECT_SOURCE_DIR}/src/ua_util_internal.h
                     ${PROJECT_SOURCE_DIR}/src/ua_types_encoding_binary.h
                     ${PROJECT_BINARY_DIR}/src_generated/ua_types_generated_encoding_binary.h
                     ${PROJECT_BINARY_DIR}/src_generated/ua_transport_generated.h
                     ${PROJECT_BINARY_DIR}/src_generated/ua_transport_generated_handling.h
                     ${PROJECT_BINARY_DIR}/src_generated/ua_transport_generated_encoding_binary.h
                     ${PROJECT_SOURCE_DIR}/src/ua_connection_internal.h
                     ${PROJECT_SOURCE_DIR}/src/ua_securechannel.h
                     ${PROJECT_SOURCE_DIR}/src/ua_workqueue.h
                     ${PROJECT_SOURCE_DIR}/src/ua_timer.h
                     ${PROJECT_SOURCE_DIR}/src/server/ua_session.h
                     ${PROJECT_SOURCE_DIR}/src/server/ua_subscription.h
                     ${PROJECT_SOURCE_DIR}/src/server/ua_session_manager.h
                     ${PROJECT_SOURCE_DIR}/src/server/ua_securechannel_manager.h
                     ${PROJECT_SOURCE_DIR}/src/pubsub/ua_pubsub_networkmessage.h
                     ${PROJECT_SOURCE_DIR}/src/pubsub/ua_pubsub.h
                     ${PROJECT_SOURCE_DIR}/src/pubsub/ua_pubsub_manager.h
                     ${PROJECT_SOURCE_DIR}/src/pubsub/ua_pubsub_ns0.h
                     ${PROJECT_SOURCE_DIR}/src/server/ua_server_internal.h
                     ${PROJECT_SOURCE_DIR}/src/server/ua_services.h
                     ${PROJECT_BINARY_DIR}/src_generated/ua_namespace0.h
                     ${PROJECT_SOURCE_DIR}/src/client/ua_client_internal.h)

# TODO: make client optional
set(lib_sources ${PROJECT_SOURCE_DIR}/src/ua_types.c
                ${PROJECT_SOURCE_DIR}/src/ua_types_encoding_binary.c
                ${PROJECT_BINARY_DIR}/src_generated/ua_types_generated.c
                ${PROJECT_BINARY_DIR}/src_generated/ua_transport_generated.c
                ${PROJECT_BINARY_DIR}/src_generated/ua_statuscodes.c
                ${PROJECT_SOURCE_DIR}/src/ua_util.c
                ${PROJECT_SOURCE_DIR}/src/ua_workqueue.c
                ${PROJECT_SOURCE_DIR}/src/ua_timer.c
                ${PROJECT_SOURCE_DIR}/src/ua_connection.c
                ${PROJECT_SOURCE_DIR}/src/ua_securechannel.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_session.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_nodes.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_server.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_server_ns0.c
                ${PROJECT_BINARY_DIR}/src_generated/ua_namespace0.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_server_binary.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_server_utils.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_server_discovery.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_securechannel_manager.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_session_manager.c
                ${PROJECT_SOURCE_DIR}/src/pubsub/ua_pubsub_networkmessage.c
                ${PROJECT_SOURCE_DIR}/src/pubsub/ua_pubsub.c
                ${PROJECT_SOURCE_DIR}/src/pubsub/ua_pubsub_manager.c
                ${PROJECT_SOURCE_DIR}/src/pubsub/ua_pubsub_ns0.c
                # services
                ${PROJECT_SOURCE_DIR}/src/server/ua_services_view.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_services_call.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_services_session.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_services_attribute.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_services_discovery.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_services_subscription.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_services_securechannel.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_services_nodemanagement.c
                ${PROJECT_SOURCE_DIR}/src/server/ua_services_discovery_multicast.c
                # client
                ${PROJECT_SOURCE_DIR}/src/client/ua_client.c
                ${PROJECT_SOURCE_DIR}/src/client/ua_client_connect.c
                ${PROJECT_SOURCE_DIR}/src/client/ua_client_connect_async.c
                ${PROJECT_SOURCE_DIR}/src/client/ua_client_discovery.c
                ${PROJECT_SOURCE_DIR}/src/client/ua_client_highlevel.c
                ${PROJECT_SOURCE_DIR}/src/client/ua_client_subscriptions.c
                ${PROJECT_SOURCE_DIR}/src/client/ua_client_worker.c

                # dependencies
                ${PROJECT_SOURCE_DIR}/deps/libc_time.c
                ${PROJECT_SOURCE_DIR}/deps/pcg_basic.c
                ${PROJECT_SOURCE_DIR}/deps/base64.c)

set(default_plugin_headers ${PROJECT_SOURCE_DIR}/plugins/ua_accesscontrol_default.h
                           ${historizing_default_plugin_headers}
                           ${PROJECT_SOURCE_DIR}/plugins/ua_pki_certificate.h
                           ${PROJECT_SOURCE_DIR}/plugins/ua_log_stdout.h
                           ${PROJECT_SOURCE_DIR}/plugins/ua_nodestore_default.h
                           ${PROJECT_SOURCE_DIR}/plugins/ua_config_default.h
                           ${PROJECT_SOURCE_DIR}/plugins/securityPolicies/ua_securitypolicies.h
)

set(default_plugin_sources ${PROJECT_SOURCE_DIR}/plugins/ua_log_stdout.c
                           ${PROJECT_SOURCE_DIR}/plugins/ua_accesscontrol_default.c
                           ${historizing_default_plugin_sources}
                           ${PROJECT_SOURCE_DIR}/plugins/ua_pki_certificate.c
                           ${PROJECT_SOURCE_DIR}/plugins/ua_nodestore_default.c
                           ${PROJECT_SOURCE_DIR}/plugins/ua_config_default.c
                           ${PROJECT_SOURCE_DIR}/plugins/securityPolicies/ua_securitypolicy_none.c
)

if(UA_ENABLE_ENCRYPTION)
    list(APPEND default_plugin_sources
         ${PROJECT_SOURCE_DIR}/plugins/securityPolicies/ua_securitypolicy_basic128rsa15.c
         ${PROJECT_SOURCE_DIR}/plugins/securityPolicies/ua_securitypolicy_basic256sha256.c)
endif()

if(UA_ENABLE_DISCOVERY)
    list(INSERT internal_headers 13 ${PROJECT_SOURCE_DIR}/src/server/ua_discovery_manager.h)
    list(APPEND lib_sources ${PROJECT_SOURCE_DIR}/src/server/ua_discovery_manager.c)
endif()

if(UA_ENABLE_PUBSUB)
    list(APPEND default_plugin_headers ${PROJECT_SOURCE_DIR}/plugins/networking/ua_network_pubsub_udp.h)
    list(APPEND default_plugin_sources ${PROJECT_SOURCE_DIR}/plugins/networking/ua_network_pubsub_udp.c)
    if(UA_ENABLE_PUBSUB_ETH_UADP)
        list(APPEND default_plugin_headers ${PROJECT_SOURCE_DIR}/plugins/networking/ua_network_pubsub_ethernet.h)
        list(APPEND default_plugin_sources ${PROJECT_SOURCE_DIR}/plugins/networking/ua_network_pubsub_ethernet.c)
    endif()
endif()

if(UA_ENABLE_JSON_ENCODING)
    list(APPEND internal_headers ${PROJECT_SOURCE_DIR}/deps/jsmn/jsmn.h
                                 ${PROJECT_SOURCE_DIR}/deps/string_escape.h
                                 ${PROJECT_SOURCE_DIR}/deps/itoa.h
                                 ${PROJECT_SOURCE_DIR}/deps/atoi.h
                                 ${PROJECT_SOURCE_DIR}/src/ua_types_encoding_json.h)
    list(APPEND lib_sources ${PROJECT_SOURCE_DIR}/deps/jsmn/jsmn.c
                            ${PROJECT_SOURCE_DIR}/deps/string_escape.c
                            ${PROJECT_SOURCE_DIR}/deps/itoa.c
                            ${PROJECT_SOURCE_DIR}/deps/atoi.c
                            ${PROJECT_SOURCE_DIR}/src/ua_types_encoding_json.c)
endif()

if(UA_ENABLE_CUSTOM_LIBC)
     list(APPEND lib_sources ${PROJECT_SOURCE_DIR}/deps/musl/floatscan.c
                             ${PROJECT_SOURCE_DIR}/deps/musl/vfprintf.c)
endif()

if(UA_ENABLE_SUBSCRIPTIONS)
    list(APPEND lib_sources ${PROJECT_SOURCE_DIR}/src/server/ua_subscription.c
                            ${PROJECT_SOURCE_DIR}/src/server/ua_subscription_monitoreditem.c
                            ${PROJECT_SOURCE_DIR}/src/server/ua_subscription_datachange.c)
    if(UA_ENABLE_SUBSCRIPTIONS_EVENTS)
        list(APPEND lib_sources ${PROJECT_SOURCE_DIR}/src/server/ua_subscription_events.c)
    endif()
endif()

if(UA_DEBUG_DUMP_PKGS)
    list(APPEND lib_sources ${PROJECT_SOURCE_DIR}/plugins/ua_debug_dump_pkgs.c)
endif()

if(UA_ENABLE_DISCOVERY_MULTICAST)
    # prepend in list, otherwise it complains that winsock2.h has to be included before windows.h
    set(internal_headers ${PROJECT_BINARY_DIR}/src_generated/mdnsd_config.h
                         ${PROJECT_SOURCE_DIR}/deps/mdnsd/libmdnsd/1035.h
                         ${PROJECT_SOURCE_DIR}/deps/mdnsd/libmdnsd/xht.h
                         ${PROJECT_SOURCE_DIR}/deps/mdnsd/libmdnsd/sdtxt.h
                         ${PROJECT_SOURCE_DIR}/deps/mdnsd/libmdnsd/mdnsd.h
                         ${internal_headers} )
    set(lib_sources ${PROJECT_SOURCE_DIR}/src/server/ua_server_discovery_mdns.c
        ${PROJECT_SOURCE_DIR}/deps/mdnsd/libmdnsd/1035.c
        ${PROJECT_SOURCE_DIR}/deps/mdnsd/libmdnsd/xht.c
        ${PROJECT_SOURCE_DIR}/deps/mdnsd/libmdnsd/sdtxt.c
        ${PROJECT_SOURCE_DIR}/deps/mdnsd/libmdnsd/mdnsd.c
        ${lib_sources})
endif()

if(UA_BUILD_FUZZING OR UA_BUILD_OSS_FUZZ)
    set(lib_sources
        ${lib_sources}
        ${PROJECT_SOURCE_DIR}/tests/fuzz/custom_memory_manager.c)
endif()

#########################
# Generate source files #
#########################

if(UA_NAMESPACE_ZERO STREQUAL "FULL")
    if(NOT UA_FILE_NS0)
        set(UA_FILE_NS0 ${PROJECT_SOURCE_DIR}/deps/ua-nodeset/Schema/Opc.Ua.NodeSet2.xml)
    endif()

    set(UA_FILE_NODEIDS ${PROJECT_SOURCE_DIR}/deps/ua-nodeset/Schema/NodeIds.csv)
    set(UA_FILE_STATUSCODES ${PROJECT_SOURCE_DIR}/deps/ua-nodeset/Schema/StatusCode.csv)
    set(UA_FILE_TYPES_BSD ${PROJECT_SOURCE_DIR}/deps/ua-nodeset/Schema/Opc.Ua.Types.bsd)
else()
    if(NOT UA_FILE_NS0)
        set(UA_FILE_NS0 ${PROJECT_SOURCE_DIR}/tools/schema/Opc.Ua.NodeSet2.Minimal.xml)
    endif()
    set(UA_FILE_DATATYPES ${PROJECT_SOURCE_DIR}/tools/schema/datatypes_minimal.txt)
    set(UA_FILE_NODEIDS ${PROJECT_SOURCE_DIR}/tools/schema/NodeIds.csv)
    set(UA_FILE_STATUSCODES ${PROJECT_SOURCE_DIR}/tools/schema/StatusCode.csv)
    set(UA_FILE_TYPES_BSD ${PROJECT_SOURCE_DIR}/tools/schema/Opc.Ua.Types.bsd)

    if(UA_ENABLE_METHODCALLS)
        list(APPEND UA_FILE_DATATYPES ${PROJECT_SOURCE_DIR}/tools/schema/datatypes_method.txt)
    endif()

    if(UA_ENABLE_SUBSCRIPTIONS)
        list(APPEND UA_FILE_DATATYPES ${PROJECT_SOURCE_DIR}/tools/schema/datatypes_subscriptions.txt)
    endif()

    if(UA_ENABLE_HISTORIZING)
        list(APPEND UA_FILE_DATATYPES ${PROJECT_SOURCE_DIR}/tools/schema/datatypes_historizing.txt)
    endif()

    if(UA_ENABLE_DISCOVERY)
        list(APPEND UA_FILE_DATATYPES ${PROJECT_SOURCE_DIR}/tools/schema/datatypes_discovery.txt)
    endif()

    if(UA_ENABLE_QUERY)
        list(APPEND UA_FILE_DATATYPES ${PROJECT_SOURCE_DIR}/tools/schema/datatypes_query.txt)
    endif()

    if(UA_ENABLE_PUBSUB)
        list(APPEND UA_FILE_DATATYPES ${PROJECT_SOURCE_DIR}/tools/schema/datatypes_pubsub.txt)
        if(UA_ENABLE_PUBSUB_INFORMATIONMODEL)
            set(UA_FILE_NSPUBSUB ${PROJECT_SOURCE_DIR}/tools/schema/Opc.Ua.NodeSet2.PubSubMinimal.xml)
        endif()
    endif()
endif()

if(NOT EXISTS "${UA_FILE_NS0}")
    message(FATAL_ERROR "File ${UA_FILE_NS0} not found. You probably need to initialize the git submodule for deps/ua-nodeset.")
endif()

# standard-defined data types
ua_generate_datatypes(
    BUILTIN
    NAME "ua_types"
    TARGET_SUFFIX "types"
    NAMESPACE_IDX 0
    FILE_CSV "${UA_FILE_NODEIDS}"
    FILES_BSD "${UA_FILE_TYPES_BSD}"
    FILES_SELECTED ${UA_FILE_DATATYPES}
)

# transport data types
ua_generate_datatypes(
    NAME "ua_transport"
    TARGET_SUFFIX "transport"
    NAMESPACE_IDX 1
    FILE_CSV "${UA_FILE_NODEIDS}"
    FILES_BSD "${UA_FILE_TYPES_BSD}" "${PROJECT_SOURCE_DIR}/tools/schema/Custom.Opc.Ua.Transport.bsd"
    FILES_SELECTED "${PROJECT_SOURCE_DIR}/tools/schema/datatypes_transport.txt"
)

# statuscode explanation
add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/src_generated/ua_statuscodes.h
                          ${PROJECT_BINARY_DIR}/src_generated/ua_statuscodes.c
        PRE_BUILD
        COMMAND ${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/tools/generate_statuscode_descriptions.py
        ${UA_FILE_STATUSCODES} ${PROJECT_BINARY_DIR}/src_generated/ua_statuscodes
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/generate_statuscode_descriptions.py
                ${UA_FILE_STATUSCODES})

# Header containing defines for all NodeIds
ua_generate_nodeid_header(
    NAME "ua_nodeids"
    ID_PREFIX "NS0"
    TARGET_SUFFIX "ids-ns0"
    FILE_CSV "${UA_FILE_NODEIDS}"
)

# we need a custom target to avoid that the generator is called concurrently and
# thus overwriting files while the other thread is compiling
add_custom_target(open62541-generator-statuscode DEPENDS
        ${PROJECT_BINARY_DIR}/src_generated/ua_nodeids.h
        ${PROJECT_BINARY_DIR}/src_generated/ua_statuscodes.h
        ${PROJECT_BINARY_DIR}/src_generated/ua_statuscodes.c)

if (UA_ENABLE_AMALGAMATION)
    # single-file release
    add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/open62541.h
                       PRE_BUILD
                       COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/tools/amalgamate.py
                               ${OPEN62541_VER_COMMIT} ${CMAKE_CURRENT_BINARY_DIR}/open62541.h
                               ${exported_headers} ${default_plugin_headers} ${ua_architecture_headers}
                       DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/amalgamate.py
                               ${exported_headers} ${default_plugin_headers} ${ua_architecture_headers})

    add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/open62541.c
                       PRE_BUILD
                       COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/tools/amalgamate.py
                               ${OPEN62541_VER_COMMIT} ${CMAKE_CURRENT_BINARY_DIR}/open62541.c
                               ${internal_headers} ${lib_sources} ${default_plugin_sources} ${ua_architecture_sources}
                       DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/amalgamate.py ${internal_headers}
                               ${lib_sources} ${default_plugin_sources} ${ua_architecture_sources} )

    add_custom_target(open62541-amalgamation-source DEPENDS ${PROJECT_BINARY_DIR}/open62541.c)
    add_custom_target(open62541-amalgamation-header DEPENDS ${PROJECT_BINARY_DIR}/open62541.h)

    add_dependencies(open62541-amalgamation-header open62541-generator-types)
    add_dependencies(open62541-amalgamation-source open62541-generator-types
                     open62541-generator-transport open62541-generator-statuscode)
endif()

if(NOT UA_NODESET_ENCODE_BINARY_SIZE)
    set(UA_NODESET_ENCODE_BINARY_SIZE 32000)
endif()

ua_generate_nodeset(
    NAME "ns0"
    FILE "${UA_FILE_NS0}" "${UA_FILE_NSPUBSUB}"
    INTERNAL
    IGNORE "${PROJECT_SOURCE_DIR}/tools/nodeset_compiler/NodeID_NS0_Base.txt"
    ENCODE_BINARY_SIZE ${UA_NODESET_ENCODE_BINARY_SIZE}
    DEPENDS_TARGET "open62541-generator-types"
)

# stack protector and optimization needs to be disabled for the huge ns0 file, otherwise debian packaging fails due to long build times.
# We also disable optimization on Appveyor builds, since they take almost an hour otherwise
if(UA_PACK_DEBIAN OR (NOT "$ENV{APPVEYOR}" STREQUAL "") OR (
        (CMAKE_BUILD_TYPE STREQUAL "MinSizeRel" OR CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo") AND (
            # List of compilers which have problems with the huge ns0 optimization
            (("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang") AND (CMAKE_C_COMPILER_VERSION VERSION_LESS 7.0))
        )
   ))
    set_source_files_properties(${PROJECT_BINARY_DIR}/src_generated/ua_namespace0.c PROPERTIES COMPILE_FLAGS "-fno-stack-protector -O0")
endif()

#####################
# Build the Library #
#####################

assign_source_group(${lib_sources})
assign_source_group(${internal_headers})
assign_source_group(${exported_headers})
assign_source_group(${default_plugin_sources})
assign_source_group(${ua_architecture_sources})

if(UA_ENABLE_AMALGAMATION)
    add_library(open62541-object OBJECT ${PROJECT_BINARY_DIR}/open62541.c ${PROJECT_BINARY_DIR}/open62541.h)
    target_include_directories(open62541-object PRIVATE ${PROJECT_BINARY_DIR})

    # make sure the open62541_amalgamation target builds before so that amalgamation is finished and it is not executed again for open62541-object
    # and thus may overwrite the amalgamation result during multiprocessor compilation
    # the header is already a dependency of open62541 target itself
    add_dependencies(open62541-object
                     open62541-amalgamation-header
                     open62541-generator-types
                     open62541-generator-transport
                     open62541-generator-statuscode
                     open62541-amalgamation-source)

    add_library(open62541 $<TARGET_OBJECTS:open62541-object>)

    if(UA_COMPILE_AS_CXX)
        set_source_files_properties(${PROJECT_BINARY_DIR}/open62541.c PROPERTIES LANGUAGE CXX)
    endif()

    add_dependencies(open62541-amalgamation-source open62541-generator-namespace)
    add_dependencies(open62541-amalgamation-header open62541-generator-namespace)
else()
    add_library(open62541-object OBJECT ${lib_sources} ${internal_headers} ${exported_headers})
    add_dependencies(open62541-object
                     open62541-generator-types
                     open62541-generator-transport
                     open62541-generator-statuscode
                     open62541-generator-namespace
                     )
    target_include_directories(open62541-object PRIVATE ${PROJECT_SOURCE_DIR}/src)

    add_library(open62541-plugins OBJECT ${default_plugin_sources} ${ua_architecture_sources} ${exported_headers})
    add_dependencies(open62541-plugins open62541-generator-types open62541-generator-transport)
    target_include_directories(open62541-plugins PRIVATE ${PROJECT_SOURCE_DIR}/plugins)
    target_include_directories(open62541-plugins PRIVATE ${PROJECT_BINARY_DIR}/src_generated)
    target_compile_definitions(open62541-plugins PRIVATE -DUA_DYNAMIC_LINKING_EXPORT)
    set_target_properties(open62541-plugins PROPERTIES FOLDER "open62541/lib")

    add_library(open62541 $<TARGET_OBJECTS:open62541-object> $<TARGET_OBJECTS:open62541-plugins>)

    if(UA_COMPILE_AS_CXX)
        set_source_files_properties(${lib_sources} PROPERTIES LANGUAGE CXX)
        set_source_files_properties(${default_plugin_sources} ${ua_architecture_sources} PROPERTIES LANGUAGE CXX)
    endif()

endif()

# Export Symbols
target_compile_definitions(open62541-object PRIVATE -DUA_DYNAMIC_LINKING_EXPORT)
target_compile_definitions(open62541 PRIVATE -DUA_DYNAMIC_LINKING_EXPORT)
if (UA_ENABLE_DISCOVERY_MULTICAST)
    target_compile_definitions(open62541-object PRIVATE -DMDNSD_DYNAMIC_LINKING_EXPORT)
    target_compile_definitions(open62541 PRIVATE -DMDNSD_DYNAMIC_LINKING_EXPORT)
endif()
# Generate properly versioned shared library links on Linux
SET_TARGET_PROPERTIES(open62541 PROPERTIES SOVERSION 0 VERSION "${OPEN62541_VER_MAJOR}.${OPEN62541_VER_MINOR}.${OPEN62541_VER_PATCH}")

##################################
#     Architectures changes      #
##################################

GET_PROPERTY(ua_architecture_add_definitions GLOBAL PROPERTY UA_ARCHITECTURE_ADD_DEFINITIONS)
add_definitions(${ua_architecture_add_definitions})

GET_PROPERTY(ua_architecture_remove_definitions GLOBAL PROPERTY UA_ARCHITECTURE_REMOVE_DEFINITIONS)
if (NOT "${ua_architecture_remove_definitions}" STREQUAL "")
  string(REPLACE " " ";" ua_architecture_remove_definitions_list ${ua_architecture_remove_definitions})
  remove_definitions(${ua_architecture_remove_definitions_list})
endif(NOT "${ua_architecture_remove_definitions}" STREQUAL "")

GET_PROPERTY(ua_architecture_append_to_library GLOBAL PROPERTY UA_ARCHITECTURE_APPEND_TO_LIBRARY)
list(APPEND open62541_LIBRARIES ${ua_architecture_append_to_library})

target_compile_definitions(open62541 PUBLIC UA_ARCHITECTURE_${UA_ARCHITECTURE_UPPER})

# DLL requires linking to dependencies
target_link_libraries(open62541 ${open62541_LIBRARIES})

##########################
# Build Selected Targets #
##########################

# always include, builds with make doc
add_subdirectory(doc)

if(UA_BUILD_EXAMPLES)
    if(UA_ENABLE_AMALGAMATION)
        # Cannot compile tests with amalgamation. Not prepared for single header include
        message(FATAL_ERROR "Examples cannot be built with source amalgamation enabled")
    endif()
    add_subdirectory(examples)
endif()

if(UA_BUILD_UNIT_TESTS)
    if(UA_ENABLE_AMALGAMATION)
        # Cannot compile tests with amalgamation. Amalgamation uses the default plugins, not the testing plugins
        message(FATAL_ERROR "Unit tests cannot be generated with source amalgamation enabled")
    endif()
    enable_testing()
    add_subdirectory(tests)
endif()

if(UA_BUILD_FUZZING OR UA_BUILD_OSS_FUZZ OR UA_BUILD_FUZZING_CORPUS)
    add_subdirectory(tests/fuzz)
endif()

##########################
# Installation           #
##########################
# invoke via `make install`
# specify install location with `-DCMAKE_INSTALL_PREFIX=xyz`
# Enable shared library with `-DBUILD_SHARED_LIBS=ON`

set(cmake_configfile_install ${LIB_INSTALL_DIR}/cmake/open62541)
set(target_install_dest_name "${cmake_configfile_install}/open62541Targets.cmake")
set(macros_install_dest_name "${cmake_configfile_install}/open62541Macros.cmake")
set(open62541_install_tools_dir share/open62541/tools)
set(open62541_install_nodeset_dir share/open62541/tools/ua-nodeset)
set(open62541_install_include_dir include/open62541)

# This list of components allows to define a find_package requirement.
# E.g.:
# find_package(open62541 0.4.0 REQUIRED COMPONENTS Events Methods FullNamespace)
set(open62541_enabled_components "")
if(UA_NAMESPACE_ZERO STREQUAL "FULL")
    list(APPEND open62541_enabled_components "FullNamespace")
endif()
if(UA_ENABLE_METHODCALLS)
    list(APPEND open62541_enabled_components "Methods")
endif()
if(UA_ENABLE_SUBSCRIPTIONS)
    list(APPEND open62541_enabled_components "Subscriptions")
endif()
if(UA_ENABLE_PUBSUB)
    list(APPEND open62541_enabled_components "PubSub")
endif()
if(UA_ENABLE_ENCRYPTION)
    list(APPEND open62541_enabled_components "Encryption")
endif()
if(UA_ENABLE_AMALGAMATION)
    list(APPEND open62541_enabled_components "Amalgamation")
endif()
if(UA_ENABLE_HISTORIZING)
    list(APPEND open62541_enabled_components "Historizing")
endif()
if(UA_ENABLE_EXPERIMENTAL_HISTORIZING)
    list(APPEND open62541_enabled_components "ExperimentalHistorizing")
endif()
if(UA_ENABLE_SUBSCRIPTIONS_EVENTS)
    list(APPEND open62541_enabled_components "Events")
endif()
if(UA_ENABLE_MULTITHREADING)
    list(APPEND open62541_enabled_components "Multithreading")
endif()
if(UA_ENABLE_DISCOVERY)
    list(APPEND open62541_enabled_components "Discovery")
endif()
if(UA_ENABLE_DISCOVERY_MULTICAST)
    list(APPEND open62541_enabled_components "DiscoveryMulticast")
endif()

# export library (either static or shared depending on BUILD_SHARED_LIBS)
if(NOT UA_ENABLE_AMALGAMATION)
install(TARGETS open62541
        EXPORT open62541Targets
        LIBRARY DESTINATION ${LIB_INSTALL_DIR}
        ARCHIVE DESTINATION ${LIB_INSTALL_DIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}
        INCLUDES DESTINATION include/open62541 include)
else()
install(TARGETS open62541
        EXPORT open62541Targets
        LIBRARY DESTINATION ${LIB_INSTALL_DIR}
        ARCHIVE DESTINATION ${LIB_INSTALL_DIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}
        INCLUDES DESTINATION include)
# Our default way of installation is the non-amalgamated version.
# See also https://github.com/open62541/open62541/pull/2292#discussion_r241106424
install(CODE "MESSAGE(WARNING \"Installation with UA_ENABLE_AMALGAMATION=ON is not recommended.\")")
endif()

include(CMakePackageConfigHelpers)
configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/tools/cmake/open62541Config.cmake.in"
                              "${CMAKE_CURRENT_BINARY_DIR}/cmake/open62541Config.cmake"
                              INSTALL_DESTINATION "${cmake_configfile_install}"
                              PATH_VARS target_install_dest_name
                                        macros_install_dest_name
                                        open62541_install_tools_dir
                                        open62541_install_nodeset_dir
                                        open62541_enabled_components
                              )

set(open62541_VERSION)
get_target_property(open62541_VERSION open62541 VERSION)

write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/open62541ConfigVersion.cmake"
                                 VERSION ${open62541_VERSION}
                                 COMPATIBILITY AnyNewerVersion)

install(EXPORT open62541Targets
        FILE open62541Targets.cmake
        DESTINATION "${cmake_configfile_install}")

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/cmake/open62541Config.cmake"
              "${CMAKE_CURRENT_BINARY_DIR}/open62541ConfigVersion.cmake"
        DESTINATION "${cmake_configfile_install}")

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/tools/cmake/macros_public.cmake"
        DESTINATION "${cmake_configfile_install}"
        RENAME "open62541Macros.cmake"
        )


if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    install(FILES "${PROJECT_BINARY_DIR}/src_generated/open62541.pc"
            DESTINATION ${LIB_INSTALL_DIR}/pkgconfig)
endif()

set(UA_install_tools_dirs "tools/certs"
    "tools/nodeset_compiler"
    "tools/schema"
    "deps/ua-nodeset")

set(UA_install_tools_files "tools/generate_datatypes.py"
    "tools/generate_nodeid_header.py"
    "tools/generate_statuscode_descriptions.py")

install(DIRECTORY ${UA_install_tools_dirs} DESTINATION ${open62541_install_tools_dir} USE_SOURCE_PERMISSIONS)
install(FILES ${UA_install_tools_files} DESTINATION ${open62541_install_tools_dir})

if(NOT UA_ENABLE_AMALGAMATION)
    # Assume no files have identical names and place everything in the include folder
    install(FILES ${internal_headers}
                  ${exported_headers}
                  ${default_plugin_headers}
                  ${historizing_default_plugin_headers}
                  ${ua_architecture_headers}
            DESTINATION ${open62541_install_include_dir})
else()
    # Export amalgamated header open62541.h which is generated due to build of 
    # open62541-object
    install(FILES ${PROJECT_BINARY_DIR}/open62541.h DESTINATION include)
endif()

add_subdirectory(tools/packaging)

##################################
# Visual studio solution folders #
##################################

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "_CmakePredifinedTargets")

set_target_properties(open62541 PROPERTIES FOLDER "open62541/lib")
set_target_properties(open62541-object PROPERTIES FOLDER "open62541/lib")
set_target_properties(lint PROPERTIES FOLDER "CodeAnalysis")
if (UA_ENABLE_AMALGAMATION)
    set_target_properties(open62541-amalgamation-header PROPERTIES FOLDER "open62541/lib")
    set_target_properties(open62541-amalgamation-source PROPERTIES FOLDER "open62541/lib")
endif()

set_target_properties(open62541-generator-namespace PROPERTIES FOLDER "open62541/generators")
set_target_properties(open62541-generator-statuscode PROPERTIES FOLDER "open62541/generators")
set_target_properties(open62541-generator-transport PROPERTIES FOLDER "open62541/generators")
set_target_properties(open62541-generator-types PROPERTIES FOLDER "open62541/generators")

