# 成员 A：阶段一算术 CPU 独立工程

本工程从原 led_first 工程复制有效源码整理，旧工程保留作学习备份。目录位于 D:/develop/fpga_learning/cpu_a_stage1。

## 打开与下载

克隆或解压整个仓库后，在 Vivado 2019.2 中直接打开 [工程文件](project/cpu_a_stage1.xpr)。保留仓库目录结构，源码和约束通过相对路径引用。硬件顶层为 ego1_a_top，板卡仿真顶层为 tb_ego1_a_top。器件暂沿用已使用的 xc7a35tcsg324-1。

下载 project/cpu_a_stage1.runs/impl_1/ego1_a_top.bit。连接 EGO1 UART/JTAG 后，在 Hardware Manager 中 Program Device，确认选的是新工程的文件。

## 板上现象

- K3（led[0]）：通过灯，全部算术结果与寄存器读回均通过后常亮。
- M1（led[1]）：失败灯，出错后常亮，直到复位。
- L1（led[2]）：运行中，测试很快完成，可能看不见这个瞬间。
- K6（led[3]）：心跳灯持续闪烁，表明 CPU 时钟仍在运行；不等于测试通过。
- J5、H5、H6、K1（led[4]～led[7]）：失败步骤编号的低到高四位，编号 0～13；只有 M1 亮时才解读。
- 按 PB0 / S0（R11 对应的通用按键），按住时复位；松开后重新自测。不是 PROG 按键。

JTAG 配置断电丢失；此工程未做 SPI Flash 固化。

## 自测内容与限制

ROM 首先运行七条程序指令：两条 addi.w 准备 12 和 5，然后 add.w、sub.w、and、or、xor。接着七条 add.w r0,rX,r0 把 r1～r7 的保存值送到 ALU 再核对；向 r0 写结果被忽略。这能检查真正写回的值，不只是 ALU 瞬时输出。

监测器核对每一步的 PC、译码有效信号与结果，全部正确才锁存通过灯，并暂停 CPU。故意破坏 ROM 或运算后应显示失败。

这是 A 的六类指令的独立板上验证，不包含 B 的访存、分支，不是完整课程阶段一验收，也不是穷尽边界测试。最终需与队友合并，并使用共同约定的 MMIO 自测状态；当前灯由外部硬件监测器驱动，没有假装已实现 st.w。

## 新工程目录

- rtl/：实际硬件源码与公共头文件。
- sim/：测试平台，不综合进板卡。
- constraints/：引脚、100 MHz 输入和 10 MHz CPU 时钟约束。
- scripts/：创建、仿真和构建脚本。
- project/：Vivado 工程及生成内容。

FPGA 内部将 100 MHz 输入除以 10，并经 BUFG 全局时钟缓冲产生 10 MHz CPU 时钟；配置初始状态和上电复位逻辑使设计无需依赖仿真 initial 测试激励运行。PB0 按键信号经过两级同步后复位 CPU。具体时序检查见 timing_summary.rpt。

## 文件取舍

保留的核心模块：alu32、regfile、decoder_add、execute_add、pc_reg、program_rom_demo、cpu_arith_demo，共 7 个；cpu_defs.vh 共享常量。

新增 arith_selftest（自动核对）、ego1_a_top（板卡适配与时钟复位）。文件名已统一，模块名字保持原样，以免破坏学习过程和测试层级引用。旧 programm_rom_demo.v 文件名的多余 m 已纠正。

不带入新工程：led_on.v、reg_alu.v、tb_adder.v、tb_reg_alu.v，以及旧的点灯 XDC。它们只服务早期练习，与当前算术 CPU 无依赖。可以在确认备份后从旧工程 Remove File；不需要立即从磁盘永久删除。

保留的单元测试：tb_alu_32、tb_regfile、tb_decoder_add、tb_execute_add、tb_cpu_arith_demo。它们用于回归，不因学完而失去价值；仿真时只选择需要的一个作为仿真顶层。tb_decoder_add 原来只测两种加法，后续应补齐六类译码测试。

不应把旧工程 .Xil、缓存和生成目录复制为新源码。新工程只引用当前目录下 rtl/sim/constraints 文件，后续在新目录继续开发，不要两边同时改。

## 接下来学习

先下载核对 K3 常亮、M1 熄灭、K6 闪烁；PB0 松开后恢复通过。然后逐行学习 arith_selftest 如何检查 PC 和读回值，并补充立即数边界、同源同目标、r0 和高位逻辑运算测试。CPU 核心接口随后再迁移到双方共同 decoder/cpu_core 规范。

## 本次验证记录（2026-11-03）

- Vivado 2019.2 完成综合、布局布线和 bitstream 生成，未出现错误或严重警告。
- 内部时序约束满足：整体 WNS=8.582 ns、WHS=0.108 ns；CPU 时钟为 10 MHz。LED 为观察输出，不作同步外设时序保证。
- 板卡顶层仿真：上电计算与寄存器读回通过；按键复位重跑通过；故意注入不支持指令，失败显示与锁存通过。
- 当前尚未实际下载到实体板，板上结果需要由使用者确认。

## 从仓库重建

在仓库根目录用 Vivado 2019.2 运行 `vivado -mode batch -source scripts/build.tcl`，或在 Vivado Tcl Console 中运行 `source scripts/build.tcl`。脚本会生成 `project/cpu_a_stage1.xpr`，运行板卡仿真并生成下载文件。协作时提交 `rtl/`、`sim/`、`constraints/` 和 `scripts/` 中的修改。
