# 个人收藏与笔记

存放日常收藏的**网站**、**笔记教程**和**软件安装记录**：网站集中在一个 `websites.md`，笔记按主题放 `notes/`，软件安装放 `app/`，辅助脚本和临时产物放本地工作目录 `build/`（不进仓库）。

## 仓库结构

| 路径 | 说明 |
|---|---|
| [websites.md](websites.md) | 网站收藏，按 6 类分节，顶部有快速索引 |
| [notes/](notes/README.md) | 笔记与教程，一个主题一个目录 |
| [app/](app/README.md) | 软件安装记录：选哪个版本、干什么用、怎么装 |
| `build/` | 本地工作目录（脚本、临时产物），已在 `.gitignore` 中排除 |

## 网站收藏

全部收录在 [websites.md](websites.md)，按以下 6 类组织：

| 分类 | 收录内容 |
|---|---|
| 硬件设计与开源硬件 | 开源电子项目、原理图 / PCB、嵌入式 |
| 机械模型与三维设计 | CAD 模型库、零件与装配体 |
| 软件与工具资源 | Windows 软件、科研与开发工具 |
| 代码托管与协作 | GitHub、Gitee、开源项目协作 |
| AI 助手 | 对话式 AI、代码辅助 |
| 技术学习与社区 | 技术博客、教程、问答 |

## 笔记与教程

| 主题 | 内容 | 入口 |
|---|---|---|
| Git | 常用命令速查（PDF，A4 两页） | [notes/git/](notes/git/README.md) |
| Linux / Ubuntu | 桌面快捷键速查（图片 + PDF，A4 单页） | [notes/linux/ubuntu/](notes/linux/ubuntu/README.md) |
| Linux Shell | 常用命令速查：符号、文件、查找过滤、进程、网络、压缩、快捷键 | [notes/linux/shell/](notes/linux/shell/README.md) |
| YAML | 语法符号、缩进、多行字符串、常见坑 | [notes/yaml/](notes/yaml/README.md) |
| Tcl | 基本语法、列表与过程、Vivado 常用命令、常见坑 | [notes/tcl/](notes/tcl/README.md) |
| Makefile | 基础语法 + Windows mingw32-make 实战（含可运行示例） | [notes/makefile/](notes/makefile/README.md) |
| SCons | SConstruct/SConscript 写法、常用 API、可运行示例 | [notes/scons/](notes/scons/README.md) |
| PowerShell | 输出/判断/循环/函数/删除/路径判断，含 clean.ps1 示例 | [notes/powershell/](notes/powershell/README.md) |
| CMake | 最小工程、两种常用结构、常用函数与坑（含可运行示例） | [notes/cmake/](notes/cmake/README.md) |
| Windows 技巧 | 文件夹里直接开 cmd/powershell、地址栏与 Win+R 小技巧 | [notes/windows/](notes/windows/README.md) |
| VS Code | 扩展推荐、推荐设置、项目级推荐配置 | [notes/vscode/](notes/vscode/README.md) |
| ARM 启动汇编 | 读懂 STM32 启动文件：向量表、Reset_Handler、.data/.bss 搬运 | [notes/arm-startup/](notes/arm-startup/README.md) |
| NextPilot | bsps 目录说明（ndt/px4/sitl/qemu）、QEMU 仿真链路、入门顺序 | [notes/nextpilot/](notes/nextpilot/README.md) |

## 使用建议

- **电子硬件设计：** 优先查阅 OSHWHub 上的开源工程，参考原理图、PCB 布局和程序实现。
- **机械结构设计：** 在 GrabCAD 中搜索相近零件或装配体，作为三维建模和结构设计参考。
- **代码学习与管理：** 使用 GitHub 或 Gitee 搜索开源项目，并通过 Git 管理自己的代码版本。
- **技术问题排查：** 可结合 CSDN、开源项目文档和 AI 助手交叉验证解决方案。
- **软件安装：** 软件资源网站可用于了解工具，但安装包应尽量从软件官网或可信发布渠道获取，并留意授权要求。

## 维护约定

- **加网站：** 直接在 [websites.md](websites.md) 对应分类的表格里加一行，不需要新建文件。
- **加笔记：** 在 `notes/` 下按主题建目录（英文小写短名，如 `git`、`stm32`），目录内放 `README.md` 做索引，再更新本页表格，写法见 [notes/README.md](notes/README.md)。
- **加软件安装：** 在 [app/README.md](app/README.md) 里按「用途 / 版本选择 / 安装步骤 / 验证」四段补一节。
- 生成的中间文件（PDF 预览图、日志等）不要提交；辅助脚本和临时产物统一放 `build/`，该目录已被 `.gitignore` 排除。
- 改完 Markdown 后可跑一次 `powershell -ExecutionPolicy Bypass -File build\scripts\check-links.ps1` 校验本地链接。
