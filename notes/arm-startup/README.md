# ARM 汇编：读懂 STM32 启动文件

[← 返回笔记索引](../README.md)

STM32 工程里那个 `startup_stm32f427xx.s`（几百行）不是普通的汇编教学代码，而是**启动汇编**：芯片上电后最先执行的一段，负责建栈、搬数据、清 .bss、跳进 `main`。

它用的语法是：

| 项 | 值 |
|---|---|
| CPU | ARM Cortex-M4（STM32F427） |
| 指令集 | Thumb / Thumb-2 |
| 汇编器 | GNU Assembler（GNU AS，工具链 `arm-none-eabi-`） |
| 汇编语法 | GNU AS 语法（AT&T 风格派系，但 ARM 用统一语法） |

## 1. 先分清两类东西

文件里绝大多数"看不懂的行"其实不是 CPU 指令：

| 类型 | 示例 | 谁处理 | 作用 |
|---|---|---|---|
| 汇编器指示（directive） | `.syntax unified`、`.section`、`.word` | 汇编器 | 告诉汇编器怎么生成目标文件 |
| CPU 指令 | `ldr`、`bl`、`movs`、`b` | CPU | 真正执行的机器码 |
| 标签（label） | `Reset_Handler:` | 汇编器 | 标记地址，供跳转/取址 |
| 注释 | `/* ... */`、`@ ...` | 汇编器 | 不生成任何东西 |

判断口诀：**以 `.` 开头的基本都是汇编器指示**；`ldr/str/mov/add/cmp/b/bl/bx` 这些才是指令。

## 2. 寄存器与调用约定

| 寄存器 | 别名 | 用途 |
|---|---|---|
| R0–R3 | a1–a4 | 传参、返回值、临时用（调用后可能被改） |
| R4–R11 | v1–v8 | 被调用者保存（函数里用了要自己 push/pop 还原） |
| R12 | IP | 临时用 |
| R13 | SP | 栈指针（Cortex-M 复位时由向量表第一项加载） |
| R14 | LR | 链接寄存器，`bl` 会把返回地址放这里 |
| R15 | PC | 程序计数器 |

启动文件里最常见的就是 `r0-r4` + `sp`；`r4` 被拿来当临时变量，因为它在函数调用之间不会被破坏。

> 栈是**满递减**（full descending）：`push` 先减 SP 再存，`pop` 先取再增 SP。

## 3. 这个文件里会用到的指令

| 指令 | 含义 | 备注 |
|---|---|---|
| `ldr rX, [rY, rZ]` | 从内存加载 32 位 | 读 RAM/Flash |
| `str rX, [rY, rZ]` | 存 32 位到内存 | 写 RAM |
| `movs rX, #imm` | 传送立即数并更新标志 | `s` = 同时更新 APSR 条件标志 |
| `adds rX, rY, #imm` | 加法 | 同上 |
| `cmp rX, rY` | 比较（做减法，只更新标志） | 后面通常跟条件跳转 |
| `b label` | 无条件跳转 | |
| `bcc label` | 进位标志为 0 时跳 | 无符号比较里表示"小于" |
| `bl func` | 带链接的跳转（调用函数） | 返回地址存 LR |
| `bx lr` | 跳转到 LR 里的地址 | 函数返回 |
| `push {r4, lr}` / `pop {r4, pc}` | 保存/恢复寄存器 | 函数序言/尾声 |

`bcc` 的名字来自"Carry Clear"：`cmp a, b` 后 C=0 表示 a < b（无符号）。同类还有 `bcs`（≥）、`bhi`（>）、`bls`（≤）。

`movs` 和 `mov` 的区别：带 `s` 会更新条件标志，`cmp`/`bcc` 依赖这些标志。启动文件里清零用 `movs r3, #0` 而不是 `mov`。

## 4. `ldr r0, =_sdata` 是怎么回事

`ldr r0, =符号` 是**伪指令**，不是真的把 32 位立即数塞进指令（Thumb 的 `ldr` 立即数范围有限）。汇编器会做两件事：

