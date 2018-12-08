# CMakePrecompiledHeader

CMake function to enable precompiled headers.

- generate pch file for project
- possibility to force include pch (MSVC /FI)
- possibility to exclude files

Works with:
- MSVC (uses /Yc /Yu /Fp /FI) - source file for precompiled header must exists in your project, usually: StdAfx.h and StdAfx.cpp


Basic usage:
------
    include( PrecompiledHeader )
    ...
    add_executable( example main.cpp )
    target_precompiled_header( example "StdAfx.h" )
- MSVC - every cpp file must include precompiled header

Force include:
------
    include( PrecompiledHeader )
    ...
    add_executable( example main.cpp )
    target_precompiled_header( example "StdAfx.h" FORCE_INCLUDE )
- MSVC - force include (/FI) precompiled header in each source file (include pch is not required in source file)

Exclude files:
------
    include( PrecompiledHeader )
    ...
    add_executable( example main.cpp a.cpp b.cpp c.cpp )
    target_precompiled_header( example "StdAfx.h" EXCLUDE_LIST "a.cpp;b.cpp" )
Precompiled header is not enabled for files from EXCLUDE_LIST. Useful when you use an external code and you don't wont to use FORCE_INCLUDE option.

You can use FORCE_INCLUDE and EXCLUDE_LIST together
    include( PrecompiledHeader )
    ...
    add_executable( example main.cpp a.cpp b.cpp c.cpp )
    target_precompiled_header( example "StdAfx.h" FORCE_INCLUDE EXCLUDE_LIST "a.cpp;b.cpp" )