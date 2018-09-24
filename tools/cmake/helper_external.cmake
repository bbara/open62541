if(UA_ENABLE_ENCRYPTION)
    # The recommended way is to install mbedtls via the OS package manager. If
    # that is not possible, manually compile mbedTLS and set the cmake variables
    # defined in /tools/cmake/FindMbedTLS.cmake.
    find_package(MbedTLS REQUIRED)
    list(APPEND open62541_LIBRARIES ${MBEDTLS_LIBRARIES})
endif()
