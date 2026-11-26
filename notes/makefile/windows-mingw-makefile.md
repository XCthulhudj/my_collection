# Windows 下的 Makefile（mingw32-make）

[← 返回 Makefile 笔记索引](README.md)

Windows 上编译 C/C++ 常用 MinGW-w64 工具链，配套的构建工具叫 **mingw32-make**（不是 `make`）。这份笔记用一个能跑通的小工程，把变量、自动变量、伪目标、Windows 命令写法串起来。示例工程在 [example-windows/](example-windows/)，已用 g++ 16.2.0 + mingw32-make 4.4.1 实测通过。

## 1. 为什么要用 mingw32-make

| 环境 | 情况 |
|---|---|
| MinGW-w64 安装包 | 提供 `mingw32-make.exe`，没有 `make.exe` |
| cmd / PowerShell | 直接敲 `make` 通常提示找不到命令 |
| Git Bash / MSYS2 | 自带 `make`，但它是另一套环境，和 MinGW 的 g++ 可能不是同一套 |
| WSL | 是 Linux 的 make，不能直接编 Windows 目标 |

所以 Windows 原生开发就统一用 `mingw32-make`。想少打字可以设别名：

```powershell
# PowerShell：当前会话有效
function make { mingw32-make @args }
```

```bat
:: cmd：放到 PATH 里的 make.bat
@echo off
mingw32-make %*
```

## 2. 示例工程结构

```text
example-windows/
├── Makefile
├── main.cpp
├── inc/
│   └── mmath.h
├── src/
│   └── mmath.cpp
├── build/        # 目标文件，make 生成
└── bin/          # 可执行文件，make 生成
```

## 3. 完整 Makefile

```makefile
# 基于 Windows 环境，使用 mingw32-make，而不是 make

CXX = g++
PROM = bin/main.exe
INC = inc

CCFLAGS = -Wall -I $(INC)

DEPS = $(wildcard $(INC)/*.h)   # wildcard 展开成实际头文件列表
OBJ = build/main.o build/mmath.o

.PHONY: all clean run

all: $(PROM)                    # 默认目标放最前面，make 就等于 make all

$(PROM): $(OBJ)                 # $^ = 冒号后全部依赖，即 $(OBJ)
	if not exist bin mkdir bin
	$(CXX) $^ -o $@

build/main.o: main.cpp $(DEPS)  # $< = 第一个依赖，即 main.cpp
	if not exist build mkdir build
	$(CXX) $(CCFLAGS) -c $< -o $@

build/mmath.o: src/mmath.cpp $(DEPS)
	if not exist build mkdir build
	$(CXX) $(CCFLAGS) -c $< -o $@

clean:
	if exist build rmdir /s /q build
	if exist bin rmdir /s /q bin

run: $(PROM)
	.\$(PROM)
```

> 注意：recipe 行（`if not exist ...`、`$(CXX) ...`）缩进必须是 **Tab**，不是空格。VS Code 里可以开「渲染空格」确认。

## 4. 变量与自动变量

| 写法 | 含义 |
|---|---|
| `CXX = g++` | 变量赋值；用 `$(CXX)` 引用 |
| `$(wildcard inc/*.h)` | 展开成实际存在的文件列表；直接写 `inc/*.h` 只是字符串 |
| `$@` | 当前规则的**目标**（如 `build/main.o`） |
| `$<` | **第一个**依赖（如 `main.cpp`） |
| `$^` | 冒号后面**全部**依赖（如 `build/main.o build/mmath.o`） |
| `$*` | 模式规则里的茎（stem），本例没用到 |

检查变量展开对不对，用 `$(info ...)` 最直接：

```makefile
$(info DEPS=[$(DEPS)])
```

## 5. 目标与依赖

```text
all → bin/main.exe → build/main.o + build/mmath.o
                     ├── main.cpp
                     └── inc/*.h（通过 DEPS）
```

- `all` 放第一个，`make` 默认执行它，等同于 `make all`；
- `PROM` 依赖两个 `.o`，链接时用 `$^` 一次拿到全部目标文件；
- 每个 `.o` 依赖「自己的 cpp + 全部头文件」，所以改头文件会让两个 `.o` 都重编；
- `DEPS` 用 `wildcard` 展开后才是真实文件列表，否则 make 会把它当成名字叫 `inc/*.h` 的依赖，永远不会存在，也就永远不会触发重编。

## 6. .PHONY 为什么必须有

