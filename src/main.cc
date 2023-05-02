#include <algorithm>
#include <concepts>
#include <filesystem>
#include <iterator>
#include <memory>
#include <ranges>

#include <CLI/CLI.hpp>
#include <elfio/elfio.hpp>

#include <verilated_vcd_c.h>

#include "Vtop.h"
#include "Vtop_imem.h"
#include "Vtop_top.h"
#include "Vtop_riscv.h"
#include "Vtop_datapath.h"
#include "Vtop_pcReg.h"


using Addr = std::uint32_t;
using Word = std::uint32_t;

template <typename T>
concept Number = std::integral<T> || std::floating_point<T>;

class ELFLoader final
{
private:
  ELFIO::elfio elfFile_{};

public:
  explicit ELFLoader(const std::filesystem::path &file)
  {
    if (!elfFile_.load(file))
      throw std::runtime_error{"Failed while loading input file: " +
                               file.string()};

    check();
  }

  auto getEntryPoint() const
  {
    return static_cast<Addr>(elfFile_.get_entry());
  }

  using IndexT = unsigned;
  auto getLoadableSegments() const
  {
    auto loadable = [](const auto &seg) {
      return ELFIO::PT_LOAD == seg->get_type();
    };
    auto get_idx = [](const auto &seg) { return seg->get_index(); };

    return elfFile_.segments | std::views::filter(loadable) |
           std::views::transform(get_idx);
  }

  auto getSegmentPtr(IndexT index) const
  {
    const auto *segment = elfFile_.segments[index];

    if (segment == nullptr)
      throw std::runtime_error{"Unknown segment index: " +
                               std::to_string(index)};

    return segment;
  }

private:
  void check() const
  {
    if (auto diagnosis = elfFile_.validate(); !diagnosis.empty())
      throw std::runtime_error{diagnosis};

    if (elfFile_.get_class() != ELFIO::ELFCLASS32)
      throw std::runtime_error{"Wrong elf file class: only elf32 supported"};

    if (elfFile_.get_encoding() != ELFIO::ELFDATA2LSB)
      throw std::runtime_error{
        "Wrong encoding: only 2's complement little endian supported"};

    if (elfFile_.get_type() != ELFIO::ET_EXEC)
      throw std::runtime_error{
        "Wrong file type: only executable files are supported"};

    if (elfFile_.get_machine() != ELFIO::EM_RISCV)
      throw std::runtime_error{"Wrong machine type: only RISC-V supported"};
  }
};

int parseCmd(int argc, char *argv[], std::filesystem::path &elf_path,
             std::filesystem::path &vcd_path, vluint64_t &end_time)
{
  // Parse cmd args
  CLI::App app{"Verilator based riscv simulator"};
  app.add_option("elf_file", elf_path, "Path to elf file")
    ->required()
    ->check(CLI::ExistingFile);

  app.add_option("--vcd-file", vcd_path, "Path to .vcd file to dump")
    ->default_val("out.vcd");

  app.add_option("--end-time", end_time, "Set end time of simulation")
    ->default_val(1000);

  CLI11_PARSE(app, argc, argv);
  return 0;
}

void loadElfToMem(const std::filesystem::path &elf_path, Vtop *top)
{
  ELFLoader loader{elf_path};
  top->top->riscv->dpath->pcreg->pc = loader.getEntryPoint();

  for (auto segmentIdx : loader.getLoadableSegments())
  {
    auto segPtr = loader.getSegmentPtr(segmentIdx);
    auto fileSize = segPtr->get_file_size();

    auto vAddr = segPtr->get_virtual_address();

    auto beg = reinterpret_cast<const std::uint8_t *>(segPtr->get_data());
    auto dst = reinterpret_cast<std::uint8_t *>(top->top->imem->RAM.data());

    std::copy_n(beg, fileSize, dst + vAddr);
  }
}

class VCDTracer final
{
private:
  std::unique_ptr<VerilatedVcdC> vcd{};

public:
  VCDTracer(Vtop *top, const std::filesystem::path &trace_file, int levels = 99)
    : vcd(std::make_unique<decltype(vcd)::element_type>())
  {
    top->trace(vcd.get(), levels);
    vcd->open(trace_file.c_str());
  }
  template <Number NumT>
  void dump(NumT val)
  {
    vcd->dump(val);
  }
};

int main(int argc, char *argv[])
try
{
  vluint64_t end_time = 0;

  std::filesystem::path elf_path{}, vcd_path{};
  if (int res = parseCmd(argc, argv, elf_path, vcd_path, end_time); res)
    return res;

  // Verilator init
  Verilated::commandArgs(argc, argv);
  auto top = std::make_unique<Vtop>();

  // enable vcd dump
  Verilated::traceEverOn(true);
  VCDTracer tracer(top.get(), vcd_path);

  // Loading elf
  loadElfToMem(elf_path, top.get());

  int clock = 0;
  for (vluint64_t vtime = 1; !Verilated::gotFinish() && vtime <= end_time;
       ++vtime)
  {
    if (vtime % 8 == 0)
      clock ^= 1;
    top->clk = clock;
    top->eval();
    tracer.dump(vtime);
  }

  top->final();
}
catch (std::runtime_error &err)
{
  std::cerr << err.what() << std::endl;
  return 1;
}
