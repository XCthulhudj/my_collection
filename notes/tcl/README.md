# TCL 笔记

[← 返回笔记索引](../README.md)

Tcl（Tool Command Language）是一门脚本语言，主要在 EDA / FPGA 领域用得最多：Vivado、Vitis、Quartus 内部都自带 Tcl 解释器，Vivado 里几乎每个界面操作都有对应的 Tcl 命令，所以学 Zynq 绕不开它。

## 1. 第一个脚本

新建 `hello.tcl`：

```tcl
# 这是注释
puts "Hello World"

set name "MuJoCo"
puts "Project name: $name"
```

执行结果：

```text
Hello World
Project name: MuJoCo
```

## 2. 基本语法

| 语法 | 作用 |
|---|---|
| `#` | 注释（只能出现在一条命令的起始位置） |
| `puts` | 输出信息 |
| `set` | 定义变量 / 读取变量 |
| `$变量名` | 获取变量值 |
| `[]` | 执行命令并获取返回值（命令替换） |
| `{}` | 把内容当整体传递，内部**不做**变量替换，常用来写代码块 |
| `""` | 字符串，内部**会**做变量替换 |

三句话记住区别：

```tcl
set x 1
puts {x = $x}     ;# 输出 x = $x（花括号里不替换）
puts "x = $x"     ;# 输出 x = 1
puts [expr {$x + 1}]  ;# 输出 2（方括号先执行 expr，再当参数传给 puts）
```

## 3. 常见语法

### 3.1 变量

```tcl
set frequency 100
set name "ZYNQ"
puts "$name, $frequency MHz"
```

变量名里含特殊字符时用 `${name}` 明确边界。

### 3.2 条件判断

```tcl
set temperature 30

if {$temperature > 25} {
    puts "Temperature is high"
} elseif {$temperature > 15} {
    puts "Temperature is normal"
} else {
    puts "Temperature is low"
}
```

### 3.3 循环

```tcl
for {set i 0} {$i < 5} {incr i} {
    puts "i = $i"
}

set n 3
while {$n > 0} {
    puts "n = $n"
    incr n -1
}
```

### 3.4 列表

```tcl
set motors {motor1 motor2 motor3}

foreach motor $motors {
    puts $motor
}

lappend motors motor4      ;# 追加元素
llength $motors            ;# 4
lindex $motors 0           ;# motor1
lrange $motors 1 2         ;# motor2 motor3
```

Tcl 没有数组下标那一套，列表就是核心数据结构；Vivado 里 `get_cells`、`get_pins` 返回的也都是列表。

### 3.5 定义过程（函数）

```tcl
proc add {a b} {
    return [expr {$a + $b}]
}

puts [add 10 20]     ;# 30
```

带默认值的参数：

```tcl
proc blink {pin {count 3}} {
    for {set i 0} {$i < $count} {incr i} {
        puts "toggle $pin, round $i"
    }
}

blink led0          ;# count 用默认值 3
blink led1 5        ;# 指定 count = 5
```

## 4. 怎么运行

| 方式 | 命令 | 说明 |
|---|---|---|
| 独立解释器 | `tclsh hello.tcl` | 需要装 Tcl（Windows 可装 ActiveTcl） |
| Vivado 图形界面 | `source hello.tcl` | 在 Tcl Console 里执行 |
| Vivado 批处理 | `vivado -mode batch -source build.tcl` | 不开 GUI，适合跑流程 |
| Vitis | `xsct script.tcl` | Xilinx 的 Tcl 命令行环境 |

> Vivado、Vitis 内部已集成 Tcl 解释环境，不用单独安装解释器也能跑。

## 5. 在 Vivado 里的用法

### 5.1 常用命令

