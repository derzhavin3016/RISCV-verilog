#include <algorithm>
#include <array>
#include <memory>
#include <verilated_vcd_c.h>

#include "Vtop.h"
#include "Vtop_imem.h"
#include "Vtop_top.h"

int main(int argc, char *argv[])
{
  constexpr vluint64_t END_TIME = 300;

  Verilated::commandArgs(argc, argv);

  auto top = std::make_unique<Vtop>();

  Verilated::traceEverOn(true);

  auto vcd = std::make_unique<VerilatedVcdC>();
  top->trace(vcd.get(), 99);
  vcd->open("out.vcd");

  auto imem = std::to_array<std::uint32_t>({
    0x20020005,
    0x2003000c,
    0x2067fff7,
    0x00e22025,
    0x00642824,
    0x00a42820,
    0x10a7000a,
    0x0064202a,
    0x10800001,
    0x20050000,
    0x00e2202a,
    0x00853820,
    0x00e23822,
    0xac670044,
    0x8c020050,
    0x08000011,
    0x20020001,
    0xac020054,
  });

  std::copy(imem.begin(), imem.end(), top->top->imem->RAM.data());

  int clock = 0;
  for (vluint64_t vtime = 1; !Verilated::gotFinish() && vtime <= END_TIME; ++vtime)
  {
    if (vtime % 8 == 0)
      clock ^= 1;
    top->clk = clock;
    top->eval();
    vcd->dump(vtime);
  }

  top->final();
  vcd->close();
}
