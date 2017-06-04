###########################################################################
# Copyright 2015, 2016, 2017 IoT.bzh
#
# author: Fulup Ar Foll <fulup@iot.bzh>
# contrib: Romain Forlot <romain.forlot@iot.bzh>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################


#--------------------------------------------------------------------------
#  WARNING:
#     Do not change this cmake template
#     Customise your preferences in "./etc/config.cmake"
#--------------------------------------------------------------------------

# Get colorized message output non Windows OS. You know bash ? :)
if(NOT WIN32)
  string(ASCII 27 Esc)
  set(ColourReset "${Esc}[m")
  set(ColourBold  "${Esc}[1m")
  set(Red         "${Esc}[31m")
  set(Green       "${Esc}[32m")
  set(Yellow      "${Esc}[33m")
  set(Blue        "${Esc}[34m")
  set(Magenta     "${Esc}[35m")
  set(Cyan        "${Esc}[36m")
  set(White       "${Esc}[37m")
  set(BoldRed     "${Esc}[1;31m")
  set(BoldGreen   "${Esc}[1;32m")
  set(BoldYellow  "${Esc}[1;33m")
  set(BoldBlue    "${Esc}[1;34m")
  set(BoldMagenta "${Esc}[1;35m")
  set(BoldCyan    "${Esc}[1;36m")
  set(BoldWhite   "${Esc}[1;37m")
endif()

# Generic useful macro
# -----------------------
macro(PROJECT_TARGET_ADD TARGET_NAME)
	set_property(GLOBAL APPEND PROPERTY PROJECT_TARGETS ${TARGET_NAME})
	set(TARGET_NAME ${TARGET_NAME})
endmacro(PROJECT_TARGET_ADD)

macro(PROJECT_PKGDEP_ADD PKG_NAME)
	set_property(GLOBAL APPEND PROPERTY PROJECT_PKG_DEPS ${PKG_NAME})
endmacro(PROJECT_PKGDEP_ADD)

# Check GCC minimal version
if (gcc_minimal_version)
	message (STATUS "${Blue}-- Check gcc_minimal_version (found gcc version ${CMAKE_C_COMPILER_VERSION})  (found g++ version ${CMAKE_CXX_COMPILER_VERSION})${ColourReset}")
if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version} OR CMAKE_C_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version})
	message(FATAL_ERROR "${Red}**** FATAL: Require at least gcc-${gcc_minimal_version} please set CMAKE_C[XX]_COMPILER")
endif()
endif(gcc_minimal_version)

# Check Kernel minimal version
if (kernel_minimal_version)
	message (STATUS "${Blue}-- Check kernel_minimal_version (found kernel version ${CMAKE_SYSTEM_VERSION})${ColourReset}")
	if (CMAKE_SYSTEM_VERSION VERSION_LESS ${kernel_minimal_version})
	message(FATAL_ERROR "${Red}**** FATAL: Require at least ${kernel_minimal_version} please use a recent kernel.")
endif()
endif(kernel_minimal_version)

macro(defstr name value)
	add_definitions(-D${name}=${value})
endmacro(defstr)

