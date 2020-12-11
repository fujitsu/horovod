#==============================================================================
# Copyright (c) 2020, FUJITSU LIMITED
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the <organization> nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#==============================================================================

if(CMAKE_CXX_COMPILER MATCHES ".*/FCC$")
  if(DEFINED ENV{MPI_HOME})
    set(TCSMPI_EXEC_PATH "$ENV{MPI_HOME}/bin")
  else()
    string(REGEX REPLACE "/FCC$" "" CMAKE_CXX_COMPILER_DIR "${CMAKE_CXX_COMPILER}")
    set(TCSMPI_EXEC_PATH "${CMAKE_CXX_COMPILER_DIR}")
  endif()
  execute_process(COMMAND "${TCSMPI_EXEC_PATH}/mpiFCC" "--show"
    RESULT_VARIABLE MPIFCC_EXEC_RESULT
    OUTPUT_QUIET
    ERROR_QUIET)
  if(MPIFCC_EXEC_RESULT EQUAL 0)
    message(STATUS "TCS-MPI ENABLED")
    set(MPI_CXX_FOUND ON)
    execute_process(COMMAND "${TCSMPI_EXEC_PATH}/mpiFCC" "--showme:compile"
      OUTPUT_VARIABLE MPI_CXX_COMPILE_FLAGS)
    string(REPLACE "\n" "" MPI_CXX_COMPILE_FLAGS "${MPI_CXX_COMPILE_FLAGS}")
    execute_process(COMMAND "${TCSMPI_EXEC_PATH}/mpiFCC" "--showme:incdirs"
      OUTPUT_VARIABLE MPI_CXX_INCLUDE_PATH)
    string(REPLACE "\n" ";" MPI_CXX_INCLUDE_PATH "${MPI_CXX_INCLUDE_PATH}")
    execute_process(COMMAND "${TCSMPI_EXEC_PATH}/mpiFCC" "--showme:link"
      OUTPUT_VARIABLE MPI_CXX_LINK_FLAGS)
    string(REPLACE "\n" "" MPI_CXX_LINK_FLAGS "${MPI_CXX_LINK_FLAGS}")
    execute_process(COMMAND "${TCSMPI_EXEC_PATH}/mpiFCC" "--showme:libdirs"
      OUTPUT_VARIABLE MPI_CXX_LIBRARY_DIRS)
    string(REPLACE "\n" "" MPI_CXX_LIBRARY_DIRS "${MPI_CXX_LIBRARY_DIRS}")
    string(REPLACE " " ";" MPI_CXX_LIBRARY_DIRS "${MPI_CXX_LIBRARY_DIRS}")
    foreach(dir IN LISTS MPI_CXX_LIBRARY_DIRS)
      if(dir MATCHES "FJSVxtclanga" OR dir MATCHES "FJSVstclanga")
        set(MPI_CXX_LIBRARIES "${dir}/libmpi.so")
      endif()
    endforeach()
    set(MPI_FOUND ON)
    set(MPI_C_FOUND ON)
    set(MPIEXEC "${TCSMPI_EXEC_PATH}/mpiexec")
    set(MPI_COMPILE_FLAGS ${MPI_CXX_COMPILE_FLAGS})
    set(MPI_C_COMPILE_FLAGS ${MPI_CXX_COMPILE_FLAGS})
    set(MPI_INCLUDE_PATH ${MPI_CXX_INCLUDE_PATH})
    set(MPI_C_INCLUDE_PATH ${MPI_CXX_INCLUDE_PATH})
    set(MPI_LINK_FLAGS ${MPI_CXX_LINK_FLAGS})
    set(MPI_C_LINK_FLAGS ${MPI_CXX_LINK_FLAGS})
    set(MPI_LIBRARIES ${MPI_CXX_LIBRARIES})
    set(MPI_C_LIBRARIES ${MPI_CXX_LIBRARIES})
  else()
    message(STATUS "TCS-MPI DISABLED")
  endif()
endif()
if(NOT MPI_FOUND)
  set(CMAKE_MODULE_PATH_TMP "${CMAKE_MODULE_PATH}")
  unset(CMAKE_MODULE_PATH)
  find_package(MPI)
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH_TMP}")
  unset(CMAKE_MODULE_PATH_TMP)
endif()
