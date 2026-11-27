# 软件安装记录

记录常用开发软件的**用途 / 版本怎么选 / 安装步骤 / 怎么验证**。以 Windows 为主，Linux 有差异的地方单独标注。

安装包的通用原则：**从官网或官方包管理器拿**；第三方站点只用来了解，别用来下安装包。

## 速查表

| 软件 | 推荐版本 | 干什么用 | 安装方式 |
|---|---|---|---|
| [Python](#python) | 3.11 / 3.12 | 跑脚本、MuJoCo、自动化 | python.org 安装包 或 `winget install Python.Python.3.12` |
| [Git](#git) | 最新稳定 2.x | 版本控制、拉代码 | 官网 Git for Windows |
| [CMake](#cmake) | 3.20 以上（新项目 3.27+） | 生成构建文件（配合 make / VS / Ninja） | 官网 msi 安装包 |
| [Arm GNU Toolchain](#arm-gnu-toolchain) | 13.x rel（arm-none-eabi） | 交叉编译 STM32 等 Cortex-M 裸机程序 | 官方 zip/msi，解压后加 PATH |
| [MuJoCo](#mujoco) | PyPI 最新稳定版 | 物理仿真、机器人 / 强化学习 | `pip install mujoco` |

> 版本号会变，这里记的是"选哪个系列"的原则；具体小版本以官网为准。

---

## Python

**干什么用：** 脚本自动化、数据处理，也是 MuJoCo、SCons、部分构建/测试工具的运行环境。

**选哪个版本：**

- **3.11 / 3.12**：生态最稳，主流库都有预编译 wheel，推荐。
- **3.13+**：太新的版本，部分科学计算库可能还没有 wheel，装的时候会现场编译（要装编译器，很慢）。新手别急。
- 不要用 Windows 应用商店版做开发（路径和被沙盒化，容易出莫名其妙的权限问题）。

**安装（Windows）：**

1. 官网 <https://www.python.org/downloads/windows/> 下 `Windows installer (64-bit)`；
2. 安装第一屏**务必勾选 `Add python.exe to PATH`**；
3. 选 `Customize installation` 时保留 `pip`、`py launcher`。

也可以用 winget：

```powershell
winget install Python.Python.3.12
```

**验证：**

```powershell
python --version      # Python 3.12.x
pip --version
```

**常用配置：**

```powershell
# 国内 pip 镜像（一次性使用）
pip install mujoco -i https://pypi.tuna.tsinghua.edu.cn/simple

# 每个项目独立环境，别把包装进全局
python -m venv .venv
.\.venv\Scripts\Activate.ps1     # 若被策略拦，先 Set-ExecutionPolicy -Scope Process Bypass
```

## Git

**干什么用：** 版本控制，管代码、看提交历史、和 GitHub / Gitee 同步。

**选哪个版本：** 官网 **Git for Windows** 最新稳定版即可；64 位系统选 `64-bit Git for Windows Setup`。要绿色版就下 `PortableGit`。

**安装要点（安装向导里几个关键选择）：**

| 选项 | 建议 |
|---|---|
| 默认编辑器 | 熟悉哪个选哪个，不熟悉就选 VS Code / Notepad++ |
| `PATH environment` | 选 **Git from the command line and also from 3rd-party software** |
| HTTPS transport | 用默认的 OpenSSL |
| 换行符 | **Checkout Windows-style, commit Unix-style**（`core.autocrlf=true`） |
| 终端 | 默认 MinTTY 即可 |

**装完必做的三件事：**

```powershell
git --version
git config --global user.name "你的名字"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main      # 新仓库默认分支叫 main
```

**验证：** `git config --global --list`。

> 国内访问 GitHub 慢属于网络问题，别乱改 hosts；需要镜像时注意镜像站的可信度。

## CMake

**干什么用：** 跨平台**构建生成器**——读 `CMakeLists.txt` 生成 Ninja / Makefile / Visual Studio 工程，再由后者编译。本身不编译代码。

**选哪个版本：**

- **3.20 以上**基本能满足现代项目；新项目建议 3.27+。
- 注意 **CMake 4.x 不再兼容 `cmake_minimum_required(VERSION < 3.5)` 的老工程**，跑老代码报错时可以装 3.31 LTS 或把版本号改到 3.5+。
- Windows 装 x64 安装包，自带 `cmake-gui`。

**安装：**

1. 官网 <https://cmake.org/download/> 下 `cmake-<版本>-windows-x86_64.msi`；
2. 安装时选 **Add CMake to the system PATH for all users**（或 current user）；
3. 已有 VS 的话，也可以在 VS Installer 里勾"使用 C++ 的桌面开发"顺带装。

```powershell
winget install Kitware.CMake
```

**验证：**

```powershell
cmake --version
```

**基本用法：**

```powershell
cmake -S . -B build          # 配置
cmake --build build          # 编译
```

详见 [CMake 笔记](../notes/cmake/README.md)。

## Arm GNU Toolchain

**干什么用：** 在 Windows 上交叉编译 ARM Cortex-M 裸机程序（STM32、GD32 等）。生成的是 `.elf` / `.bin` / `.hex`，需要另外烧录。

**选哪个版本：**

- 选 **`arm-none-eabi`** 目标（bare-metal），下载页里通常写作 *AArch32 bare-metal target (arm-none-eabi)*；
- 版本用较新的 `13.x rel1` 一类即可，太老可能不支持新芯片；
- **别下错**：`arm-none-linux-gnueabihf` 是编译 Linux 用户态程序的，用在裸机上会缺库；
- 装 x86_64 Windows 的包（主机是 Windows），不是 aarch64。

**安装（用压缩包最省事）：**

1. 在 <https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads> 找 `arm-gnu-toolchain-<版本>-mingw-w64-x86_64-arm-none-eabi.zip`；
2. 解压到无空格路径，例如 `D:\Tools\arm-gnu-toolchain\`；
3. 把 `...\bin` 加进 PATH：

```powershell
# 当前用户永久生效
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";D:\Tools\arm-gnu-toolchain\bin",
    "User")
```

**验证**（要重开终端让 PATH 生效）：

```powershell
arm-none-eabi-gcc --version
arm-none-eabi-gdb --version
arm-none-eabi-size --version
```

**配套工具：** `arm-none-eabi-objcopy`（转 bin/hex）、`arm-none-eabi-size`（看 flash/ram 占用）、`arm-none-eabi-objdump`（反汇编）。

## MuJoCo

**干什么用：** 物理仿真引擎（DeepMind 开源），常用于机器人控制、强化学习、倒立摆 / 机械臂这类仿真验证。

**选哪个版本：**

- 直接用 PyPI 的最新稳定版，包名 `mujoco`，`pip` 会自动匹配 Python 版本；
- 新版本对 Python 版本有要求（3.11+ 支持较好），装之前看 PyPI 页面上的 **Requires** 一行；
- 只跑无图形界面的仿真（训练、服务器）可以装轻量包 `mujoco-core`，不带 Studio 和 OpenGL 依赖。

**安装：**

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install mujoco
```

**验证：**

```powershell
python -c "import mujoco; print(mujoco.__version__)"
python -m mujoco.viewer          # 打开查看器（需要 OpenGL）
```

**注意：**

- 可视化依赖 OpenGL / GLFW，远程桌面或虚拟机里可能报错；纯训练不需要 viewer，用无头模式即可；
- 想跟 MuJoCo 的模型文件打交道，学一下 XML（MJCF），比写代码还重要；
- 仿真里做倒立摆建模，可参考收藏的 [倒立摆建模教程](../websites.md)。

---

## 装完统一检查

```powershell
python --version
git --version
cmake --version
arm-none-eabi-gcc --version
python -c "import mujoco; print(mujoco.__version__)"
```

任何一条提示"不是内部或外部命令"，基本都是 **PATH 没配好**：改完 PATH 必须**重开终端**，PowerShell 里也可以先 `$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")` 临时刷新。
