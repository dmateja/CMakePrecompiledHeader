cmake_minimum_required( VERSION 3.12 )

include( ../PrecompiledHeader.cmake )

include_directories( incGlobal )
include_directories( SYSTEM incSys )
add_definitions( -DGLOB_CD )
add_compile_definitions( GLOB_CD_ADD=1 )
add_compile_options( -DGLOB_CO )

set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -DHAVE_ATOMICS=1" )
set( CMAKE_CXX_STANDARD 17 )
set( CMAKE_CXX_EXTENSIONS OFF )

add_subdirectory( "proj" )
add_subdirectory( "l1" )
add_subdirectory( "l2" )
add_subdirectory( "dlls" )