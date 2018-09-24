############################
# Linting run (clang-tidy) #
############################

if(UA_ENABLE_STATIC_ANALYZER)
  if(CMAKE_VERSION VERSION_GREATER 3.6)
    find_program(CLANG_TIDY_EXE NAMES "clang-tidy")
    if(CLANG_TIDY_EXE)
      set(CMAKE_C_CLANG_TIDY "${CLANG_TIDY_EXE};-checks=cert-*,performance-*,readability-*,-readability-braces-around-statements;\
-warnings-as-errors=cert-*,performance-*,readability-*,-readability-braces-around-statements")
    endif()

    find_program(CPPCHECK_EXE NAMES "cppcheck")
    if(CPPCHECK_EXE)
      set(CMAKE_C_CPPCHECK "${CPPCHECK_EXE};--enable=all;--inconclusive;--suppress=missingIncludeSystem")
    endif()

    find_program(CPPLINT_EXE NAMES "cpplint")
    if(CPPLINT_EXE)
      set(CMAKE_C_CPPLINT "${CPPLINT_EXE}")
    endif()
  endif()

  find_program(IWYU_EXE NAMES "iwyu")
  if(IWYU_EXE)
    set(CMAKE_C_INCLUDE_WHAT_YOU_USE "${IWYU_EXE}")
  endif()
endif()

find_program(CLANG_FORMAT_EXE NAMES "clang-format")
if(CLANG_FORMAT_EXE)
  file(GLOB_RECURSE FILES_TO_FORMAT *.c *.h)
  add_custom_target(
    clangformat
      COMMAND ${CLANG_FORMAT_EXE}
          -style=file
          -i
          ${FILES_TO_FORMAT}
  )
endif()

# keep the targets for now
find_package(ClangTools)
add_custom_target(lint ${CLANG_TIDY_PROGRAM}
                  ${lib_sources}
                  -checks=cert-*,performance-*,readability-*,-readability-braces-around-statements
                  -warnings-as-errors=cert-*,performance-*,readability-*,-readability-braces-around-statements
                  --
                  -std=c99
                  -I${PROJECT_SOURCE_DIR}/include
                  -I${PROJECT_SOURCE_DIR}/plugins
                  -I${PROJECT_SOURCE_DIR}/deps
                  -I${PROJECT_SOURCE_DIR}/src
                  -I${PROJECT_SOURCE_DIR}/src/server
                  -I${PROJECT_SOURCE_DIR}/src/client
                  -I${PROJECT_BINARY_DIR}/src_generated
                  -DUA_NO_AMALGAMATION
                  DEPENDS ${lib_sources}
                  COMMENT "Run clang-tidy on the library")
add_dependencies(lint open62541)

add_custom_target(cpplint cpplint
                  ${lib_sources}
                  ${internal_headers}
                  ${default_plugin_headers}
                  ${default_plugin_sources}
                  ${ua_architecture_headers}
                  ${ua_architecture_sources}
                  DEPENDS ${lib_sources}
                          ${internal_headers}
                          ${default_plugin_headers}
                          ${default_plugin_sources}
                          ${ua_architecture_headers}
                          ${ua_architecture_sources}

                  COMMENT "Run cpplint code style checker on the library")