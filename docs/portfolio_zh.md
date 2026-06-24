# FPGA / RTL 学习作品集说明

## 1. 我的当前定位

我目前是微电子 / 集成电路方向学生，正在使用 Codex 辅助进行 Verilog / RTL 学习与项目开发。

当前重点不是做复杂 SoC 或完整 ASIC 流程，而是围绕基础 RTL 模块开发、Testbench 编写、仿真调试和项目文档整理，建立一套可复现、可审查、适合作品集展示的学习项目。

## 2. 已完成项目总览

| 项目名称 | 路径 | 项目内容 | 验证方式 | 状态 |
|---|---|---|---|---|
| UART TX | `verilog/uart/` | Verilog UART 发送模块 | 自检查 Testbench + Icarus Verilog + `run_sim.ps1` | Completed |
| UART RX | `verilog/uart_rx/` | Verilog UART 接收模块 | 自检查 Testbench + Icarus Verilog + `run_sim.ps1` | Completed |
| UART Loopback | `verilog/uart_loopback/` | UART TX + RX 内部回环系统 | 自检查 Testbench + Icarus Verilog + `run_sim.ps1` | Completed |

## 3. 项目详细说明

### 3.1 UART TX

项目路径：`verilog/uart/`

项目目标：

- 实现一个基础 UART 发送模块。
- 将 8-bit 并行数据转换为 UART 串行帧。
- 建立基础自检查 Testbench 和一键仿真脚本。

实现内容：

- Verilog UART TX RTL。
- 参数化 `CLK_FREQ` 和 `BAUD_RATE`。
- UART 帧格式：start bit、8 data bits、stop bit。
- LSB first 发送。
- `data_valid / busy` 握手机制。
- `baud_cnt` 计数逻辑。

验证内容：

- 检查 UART 帧内容。
- 检查 start bit、data bits、stop bit。
- 检查 busy 行为。
- 检查帧持续时间。
- 检查 busy 期间 `data_valid` 请求会被忽略。
- 使用 timeout 防止仿真卡死。

使用工具：

- Verilog HDL
- Icarus Verilog
- GTKWave
- PowerShell

项目亮点：

- 不只是手写 RTL，还补充了自检查 Testbench。
- Testbench 包含 timeout 保护，避免错误设计导致仿真无限等待。
- 对 UART 帧时序和握手规则做了基础验证。
- 配套 README 和设计文档，便于复盘和展示。

能证明的能力：

- 基础 FSM 设计能力。
- UART TX 协议理解。
- Verilog 顺序逻辑编写能力。
- 自检查 Testbench 编写能力。
- 基础仿真调试和文档整理能力。

### 3.2 UART RX

项目路径：`verilog/uart_rx/`

项目目标：

- 实现一个基础 UART 接收模块。
- 从串行 `rx` 输入中恢复 8-bit 并行数据。
- 验证 start bit 检测、bit 中心采样和 stop bit 检查。

实现内容：

- Verilog UART RX RTL。
- 2 级 `rx` 同步器。
- start bit 检测。
- bit 中心采样。
- 8-bit LSB first 数据接收。
- stop bit 检查。
- `data_valid` 单拍输出。
- `busy` 接收状态指示。

验证内容：

- 正常帧测试：`8'h55`、`8'hA5`、`8'h00`、`8'hFF`。
- busy 行为检查。
- false start 测试。
- invalid stop bit 测试。
- back-to-back frames 连续帧测试。
- `data_valid` 单拍检查。
- timeout 防卡死机制。

使用工具：

- Verilog HDL
- Icarus Verilog
- GTKWave
- PowerShell

项目亮点：

- 覆盖了 UART RX 的关键行为：start bit、data bits、stop bit。
- 增加 false start 和 invalid stop bit 测试，避免只验证理想帧。
- Testbench 覆盖连续帧接收，验证基础接收稳定性。
- 文档中说明了 `CLKS_PER_BIT`、`HALF_CLKS_PER_BIT` 和同步器作用。

能证明的能力：

- UART RX 接收流程理解。
- bit 中心采样时序理解。
- 异步输入同步风险意识。
- 异常帧基础验证能力。
- 逐步增强 Testbench 覆盖项的能力。

### 3.3 UART Loopback

项目路径：`verilog/uart_loopback/`

项目目标：

- 将 UART TX 和 UART RX 集成为一个内部 loopback 小系统。
- 验证 TX 发送的数据可以通过内部串行线被 RX 正确恢复。
- 练习模块集成、顶层连接和系统级 Testbench。

实现内容：

- `uart_loopback` 顶层模块。
- 内部例化 `uart_tx`。
- 内部例化 `uart_rx`。
- 将 `uart_tx.tx` 连接到 `uart_rx.rx`。
- 将内部串行线导出为 `tx_line`，便于 Testbench 和 GTKWave 观察。

验证内容：

- 测试数据：`8'h55`、`8'hA5`、`8'h00`、`8'hFF`、`8'h3C`、`8'hC3`。
- 检查 `rx_data_valid` 是否出现。
- 检查 `rx_data_out` 是否等于发送值。
- 检查 `rx_data_valid` 是否只打一拍。
- 检查 `tx_busy` 和 `rx_busy` 行为。
- 检查 timeout，避免仿真卡死。

使用工具：

- Verilog HDL
- Icarus Verilog
- GTKWave
- PowerShell

项目亮点：

- 从单独 TX / RX 模块推进到小系统集成。
- 顶层逻辑保持简单，只做模块连接，不引入复杂控制。
- Testbench 验证了端到端数据路径：`data_in -> uart_tx -> tx_line -> uart_rx -> rx_data_out`。
- README 和设计文档明确说明这是内部 loopback，不夸大为板级 UART 验证。

能证明的能力：

- RTL 模块集成能力。
- 顶层端口设计和信号命名能力。
- 系统级自检查 Testbench 编写能力。
- 仿真脚本和作品集文档整理能力。

## 4. 技术栈

- Verilog HDL
- Icarus Verilog
- GTKWave
- PowerShell
- Git / GitHub
- Codex-assisted workflow

## 5. 当前可提供的能力

- Verilog 基础 RTL 模块开发。
- FSM 状态机设计。
- UART 协议基础实现。
- Testbench 编写。
- 自检查 Testbench 编写。
- timeout 防卡死机制设计。
- 仿真脚本整理。
- README / 设计文档整理。
- 使用 AI 辅助进行代码审查、迭代和复盘。

## 6. 当前能力边界

当前作品集主要体现基础 RTL 项目和验证练习，不夸大为精通芯片设计。

目前暂不覆盖：

- 高级 ASIC 全流程。
- 复杂 SoC 设计。
- AXI 总线系统。
- CPU 微架构设计。
- 完整综合、STA、DFT、后端实现流程。

当前定位是：通过小型、可运行、可验证的 RTL 项目，逐步建立数字设计和验证基础。

## 7. 作品集总结

这一阶段的项目围绕 UART 协议逐步展开：先实现 UART TX，再实现 UART RX，最后将两者集成为内部 Loopback 小系统。

这些项目的重点不是规模，而是工程习惯：RTL 代码清晰、Testbench 可自检查、仿真可一键复现、文档能说明设计意图和验证范围。

作为早期 RTL 学习作品集，这些项目可以展示我对基础时序逻辑、FSM、UART 协议、仿真验证和项目整理流程的理解。后续可以在此基础上继续扩展到 FIFO、错误检测、板级验证和更完整的接口协议练习。
