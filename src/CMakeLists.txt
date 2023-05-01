find_package(verilator REQUIRED HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})

if(NOT verilator_FOUND)
  message(
    FATAL_ERROR
      "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable"
  )
endif()

add_executable(sim main.cc)
target_compile_features(sim PRIVATE cxx_std_20)
target_compile_options(sim PRIVATE -Wall -Wextra -Wpedantic)

verilate(
  sim
  SOURCES
  top.v
  TRACE
  VERILATOR_ARGS
  -cc
  -Wall
  --exe)

target_link_libraries(sim PRIVATE elfio::elfio)
target_include_directories(sim SYSTEM
                           PRIVATE ${CMAKE_SOURCE_DIR}/thirdparty/ELFIO/)

target_link_libraries(sim PRIVATE CLI11::CLI11)
target_include_directories(sim SYSTEM
                           PRIVATE ${CMAKE_SOURCE_DIR}/thirdparty/CLI11/include)

target_include_directories(
  sim SYSTEM PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/sim.dir/Vtop.dir)

  target_include_directories(
  sim SYSTEM PRIVATE ${VERILATOR_ROOT}/include)
