# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#.rst:
# FindPatch
# ---------
#
# The module defines the following variables:
#
# ``Patch_EXECUTABLE``
#   Path to patch command-line executable.
# ``Patch_FOUND``
#   True if the patch command-line executable was found.
#
# The following :prop_tgt:`IMPORTED` targets are also defined:
#
# ``Patch::patch``
#   The command-line executable.
#
# Example usage:
#
# .. code-block:: cmake
#
#    find_package(Patch)
#    if(Patch_FOUND)
#      message("Patch found: ${Patch_EXECUTABLE}")
#    endif()

set(_doc "Patch command line executable")
set(_patch_path )

if(CMAKE_HOST_WIN32)
  set(_patch_path
    "$ENV{LOCALAPPDATA}/Programs/Git/bin"
    "$ENV{LOCALAPPDATA}/Programs/Git/usr/bin"
    "$ENV{APPDATA}/Programs/Git/bin"
    "$ENV{APPDATA}/Programs/Git/usr/bin"
    )
endif()

if(FreeBSD)
  find_program(Patch_EXECUTABLE
    NAME gpatch
    PATHS ${_patch_path}
    DOC ${_doc}
  )
else()
  # First search the PATH
  find_program(Patch_EXECUTABLE
    NAME patch
    PATHS ${_patch_path}
    DOC ${_doc}
  )
endif()

if(CMAKE_HOST_WIN32)
  # Now look for installations in Git/ directories under typical installation
  # prefixes on Windows.
  find_program(Patch_EXECUTABLE
    NAMES patch
    PATH_SUFFIXES Git/usr/bin Git/bin GnuWin32/bin
    DOC ${_doc}
    )
endif()

if(Patch_EXECUTABLE AND NOT TARGET Patch::patch)
  add_executable(Patch::patch IMPORTED)
  set_property(TARGET Patch::patch PROPERTY IMPORTED_LOCATION ${Patch_EXECUTABLE})

  execute_process(COMMAND ${Patch_EXECUTABLE} --version
                  OUTPUT_VARIABLE patch_version
                  ERROR_QUIET
                  OUTPUT_STRIP_TRAILING_WHITESPACE
                  )
  set(_patch_version_regex ".*patch ([0-9]+\\.[0-9]+\\.[0-9]+)")
  if(patch_version MATCHES "${_patch_version_regex}")
    set(Patch_VERSION ${CMAKE_MATCH_1})
  endif()
endif()

unset(_patch_path)
unset(_doc)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Patch
                                  REQUIRED_VARS Patch_EXECUTABLE
                                  VERSION_VAR Patch_VERSION)
