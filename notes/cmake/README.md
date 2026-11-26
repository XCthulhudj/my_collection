# CMake 笔记

[← 返回笔记索引](../README.md)

CMake 不直接编译，而是**读 `CMakeLists.txt` 生成别的构建系统**（Windows 上默认生成 Visual Studio 工程或 Ninja 文件），再交给真正的构建工具去编。所以流程永远是两步：先 configure（生成），再 build（编译）。

两个可运行示例：[example-basic/](example-basic/)（单可执行文件）、[example-lib/](example-lib/)（可执行 + 共享库），均已用 CMake + MinGW g++ 实测。

## 1. 最小工程

```cmake
cmake_minimum_required(VERSION 3.20)
project(hello)
add_executable(main main.cpp)
```

三步跑起来：

```powershell
cmake -S . -B build      # 配置：读 CMakeLists.txt，生成 build/
cmake --build build      # 编译
.\build\main.exe
```

`-S .` 是源码目录，`-B build` 是生成目录（build 目录不要提交）。

## 2. 两种最常用结构

### 2.1 单可执行文件 —— [example-basic/](example-basic/)

```cmake
cmake_minimum_required(VERSION 3.20)
project(program)

add_executable(main
    main.cpp
    src/mmath.cpp
)

target_include_directories(main PRIVATE inc)
target_compile_definitions(main PRIVATE DEBUG)
target_compile_options(main PRIVATE -Wall -O2)
```

| 语句 | 作用 |
|---|---|
| `add_executable(main 源文件...)` | 定义可执行目标 `main` |
| `target_include_directories(main PRIVATE inc)` | 只给 `main` 加头文件路径（等价 `-Iinc`） |
| `target_compile_definitions(main PRIVATE DEBUG)` | 只给 `main` 加宏（等价 `-DDEBUG`） |
| `target_compile_options(main PRIVATE -Wall -O2)` | 只给 `main` 加编译参数 |

`PRIVATE` 表示"只自己用"；如果还要传给依赖它的目标，用 `PUBLIC`。

### 2.2 可执行 + 共享库 —— [example-lib/](example-lib/)

```cmake
cmake_minimum_required(VERSION 3.10)
project(demo_project LANGUAGES C CXX)

set(CMAKE_BUILD_TYPE Debug)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Debug build")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)

include_directories(module)

add_library(calc_shared SHARED module/calc.c)
set_target_properties(calc_shared PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin
)

add_executable(main main.cpp)
target_link_libraries(main calc_shared)
```

要点：

- `add_library(名字 SHARED 源文件)` 生成 `.dll` / `.so`；`STATIC` 生成 `.a` / `.lib`。
- `target_link_libraries(main calc_shared)` 让 main 链接这个库，不用写 `-l`。
- Windows 上 DLL 属于 **RUNTIME** 产物，`.a`（导入库）属于 **ARCHIVE** 产物——所以共享库要单独设 `RUNTIME_OUTPUT_DIRECTORY`，否则 DLL 会跑到 `lib/`，运行时找不到。
- `include_directories(module)` 是**全局**写法（影响后面所有目标），单个目标建议改 `target_include_directories`。

实测构建输出（Windows + MinGW）：

```text
[1/4] Building C object CMakeFiles/calc_shared.dir/module/calc.c.obj
[2/4] Linking C shared library ...\bin\libcalc_shared.dll
[3/4] Building CXX object CMakeFiles/main.dir/main.cpp.obj
[4/4] Linking CXX executable ...\bin\main.exe

$ .\bin\main.exe
calc_add(2, 3) = 5
```

## 3. 常用命令

| 命令 | 作用 |
|---|---|
| `cmake -S . -B build` | 配置（生成构建文件） |
| `cmake --build build` | 编译 |
| `cmake --build build -j8` | 并行编译 |
| `cmake --build build --target main` | 只编某个目标 |
| `cmake --build build --clean-first` | 先清理再编 |
| `cmake -S . -B build -DCMAKE_BUILD_TYPE=Release` | 指定构建类型 |
| `cmake -S . -B build -G "MinGW Makefiles"` | 指定生成器（VS / Ninja / MinGW） |
| `cmake -S . -B build -DCMAKE_CXX_COMPILER=g++` | 指定编译器 |

