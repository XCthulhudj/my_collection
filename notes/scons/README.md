# SCons 笔记

[← 返回笔记索引](../README.md)

SCons 是用 Python 写的构建工具：`SConstruct` 相当于 Makefile，但内容就是 Python 脚本，能直接调 `os`、`glob`、写函数。相比 make 最大的好处是不用管 Tab 缩进、依赖靠内容签名自动判断。

本文示例可直接运行：[example/](example/)（已用 scons 4.8.1 + g++ 实测编译通过）。

## 1. 示例工程结构

```text
example/
├── SConstruct          # 主构建脚本（入口）
├── SConscript          # 子构建脚本
├── main.cpp
├── inc/
│   └── my_math.h
├── src/
│   └── my_math.cpp
├── build/              # 目标文件，自动生成（gitignore）
└── bin/                # 安装产物，自动生成（gitignore）
```

## 2. SConstruct 逐段说明

```python
import os

os.makedirs('build', exist_ok=True)      # 创建构建目录
os.makedirs('bin', exist_ok=True)
SConsignFile('build/.sconsign')          # 指定 SCons 状态数据库的位置

env = Environment()

inc_paths = ['#inc']
defines = ['DEBUG']

env.Append(
    CPPPATH=inc_paths,
    CPPDEFINES=defines,
    CXXFLAGS=['-std=c++17', '-Wall'],    # C++ 专用
    CCFLAGS=['-O2']                      # C / C++ 共用
)

program = env.SConscript(
    'SConscript',                        # 子构建脚本
    variant_dir='build',                 # 构建目录
    duplicate=0,                         # 不复制源文件
    exports='env'                        # 把 env 传给子脚本
)

installed_program = env.Install('bin', program)   # 安装到 bin/
env.Alias('install', installed_program)           # 给安装任务起名 install

Default(program)                         # 默认目标
```

逐条对应：

| 语句 | 作用 |
|---|---|
| `Environment()` | 创建构建环境，里面是一堆变量（CC、CXX、CCFLAGS…），相当于一整套编译配置 |
| `Append(...)` | 往环境里追加变量值（`Replace` 是替换，`Prepend` 是加在前面） |
| `SConsignFile('build/.sconsign')` | 指定签名数据库位置，默认是各目录下的 `.sconsign.dblite`；集中放可以少污染源码目录 |
| `'#inc'` | `#` 表示“以 SConstruct 所在目录为根”，等价于相对顶层目录的路径 |
| `CPPPATH` | 头文件搜索路径，对应 `-Iinc` |
| `CPPDEFINES` | 宏定义，对应 `-DDEBUG` |
| `CXXFLAGS` / `CCFLAGS` | C++ 专用参数 / C 与 C++ 共用参数 |
| `SConscript(...)` | 执行子构建脚本，`variant_dir` 是构建目录，`exports` 传变量 |
| `Install('bin', program)` | 把产物复制到 `bin/`，返回新的节点列表 |
| `Alias('install', ...)` | 给任务起名字，之后可以 `scons install` |
| `Default(program)` | 不指定目标时默认构建它 |

## 3. SConscript：Import / Return

```python
Import('env')                            # 接收主脚本 exports 的 env

src_files = [
    'main.cpp',
    'src/my_math.cpp'
]

program = env.Program('main', src_files) # 编译链接成 build/main.exe

Return('program')                        # 把目标节点返回给主脚本
```

机制很简单：

- 主脚本 `exports='env'` → 子脚本 `Import('env')`，两边名称要一致；
- 子脚本 `Return('program')` → `env.SConscript()` 的返回值就是它，所以主脚本能拿到 `program` 去 `Install` 和 `Default`。

注意：`Program` 的第一个参数是**输出名**，第二个是源文件列表；写 `env.Program('main', src_files)` 不会把源码目录结构带进产物名。

## 4. 常用 API 速查

| API | 作用 |
|---|---|
| `Environment()` / `DefaultEnvironment()` | 新建 / 修改默认构建环境 |
| `Append()` / `Prepend()` / `Replace()` | 追加 / 前置 / 替换环境变量 |
| `Clone()` | 复制一份环境，用来做多套编译配置（如 debug / release） |
| `Program()` / `Object()` / `StaticLibrary()` / `SharedLibrary()` | 编译可执行文件 / 目标文件 / 静态库 / 动态库 |
| `Glob('*.cpp')` | 按通配符收源文件 |
| `Split('a.cpp b.cpp')` | 把空格分隔的字符串拆成列表 |
| `SConscript(scripts, variant_dir=..., duplicate=..., exports=...)` | 执行子脚本，`dirs=` 形式可批量执行多个目录 |
| `Import()` / `Return()` / `Export()` | 脚本间传递变量 / 回传结果 / 导出变量 |
| `Install(dir, targets)` | 复制产物到指定目录 |
| `Alias(name, targets)` | 给目标集合起别名 |
| `Default(targets)` | 默认目标；传 `None` 清空 |
| `SConsignFile(path)` | 签名数据库位置 |
| `VariantDir(build_dir, src_dir)` | 显式指定构建目录（`variant_dir` 的底层形式） |

