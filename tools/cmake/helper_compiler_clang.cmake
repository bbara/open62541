if(NOT UA_COMPILE_AS_CXX)
    add_definitions(-std=c99 -pipe
                    -Wall -Wextra -Werror -Wpedantic
                    -Wno-static-in-inline # clang doesn't like the use of static inline methods inside static inline methods
                    -Wno-overlength-strings # may happen in the nodeset compiler when complex values are directly encoded
                    -Wno-unused-parameter # some methods may require unused arguments to cast to a method pointer
                    -Wmissing-prototypes -Wstrict-prototypes -Wredundant-decls
                    -Wformat -Wformat-security -Wformat-nonliteral
                    -Wuninitialized -Winit-self
                    -Wcast-qual
                    -Wstrict-overflow
                    -Wnested-externs
                    -Wmultichar
                    -Wundef
                    -Wc++-compat
                    -fno-strict-aliasing # fewer compiler assumptions about pointer types
                    -fexceptions # recommended for multi-threaded C code, also in combination with C++ code
    )

    if(UA_ENABLE_PROTECTORS)
        check_cc_flag("-fstack-protector-strong") # more performant stack protector, available since gcc 4.9
        check_cc_flag_untested("-mcet -fcf-protection") # future use (control flow integrity protection)
        check_cc_flag_untested("-fstack-clash-protection") # future use (increased reliability of stack overflow detection)        
    endif()

    # needed to check if IPO is supported (check needs cmake > 3.9)
    if("${CMAKE_VERSION}" VERSION_GREATER 3.9)
        cmake_policy(SET CMP0069 NEW) # needed as long as required cmake < 3.9
        include(CheckIPOSupported)
        check_ipo_supported(RESULT CC_HAS_IPO) # Inter Procedural Optimization / Link Time Optimization (should be same as -flto)
        if(CC_HAS_IPO)
            set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
        endif()
    endif()

    if(UA_ENABLE_AMALGAMATION)
        add_definitions(-Wno-unused-function)
    endif()

    # Linker
    set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "") # cmake sets -rdynamic by default

    # Debug
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        # Add default sanitizer settings when using clang and Debug build.
        # This allows e.g. CLion to find memory locations for SegFaults
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-omit-frame-pointer -gline-tables-only -fsanitize=address -fsanitize-address-use-after-scope -fsanitize-coverage=trace-pc-guard,trace-cmp")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer -gline-tables-only -fsanitize=address -fsanitize-address-use-after-scope -fsanitize-coverage=trace-pc-guard,trace-cmp")
    endif()

    # Strip release builds
    if(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel" OR CMAKE_BUILD_TYPE STREQUAL "Release")
        add_definitions(-ffunction-sections -fdata-sections -fno-stack-protector -fno-unwind-tables
                        -fno-asynchronous-unwind-tables -fno-math-errno -fno-ident)
        if(UA_ENABLE_PROTECTORS)
            check_cc_flag("-D_FORTIFY_SOURCE=2") # run-time buffer overflow detection (needs at least -O1)    
        endif()
        if(NOT OS9)
            set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -s")
            set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -s")
        endif()
        if(APPLE)
            set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -Wl,-dead_strip")
            set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-dead_strip")
        else()
            set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -Wl,--gc-sections")
            set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--gc-sections")
        endif()
        if(NOT WIN32 AND NOT CYGWIN AND NOT APPLE)
            # these settings reduce the binary size by ~2kb
            set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -Wl,-z,norelro -Wl,--hash-style=gnu -Wl,--build-id=none")
        endif()
    endif()
endif()
