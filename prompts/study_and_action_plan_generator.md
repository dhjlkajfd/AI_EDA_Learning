你现在是我的“AI + FPGA/EDA 变现学习规划导师”和“Codex 实操项目教练”。

请你根据我的真实进度，为我生成两份计划单：

1. 第一份：专业知识学习计划单
2. 第二份：详细项目实操步骤计划单

请注意，我现在的真实进度是：

已完成：

* Git / GitHub 初步配置
* 项目仓库创建
* 本地项目目录创建
* 第 11 步：配置 AI 工作流

我目前已经有或准备有以下文件和目录：

* README.md
* PROJECT_CONTEXT.md
* RULES.md
* CODEX_WORKFLOW.md
* prompts/
* verilog/
* python/
* datasets/
* docs/

但我还没有开始：

* 第 12 步：建立第一个真实项目 UART TX
* 还没有创建 verilog/uart/
* 还没有写 uart_tx.v
* 还没有写 tb_uart_tx.v
* 还没有跑通仿真

我的背景：

1. 我的专业是微电子科学与工程。
2. 但我已经遗忘了很多专业知识，请把我当成完全零基础小白。
3. 我希望借助 Codex / AI 编程工具，提高 FPGA、Verilog、EDA 自动化方向的开发效率。
4. 我的短期目标不是系统学完整个微电子专业，而是在 1～2 个月内具备接小单赚钱的能力。
5. 我的目标方向是：

   * Verilog / FPGA 小模块开发
   * Testbench 编写
   * Vivado / Verilog 报错分析
   * Python EDA 自动化脚本
   * Vivado log 解析
   * Timing report 解析
   * GitHub 作品集展示
   * 后续接单变现

请你根据以上情况，生成两份计划单。

==================================================
第一份计划单：专业知识学习计划单
================

请为我生成一份 60 天专业知识学习计划。

要求：

1. 不要按照大学课程顺序安排。
2. 请按照“能不能帮助我短期变现”的优先级安排。
3. 请把我当成完全零基础小白。
4. 每个知识点都要说明：

   * 为什么要学
   * 学到什么程度就够
   * 对应哪个项目
   * 对应哪个变现方向
   * 应该做什么练习
   * 如何判断自己学会了
5. 请给出两个版本：

   * 每天 1～2 小时版本
   * 每天 3～4 小时版本
6. 每周都要有明确学习目标。
7. 每周都要有验收标准。
8. 每个知识点都要尽量和我的 GitHub 项目仓库结合。
9. 请重点围绕我即将开始的第 12 步 UART TX 项目展开。
10. 请不要让我一开始学太难的内容，比如 PCIe、DDR、UVM、复杂 SoC、ASIC 后端等。

第一份计划单至少要覆盖以下知识模块：

一、数字电路基础

* 二进制
* 十六进制
* 位宽
* wire / reg 的硬件含义
* 组合逻辑
* 时序逻辑
* 触发器
* 寄存器
* 计数器
* 状态机 FSM

二、Verilog 基础

* module
* input / output
* wire / reg
* assign
* always @(*)
* always @(posedge clk)
* 阻塞赋值 =
* 非阻塞赋值 <=
* if / case / for
* parameter
* localparam
* 可综合代码与不可综合代码

三、FPGA 开发基础

* FPGA 是什么
* RTL 是什么
* 仿真是什么
* 综合是什么
* Vivado 基础流程
* 时钟 clk
* 复位 rst_n
* XDC 约束文件基本概念
* 常见 Vivado 报错类型

四、Testbench 与仿真

* Testbench 是什么
* 时钟生成
* 复位生成
* 输入激励
* 自检查 Testbench
* $display
* $finish
* $dumpfile
* $dumpvars
* Icarus Verilog
* GTKWave
* 如何看波形

五、常见可变现模块

* UART TX
* UART RX
* 同步 FIFO
* SPI Master
* PWM
* 按键消抖
* 简单状态机控制模块

六、Python + EDA 自动化

* Python 基础
* pathlib
* 文件读取
* 字符串处理
* 正则表达式 re
* CSV / Excel
* pandas
* openpyxl
* Vivado log 解析
* Timing report 解析
* 自动生成 Excel 报告

七、GitHub 作品集建设

* README 怎么写
* 项目目录怎么组织
* 如何展示 RTL
* 如何展示 Testbench
* 如何展示仿真结果
* 如何写项目说明文档
* 如何让潜在客户看懂我的能力

八、接单变现基础

* 如何拆解客户需求
* 如何判断一个单能不能接
* 如何报价
* 如何交付
* 如何避免高风险代写论文 / 代做毕设
* 如何把服务包装成套餐

请按照以下结构输出第一份计划单：

1. 学习总路线图
2. 60 天分阶段学习安排
3. 每周学习目标
4. 每周知识点清单
5. 每周练习任务
6. 每周验收标准
7. 每周对应的项目产出
8. 每周对应的变现能力
9. 每天 1～2 小时版本安排
10. 每天 3～4 小时版本安排
11. 最后给我一个“每日学习记录模板”

==================================================
第二份计划单：详细项目实操步骤计划单
==================

请为我生成一份从当前状态开始的详细实操计划。

我的当前状态是：

* 已完成第 11 步：配置 AI 工作流
* 尚未开始第 12 步：建立第一个真实项目 UART TX

请从第 12 步开始，为我设计后续 60 天实操计划。

第二份计划单的目标不是讲理论，而是告诉我每天具体做什么文件、写什么代码、运行什么命令、提交什么 Git commit。

请按照以下阶段设计：

第 12 步：建立 UART TX 项目目录

目标：

* 创建 verilog/uart/
* 创建 src/
* 创建 tb/
* 创建 docs/
* 创建 sim/
* 创建 README.md
* 创建 uart_tx_design.md

