# NextPilot 的 bsps 目录

[← 返回笔记索引](../README.md)

NextPilot（基于 RT-Thread、移植了 PX4 飞控功能的开源飞控）里，`bsps/` 是 **BSP（Board Support Package，板级支持包）** 目录。同一套飞控代码，编译到哪个 `bsps` 子目录，就决定了它跑在什么硬件或仿真环境上。

目录结构（已对照仓库 main 分支核对）：

```text
bsps/
├── README.md
├── ndt/                 # 自研硬件（NextPilot Develop Team）
│   ├── ads-v1/          # 大气数据系统
│   ├── fcs-v1/          # 飞行控制计算机
│   └── ins-v1/          # 组合导航系统
├── px4/                 # 按 PX4 硬件标准适配的第三方飞控板
│   ├── fmu-v5/
│   ├── fmu-v5x/
│   ├── fmu-v6x/
│   └── fmu-v6xrt/
└── sitl/                # 软件在环仿真
    └── qemu/            # 用 QEMU 跑 SITL
```

## 1. BSP 到底管什么

BSP 是"操作系统/飞控框架"和"具体板子"之间的胶水层，一般包括：

| 内容 | 作用 | 对应文件 |
|---|---|---|
| 启动与链接 | 内存布局、向量表、栈大小 | `link.lds`、startup 汇编 |
| 板级配置 | 时钟、外设、驱动开关、模块裁剪 | `rtconfig.h`、Kconfig |
| 编译描述 | 选编译器、编译哪些文件 | `SConstruct`、`SConscript`、`rtconfig.py` |
| 驱动 | 该板上的 IMU、磁罗盘、气压计、PWM、串口 | `drivers/` |
| 应用装配 | 起哪些应用模块、参数与日志 | `applications/` |

所以"换 BSP"这件事，本质是换一套启动、驱动和编译配置，**飞控业务代码不动**。这也是为什么仿真和真机的逻辑完全一致。

## 2. 三个分类的区别

| 目录 | 主要作用 | 要不要真实飞控板 |
|---|---|---|
| `ndt` | NextPilot 自研硬件适配 | 需要 |
| `px4` | 按 PX4 硬件标准（Pixhawk 类）适配 | 需要 |
| `sitl/qemu` | 用 QEMU 跑软件在环仿真 | 不需要 |

### 2.1 `ndt`：自研硬件

三块板子，分别对应飞行器上的三个角色：

| 子目录 | 硬件 | 大致职责 |
|---|---|---|
| `fcs-v1` | 飞行控制计算机 | 跑飞控主逻辑、控制律 |
| `ins-v1` | 组合导航计算机 | 卫星接收机 + 陀螺/加计/磁罗盘/气压计的融合 |
| `ads-v1` | 大气数据系统 | 空速、气压高度这类大气参数 |

### 2.2 `px4`：第三方飞控板

这里的 `px4` 指的是**硬件标准**（PX4/Pixhawk 的板型定义），**不代表跑 PX4 固件**。当前仓库里有四个板型：

| 子目录 | 说明 |
|---|---|
| `fmu-v5` | 经典 Pixhawk FMUv5，如 CUAV V5+，主控 STM32F765 + IO 协处理器 STM32F100 |
| `fmu-v5x` | FMUv5X 标准（更高主频、更强传感器配置） |
| `fmu-v6x` | FMUv6X 标准 |
| `fmu-v6xrt` | FMUv6X RT 变体（带 RT-Thread 相关适配） |

> 网上不少 NextPilot 笔记只列了 `fmu-v5`，那是早期版本；现在仓库里已经有 4 个板型了。

### 2.3 `sitl` 与 `sitl/qemu`

- `sitl` 是**分类**（Software In The Loop，软件在环）——不接真硬件，在电脑上跑飞控程序，喂模拟的传感器数据；
- `qemu` 是 sitl 目前的**具体平台**：用 QEMU 模拟 ARM 开发板。

所以严格说不是四个并列的东西，而是 `sitl` 下面挂 `qemu`。将来也可能出现别的仿真后端。

## 3. QEMU 仿真这条链路

