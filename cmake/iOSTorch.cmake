cmake_minimum_required( VERSION 2.6.3 )

MESSAGE(STATUS " ===== Configuration iOS troch build =======")

if( CMAKE_VERSION VERSION_LESS 2.8.5 )
  MESSAGE(STATUS "VERSION_LESS 2.8.5 SET ARG1")
  set( CMAKE_ASM_COMPILER_ARG1 "-c" )
endif()

set( CMAKE_ASM_COMPILER_ARG1 "--sdk iphoneos clang -arch $ENV{IOS_ARCH} -fPIC" )

# force ASM compiler (required for CMake < 2.8.5)
set( CMAKE_ASM_COMPILER_ID_RUN TRUE )
set( CMAKE_ASM_COMPILER_ID GNU )
set( CMAKE_ASM_COMPILER_WORKS TRUE )
set( CMAKE_ASM_COMPILER_FORCED TRUE )
set( CMAKE_COMPILER_IS_GNUASM 1)
set( CMAKE_ASM_SOURCE_FILE_EXTENSIONS s S asm )

foreach( lang C CXX ASM )
 MESSAGE(STATUS ">>>>>>>>>>> CLANG:${lang}")
endforeach()

SET( IOS_BUILD TRUE)