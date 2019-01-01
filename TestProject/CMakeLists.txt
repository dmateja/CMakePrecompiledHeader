cmake_minimum_required( VERSION 3.12 )

include( ../PrecompiledHeader.cmake )

include_directories( incGlobal )
include_directories( SYSTEM incSys )
add_definitions( -DGLOB_CD )
add_compile_definitions( GLOB_CD_ADD=1 )

add_subdirectory( "proj" )
add_subdirectory( "l1" )
add_subdirectory( "l2" )
add_subdirectory( "dlls" )