`bsps/sitl/qemu` 基于 RT-Thread 的 **qemu-vexpress-a9** BSP，QEMU 模拟的是 **ARM VExpress-A9**（可配单核/多核 A9、A15，并模拟大部分板载外设）。

跑起来的过程：

```text
NextPilot 源码
   │  SCons + ARM GCC（通过 RT-Thread env 环境）
   ▼
rtthread.elf / rtthread.bin
   │  交给 QEMU 执行
   ▼
QEMU 模拟 VExpress-A9（CPU + 外设）
   │  内部启动 SIH 模块
   ▼
SIH 模拟飞行器动力学 + IMU/GPS/MAG/BARO 等传感器数据
   │  MAVLink over UDP（输出 14550，输入 14551）
   ▼
地面站（QGC 等）连接 14550，即可像真机一样操作
```

两个容易混的点：

- **QEMU 只负责"CPU + 板子"**，不负责飞行物理；
- **SIH 负责飞行器动力学和传感器模拟**，它跑在 QEMU 里的固件中。

编译时会根据条件编译自动做几件事：不编译真实外设驱动；MAVLink 改成 UDP；默认启用编号 **1102** 的仿真机架并启动 SIH、模拟 IMU/GPS/MAG/BARO。

## 4. 仿真怎么跑

```powershell
cd bsps\sitl\qemu
scons -j10          # 需要 RT-Thread env 环境 + ARM GCC
.\qemu.bat           # Windows 普通模式
# 或 qemu-dbg.bat（调试）、qemu-nographic.bat（无图形界面）
```

提供的脚本：

| 脚本 | 平台 | 用途 |
|---|---|---|
| `qemu.bat` / `qemu.sh` | Win / Linux | 普通启动 |
| `qemu-dbg.bat` / `qemu-dbg.sh` | Win / Linux | 调试模式（配合 gdb） |
| `qemu-nographic.bat` / `qemu-nographic.sh` | Win / Linux | 无图形界面 |

退出方式：`msh` 提示符下按 `Ctrl + C`，再按 `y` 确认。

> 官方 README 里写的是旧路径 `sitl/qemu-vexpress-a9`，现在目录已经简化为 `sitl/qemu`，命令不变。

## 5. 为什么建议先从 `sitl/qemu` 入手

1. **不用等板子**：没有 STM32F765、没有传感器，也能把整条链路跑通；
2. **不用担心硬件坑**：跳过驱动初始化、外设匹配、烧录这些硬件问题，先专注软件结构；
3. **代码是同一套**：飞控业务逻辑和真机完全一致，学会了直接迁移；
4. **调试方便**：QEMU + gdb 单步，比上板调试舒服。

## 6. 阅读顺序（配合本仓库其它笔记）

1. `SConstruct` / `SConscript`：BSP 怎么组织、怎么选编译器 → [SCons 笔记](../scons/README.md)
2. `rtconfig.h` / `Kconfig`：哪些模块编进来、哪些裁掉
3. `link.lds`：`.text`/`.data`/`.bss` 布局，和启动汇编配合 → [ARM 启动汇编笔记](../arm-startup/README.md)
4. `applications/`：飞控应用模块在哪注册、启动顺序
5. `drivers/`：仿真模式下这些驱动被条件编译裁掉了，对照真机 BSP 看差异最能理解 BSP 的作用
6. MAVLink UDP 配置：14550/14551 端口怎么接地面站

## 7. 常见问题

| 现象 | 原因 / 解决 |
|---|---|
| `scons` 找不到或编译报工具链错误 | 需要 RT-Thread env 环境（自带 ARM GCC 与 scons），普通 cmd 不行 |
| 双击 `qemu.bat` 一闪而过 | `qemu-system-arm.exe` 不在 PATH，或没在 `env` 里执行 |
| QEMU 起来了但地面站连不上 | 端口没对上：地面站看 14550；检查防火墙 |
| 想在没有编译环境的机器上跑 | 装 QEMU 并加 PATH，把 `rtthread.elf` 和 `qemu*.bat` 拷过去即可 |
| 找不到 `rtthread.elf` | 编译失败没生成，看 `scons` 输出的第一个 error |
| 多机仿真跑不起来 | 官方 README 标注当前暂不支持多机 |