请给出：

* PowerShell 命令
* 文件路径
* 每个文件应该写什么
* Git 提交命令
* 验收标准

第 13 步：生成 UART TX RTL

目标：

* 生成 verilog/uart/src/uart_tx.v
* 使用 Verilog 2001
* 支持 50MHz 时钟
* 支持 115200 波特率
* 支持 data_in[7:0]
* 支持 data_valid
* 输出 tx
* 输出 busy
* 使用状态机 IDLE / START / DATA / STOP

请给出：

* 应该发给 Codex 的 Prompt
* 代码生成后如何保存
* 如何检查代码结构
* 如何让 Codex 审查代码
* Git 提交命令
* 验收标准

第 14 步：生成 UART TX Testbench

目标：

* 生成 verilog/uart/tb/tb_uart_tx.v
* 生成 50MHz 时钟
* 生成 rst_n 复位
* 测试 8'h55、8'hA5、8'h00、8'hFF
* 自动检查 start bit
* 自动检查 data bits
* 自动检查 stop bit
* 输出 PASS / FAIL
* 生成 VCD 波形

请给出：

* 应该发给 Codex 的 Prompt
* Testbench 保存路径
* 如何检查 Testbench 是否合理
* Git 提交命令
* 验收标准

第 15 步：安装并使用仿真工具

目标：

* 安装 Icarus Verilog
* 安装 GTKWave
* 编译 UART TX
* 运行仿真
* 生成 VCD
* 打开波形
* 看懂 tx / busy / state / baud_cnt 波形

请给出：

* Windows 安装建议
* PowerShell 命令
* iverilog 编译命令
* vvp 运行命令
* gtkwave 打开命令
* 常见报错处理方式
* Git 提交命令
* 验收标准

第 16 步：优化 UART 项目 README

目标：

* 让 GitHub 访客能看懂我做了什么
* 写明项目功能
* 写明目录结构
* 写明如何运行仿真
* 写明预期结果
* 添加后续改进计划

请给出：

* README 模板
* 文档结构
* Git 提交命令
* 验收标准

第 17 步：做同步 FIFO 项目

目标：

* 创建 verilog/fifo/
* 写 fifo_sync.v
* 写 tb_fifo_sync.v
* 支持参数化数据宽度
* 支持参数化深度
* 支持 full / empty
* 支持自检查 Testbench

请给出：

* 目录结构
* Codex Prompt
* 文件清单
* 仿真命令
* README 要点
* Git 提交命令
* 验收标准

第 18 步：做 PWM 项目

目标：

* 创建 verilog/pwm/
* 写 pwm.v
* 写 tb_pwm.v
* 支持周期参数
* 支持占空比参数
* 能仿真查看波形

请给出：

* 目录结构
* Codex Prompt
* 文件清单
* 仿真命令
* README 要点
* Git 提交命令
* 验收标准

第 19 步：做 Vivado Log Parser

目标：

* 创建 python/vivado_log_parser/
* 写 log_parser.py
* 输入 vivado.log
* 统计 ERROR
* 统计 WARNING
* 统计 CRITICAL WARNING
* 输出控制台报告
* 后续支持 Excel 输出

请给出：

* Python 文件结构
* Codex Prompt
* 示例 log 文件
* 运行命令
* README 要点
* Git 提交命令
* 验收标准

第 20 步：做 Timing Report Parser

目标：

* 创建 python/timing_report_parser/
* 写 timing_parser.py
* 输入 timing.rpt
* 提取 Worst Slack
* 提取路径数量
* 提取 violation 信息
* 输出 CSV / Excel

请给出：

* Python 文件结构
* Codex Prompt
* 示例 timing.rpt 文件
* 运行命令
* README 要点
* Git 提交命令
* 验收标准

第 21 步：整理 GitHub 作品集首页

目标：

* 优化根目录 README.md
* 展示 UART、FIFO、PWM、Log Parser、Timing Parser
* 写清楚我的能力范围
* 写清楚项目截图或仿真结果
* 让潜在客户看懂我可以提供什么服务

请给出：

* README 首页模板
* 项目展示格式
* 技术能力展示格式
* Git 提交命令
* 验收标准

第 22 步：准备接单服务文案

目标：

* 生成闲鱼 / 知乎 / 小红书 / CSDN / 论坛可用的服务介绍文案
* 包括 FPGA / Verilog 技术支持
* Testbench 编写
* Vivado 报错分析
* Python 自动化脚本开发
* 避免出现“代写论文”“包过毕设”等高风险表述

请给出：

* 服务标题
* 服务简介
* 能接的单
* 不接的单
* 初期报价
* 沟通话术
* 交付流程
* 售后边界
* 风险提醒

第二份计划单请按照以下结构输出：

1. 当前进度确认
2. 后续 60 天实操路线图
3. 第 12 步到第 22 步详细步骤
4. 每一步的目标
5. 每一步的目录结构
6. 每一步需要创建的文件
7. 每一步需要运行的命令
8. 每一步给 Codex 的 Prompt
9. 每一步的 Git 提交命令
10. 每一步的验收标准
11. 每一步和变现之间的关系
12. 最后给我一个“每日实操记录模板”

==================================================
输出风格要求
======

请用中文输出。

请写得非常具体，不要泛泛而谈。

请把我当成完全零基础小白。

请严格区分：

第一份计划单：知识学习部分
第二份计划单：详细实操步骤部分

请不要假设我已经完成 UART TX 项目。

请从“已完成第 11 步，尚未开始第 12 步”的状态开始规划。

请优先考虑 1～2 个月内变现。

请每一个学习内容和每一个实操项目都说明它如何服务于短期变现。

请最后给我一个明确的下一步行动：

“今天应该先做什么？”
