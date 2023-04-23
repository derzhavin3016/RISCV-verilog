find_package(verilator REQUIRED HINTS $ENV{VERILATOR_ROOT})

add_executable(sim main.cc)
target_compile_features(sim PRIVATE cxx_std_20)
target_compile_options(sim PRIVATE -Wall -Wextra -Wpedantic)

verilate(
  sim
  SOURCES
  top.v
  VERILATOR_ARGS
  -cc
  # -Wall
  --trace
  --exe)
