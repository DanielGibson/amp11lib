cmake_minimum_required(VERSION 2.8)
project(amp11lib)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffast-math -Wall")

add_definitions(-DFASTBITS)
add_definitions(-DTIME)
add_definitions(-DUNIX)
add_definitions(-DLINUX)
add_definitions(-DOSS)
add_definitions(-DAMP11LIB_EXPORTS)

set(SOURCE_FILES
    binfile/binfarc.cpp
    binfile/binfarc.h
    binfile/binfcon.cpp
    binfile/binfcon.h
    binfile/binfhttp.cpp
    binfile/binfhttp.h
    binfile/binfile.cpp
    binfile/binfile.h
    binfile/binfilef.cpp
    #binfile/binfpllx.cpp
    binfile/binfpllx.h
    binfile/binfplwv.cpp
    binfile/binfplwv.h
    binfile/binfstd.cpp
    binfile/binfstd.h
    binfile/binftcp.cpp
    binfile/binftcp.h
    binfile/ptypes.h
    amp11lib.cpp
    amp11lib.h
    amp1dec.cpp
    amp2dec.cpp
    amp3dec.cpp
    ampdec.cpp
    ampdec.h
    ampsynth.cpp
    mpgsplit.cpp
    mpgsplit.h)

add_library(amp11lib SHARED ${SOURCE_FILES})
