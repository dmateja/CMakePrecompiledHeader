# MIT License
#
# Copyright (c) 2018 Daniel Mateja
#
# https://github.com/dmateja/CMakePrecompiledHeader
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



cmake_minimum_required( VERSION 3.12 )

function( target_precompiled_header pch_target pch_file )
	cmake_parse_arguments( pch "FORCE_INCLUDE" "" "EXCLUDE_LIST" ${ARGN} )

	message( STATUS "${pch_target}")

	get_filename_component( pch_name ${pch_file} NAME )
	get_filename_component( pch_name_we ${pch_file} NAME_WE )
	get_filename_component( pch_dir ${pch_file} DIRECTORY )
	set( pch_h "${pch_file}" ) # StdAfx.h or Dir1/Dir2/StdAfx.h
	set( pch_pure_h "${pch_name}" ) # just StdAfx.h NOT Dir1/Dir2/StdAfx.h
	set( pch_pch "${pch_name}.pch" ) # just StdAfx.h.pch
	set( pch_out_dir "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${pch_target}.dir" )

	get_target_property( srcs ${pch_target} SOURCES )

	if( CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" )
		# set path to c/cc/cpp/cxx next to h
		if( pch_dir )
			set( pch_cpp_reg ".*${pch_dir}/${pch_name_we}.\(cpp|cc|c\)$" )
		else()
			set( pch_cpp_reg ".*${pch_name_we}.\(cpp|cxx|cc|c\)$" )
		endif()

		set( pch_out "${pch_out_dir}/${pch_pch}" )

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
		set( pch_out_h "${pch_out_dir}/${pch_name}" )
		set( pch_out "${pch_out_dir}/${pch_pch}" )
		set( pch_h_in "${CMAKE_CURRENT_SOURCE_DIR}/${pch_file}")

		### check deprecated COMPILE_FLAGS
		get_directory_property( for_check COMPILE_FLAGS )
		if( for_check )
			message( FATAL_ERROR "COMPILE_FLAGS is deprecated and not supported by precompiled headers: ${for_check}" )
		endif()
		get_target_property( for_check ${pch_target} COMPILE_FLAGS )
		if( for_check )
			message( FATAL_ERROR "COMPILE_FLAGS is deprecated and not supported by precompiled headers: ${for_check}" )
		endif()
		foreach( src ${srcs} )
			get_filename_component( src_name "${src}" NAME )
			
			if( ${src_name} IN_LIST pch_EXCLUDE_LIST )
				continue()
			endif()

			get_source_file_property( for_check ${src} COMPILE_FLAGS )
			if( for_check )
				message( FATAL_ERROR "COMPILE_FLAGS is deprecated and not supported by precompiled headers: ${for_check}" )
			endif()
		endforeach()


		### prepare

		set( build_type ${CMAKE_BUILD_TYPE} )
		string( TOUPPER "${build_type}" build_type )
		set( current_build_cxx_flags ${CMAKE_CXX_FLAGS_${build_type}} )
		separate_arguments( current_build_cxx_flags )

		set( main_cmake_cxx_flags ${CMAKE_CXX_FLAGS} )
		separate_arguments( main_cmake_cxx_flags )

		get_target_property( tar_cxx_stand ${pch_target} CXX_STANDARD )		
		get_target_property( tar_cxx_ext ${pch_target} CXX_EXTENSIONS )
		set( _cxx_standard "" )
		if( tar_cxx_stand )
			if( tar_cxx_ext )
				set( _cxx_standard "-std=gnu++${tar_cxx_stand}" )
			else()
				set( _cxx_standard "-std=c++${tar_cxx_stand}" )
			endif()
		endif()

		get_target_property( tar_pic ${pch_target} POSITION_INDEPENDENT_CODE )
		get_target_property( tar_type ${pch_target} TYPE )
		set( _pic "" )
		if( tar_type STREQUAL EXECUTABLE )
			set( _pic "-fno-PIE" )
			if( tar_pic )
				set( _pic "-fPIE")
			endif()
		elseif( tar_type STREQUAL SHARED )
			#set( _pic "-fno-PIC" )
			if( tar_pic )
				set( _pic "-fPIC")
			else()
				message( FATAL_ERROR "There is no PIC enabled for SHARED" )
			endif()
		else()
			set( _pic "-fno-PIC" )
			if( tar_pic )
				set( _pic "-fPIC")
			endif()
		endif()
		
		get_target_property( tar_inc_dir ${pch_target} INCLUDE_DIRECTORIES )
		string( REPLACE ";" ";-I" tar_inc_dir "${tar_inc_dir}" )
		set( tar_inc_dir "-I${tar_inc_dir}" )

		get_target_property( dependencies ${pch_target} MANUALLY_ADDED_DEPENDENCIES )
		if( dependencies )
			foreach( project ${dependencies})
				get_target_property( tar_interface_inc_dir ${project} INTERFACE_INCLUDE_DIRECTORIES )
				string( REPLACE ";" ";-I" tar_interface_inc_dir "${tar_interface_inc_dir}" )
				set( tar_interface_inc_dir "-I${tar_interface_inc_dir}" )
				list( APPEND tar_inc_dir ${tar_interface_inc_dir})

				# TODO?
				# get_target_property( dep_int_def ${project} INTERFACE_COMPILE_DEFINITIONS )
				# message( STATUS "dep_int_def ${dep_int_def}")
				# get_target_property( dep_int_opt ${project} INTERFACE_COMPILE_OPTIONS )
				# message( STATUS "dep_int_opt ${dep_int_opt}")
			endforeach()
		endif()

		
		# add_compile_options writes from directory to target compile
		# add_compile_definitions writes only to directory

		get_target_property( tar_comp_opt ${pch_target} COMPILE_OPTIONS )

		get_directory_property( dir_comp_def COMPILE_DEFINITIONS )
		if( dir_comp_def )
			string( REPLACE ";" ";-D" dir_comp_def "${dir_comp_def}" )
			set( dir_comp_def "-D${dir_comp_def}" )
		elseif()
			set( dir_comp_def "" )
		endif()

		get_target_property( tar_comp_def ${pch_target} COMPILE_DEFINITIONS )
		if( tar_comp_def )
			string( REPLACE ";" ";-D" tar_comp_def "${tar_comp_def}" )
			set( tar_comp_def "-D${tar_comp_def}" )
		else()
			set( tar_comp_def "" )
		endif()

		# add command to copy precompiled header and compile it

		add_custom_command(
			OUTPUT "${pch_out_h}" 
			COMMAND "${CMAKE_COMMAND}" -E copy "${pch_h_in}" "${pch_out_h}"
			COMMENT "Coping precompiled header"
		)

		add_custom_command(
			OUTPUT "${pch_out}"
			COMMAND ${CMAKE_CXX_COMPILER} ${_cxx_standard} ${main_cmake_cxx_flags} ${current_build_cxx_flags} ${dir_comp_def} ${tar_comp_def} ${tar_comp_opt} ${_pic} ${tar_inc_dir} -x c++-header ${pch_h_in} -o ${pch_out}
			DEPENDS "${pch_out_h}"
			COMMENT "Compiling precompiled header"
		)

		# set dependencies to precompiled header

		foreach( src ${srcs} )
			get_filename_component( src_name "${src}" NAME )
			
			if( ${src_name} IN_LIST pch_EXCLUDE_LIST )
				continue()
			endif()

			if( src MATCHES \\.\(cpp|cxx|cc|c\)$ )
				set_property( SOURCE ${src} APPEND PROPERTY OBJECT_DEPENDS "${pch_out}" )
				set_property( SOURCE ${src} APPEND_STRING PROPERTY COMPILE_FLAGS " -Winvalid-pch -include ${pch_out_h}" )
			endif()
		endforeach()

	endif()

endfunction()