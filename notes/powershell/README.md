# PowerShell 脚本基础

[← 返回笔记索引](../README.md)

用最常见的 6 个语法写日常的项目构建、清理、复制、环境检查脚本。示例配合 [SCons 示例工程](../scons/example/) 讲解，脚本在 [example/](example/)，已实测运行。

## 0. 两个前提：执行策略与脚本编码

这两个坑不开解决，脚本写了也跑不起来。

**① 执行策略（Execution Policy）**

默认策略是 `Restricted`，直接 `.\clean.ps1` 会报：

```text
无法加载文件 ...\clean.ps1，因为在此系统上禁止运行脚本。
```

三种解法，按需选：

```powershell
# 只对这一次调用生效（推荐，不改系统设置）
powershell -NoProfile -ExecutionPolicy Bypass -File .\clean.ps1

# 只对当前会话生效
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 查看当前策略
Get-ExecutionPolicy -List
```

**② 脚本编码**

Windows PowerShell 5.1 按 ANSI 读 `.ps1`，文件里含中文却没存成 **UTF-8 with BOM** 时，轻则中文乱码，重则语法报错（中文注释被错误解码成引号、反引号之类）。VS Code 里选「UTF-8 with BOM」保存即可。

## 1. Write-Host：输出信息

```powershell
Write-Host "Hello World"

$name = "SCons"
Write-Host "当前项目：$name"     # 双引号里变量会展开

$dir = ".\build"
Write-Host $dir                  # 也可以直接输出变量
```

输出：

```text
Hello World
当前项目：SCons
.\build
```

单引号 `'...'` 不展开变量，双引号 `"..."` 展开——和 bash 一样。

## 2. if / else：条件判断

```powershell
$number = 10

if ($number -gt 5) {
    Write-Host "大于5"
}
elseif ($number -eq 5) {
    Write-Host "等于5"
}
else {
    Write-Host "小于5"
}
```

比较运算符（注意不是 `>` `<` `==`）：

| 运算符 | 含义 |
|---|---|
| `-eq` | 等于 |
| `-ne` | 不等于 |
| `-gt` | 大于 |
| `-lt` | 小于 |
| `-ge` | 大于等于 |
| `-le` | 小于等于 |

逻辑运算：

```powershell
if ($a -gt 0 -and $b -lt 10) { ... }   # 并且
if ($a -gt 0 -or  $b -lt 10) { ... }   # 或者
if (-not (Test-Path $dir))   { ... }   # 取反
```

> 为什么不用 `>`：在 PowerShell 里 `>` 是重定向操作符，`$a > $b` 会把 `$b` 当文件名写出去。

## 3. foreach：循环

```powershell
$dirs = @("build", "bin", "temp")

foreach ($dir in $dirs) {
    Write-Host $dir
}
```

输出：

```text
build
bin
temp
```

数组用 `@(...)` 定义；`for` / `while` 也存在，但遍历列表时 `foreach` 最直观。

## 4. function：定义函数

```powershell
function Say-Hello {
    Write-Host "Hello World!"
}

Say-Hello
```

带参数：

```powershell
function Say-Hello($name) {
    Write-Host "Hello $name!"
}

Say-Hello "SCons"
Say-Hello "CMake"
```

输出：

```text
Hello SCons!
Hello CMake!
```

带默认值和返回值：

```powershell
function Get-BuildDir($root = ".") {
    return Join-Path $root "build"
}

$b = Get-BuildDir
Write-Host "构建目录：$b"
```

命名习惯是「动词-名词」（`Clean-Dir`、`Get-BuildDir`），和内置 cmdlet 风格一致，读起来更顺。

## 5. Remove-Item：删除文件或目录

```powershell
Remove-Item 文件路径
```

别名 `rm`、`del`、`erase` 都可以用。

| 参数 | 作用 |
|---|---|
| `-Force` | 强制删除（含只读、隐藏） |
| `-Recurse` | 递归删除目录及其内容 |
| `-Confirm` | 删除前确认 |
| `-WhatIf` | 只显示将执行的操作，不真正删除 |