# Pre-packaging
macro(project_targets_populate)

	# Default Widget default directory
	set(PACKAGE_BINDIR  ${PROJECT_PKG_BUILD_DIR}/bin)
	set(PACKAGE_ETCDIR  ${PROJECT_PKG_BUILD_DIR}/etc)
	set(PACKAGE_LIBDIR  ${PROJECT_PKG_BUILD_DIR}/lib)
	set(PACKAGE_HTTPDIR ${PROJECT_PKG_BUILD_DIR}/htdocs)
	set(PACKAGE_DATADIR ${PROJECT_PKG_BUILD_DIR}/data)

	add_custom_target(populate)
		get_property(PROJECT_TARGETS GLOBAL PROPERTY PROJECT_TARGETS)
	foreach(TARGET ${PROJECT_TARGETS})
		get_target_property(T ${TARGET} LABELS)
		if(T)
			# Declaration of a custom command that will populate widget tree with the target
			set(POPULE_PACKAGE_TARGET "project_populate_${TARGET}")

			get_target_property(P ${TARGET} PREFIX)
			get_target_property(BD ${TARGET} BINARY_DIR)
			get_target_property(OUT ${TARGET} OUTPUT_NAME)

			if(P MATCHES "NOTFOUND$")
				if (${T} STREQUAL "BINDING")
					set(P "lib")
				else()
					set(P "")
				endif()
			endif()

			if(${T} STREQUAL "BINDING")
				add_custom_command(OUTPUT ${PACKAGE_LIBDIR}/${P}${TARGET}.so
					DEPENDS ${TARGET}
					COMMAND mkdir -p ${PACKAGE_LIBDIR}
					COMMAND cp ${BD}/${P}${OUT}.so ${PACKAGE_LIBDIR}
				)
				add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PACKAGE_LIBDIR}/${P}${TARGET}.so)
				add_dependencies(populate ${POPULE_PACKAGE_TARGET}) 
			elseif(${T} STREQUAL "EXECUTABLE")
				add_custom_command(OUTPUT ${PACKAGE_BINDIR}/${P}${TARGET}
					DEPENDS ${TARGET}
					COMMAND mkdir -p ${PACKAGE_BINDIR}
					COMMAND cp ${BD}/${P}${OUT} ${PACKAGE_BINDIR}
				)
				add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PACKAGE_BINDIR}/${P}${TARGET})
				add_dependencies(populate ${POPULE_PACKAGE_TARGET}) 
			elseif(${T} STREQUAL "HTDOCS")
				add_custom_command(OUTPUT ${PACKAGE_HTTPDIR}-xx
					DEPENDS ${TARGET}
					COMMAND mkdir -p ${PACKAGE_HTTPDIR}
					COMMAND touch ${PACKAGE_HTTPDIR}
					COMMAND cp -r ${BD}/${P}${OUT}/* ${PACKAGE_HTTPDIR}
				)
					add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PACKAGE_HTTPDIR}-xx)
					add_dependencies(populate ${POPULE_PACKAGE_TARGET}) 
			elseif(${T} STREQUAL "DATA")
				add_custom_command(OUTPUT ${PACKAGE_DATADIR}-xx
					DEPENDS ${TARGET}
					COMMAND mkdir -p ${PACKAGE_DATADIR}
					COMMAND touch ${PACKAGE_DATADIR}
					COMMAND cp -r ${BD}/${P}${OUT} ${PACKAGE_DATADIR}
				)
					add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PACKAGE_DATADIR}-xx)
					add_dependencies(populate ${POPULE_PACKAGE_TARGET}) 
			endif(${T} STREQUAL "BINDING")
		elseif(${CMAKE_BUILD_TYPE} MATCHES "[Dd][Ee][Bb][Uu][Gg]")
			MESSAGE(".. Warning: ${TARGET} ignored when packaging.")
		endif()
	endforeach()
endmacro(project_targets_populate)

macro(remote_targets_populate)
	if (DEFINED ENV{RSYNC_TARGET})
	set (RSYNC_TARGET $ENV{RSYNC_TARGET})
	endif()
	if (DEFINED ENV{RSYNC_PREFIX})
	set (RSYNC_PREFIX $ENV{RSYNC_PREFIX})
	endif()

	set(
		REMOTE_LAUNCH "Test on target with: ${CMAKE_CURRENT_BINARY_DIR}/target/start-on-${RSYNC_TARGET}.sh" 
		CACHE STRING "Command to start ${PROJECT_NAME} on remote target ${RSYNC_TARGET}"
	)

	if(NOT RSYNC_TARGET OR NOT RSYNC_PREFIX)
		message ("${Yellow}.. Warning: RSYNC_TARGET RSYNC_PREFIX not defined 'make remote-target-populate' not instanciated${ColourReset}")
		add_custom_target(remote-target-populate
			COMMENT "${Red}*** Fatal: RSYNC_TARGET RSYNC_PREFIX environment variables required with 'make remote-target-populate'${ColourReset}"
			COMMAND exit -1
		)
	else()

		configure_file(${SSH_TEMPLATE_DIR}/start-on-target.in ${CMAKE_CURRENT_BINARY_DIR}/target/start-on-${RSYNC_TARGET}.sh)
		configure_file(${GDB_TEMPLATE_DIR}/gdb-on-target.in ${CMAKE_CURRENT_BINARY_DIR}/target/gdb-on-${RSYNC_TARGET}.ini)

		add_custom_target(remote-target-populate
			DEPENDS populate
			COMMAND chmod +x ${CMAKE_CURRENT_BINARY_DIR}/target/start-on-${RSYNC_TARGET}.sh
			COMMAND rsync --archive --delete ${PROJECT_PKG_BUILD_DIR}/ ${RSYNC_TARGET}:${RSYNC_PREFIX}/${PROJECT_NAME}
			COMMENT "${REMOTE_LAUNCH}"
		)
	endif()
endmacro(remote_targets_populate)

macro(wgt_package_build)
	if(NOT EXISTS ${WGT_TEMPLATE_DIR}/config.xml.in OR NOT EXISTS ${WGT_TEMPLATE_DIR}/icon-default.png)
		MESSAGE(FATAL_ERROR "${Red}WARNING ! Missing mandatory files to build widget file.\nYou need config.xml.in and ${PROJECT_ICON} files in ${WGT_TEMPLATE_DIR} folder.${ColourReset}")
	endif()

	configure_file(${WGT_TEMPLATE_DIR}/config.xml.in ${PROJECT_PKG_BUILD_DIR}/config.xml)
	configure_file(${WGT_TEMPLATE_DIR}/config.xml.in ${PROJECT_PKG_ENTRY_POINT}/config.xml)
	file(COPY ${WGT_TEMPLATE_DIR}/icon-default.png DESTINATION ${PROJECT_PKG_BUILD_DIR}/${PROJECT_ICON})

	# Fulup ??? copy any extra file in wgt/etc into populate package before building the widget
	file(GLOB PROJECT_CONF_FILES "${WGT_TEMPLATE_DIR}/etc/*")
	if(${PROJECT_CONF_FILES})
		file(COPY "${WGT_TEMPLATE_DIR}/etc/*" DESTINATION ${PROJECT_PKG_BUILD_DIR}/etc/)
	endif(${PROJECT_CONF_FILES})

	add_custom_command(OUTPUT ${PROJECT_NAME}.wgt
		DEPENDS ${PROJECT_TARGETS}
		COMMAND wgtpkg-pack -f -o ${PROJECT_NAME}.wgt ${PROJECT_PKG_BUILD_DIR}
	)

	add_custom_target(widget DEPENDS ${PROJECT_NAME}.wgt)
	add_dependencies(widget populate)
	set(ADDITIONAL_MAKE_CLEAN_FILES, "${PROJECT_NAME}.wgt")

	if(PACKAGE_MESSAGE)
	add_custom_command(TARGET widget
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "++ ${PACKAGE_MESSAGE}")
	endif()
endmacro(wgt_package_build)

macro(rpm_package_build)
	if(NOT EXISTS ${RPM_TEMPLATE_DIR}/rpm-config.spec.in)
		MESSAGE(FATAL_ERROR "${Red}Missing mandatory files: you need rpm-config.spec.in in ${RPM_TEMPLATE_DIR} folder.${ColourReset}")
	endif()

	# extract PROJECT_PKG_DEPS and replace ; by , for RPM spec file
	get_property(PROJECT_PKG_DEPS GLOBAL PROPERTY PROJECT_PKG_DEPS)
	foreach (PKFCONF ${PROJECT_PKG_DEPS})
		set(RPM_PKG_DEPS "${RPM_PKG_DEPS}, pkgconfig(${PKFCONF})")
	endforeach()

	# build rpm spec file from template
	configure_file(${RPM_TEMPLATE_DIR}/rpm-config.spec.in ${PROJECT_PKG_BUILD_DIR}/${PROJECT_NAME}.spec)
	configure_file(${RPM_TEMPLATE_DIR}/rpm-config.spec.in ${PROJECT_PKG_ENTRY_POINT}/${PROJECT_NAME}.spec)

	add_custom_command(OUTPUT ${PROJECT_NAME}.spec
		DEPENDS ${PROJECT_TARGETS}
		COMMAND rpmbuild -ba  ${PROJECT_PKG_BUILD_DIR}/${PROJECT_NAME}.spec
	)

	add_custom_target(rpm DEPENDS ${PROJECT_NAME}.spec)
	add_dependencies(rpm populate)
	set(ADDITIONAL_MAKE_CLEAN_FILES, "${PROJECT_NAME}.spec")

	if(PACKAGE_MESSAGE)
	add_custom_command(TARGET rpm
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "++ ${PACKAGE_MESSAGE}")
	endif()
endmacro(rpm_package_build)

macro(project_package_build)
	if(EXISTS ${RPM_TEMPLATE_DIR})
		rpm_package_build()
	endif()

	if(EXISTS ${WGT_TEMPLATE_DIR})
		wgt_package_build()
	endif()

	if(EXISTS ${DEB_TEMPLATE_DIR})
		deb_package_build()
	endif()
endmacro(project_package_build)

macro(project_subdirs_add)
	set (ARGSLIST ${ARGN})
	list(LENGTH ARGSLIST ARGSNUM)
	if(${ARGSNUM} GREATER 0)
		file(GLOB filelist "${ARGV0}")
	else()
	file(GLOB filelist "*")
	endif()

	foreach(filename ${filelist})
		if(EXISTS "${filename}/CMakeLists.txt")
			add_subdirectory(${filename})
		endif(EXISTS "${filename}/CMakeLists.txt")
	endforeach()
endmacro(project_subdirs_add)

set(CMAKE_BUILD_TYPE Debug CACHE STRING "the type of build")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMP0048 1)

# Include project configuration
# ------------------------------
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGES})
set(PROJECT_LIBDIR "${CMAKE_SOURCE_DIR}/libs" CACHE PATH "Subpath to libraries")
set(PROJECT_RESOURCES "${CMAKE_SOURCE_DIR}/data" CACHE PATH "Subpath to data")

set(AFB_TOKEN   ""      CACHE PATH "Default AFB_TOKEN")
set(AFB_REMPORT "1234" CACHE PATH "Default AFB_TOKEN")

INCLUDE(FindPkgConfig)
INCLUDE(CheckIncludeFiles)
INCLUDE(CheckLibraryExists)
INCLUDE(GNUInstallDirs)

# Default compilation options
############################################################################
link_libraries(-Wl,--as-needed -Wl,--gc-sections)
add_compile_options(-Wall -Wextra -Wconversion)
add_compile_options(-Wno-unused-parameter) # frankly not using a parameter does it care?
add_compile_options(-Wno-sign-compare -Wno-sign-conversion)
add_compile_options(-Werror=maybe-uninitialized)
add_compile_options(-Werror=implicit-function-declaration)
add_compile_options(-ffunction-sections -fdata-sections)
add_compile_options(-fPIC)
add_compile_options(-g)

set(CMAKE_C_FLAGS_PROFILING   "-g -O2 -pg -Wp,-U_FORTIFY_SOURCE" CACHE STRING "Flags for profiling")
set(CMAKE_C_FLAGS_DEBUG       "-g -O2 -ggdb -Wp,-U_FORTIFY_SOURCE" CACHE STRING "Flags for debugging")
set(CMAKE_C_FLAGS_RELEASE     "-O2" CACHE STRING "Flags for releasing")
set(CMAKE_C_FLAGS_CCOV        "-g -O2 --coverage" CACHE STRING "Flags for coverage test")

set(CMAKE_CXX_FLAGS_PROFILING    "-g -O0 -pg -Wp,-U_FORTIFY_SOURCE")
set(CMAKE_CXX_FLAGS_DEBUG        "-g -O0 -ggdb -Wp,-U_FORTIFY_SOURCE")
set(CMAKE_CXX_FLAGS_RELEASE      "-g -O2")
set(CMAKE_CXX_FLAGS_CCOV "-g -O2 --coverage")

# Env variable overload default
if(DEFINED ENV{INSTALL_PREFIX})
	set (INSTALL_PREFIX $ENV{INSTALL_PREFIX})
else()
	set(INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/Install" CACHE PATH "The path where to install")
endif()
set(CMAKE_INSTALL_PREFIX ${INSTALL_PREFIX} CACHE STRING "Installation Prefix" FORCE)

# (BUG!!!) as PKG_CONFIG_PATH does not work [should be en env variable]
set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH ON CACHE BOOLEAN "Flag for using prefix path")

# Loop on required package and add options
foreach (PKG_CONFIG ${PKG_REQUIRED_LIST})
	string(REGEX REPLACE "[<>]?=.*$" "" XPREFIX ${PKG_CONFIG})
	PKG_CHECK_MODULES(${XPREFIX} REQUIRED ${PKG_CONFIG})

	INCLUDE_DIRECTORIES(${${XPREFIX}_INCLUDE_DIRS})
	list (APPEND link_libraries ${${XPREFIX}_LIBRARIES})
	add_compile_options (${${XPREFIX}_CFLAGS})
endforeach(PKG_CONFIG)

# Optional LibEfence Malloc debug library
IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
CHECK_LIBRARY_EXISTS(efence malloc "" HAVE_LIBEFENCE)
IF(HAVE_LIBEFENCE)
	MESSAGE(STATUS "Linking with ElectricFence for debugging purposes...")
	SET(libefence_LIBRARIES "-lefence")
	list (APPEND link_libraries ${libefence_LIBRARIES})
ENDIF(HAVE_LIBEFENCE)
ENDIF(CMAKE_BUILD_TYPE MATCHES DEBUG)

# set default include directories
INCLUDE_DIRECTORIES(${EXTRA_INCLUDE_DIRS})

# If no install dir try to guess some smart default
if(BINDINGS_INSTALL_PREFIX)
	set(BINDINGS_INSTALL_DIR ${BINDINGS_INSTALL_PREFIX}/${PROJECT_NAME} CACHE PATH "Where the binding will be installed in your system")
else()
	set(BINDINGS_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME} CACHE PATH "Where the binding will be installed in your system")
endif()

# Define a default package directory
if(PACKAGE_PREFIX)
	set(PROJECT_PKG_BUILD_DIR ${PKG_PREFIX}/package CACHE PATH "Where the package will be built.")
else()
	set(PROJECT_PKG_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/package CACHE PATH "Where the package will be built")
endif()

set (PKG_TEMPLATE_PREFIX ${CMAKE_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR} CACHE PATH "Default Package Templates Directory")
set(SSH_TEMPLATE_DIR "${PKG_TEMPLATE_PREFIX}/ssh" CACHE PATH "Subpath to a directory where are stored needed files to launch on remote target to debuging purposes")
set(GDB_TEMPLATE_DIR "${PKG_TEMPLATE_PREFIX}/gdb" CACHE PATH "Subpath to a directory where are stored needed files to launch debuging server on a remote target. Use gdbserver.")
set(WGT_TEMPLATE_DIR "${PKG_TEMPLATE_PREFIX}/wgt" CACHE PATH "Subpath to a directory where are stored needed files to build widget")
set(RPM_TEMPLATE_DIR "${PKG_TEMPLATE_PREFIX}/rpm" CACHE PATH "Subpath to a directory where are stored needed files to build rpm package")
set(DEB_TEMPLATE_DIR "${PKG_TEMPLATE_PREFIX}/deb" CACHE PATH "Subpath to a directory where are stored needed files to build deb package")

string(REGEX REPLACE "(.*)\/.*$" "\\1" ENTRY_POINT "${PKG_TEMPLATE_PREFIX}")
set(PROJECT_PKG_ENTRY_POINT ${ENTRY_POINT}/packaging CACHE PATH "Where package build files, like rpm.spec file or config.xml, are write.")

# Default Linkflag
if(NOT BINDINGS_LINK_FLAG)
	set(BINDINGS_LINK_FLAG "-Wl,--version-script=${PKG_TEMPLATE_PREFIX}/cmake/export.map")
endif()

# Add a dummy target to enable global dependency order
# -----------------------------------------------------
if(EXTRA_DEPENDENCIES_ORDER)
	set(DEPENDENCIES_TARGET ${PROJECT_NAME}_extra_dependencies)
	add_custom_target(${DEPENDENCIES_TARGET} ALL
		DEPENDS ${EXTRA_DEPENDENCY_ORDER}
	)
endif()

# Print developer helper message when build is done
# -------------------------------------------------------
macro(project_closing_msg)
	get_property(PROJECT_TARGETS_SET GLOBAL PROPERTY PROJECT_TARGETS SET)
	get_property(PROJECT_TARGETS GLOBAL PROPERTY PROJECT_TARGETS)
	if(CLOSING_MESSAGE AND ${PROJECT_TARGETS_SET})
		add_custom_target(${PROJECT_NAME}_build_done ALL
			COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "++ ${CLOSING_MESSAGE}"
		)
		 add_dependencies(${PROJECT_NAME}_build_done
		 	${DEPENDENCIES_TARGET} ${PROJECT_TARGETS})
	endif()
endmacro()

# Add RSYSTARGET
remote_targets_populate()