1. 在附近的**文字池（literal pool）**里放一个 32 位常量（地址值）；
2. 把这条伪指令换成 `ldr r0, [pc, #偏移]`，从文字池里读。

所以 `=` 后面可以跟任意表达式：`ldr r0, =0x0800F000`、`ldr r0, =_estack`、`ldr r0, =SystemInit`。

想验证可以直接反汇编：`arm-none-eabi-objdump -d 文件.o`，会看到 `ldr r0, [pc, #x]` 后面跟着一段 `.word` 数据。

## 5. 向量表：为什么第一项是栈顶

Cortex-M 上电/复位时，硬件自动做两件事：

- 从 **0x0000_0000**（多数 STM32 上被映射到 Flash 起始 0x0800_0000）读第一个字 → 装进 **MSP**（主栈指针）；
- 从 **0x0000_0004** 读第二个字 → 装进 **PC**，从这里开始执行（就是 `Reset_Handler`）。

所以启动文件开头通常长这样：

```asm
.section .isr_vector, "a", %progbits
.global g_pfnVectors
g_pfnVectors:
    .word _estack
    .word Reset_Handler
    .word NMI_Handler
    .word HardFault_Handler
    ...
```

- `.word` 就是"在这里放一个 32 位数据"，放的是函数**地址**；
- `_estack`、`_sdata` 这些名字由**链接脚本**定义（`STM32F427VITx_FLASH.ld` 里），汇编文件和链接脚本必须对得上；
- 中断函数用 `.weak` 声明，用户没实现时链接到 `Default_Handler`（死循环），这是常见写法：

```asm
.weak NMI_Handler
.thumb_set NMI_Handler, Default_Handler
```

## 6. Reset_Handler 逐行

```asm
Reset_Handler:
    ldr   sp, =_estack          /* 建栈：SP 指向 RAM 顶端 */
    bl    SystemInit            /* 时钟、FPU 等系统初始化（C 函数） */

    ldr   r0, =_sdata           /* RAM 中 .data 起始 */
    ldr   r1, =_edata           /* RAM 中 .data 结束 */
    ldr   r2, =_sidata          /* Flash 中 .data 初值镜像 */
    movs  r3, #0                /* 偏移量 = 0 */
    b     LoopCopyDataInit

CopyDataInit:
    ldr   r4, [r2, r3]          /* 从 Flash 读一个 word */
    str   r4, [r0, r3]          /* 写到 RAM 对应位置 */
    adds  r3, r3, #4            /* 偏移 += 4 */

LoopCopyDataInit:
    adds  r4, r0, r3            /* r4 = 当前写到的地址 */
    cmp   r4, r1                /* 到 _edata 了吗 */
    bcc   CopyDataInit          /* 没到就继续（无符号小于） */

    ldr   r2, =_sbss            /* .bss 起始 */
    ldr   r4, =_ebss            /* .bss 结束 */
    movs  r3, #0                /* 清零用的 0 */
    b     LoopFillZerobss

FillZerobss:
    str   r3, [r2]              /* 写 0 */
    adds  r2, r2, #4

LoopFillZerobss:
    cmp   r2, r4
    bcc   FillZerobss

    bl    __libc_init_array     /* 跑 C++ 全局构造等 */
    bl    main                  /* 进 main */
    bx    lr                    /* main 若返回，退回这里 */
```

对应 C 逻辑：

```c
/* .data：把 Flash 里的初值拷到 RAM */
for (uint32_t *src = _sidata, *dst = _sdata; dst < _edata; )
    *dst++ = *src++;

/* .bss：清零 */
for (uint32_t *p = _sbss; p < _ebss; )
    *p++ = 0;
```

## 7. 为什么必须搬 .data、清 .bss

以 `int count = 100;` 为例：

- **存储**：初值 100 存在 Flash（掉电不丢），运行时的变量本体在 RAM；
- **运行**：CPU 读写的是 RAM 地址，所以启动时必须把 Flash 里的初值复制到 RAM 的 `.data` 段；
- `.bss` 段（`int count;`、`static int value;` 这类未初始化的全局/静态变量）**不占 Flash 空间**，只占 RAM，启动时清零即可。

链接脚本里对应两组符号：

