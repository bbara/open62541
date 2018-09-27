# automatically add encryption support if mbedtls library found

# The recommended way is to install mbedtls via the OS package manager. If
# that is not possible, manually compile mbedTLS and set the cmake variables
# defined in /tools/cmake/FindMbedTLS.cmake.
find_package(MbedTLS)
if(MbedTLS_FOUND)
  list(APPEND open62541_LIBRARIES ${MBEDTLS_LIBRARIES})
  ua_set_if_not_set(UA_ENABLE_ENCRYPTION ON)
endif()