## 4. 常用函数速查

| 用途 | 写法 |
|---|---|
| 最低版本 / 工程 | `cmake_minimum_required(VERSION 3.20)`、`project(名字 LANGUAGES C CXX VERSION 1.0)` |
| 生成可执行 | `add_executable(main a.cpp b.cpp)` |
| 生成库 | `add_library(x STATIC/SHARED a.cpp)` |
| 加头文件路径 | `target_include_directories(main PRIVATE inc)` |
| 加宏 | `target_compile_definitions(main PRIVATE DEBUG)` |
| 加编译选项 | `target_compile_options(main PRIVATE -Wall -O2)` |
| 链接库 | `target_link_libraries(main 库名)` |
| 找系统库 | `find_package(Threads REQUIRED)` + `target_link_libraries(main Threads::Threads)` |
| 设置变量 | `set(SRC a.cpp b.cpp)`，之后 `add_executable(main ${SRC})` |
| C++ 标准 | `set(CMAKE_CXX_STANDARD 17)` + `set(CMAKE_CXX_STANDARD_REQUIRED ON)` |
| 条件打印 | `message(STATUS "xxx")` |
| 开关选项 | `option(USE_FOO "说明" OFF)`，配 `if(USE_FOO)` |
| 子目录 | `add_subdirectory(src)`（src 里放自己的 CMakeLists.txt） |
| 输出目录 | `set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)` |

## 5. 现代写法 vs 旧写法

你给的两段正好是新旧两种风格，对照一下：

| 旧写法（全局） | 新写法（目标级） | 差别 |
|---|---|---|
| `include_directories(module)` | `target_include_directories(main PRIVATE module)` | 只作用于某个目标，不污染别人 |
| `add_compile_options(-g)` | `target_compile_options(main PRIVATE -g)` | 同上 |
| `add_definitions(-DDEBUG)` | `target_compile_definitions(main PRIVATE DEBUG)` | 同上 |
| `link_directories(...)` + `target_link_libraries(main foo)` | `target_link_libraries(main PRIVATE 路径/库)` | 少一层路径设置 |

新工程建议全用 `target_*` 系列；旧工程里看到 `include_directories` / `add_compile_options` 也不用改，能跑就行。

## 6. 常见坑

| 现象 | 原因 / 解决 |
|---|---|
| `CMAKE_BUILD_TYPE` 设了没用 | Visual Studio / Ninja Multi-Config 这类多配置生成器忽略它，用 `cmake --build build --config Release` |
| Windows 下双击 exe 报缺 DLL | DLL 不在 exe 同目录或 PATH 里；用 `RUNTIME_OUTPUT_DIRECTORY` 把两者放一起 |
| C 库给 C++ 用，链接时找不到符号 | 头文件要加 `extern "C"`（见 [example-lib/module/calc.h](example-lib/module/calc.h)） |
| 改了 CMakeLists 没生效 | 重新执行 `cmake -S . -B build`；CMake 一般会自动重新配置，但生成器换了要删 build |
| `No CMAKE_CXX_COMPILER could be found` | 编译器没在 PATH，用 `-DCMAKE_CXX_COMPILER=g++` 指定 |
| 源码里 `#include "xxx.h"` 报找不到 | 缺 `target_include_directories`，或路径写错（相对 CMakeLists.txt 所在目录） |
| 生成的 build 目录被提交进 git | `.gitignore` 里加 `build/`、`bin/`、`lib/` |

## 7. 延伸

- 官方文档：<https://cmake.org/cmake/help/latest/>
- 和 make / SCons 的区别见 [Makefile 笔记](../makefile/README.md) 与 [SCons 笔记](../scons/README.md)：CMake 是"生成器"，本身不编译；make/SCons 是"执行器"。
