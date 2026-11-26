# 笔记与教程

按主题分目录存放，一个主题一个文件夹：`notes/<主题>/`。
每个主题目录里放一份 `README.md` 作为入口说明，笔记正文和生成的文件都放在该目录内。

## 现有主题

| 主题 | 目录 | 内容 |
|---|---|---|
| Git | [git/](git/README.md) | 常用命令速查（PDF + HTML 源文件） |
| Linux / Ubuntu | [linux/ubuntu/](linux/ubuntu/README.md) | 桌面快捷键速查（图片 + PDF + HTML 源文件） |
| Linux Shell | [linux/shell/](linux/shell/README.md) | 常用命令速查：符号、文件、查找过滤、进程、网络、压缩、快捷键 |
| YAML | [yaml/](yaml/README.md) | 语法符号、缩进规则、多行字符串、常见坑 |
| Tcl | [tcl/](tcl/README.md) | 基本语法、列表与过程、运行方式、Vivado 常用命令、常见坑 |
| PowerShell | [powershell/](powershell/README.md) | 输出/判断/循环/函数/删除/路径判断，含 clean.ps1 实测示例 |
| Makefile | [makefile/](makefile/README.md) | 基础语法 + Windows mingw32-make 实战（含可运行示例） |
| SCons | [scons/](scons/README.md) | SConstruct/SConscript 写法、常用 API、增量构建、可运行示例 |
| CMake | [cmake/](cmake/README.md) | 最小工程、单可执行/可执行+库两种结构、常用函数、现代写法与坑 |

## 新增主题的做法

```
notes/
└─ 新主题/
   ├─ README.md          # 主题说明 + 笔记索引
   ├─ 笔记正文.md         # 可多篇
   └─ 附件/              # 图片、PDF 等
```

1. 建目录时用英文小写短名（如 `git`、`stm32`、`pcb`），避免中文路径在命令里转义麻烦。
2. 在 `README.md` 里写清：这个主题记什么、有哪些文件、如何更新。
3. 由 HTML / Markdown 生成的 PDF，请把源文件一并保留，方便以后修改。
4. 回到本页面的「现有主题」表格补一行。
