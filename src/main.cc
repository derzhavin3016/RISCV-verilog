#include <CLI/App.hpp>
#include <CLI/Validators.hpp>
#include <algorithm>
#include <array>
#include <filesystem>
#include <memory>
#include <vector>

#include <CLI/CLI.hpp>
#include <elfio/elfio.hpp>

#include <verilated_vcd_c.h>

#include "Vtop.h"
#include "Vtop_imem.h"
#include "Vtop_top.h"

using Addr = std::uint32_t;
using Word = std::uint32_t;

class ELFLoader final
{
private:
  ELFIO::elfio elfFile_{};

public:
  ELFLoader(const std::filesystem::path &file)
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
    std::vector<IndexT> res{};
    for (auto &&segment : elfFile_.segments)
      if (ELFIO::PT_LOAD == segment->get_type())
        res.push_back(segment->get_index());
    return res;
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

int main(int argc, char *argv[])
{
  constexpr vluint64_t END_TIME = 300;

  // Parse cmd args
  CLI::App app{"Verilator based riscv simulator"};
  std::filesystem::path elf_path{};
  app.add_option("elf_file", elf_path, "Path to elf file")
    ->required()
    ->check(CLI::ExistingFile);

  CLI11_PARSE(app, argc, argv);

  Verilated::commandArgs(argc, argv);

  auto top = std::make_unique<Vtop>();

  int clock = 0;
  for (vluint64_t vtime = 1; !Verilated::gotFinish() && vtime <= END_TIME;
       ++vtime)
  {
    if (vtime % 8 == 0)
      clock ^= 1;
    top->clk = clock;
    top->eval();
  }

  top->final();
}