```powershell
Remove-Item .\main.o                      # 删文件
Remove-Item .\build -Recurse -Force       # 删目录
Remove-Item .\build -Recurse -Confirm     # 删前询问
Remove-Item .\build -Recurse -WhatIf      # 预览
```

`-WhatIf` 的实际输出：

```text
What if: Performing the operation "Remove Directory" on target "D:\project\build".
```

删非空目录时**必须**加 `-Recurse`，否则会弹确认（非交互环境直接报错 `Windows PowerShell is in NonInteractive mode`）。

## 6. Test-Path：判断路径是否存在

```powershell
Test-Path .\build        # True / False
```

区分文件和目录：

```powershell
Test-Path .\build -PathType Container   # 只判断目录
Test-Path .\main.cpp -PathType Leaf     # 只判断文件
```

配合 if：

```powershell
if (Test-Path .\build) {
    Write-Host "build目录存在"
}
else {
    Write-Host "build目录不存在"
}
```

## 7. 综合练习：清理脚本

[example/clean.ps1](example/clean.ps1)：

```powershell
function Clean-Dir($dir) {
    if (Test-Path $dir) {
        Remove-Item $dir -Recurse -Force
        Write-Host "Deleted: $dir"
    }
    else {
        Write-Host "Not Found: $dir"
    }
}

$dirs = @("build", "bin")

foreach ($dir in $dirs) {
    Clean-Dir $dir
}

Write-Host "Clean completed!"
```

在 SCons 示例工程里实测（先用 `scons -Q` 生成 `build/` 和 `bin/`，再跑脚本）：

```text
$ .\clean.ps1
Deleted: build
Deleted: bin
Clean completed!
```

再跑一次（目录已经不存在）：

```text
$ .\clean.ps1
Not Found: build
Not Found: bin
Clean completed!
```

带安全开关的版本见 [example/clean-whatif.ps1](example/clean-whatif.ps1)，实测预览效果：

```text
$ .\clean-whatif.ps1 -WhatIf
Would delete: build
Would delete: bin
Clean completed!
```

## 8. 语法速查

| 语法 | 主要用途 | 类似 C/C++ 的概念 |
|---|---|---|
| `Write-Host` | 输出信息 | `printf()` |
| `if / else` | 条件判断 | `if / else` |
| `foreach` | 遍历数组 | `for` / 范围循环 |
| `function` | 定义函数 | 函数定义 |
| `Remove-Item` | 删除文件 | `remove()` |
| `Test-Path` | 检查路径 | 文件存在性检查 |

## 9. 常见坑

| 现象 | 原因 / 解决 |
|---|---|
| `禁止运行脚本` | 执行策略是 Restricted，见第 0 节 |
| 中文注释导致语法错误 | 脚本不是 UTF-8 with BOM，PS 5.1 按 ANSI 解析 |
| `$a > $b` 不比较大小 | `>` 是重定向，比较用 `-gt`、`-lt` |
| `'$name'` 不展开 | 单引号是字面量，要展开用双引号 |
| `Remove-Item build` 报目录非空 | 删目录要加 `-Recurse` |
| `Test-Path build` 返回 False，但目录明明在 | 当前工作目录不对；用绝对路径或先 `Set-Location` |
| 函数名报错 `不是有效的命令名` | 用了保留动词冲突或含空格，改成 `动词-名词` |
| 脚本路径含空格执行失败 | 用 `& "C:\My Path\clean.ps1"` 显式调用 |

## 10. 延伸

- 本机工作目录 `build/scripts/` 里有两个现成脚本可以参考写法：`html-to-pdf.ps1`（调用 Chrome 无头打印 PDF）、`check-links.ps1`（检查 Markdown 本地链接）。该目录不进仓库，换机器需要自己重建。
- [SCons 笔记](../scons/README.md)：`scons -c` 也能清理，但用 PowerShell 脚本可以顺手清更多目录（日志、临时文件）。
