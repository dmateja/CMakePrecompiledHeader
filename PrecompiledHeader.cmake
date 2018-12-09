cmake_minimum_required( VERSION 3.10 )

function( target_precompiled_header pch_target pch_file )
	cmake_parse_arguments( pch "FORCE_INCLUDE" "" "EXCLUDE_LIST" ${ARGN} )

	message( STATUS "${pch_target}")

	get_filename_component( pch_name ${pch_file} NAME )
	get_filename_component( pch_name_we ${pch_file} NAME_WE )
	get_filename_component( pch_dir ${pch_file} DIRECTORY )
	set( pch_h "${pch_file}" ) # StdAfx.h or Dir1/Dir2/StdAfx.h
	set( pch_pure_h "${pch_name}" ) # just StdAfx.h NOT Dir1/Dir2/StdAfx.h

	set( pch_pch "${pch_name}.pch" ) # just StdAfx.h.pch

	get_target_property( srcs ${pch_target} SOURCES )

	if( CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" )
		# set path to c/cc/cpp/cxx next to h
		if( pch_dir )
			set( pch_cpp_reg ".*${pch_dir}/${pch_name_we}.\(cpp|cc|c\)$" )
		else()
			set( pch_cpp_reg ".*${pch_name_we}.\(cpp|cxx|cc|c\)$" )
		endif()

		set( pch_out "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${pch_target}.dir/${pch_pch}" )

		foreach( src ${srcs} )
			get_filename_component( src_name "${src}" NAME )
			
			if( ${src_name} IN_LIST pch_EXCLUDE_LIST )
				continue()
			endif()

			if( src MATCHES \\.\(cpp|cxx|cc|c\)$ )
				# precompiled cpp
				if( ${src} MATCHES ${pch_cpp_reg} )
					if( pch_cpp_found )
						message( FATAL_ERROR "Too many ${pch_file} in ${pch_target}")
					endif()
					set( pch_cpp_found TRUE )
					set_property( SOURCE ${src} APPEND PROPERTY OBJECT_OUTPUTS "${pch_out}" )
					set_property( SOURCE ${src} APPEND_STRING PROPERTY COMPILE_FLAGS " /Yc${pch_pure_h} /Fp${pch_out}" )
				# common cpp
				else()
					set( pch_cpp_needed TRUE )
					set_property( SOURCE ${src} APPEND PROPERTY OBJECT_DEPENDS "${pch_out}" )
					set_property( SOURCE ${src} APPEND_STRING PROPERTY COMPILE_FLAGS " /Yu${pch_pure_h} /Fp${pch_out}" )

					if( pch_FORCE_INCLUDE )
						set_property( SOURCE ${src} APPEND_STRING PROPERTY COMPILE_FLAGS " /FI${pch_pure_h}" )
					endif()
				endif()
			endif()
		endforeach()

		if( pch_cpp_needed AND NOT pch_cpp_found )
			message( FATAL_ERROR "${pch_cpp} is required by MSVC" )
		endif()

		message( STATUS "Precompiled header enabled for ${pch_target}" )
	endif()

	if( CMAKE_CXX_COMPILER_ID STREQUAL "Clang" )
		set( pch_out "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${pch_target}.dir/${pch_pch}" )


	endif()

endfunction()