| 符号 | 含义 |
|---|---|
| `_sdata` / `_edata` | RAM 中 .data 段的起止 |
| `_sidata` | Flash 中 .data 初值的起始（LMA） |
| `_sbss` / `_ebss` | RAM 中 .bss 段的起止 |
| `_estack` | 栈顶（RAM 末尾） |

> 搬运用 `ldr`/`str` 按 4 字节走，所以链接脚本里 .data 的大小通常是 4 字节对齐的（`. = ALIGN(4);`），否则末几个字节会漏拷。

## 8. `__libc_init_array` 与 `main`

- `__libc_init_array` 由 newlib 提供：调用 `.init_array` 里注册的函数，C++ 的全局对象构造、`__attribute__((constructor))` 都靠它；
- `bl main` 之后，LR 里存的是"Reset_Handler 里 `bl main` 的下一条指令"的地址——也就是 **`bx lr` 那条**；
- `bx lr` 会把控制权交回启动文件内部，而不是"返回用户代码的调用者"。按 ST 模板，`main` 返回后基本就是跑飞/进 `Default_Handler`。

所以嵌入式里 `main` 一般写成 `while (1) { ... }` 永不返回；真返回了要自己兜底（比如 `for(;;);`）。

## 9. 建议的学习顺序

不要一上来硬啃完整 500+ 行文件，按这个顺序：

1. **寄存器**：R0–R15、SP、LR、PC，搞清楚谁是"临时"、谁是"要保存"的；
2. **基础指令**：`mov/movs`、`ldr`、`str`、`add/adds`、`cmp`、`b`、`bcc`、`bl`、`bx`；
3. **GNU AS 伪指令**：`.syntax`、`.cpu`、`.thumb`、`.section`、`.global`、`.weak`、`.word`、`.align`、`.equ`；
4. **启动流程**：向量表 → Reset_Handler → SystemInit → 搬 .data → 清 .bss → `__libc_init_array` → `main`；
5. **链接脚本**：`.isr_vector`、`.text`、`.data`、`.bss` 的 VMA/LMA，以及 `_sdata` 这些符号怎么来的。

先吃透 `ldr` / `str` 和寄存器，其余都是这两个的组合。

## 10. 常见坑

| 现象 | 原因 |
|---|---|
| 程序一上电就进 HardFault | 向量表第一项不是合法栈顶，或 `_estack` 超出 RAM 范围 |
| 全局变量初值不对（比如 `int x = 5;` 读到 0 或乱码） | `.data` 没搬，或 `_sidata` / `_sdata` 在链接脚本里对不上 |
| 未初始化变量居然是脏值 | `.bss` 没清，或 `_sbss/_ebss` 符号写错 |
| 用了 bootloader，跳转后中断不响应 | 需要设置 `SCB->VTOR = 0x0800_0000 + 偏移`（启动文件里通常有 `SystemInit` 或手动写） |
| C++ 全局对象没构造 | 没调 `__libc_init_array`，或用 `-nostartfiles` 把启动段去掉了 |
| 栈一用就崩 | `_estack` / `_Min_Stack_Size` 设置太小，或 startup 里的栈大小和链接脚本不一致 |
| 反汇编看不懂 `[pc, #x]` | 那是 `ldr r0, =xxx` 伪指令展开后的文字池读取，正常 |

## 11. 动手练习（不用板子也能做）

1. 装好 [Arm GNU Toolchain](../../app/README.md)，随便写个 `.s`，用 `arm-none-eabi-as` 汇编、`arm-none-eabi-objdump -d` 反汇编，确认 `ldr r0, =xxx` 变成了文字池读取；
2. 把 `startup_stm32f427xx.s` 里的 `Reset_Handler` 抄一遍，删掉 `.bss` 清零那段，观察未初始化变量变成脏值（需要能仿真或上板）；
3. 对照 `STM32F427VITx_FLASH.ld`，把 `_sdata`、`_edata`、`_sidata`、`_sbss`、`_ebss` 的位置在 map 文件里找出来；
4. 读完再看 `SystemInit`（C 代码，配时钟），启动链路就完整了。