## 5. 运行与常用选项

| 命令 | 作用 |
|---|---|
| `scons` | 构建默认目标 |
| `scons -Q` | 构建，并且不打印 “scons: Reading SConscript files...” 之类的提示 |
| `scons -j8` | 并行编译（8 个任务） |
| `scons install` | 执行别名为 install 的任务，把产物复制到 `bin/` |
| `scons -c` | 清理构建产物 |
| `scons -n` | 只打印要执行的命令，不真正执行 |

## 6. 实际构建输出

在 `notes/scons/example/` 下执行 `scons -Q`，实测输出：

```text
g++ -o build\main.o -c -std=c++17 -Wall -O2 -DDEBUG -Iinc main.cpp
g++ -o build\src\my_math.o -c -std=c++17 -Wall -O2 -DDEBUG -Iinc src\my_math.cpp
g++ -o build\main.exe build\main.o build\src\my_math.o
```

运行 `build/main.exe`：

```text
2 + 3 = 5
built with -DDEBUG
```

再执行一次 `scons -Q`，因为没有改动，输出：

```text
scons: `build\main.exe' is up to date.
```

执行 `scons -Q install`：

```text
Install file: "build\main.exe" as "bin\main.exe"
```

## 7. 增量构建靠内容签名，不看时间戳

这是 SCons 和 make 最容易混淆的地方，实测验证过：

- 用 `touch` 改 `inc/my_math.h` 的修改时间，**不会**触发重编译（内容没变）；
- 真的改一行注释，两个 `.o` 都会重编（内容变了）。

所以别用 `touch` 骗 SCons，想让某个文件重编就改内容，或者 `scons -c` 清理后重建。

依赖判断也不需要像 make 那样手写规则：只要头文件在 `CPPPATH` 目录里，改头文件会自动触发所有包含它的源文件重编。

## 8. 常踩的坑

| 现象 | 原因 / 解决 |
|---|---|
| `scons: *** No SConstruct file found` | 必须在 SConstruct 所在目录（或上级）执行；用 `scons -f 路径/SConstruct` 指定 |
| 子脚本里 `Import('env')` 报 NameError | 主脚本 `exports='env'` 的名字和 `Import` 的名字不一致 |
| `SConscript` 返回值是 `None` | 忘了写 `Return('program')` |
| 产物没出现在 `build/` | `variant_dir` 只影响目标文件，源文件仍在原处；`duplicate=0` 表示不去复制 |
| 源码里 `#include "my_math.h"` 找不到 | 头文件目录要放进 `CPPPATH`，且相对路径以 SConstruct 目录为基准 |
| `scons install` 报找不到目标 | 要先 `env.Alias('install', installed_program)`，只 `Install` 不 `Alias` 的话没有 install 这个目标名 |
| 改脚本后行为没变 | SConstruct 本身也会被签名；如果还不对，`scons -c` 再来一次 |

## 9. 与 Makefile / CMake 对照

| 场景 | Makefile | CMake | SCons |
|---|---|---|---|
| 脚本文件 | `Makefile` | `CMakeLists.txt` | `SConstruct` + `SConscript` |
| 语言 | 自有的规则语法 | 自有 DSL | Python |
| 缩进要求 | 命令必须 Tab | 无 | 无（Python 缩进） |
| 依赖判断 | 时间戳 | 时间戳（+ 编译器依赖） | 内容签名 |
| 换编译参数 | 改变量 | 改 target 属性 | 改 Environment |
| 跨平台 | 写法差异大 | 强项 | Python 里判断 `sys.platform` |

## 10. 延伸

- 入门外文：[SCons 使用教程（博客园）](https://www.cnblogs.com/dreamboy2000/p/15355410.html) —— 也收在 [websites.md](../../websites.md) 的参考文章里。
- 官方文档：`man scons` 或 <https://scons.org/doc.php>，查某个 builder 的参数最准。
