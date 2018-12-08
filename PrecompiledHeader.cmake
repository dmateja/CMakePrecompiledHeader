cmake_minimum_required( VERSION 3.10 )

function( target_precompiled_header pch_target pch_file )
	cmake_parse_arguments( pch "FORCE_INCLUDE" "" "EXCLUDE_LIST" ${ARGN} )

	message( STATUS "${pch_target}")

	get_filename_component( pch_name ${pch_file} NAME_WE )
	set( pch_h "${pch_file}" )
	set( pch_cpp "${pch_name}.cpp" )
	set( pch_pch "${pch_name}.pch" )

	get_target_property( srcs ${pch_target} SOURCES )

	if( CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" )
		set( pch_out "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${pch_target}.dir/${pch_pch}" )

		foreach( src ${srcs} )
			get_filename_component( src_name "${src}" NAME )
			
			if( ${src_name} IN_LIST pch_EXCLUDE_LIST )
				continue()
			endif()

			if( src MATCHES \\.\(cpp|cxx|cc\)$ )
				# kompilacja stdafx cppka i ustawienie outputa - tu jest problem z ninja i OBJECT_OUTPUTS - olewa to
				if( src_name STREQUAL ${pch_cpp} )
					# cppk pch znaleziony
					set( pch_cpp_found TRUE )
					set_property( SOURCE ${src} APPEND PROPERTY OBJECT_OUTPUTS "${pch_out}" )
					set_property( SOURCE ${src} APPEND_STRING PROPERTY COMPILE_FLAGS " /Yc${pch_h} /Fp${pch_out}" )
				# zwykly plik cpp
				else()
					# jest cppk wiec cppk pch potrzebny bo tak chce Visual
					set( pch_cpp_needed TRUE )
					set_property( SOURCE ${src} APPEND PROPERTY OBJECT_DEPENDS "${pch_out}" )
					set_property( SOURCE ${src} APPEND_STRING PROPERTY COMPILE_FLAGS " /Yu${pch_h} /Fp${pch_out}" )

					if( pch_FORCE_INCLUDE )
						set_property( SOURCE ${src} APPEND_STRING PROPERTY COMPILE_FLAGS " /FI${pch_h}" )
					endif()
				endif()
			endif()
		endforeach()

		if( pch_cpp_needed AND NOT pch_cpp_found )
			message( FATAL_ERROR "${pch_cpp} is required by MSVC" )
		endif()

		message( STATUS "Precompiled headers enabled for ${pch_target}" )
	endif()

endfunction()