## 8. Kconfig 工具链：kconfiglib / menuconfig / curses / windows-curses

`rtconfig.h` 不是手写的，是 `menuconfig` 根据各目录的 `Kconfig` 生成出来的。这一串工具的分工：

| 名称 | 作用 | 在 NextPilot / RT-Thread 里对应什么 |
|---|---|---|
| `Kconfig` | 配置项的**声明**：菜单结构、默认值、依赖关系 | 每个 BSP 目录下的 `Kconfig`，如 `bsps/sitl/qemu/Kconfig` |
| `kconfiglib` | 用 Python 实现的 Kconfig **解析库**：读 Kconfig、合并 `.config`、导出头文件 | `menuconfig` 命令的底层引擎 |
| `menuconfig` | 基于 kconfiglib 的**交互式配置界面**：上下键选、回车进子菜单、空格勾选 | `env` 里敲 `menuconfig` 或 `scons --menuconfig` 打开的那个界面 |
| `curses` | 终端界面**底层库**：控制光标、画窗口、读按键。Python 标准库自带，但**只在类 Unix 上有** | 界面能"动"起来的原因 |
| `windows-curses` | 把 `curses` 补到 Windows 上的第三方包 | 让 menuconfig 在 Windows 的 Python 下能画界面 |
| `pip` | Python 包管理器 | 装 `windows-curses` / `kconfiglib` 用的 |

一句话串起来：

```text
menuconfig（界面）──调用──▶ kconfiglib（解析 Kconfig）──读取──▶ Kconfig
        │                              │
        └── curses（画界面）            └── 产出 ──▶ .config + rtconfig.h
                    ▲
        Windows 下靠 windows-curses 补齐
```

### 什么时候需要装 windows-curses

- 用 **RT-Thread env 工具**（官方自带 Python、scons、menuconfig）：一般**不用手动装**，env 里已经处理好了；
- 用**自己装的 Python** 跑 `kconfiglib` 的 `menuconfig.py`：Windows 上会报

```text
ModuleNotFoundError: No module named '_curses'
```

或

```text
ImportError: No module named 'curses'
```

解决：

```powershell
pip install windows-curses
python -c "import curses; print('ok')"   # 验证
```

> 装的时候注意**装到哪个 Python**：如果 menuconfig 用的解释器是 env 自带的，就要在那个 Python 里 `pip install`，否则会出现"明明装了还是报找不到"。国内网络慢可以加 `-i https://pypi.tuna.tsinghua.edu.cn/simple`。

### 配置产物与使用注意

| 产物 | 说明 |
|---|---|
| `.config` | menuconfig 保存的配置原始数据（键值对形式） |
| `rtconfig.h` | 由 `.config` 导出的 C 头文件，决定哪些模块被编进来 |

- `rtconfig.h` 里能看到大量 `#define RT_USING_XXX`，就是第 1 节表格里说的"板级配置"；
- **不要手改 `rtconfig.h`**，下次 menuconfig 一保存就会被覆盖；要改就走 `menuconfig` 改 `Kconfig` 里的对应项；
- 改完配置后重新 `scons -j10` 编译，行为变化才生效；
- 想知道某个选项的开头位置，先看菜单层级（`menuconfig` 里的路径），再去对应 `Kconfig` 里搜 `config XXX`。

## 9. 和其他笔记的关联

- `bsps/sitl/qemu` 里就是 `SConstruct` + `SConscript`，编译命令也是 `scons -j10` → 见 [SCons 笔记](../scons/README.md)；
- `link.lds` 和启动汇编是同一套启动流程 → 见 [ARM 启动汇编笔记](../arm-startup/README.md)；
- 交叉编译工具链装法 → 见 [软件安装记录 · Arm GNU Toolchain](../../app/README.md)；
- `menuconfig` 的配置项最终变成 `rtconfig.h` 里的宏，和 BSP 的编译裁剪直接相关 → 见第 1 节表格。
