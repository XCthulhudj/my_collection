# CMD / PowerShell / Ubuntu 常用命令对照表

> 只收录三种终端都能直接敲的写法；PowerShell 一列优先用别名（`ls` / `rm` / `cp` / `mv` / `cat`），
> 完整命令名（`Get-ChildItem` 之类）只在最后对照一次。
>
> 前提：写法能直接敲，**参数不完全通用**，尤其删除类操作。

## 文件与文件夹

| 操作 | CMD | PowerShell | Ubuntu |
|---|---|---|---|
| 新建文件夹 | `mkdir test` | `mkdir test` | `mkdir test` |
| 新建空文件 | `type nul > a.txt` | `New-Item a.txt` | `touch a.txt` |
| 复制文件 | `copy a.txt b.txt` | `cp a.txt b.txt` | `cp a.txt b.txt` |
| 移动文件 | `move a.txt D:\test\` | `mv a.txt D:\test\` | `mv a.txt ~/test/` |
| 重命名 | `ren old.txt new.txt` | `ren old.txt new.txt` | `mv old.txt new.txt` |
| 删除文件 | `del a.txt` | `rm a.txt` | `rm a.txt` |
| 删除空文件夹 | `rmdir test` | `rmdir test` | `rmdir test` |
| 删除整个文件夹 | `rmdir /s /q test` | `rm -r -force test` | `rm -rf test` |

## 目录与查看

| 操作 | CMD | PowerShell | Ubuntu |
|---|---|---|---|
| 进入目录 | `cd test` | `cd test` | `cd test` |
| 返回上级目录 | `cd ..` | `cd ..` | `cd ..` |
| 回到主目录 | `cd %USERPROFILE%` | `cd ~` | `cd ~` |
| 查看当前路径 | `cd` | `pwd` | `pwd` |
| 列出目录内容 | `dir` | `ls` | `ls -l` |
| 查看文件内容 | `type a.txt` | `cat a.txt` | `cat a.txt` |
| 清屏 | `cls` | `cls` | `clear` |
| 输出文本 | `echo Hello` | `echo Hello` | `echo Hello` |

## 查找与文本处理

| 操作 | CMD | PowerShell | Ubuntu |
|---|---|---|---|
| 查找文件 | `where /r . a.txt` | `ls -Recurse -Filter a.txt` | `find . -name a.txt` |
| 搜索文件内容 | `findstr "xx" a.txt` | `sls "xx" a.txt` | `grep -n "xx" a.txt` |
| 统计行数 | `find /c /v "" a.txt` | `(cat a.txt).Count` | `wc -l a.txt` |

## 系统与网络

| 操作 | CMD | PowerShell | Ubuntu |
|---|---|---|---|
| 查看进程 | `tasklist` | `ps` | `ps aux` |
| 结束进程 | `taskkill /F /PID 1234` | `kill 1234` | `kill -9 1234` |
| 查看本机 IP | `ipconfig` | `ipconfig` | `ip a` |
| 测连通 | `ping 8.8.8.8` | `ping 8.8.8.8` | `ping 8.8.8.8` |
| 查看命令帮助 | `help` | `help <cmd>` | `man <cmd>` |

## 常用组合（直接抄）

| 操作 | CMD | PowerShell | Ubuntu |
|---|---|---|---|
| 递归复制整个目录 | `xcopy proj new /E /I` | `cp -r proj new` | `cp -r proj new` |
| 打包压缩 | `tar -czf a.tar.gz dir` | `tar -czf a.tar.gz dir` | `tar -czf a.tar.gz dir` |
| 查端口占用 | `netstat -ano \| findstr :80` | `netstat -ano \| findstr :80` | `ss -tlnp \| grep 80` |
| 查命令装在哪 | `where python` | `where.exe python` | `which python` |

## 记住这几条差别就够了

**1. PowerShell 的 `ls` / `rm` / `cp` / `mv` / `cat` / `pwd` / `echo` 全是别名**

它们指向 `Get-ChildItem` / `Remove-Item` / `Copy-Item` / `Move-Item` / `Get-Content` / `Get-Location` / `Write-Output`。
写法一样，**参数不一样**：`rm -rf` 在 PowerShell 会报错，要写 `rm -r -force` 或 `Remove-Item -Recurse -Force`。

| PowerShell 别名 | 对应命令 |
|---|---|
| `ls` / `dir` / `gci` | `Get-ChildItem` |
| `cd` / `chdir` | `Set-Location` |
| `pwd` | `Get-Location` |
| `rm` / `del` / `rd` / `rmdir` | `Remove-Item` |
| `cp` / `copy` | `Copy-Item` |
| `mv` / `move` | `Move-Item` |
| `ren` | `Rename-Item` |
| `cat` / `type` | `Get-Content` |
| `echo` / `write` | `Write-Output` |
| `cls` / `clear` | `Clear-Host` |
| `sls` | `Select-String` |

**2. CMD 没有 `rm` / `cp` / `mv` / `ls` / `pwd` / `cat`**

分别用 `del` / `copy` / `move`（重命名用 `ren`）/ `dir` / `cd`（不带参数即显示路径）/ `type`。

**3. 路径与大小写**

Windows 用反斜杠 `\`（PowerShell 也认 `/`），Ubuntu 用 `/`；Windows 路径不区分大小写，Linux 区分。

**4. 通配符由谁解析**

CMD 交给程序自己处理；PowerShell 由 cmdlet 处理；Ubuntu 由 shell 展开。
所以 `dir *.txt` 和 `ls *.txt` 在各自环境里都行，但跨环境照抄命令时要留意。

**5. 最危险的一条**

`del` / `rm` 默认都不进回收站，删了就没了；`rm -rf /` 能直接删掉系统。
在服务器上永远先 `ls` 看清楚再删。

---

*同名 PDF：`CMD_PowerShell_Ubuntu_命令对照表.pdf`；生成脚本：`build_cmd_table_pdf.py`。*
