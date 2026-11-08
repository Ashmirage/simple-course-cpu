# 双人共用：12 条单周期 CPU

Vivado 2019.2，EGO1，xc7a35tcsg324-1。A：add.w/sub.w/addi.w/and/or/xor；B：lu12i.w/ld.w/st.w/beq/bne/b。统一 decoder 和 cpu_core。

直接打开 project/cpu_stage1.xpr。硬件顶层 ego1_top，支持 12 条。如提示时钟 IP 需要生成，右键 clk_wiz_0 → Generate Output Products。

仿真顶层 tb_cpu_twelve，运行 Behavioral Simulation，预期 `TWELVE INSTRUCTION TEST PASS: 2026, 7887, 8704`。顶层 tb_cpu_twelve_injected 可验证加法被故意换成减法时报告第 3 项失败。

综合、实现，确认时序通过后生成 bitstream，下载 project/cpu_stage1.runs/impl_1/ego1_top.bit。板载 100 MHz，经 MMCM 转为 CPU 25 MHz。执行使能每 2^20 周期推进一次，自测约 4 秒。

程序构造真实整数 2026（年份）、7887（B 学号）、8704（A 学号），检查存取；对 2026、7887 加减、与或异或结果存储读回并校验，另验证 8704+2026=10730。包含条件分支两种结果、反向循环、无条件跳转。ROM 源码逐行附指令。

- K3/LED0：全部程序检查通过。
- H6/LED6：程序结果错误，LED1～5 显示失败编号的低到高五位。
- K1/LED7：CPU 故障。
- R11/PB0：复位，松开后约 4 秒重新完成。

MMIO 状态 0x1FFF0008：0 运行，1 通过，0x80000000|编号 失败。LED 数据 0x1FFF0000。数据 RAM 0x10000000～0x100003FF，先写后读。

包含 2026、7887、8704 的共同工程已通过功能仿真，使用者重新生成下载文件后确认实板只有 K3 亮。此前 2026、7887 版本的 25 MHz 实现时序 WNS=16.226 ns，并验证过复位重跑；该数值不作为新增数据后的时序记录。尚未实现流水线、乘除法。

rtl/ 硬件，sim/ 仿真，constraints/ 约束，ip/ 时钟配置，project/ GUI 入口。旧 A 练习保留，但当前 GUI 工程不再引用其顶层。不得重复添加同名公共模块。