| 命令 | 作用 |
|---|---|
| `create_project` / `open_project` | 新建 / 打开工程 |
| `add_files` | 添加源文件（`-norecurse` 只加当前目录） |
| `set_property` | 设置属性，如 top 模块、器件型号、文件类型 |
| `update_compile_order` | 刷新编译顺序 |
| `launch_runs` / `wait_on_run` | 启动综合 / 实现并等待完成 |
| `write_bitstream` | 生成 bit 文件 |
| `create_bd_design` / `create_bd_cell` | 创建 Block Design 和其中的 IP |
| `get_bd_cells` / `connect_bd_intf_net` | 取 BD 中的 IP、连线 |
| `generate_target` / `make_wrapper` | 生成 BD 产物、生成 HDL wrapper |
| `get_parts` / `get_property` | 查器件 / 查属性 |
| `start_gui` | 批处理脚本里回到图形界面 |

### 5.2 自动创建 Zynq 工程

```tcl
create_project my_project ./my_project -part xc7z010clg400-1

create_bd_design "system"

create_bd_cell -type ip \
    -vlnv xilinx.com:ip:processing_system7:5.5 \
    processing_system7_0

save_bd_design
```

### 5.3 一个可跑通的构建流程

```tcl
create_project zynq_demo ./zynq_demo -part xc7z010clg400-1 -force

# 添加源文件并设置顶层
add_files -norecurse [glob ./src/*.v]
set_property top my_top [current_fileset]
update_compile_order -fileset sources_1

# 综合 → 实现 → 出 bit
launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# 检查结果
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: implementation failed"
} else {
    puts "OK: bitstream at ./zynq_demo/zynq_demo.runs/impl_1/my_top.bit"
}
```

把这段存成 `build.tcl`，执行 `vivado -mode batch -source build.tcl`，就能不点界面完成一次完整构建。

## 6. Tcl 和 Python 的区别

| 对比 | TCL | Python |
|---|---|---|
| 语言类型 | 脚本语言 | 通用编程语言 |
| 变量 | `set a 10` | `a = 10` |
| 输出 | `puts` | `print()` |
| 函数 | `proc` | `def` |
| 常见应用 | EDA、FPGA、自动化 | AI、仿真、数据处理 |
| 运行环境 | Tcl 解释器或软件内置解释器 | Python 解释器 |

关键差异：**Tcl 不一定需要单独安装解释器**——Vivado、Vitis 里已经内嵌了 Tcl 环境，直接在里面敲命令即可。

## 7. 容易踩的坑

| 现象 | 原因 |
|---|---|
| `invalid command name "xxx"` 或参数个数错 | 行内 `#` 注释位置不对：`set a 1 # 注释` 会报错，要写成 `set a 1 ;# 注释` |
| 花括号里的 `$x` 没被替换 | `{}` 是字面量，替换只发生在 `""` 里 |
| `expr` 结果不对 | 条件/表达式要用花括号：`expr {$a + $b}`，别写成 `expr $a + $b` 再拼字符串 |
| 一行太长想换行 | 行尾用 `\` 续行（Vivado 命令常用） |
| 命令找不到 | Tcl 区分大小写，`puts` 不能写成 `Puts` |
| 输出不换行 | `puts -nonewline "..."`，默认是换行的 |
| 变量名后面紧跟字符被吞 | 用 `${name}_suffix` 明确边界 |

## 8. 学习建议（Zynq / Vivado 方向）

按这个顺序练，性价比最高：

1. **语法**：`set`、`$`、`""` vs `{}`、`[]`、`expr`、`if`、`for`、`foreach`、`proc`。
2. **列表操作**：`lappend`、`llength`、`lindex`、`lrange`，因为 Vivado 返回值都是列表。
3. **工程命令**：`create_project`、`add_files`、`set_property`、`update_compile_order`。
4. **构建命令**：`launch_runs` + `wait_on_run` + `write_bitstream`，把重复点击变成脚本。
5. **Block Design**：`create_bd_design`、`create_bd_cell`、`connect_bd_intf_net`、`make_wrapper`。

先在 Vivado Tcl Console 里单条试命令，确认效果后再写进 `.tcl` 文件；把 GUI 里刚做过的操作在 Console 里回放一遍，是最快的入门方式。