Make 的规则是：**目标文件存在且不比依赖旧，就不执行命令**。如果你的目录里恰好有个叫 `all` 或 `clean` 的文件，make 就会以为"这个目标已经是最新"，直接跳过。

`.PHONY: all clean run` 声明这几个名字是**动作**，不是要生成的文件，每次都会执行。实测验证：

```text
# 在目录里手动创建了名为 all 和 clean 的空文件
$ mingw32-make clean
if exist build rmdir /s /q build
if exist bin rmdir /s /q bin        ← 仍然执行，说明 .PHONY 生效
```

## 7. Windows 特有的写法

Makefile 的 recipe 是交给 **cmd.exe** 执行的（即使你在 PowerShell 里敲 mingw32-make），所以这里要用 cmd 语法：

| 需求 | Windows 写法 | Linux 写法 |
|---|---|---|
| 建目录（不存在时） | `if not exist bin mkdir bin` | `mkdir -p bin` |
| 删目录 | `if exist build rmdir /s /q build` | `rm -rf build` |
| 运行程序 | `.\$(PROM)` | `./$(PROM)` |
| 路径分隔符 | 正反斜杠都行，但 `.\` 开头最稳 | `/` |

另外 make **不会**自动创建目标文件所在目录，所以 `build/`、`bin/` 必须自己 `mkdir`，否则 g++ 报错找不到输出目录。

## 8. 实测输出

在 [example-windows/](example-windows/) 下执行 `mingw32-make`：

```text
if not exist build mkdir build
g++ -Wall -I inc -c main.cpp -o build/main.o
if not exist build mkdir build
g++ -Wall -I inc -c src/mmath.cpp -o build/mmath.o
if not exist bin mkdir bin
g++ build/main.o build/mmath.o -o bin/main.exe
```

`mingw32-make run`：

```text
add(2, 3) = 5
```

再执行一次 `mingw32-make`（无改动）：

```text
mingw32-make: Nothing to be done for 'all'.
```

`mingw32-make clean`：

```text
if exist build rmdir /s /q build
if exist bin rmdir /s /q bin
```

## 9. 增量构建看时间戳（而且只精确到秒）

Make 判断要不要重编，靠的是**文件修改时间**，不是内容。实测两种现象：

1. 只改头文件的时间戳、内容一字没动 → 两个 `.o` 照样重编；
2. 改动和上次编译发生在**同一秒内** → make 可能认为"没更新"，跳过不编。

第 2 条容易被误判成"Makefile 写错了"，尤其是脚本连续操作时。两个规避方法：

```powershell
mingw32-make -B     # 强制全部重编，不信时间戳
mingw32-make clean  # 清理后重建
```

> 顺带对比：项目里 [SCons 笔记](../scons/README.md) 用的是内容签名，改时间戳不会重编、改一个字符就会重编，正好相反。这也是 SCons 相比 make 的一个卖点。

## 10. 常用命令

| 命令 | 作用 |
|---|---|
| `mingw32-make` | 构建默认目标（all） |
| `mingw32-make all` | 同上，显式写出来 |
| `mingw32-make run` | 构建并运行 |
| `mingw32-make clean` | 清理 build / bin |
| `mingw32-make -j8` | 并行编译 8 个任务 |
| `mingw32-make -n` | 只打印命令，不执行（检查写的对不对） |
| `mingw32-make -B` | 强制重编 |
| `mingw32-make -f 名称.mk` | 指定 Makefile 文件名 |

## 11. 常见坑

| 现象 | 原因 |
|---|---|
| `missing separator` | recipe 行用了空格缩进，必须 Tab |
| `'all' is up to date` 但没编译 | 目录里存在同名 `all` 文件，且没写 `.PHONY` |
| `g++: error: build/main.o: No such file or directory` | 没先 `mkdir build`，或路径写错 |
| 改了头文件不重编 | `DEPS` 没展开（少了 `wildcard`），或依赖里没包含头文件 |
| `make: command not found` | Windows 上要用 `mingw32-make` |
| `if` / `rmdir` 报"不是内部或外部命令" | recipe 写成了 Linux 语法 `mkdir -p`、`rm -rf` |
| 变量明明改了却不生效 | 改的是 `=` 定义但被后续行覆盖；用 `$(info ...)` 打出来看 |

## 12. 延伸

- Makefile 基础（目标、依赖、变量、模式规则）：[makefile学习笔记.md](makefile学习笔记.md)
- SCons（Python 语法的替代构建工具）：[notes/scons/](../scons/README.md)
- 官方手册：<https://www.gnu.org/software/make/manual/make.html>
