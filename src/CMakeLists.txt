find_package(verilator REQUIRED HINTS $ENV{VERILATOR_ROOT})

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
