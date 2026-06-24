# AI + EDA / Verilog Learning Portfolio

本仓库记录我使用 Codex 辅助完成 Verilog / RTL / FPGA 基础项目的过程。

当前目标是建立一组可复现、可展示、可交付的小型 RTL 项目作品集。项目重点放在基础 RTL 模块设计、Testbench 编写、仿真调试、脚本整理和项目文档沉淀。

## 项目总览

| Project | Path | Description | Verification | Status |
|---|---|---|---|---|
| UART TX | [verilog/uart/](verilog/uart/) | Verilog UART transmitter | Self-checking Testbench + Icarus Verilog + PowerShell script | Completed |
| UART RX | [verilog/uart_rx/](verilog/uart_rx/) | Verilog UART receiver | Self-checking Testbench + Icarus Verilog + PowerShell script | Completed |
| UART Loopback | [verilog/uart_loopback/](verilog/uart_loopback/) | UART TX + RX internal loopback system | Self-checking Testbench + Icarus Verilog + PowerShell script | Completed |

## 已完成项目

### UART TX

[UART TX](verilog/uart/) 是一个基础 Verilog UART 发送模块，用于将 8-bit 并行数据转换为 UART 串行帧。

项目包含：

- UART TX RTL。
- `data_valid / busy` 握手机制。
- start bit、8 data bits、stop bit 发送。
- 自检查 Testbench。
- timeout 防卡死机制。
- Icarus Verilog 仿真脚本。
- README 和设计文档。

### UART RX

[UART RX](verilog/uart_rx/) 是一个基础 Verilog UART 接收模块，用于从串行 `rx` 输入中恢复 8-bit 并行数据。

项目包含：

- UART RX RTL。
- start bit 检测。
- bit 中心采样。
- LSB first 数据接收。
- stop bit 检查。
- 2 级 `rx` 同步器。
- 自检查 Testbench。
- false start、invalid stop bit、back-to-back frames 等基础测试。
- README 和设计文档。

### UART Loopback

[UART Loopback](verilog/uart_loopback/) 是一个内部 TX -> RX 回环系统，将 `uart_tx.tx` 连接到 `uart_rx.rx`，用于验证 UART TX 和 UART RX 的模块集成能力。

项目包含：

- `uart_loopback` 顶层模块。
- UART TX -> UART RX 内部串行连接。
- `tx_line` 顶层输出，便于观察波形。
- 多字节回环自检查 Testbench。
- `tx_busy`、`rx_busy`、`rx_data_valid` 行为检查。
- Icarus Verilog 一键仿真脚本。
- README 和设计文档。

## 已具备能力

- Verilog RTL 基础模块设计。
- FSM 状态机设计。
- UART 协议基础。
- 自检查 Testbench。
- timeout 防卡死机制。
- Icarus Verilog 仿真。
- PowerShell 一键脚本。
- Markdown 项目文档。
- Git / GitHub 版本管理。
- Codex-assisted RTL learning workflow。

## 如何运行仿真

以下命令适用于 Windows PowerShell。

### UART TX

```powershell
cd verilog/uart/sim
powershell -ExecutionPolicy Bypass -File .\run_sim.ps1
```

### UART RX

```powershell
cd verilog/uart_rx/sim
powershell -ExecutionPolicy Bypass -File .\run_sim.ps1
```

### UART Loopback

```powershell
cd verilog/uart_loopback/sim
powershell -ExecutionPolicy Bypass -File .\run_sim.ps1
```

## 作品集与服务文档

- [中文作品集说明](docs/portfolio_zh.md)
- [中文服务菜单](docs/service_menu_zh.md)
- [客户沟通话术模板](docs/client_message_templates.md)
- [潜在客户记录表](docs/customer_leads.md)

## 当前能力边界

- 当前项目聚焦基础 RTL 练习和小型 Verilog 模块。
- 当前作品集可以展示基础 RTL 设计、仿真验证和文档整理能力。
- 不夸大为高级芯片设计能力。
- 复杂 CPU / AXI / SoC 尚未覆盖。
- 尚未覆盖完整 FPGA 上板验证、复杂约束、复杂总线系统或高级 ASIC 流程。

