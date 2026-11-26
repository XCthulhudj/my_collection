# Makefile 笔记

[← 返回笔记索引](../README.md)

Make 是 C/C++ 项目最常见的构建工具，这里放两篇：一篇是基础语法，一篇是 Windows 下 mingw32-make 的实战写法（带可运行示例）。

## 笔记列表

| 笔记 | 内容 | 适合场景 |
|---|---|---|
| [makefile学习笔记.md](makefile学习笔记.md) | 目标、依赖、变量、增量编译的原因、make 的工作原理 | 第一次接触 Makefile |
| [windows-mingw-makefile.md](windows-mingw-makefile.md) | Windows + mingw32-make 完整示例、`$@`/`$<`/`$^`、`wildcard`、`.PHONY`、cmd 风格命令、时间戳增量与坑 | 在 Windows 上实际写 Makefile |

## 可运行示例

| 目录 | 说明 |
|---|---|
| [example-windows/](example-windows/) | 对应 Windows 笔记的完整工程，`mingw32-make` 直接可编（需 g++ 在 PATH） |

跑法：

```powershell
cd notes\makefile\example-windows
mingw32-make        # 编译
mingw32-make run    # 编译并运行
mingw32-make clean  # 清理
```

## 相关笔记

- [SCons（Python 语法的构建工具）](../scons/README.md)：和 make 的时间戳机制正好相反，用内容签名判断增量。
