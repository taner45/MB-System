#
# Locate GMT
#
# This module accepts the following environment variables:
#
# GMT_DIR or GMT_ROOT - Specify the location of GMT
#
# This module defines the following CMake variables:
#
# GMT_FOUND - True if libgmt is found 
# GMT_LIBRARY - A variable pointing to the GMT library 
# GMT_INCLUDE_DIR - Where to find the headers 
# GMT_INCLUDE_DIRS - Where to find the headers 
# GMT_DEFINITIONS - Extra compiler flags

# =============================================================================
# Inspired by FindGDAL
#
# Distributed under the OSI-approved bsd license (the "License")
#
# This software is distributed WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
# COPYING-CMAKE-SCRIPTS for more information.
# =============================================================================

# This makes the presumption that you include gmt.h like
#
# include "gmt.h"

if(UNIX AND NOT GMT_FOUND)
  # Use gmt-config to obtain the libraries
  find_program(
    GMT_CONFIG gmt-config
    HINTS ${GMT_DIR} ${GMT_ROOT} $ENV{GMT_DIR} $ENV{GMT_ROOT}
    PATH_SUFFIXES bin
    PATHS /sw # Fink
          /opt/sw # Fink
          /opt/local # MacPorts
          /opt/local/lib/gmt6 
          /opt/local/lib/gmt5
          /opt/csw # Blastwave
          /opt
          /usr/local)

  if(GMT_CONFIG)
    execute_process(
      COMMAND ${GMT_CONFIG} --cflags
      ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
      OUTPUT_VARIABLE GMT_CONFIG_CFLAGS)
    if(GMT_CONFIG_CFLAGS)
      string(REGEX MATCHALL "(^| )-I[^ ]+" _gmt_dashI ${GMT_CONFIG_CFLAGS})
      string(REGEX REPLACE "(^| )-I" "" _gmt_includepath "${_gmt_dashI}")
      string(REGEX REPLACE "(^| )-I[^ ]+" "" _gmt_cflags_other
                           ${GMT_CONFIG_CFLAGS})
    endif(GMT_CONFIG_CFLAGS)
    execute_process(
      COMMAND ${GMT_CONFIG} --libs
      ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
      OUTPUT_VARIABLE GMT_CONFIG_LIBS)
    if(GMT_CONFIG_LIBS)
      # Ensure -l is precedeced by whitespace to not match '-l' in
      # '-L/usr/lib/x86_64-linux-gnu/hdf5/serial'
      string(REGEX MATCHALL "(^| )-l[^ ]+" _gmt_dashl ${GMT_CONFIG_LIBS})
      string(REGEX REPLACE "(^| )-l" "" _gmt_lib "${_gmt_dashl}")
      string(REGEX MATCHALL "(^| )-L[^ ]+" _gmt_dashL ${GMT_CONFIG_LIBS})
      string(REGEX REPLACE "(^| )-L" "" _gmt_libpath "${_gmt_dashL}")
    endif(GMT_CONFIG_LIBS)
  endif(GMT_CONFIG)
  if(_gmt_lib)
    list(REMOVE_DUPLICATES _gmt_lib)
  endif(_gmt_lib)
endif(UNIX AND NOT GMT_FOUND)

# find all libs that gmt-config reports (which is just libgmt, not libpostscriptlight)
foreach(_extralib ${_gmt_lib})
  find_library(
    _found_lib_${_extralib}
    NAMES ${_extralib}
    PATHS ${_gmt_libpath})
  list(APPEND GMT_LIBRARY ${_found_lib_${_extralib}})
endforeach(_extralib)
list(REMOVE_DUPLICATES GMT_LIBRARY)

find_path(
  GMT_INCLUDE_DIR gmt.h
  HINTS ${_gmt_includepath} ${GMT_DIR} ${GMT_ROOT} $ENV{GMT_DIR} $ENV{GMT_ROOT}
  PATH_SUFFIXES include/gmt include
  PATHS /sw # Fink
        /opt/sw # Fink
        /opt/local # MacPorts
        /opt/local/lib/gmt6 
        /opt/local/lib/gmt5
        /opt/csw # Blastwave
        /opt
        /usr/local)

if (NOT GMT_LIBRARY)
  find_library(
    GMT_LIBRARY
    NAMES gmt 
    HINTS ${_gmt_libpath} ${GMT_DIR} ${GMT_ROOT} $ENV{GMT_DIR} $ENV{GMT_ROOT}
    PATH_SUFFIXES lib
    PATHS /sw # Fink
          /opt/sw # Fink
          /opt/local # MacPorts
          /opt/local/lib/gmt6 
          /opt/local/lib/gmt5
          /opt/csw # Blastwave
          /opt
          /usr/local)
endif (NOT GMT_LIBRARY)

find_library(
  PSL_LIBRARY
  NAMES postscriptlight 
  HINTS ${_gmt_libpath} ${GMT_DIR} ${GMT_ROOT} $ENV{GMT_DIR} $ENV{GMT_ROOT}
  PATH_SUFFIXES lib
  PATHS /sw # Fink
        /opt/sw # Fink
        /opt/local # MacPorts
        /opt/local/lib/gmt6 
        /opt/local/lib/gmt5
        /opt/csw # Blastwave
        /opt
        /usr/local)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GMT DEFAULT_MSG GMT_LIBRARY PSL_LIBRARY GMT_INCLUDE_DIR)

if(GMT_FOUND)
  set(GMT_LIBRARIES ${GMT_LIBRARY})
  set(GMT_INCLUDE_DIRS ${GMT_INCLUDE_DIR})

  if(NOT TARGET GMT::GMT)
    add_library(GMT::GMT UNKNOWN IMPORTED)
    set_target_properties(
      GMT::GMT PROPERTIES IMPORTED_LOCATION "${GMT_LIBRARY}"
                          INTERFACE_INCLUDE_DIRECTORIES "${GMT_INCLUDE_DIR}")
  endif()

  if(NOT TARGET GMT::PSL)
    add_library(GMT::PSL UNKNOWN IMPORTED)
    set_target_properties(
      GMT::PSL PROPERTIES IMPORTED_LOCATION "${PSL_LIBRARY}"
                          INTERFACE_INCLUDE_DIRECTORIES "${GMT_INCLUDE_DIR}")
  endif()
endif()
