# Linux Shell 常用命令

[← 返回笔记索引](../../README.md)

按「用得上」的顺序整理，不按字母排：先记符号（符号决定命令怎么组合），再记命令本身。重点覆盖嵌入式开发日常——编译、查找、看日志、传文件、串口。

## 0. 先记住这几个符号（比命令更重要）

| 写法 | 含义 |
|---|---|
| `>` `>>` | 输出重定向：覆盖 / 追加 |
| `2>` `&>` | 错误输出 / 全部输出重定向 |
| `\|` | 管道：左边输出交给右边处理 |
| `$(cmd)` 或 `` `cmd` `` | 命令替换，把结果当参数 |
| `&&` `;` `\|\|` | 成功才执行 / 顺序执行 / 失败才执行 |
| `'...'` vs `"..."` | 单引号原样；双引号里 `$变量` 会展开 |
| `*` `?` `[abc]` | 通配符：任意串 / 单个字符 / 范围内一个 |

两个最常用的组合：

```bash
# 后台跑，日志写到文件，终端断开也不退出
nohup ./app > out.log 2>&1 &

# 搜进程时排除 grep 自己
ps aux | grep calc | grep -v grep
```

## 1. 文件与目录

| 命令 | 说明 |
|---|---|
| `ls -lh` | 列表 + 人类可读大小（`-a` 含隐藏文件，`-t` 按时间） |
| `cd -` / `cd ~` | 回上一个目录 / 回家目录 |
| `pwd` | 当前路径 |
| `mkdir -p a/b/c` | 递归建目录 |
| `cp -r src dst` | 递归复制 |
| `mv a b` | 移动 / 重命名 |
| `rm -rf dir` | 递归强删（**危险，先 `ls` 确认**） |
| `ln -s target link` | 软链接 |
| `tree -L 2` | 树状看目录（可能要装） |
| `stat file` / `file file` | 详情 / 判断文件类型 |

## 2. 看文件内容

| 命令 | 说明 |
|---|---|
| `cat f` | 全文输出 |
| `less f` | 分页看（`/` 搜索、`q` 退出，大文件用这个） |
| `head -n 20 f` / `tail -n 20 f` | 前 / 后 20 行 |
| `tail -f log` | **实时跟踪日志**，调试必备 |
| `wc -l f` | 行数（`-c` 字节、`-w` 词数） |
| `nl f` | 带行号输出 |

## 3. 查找与过滤（最核心）

```bash
grep -rn "ETH_MDC" . --include=*.c      # 递归搜内容，只看 .c
find . -name "*.c" -mtime -7            # 找 7 天内改过的 .c
find . -name "*.o" -delete              # 找并删除
sed -i 's/old/new/g' file.c             # 原地替换
awk '{print $1, $3}' log                # 按列取
sort f | uniq -c | sort -rn             # 统计出现次数并排序
which gcc / whereis scons               # 命令装在哪
```

要点：

- `grep` 搜**内容**，`find` 搜**文件**，别混。
- `grep -r` 配 `--include=` 能大幅缩小范围；`.git` 目录用 `--exclude-dir=.git` 排除。
- `sed -i` 是原地改文件，改之前先 `git diff` 或备份；想先看效果就不加 `-i`。
- `find -exec` 比 `-delete` 更通用：`find . -name "*.o" -exec rm -f {} \;`。

## 4. 权限与用户

| 命令 | 说明 |
|---|---|
| `chmod 755 f` / `chmod +x f` | 数字权限（r=4 w=2 x=1）/ 加可执行 |
| `chown user:group f` | 改属主属组 |
| `sudo cmd` | 以 root 执行 |
| `su - user` | 切换用户 |
| `id` / `whoami` | 当前身份 |

`755` = `rwxr-xr-x`：属主可读写执行，组和其他人只读+执行。改设备节点权限、给脚本加 `+x` 最常用。

## 5. 进程与系统

| 命令 | 说明 |
|---|---|
| `ps aux \| grep calc` | 找进程 |
| `top` / `htop` | 实时资源占用 |
| `kill -9 PID` / `pkill calc` | 杀进程（先 `kill` 不加 -9） |
| `nohup ./app > out.log 2>&1 &` | 后台跑、断开终端不死 |
| `free -h` / `df -h` / `du -sh dir` | 内存 / 磁盘剩余 / 目录占用 |
| `dmesg \| tail` | 内核日志（插 USB、串口问题先看这个） |
| `systemctl status xxx` / `journalctl -f` | 服务状态 / 服务日志 |

## 6. 网络与远程（嵌入式天天用）

```bash
ping 192.168.1.10
ip a                     # 看网卡 IP（旧命令 ifconfig）
ss -tlnp                 # 看端口占用（旧命令 netstat）
ssh user@192.168.1.10    # 登录开发板/服务器
scp -r ./out user@host:/home/user/   # 传文件
rsync -av out/ host:/home/user/out/  # 增量同步
curl -O http://xxx/file  # 下载
```

`scp` 每次全量传，`rsync` 只传差异，重复同步用 `rsync` 更省时间。

## 7. 压缩打包

```bash
tar -czf pkg.tar.gz dir/     # c=创建 z=gzip f=文件名
tar -xzf pkg.tar.gz          # x=解压
tar -tzf pkg.tar.gz          # t=只看内容不解压
tar -xzf x.tar.gz -C /opt    # 解到指定目录
zip -r a.zip dir / unzip a.zip
```

口诀：**c 创建、x 解压、t 查看，z 走 gzip，f 后面跟文件名。**

## 8. 环境与日常

| 命令 | 说明 |
|---|---|
| `export PATH=$PATH:/opt/bin` | 加 PATH（写进 `~/.bashrc` 才永久） |
| `source ~/.bashrc` | 让修改立即生效 |
| `alias ll='ls -lh'` | 设别名 |
| `history \| grep make` | 翻历史命令 |
| `echo $?` | 上一条命令退出码（0 = 成功） |
| `man cmd` / `cmd --help` | 查用法 |

## 9. 与开发方向强相关的

```bash
gcc -Wall -O2 -c a.c -o a.o
make -j8 && make clean
cmake -B build -S . && cmake --build build
git status / git diff / git log --oneline
ldd ./app                # 看依赖哪些动态库
nm -C app | grep func    # 看符号表
objdump -d app           # 反汇编
size app                 # 各段大小（flash/ram 够不够）
strace -f ./app          # 跟踪系统调用
screen /dev/ttyUSB0 115200   # 串口终端（也可 minicom）
```

`size` 和 `strace` 是嵌入式排查的两个高频工具：一个看内存/flash 占用，一个看程序卡在哪个系统调用。

## 10. 省时间的快捷键

| 键 | 作用 |
|---|---|
| `Tab` | 补全（命令/路径，按两次列全部） |
| `Ctrl+R` | 反向搜历史命令（最省时间的一个） |
| `Ctrl+C` / `Ctrl+D` | 中断当前命令 / 结束输入（EOF） |
| `Ctrl+Z` → `bg`/`fg` | 挂起 → 放后台 / 调回前台 |
| `Ctrl+A` / `Ctrl+E` | 行首 / 行尾 |
| `Ctrl+U` / `Ctrl+K` / `Ctrl+W` | 删到行首 / 删到行尾 / 删一个词 |
| `!!` / `sudo !!` | 重复上一条 / 用 sudo 重跑上一条 |

> **终端里的复制粘贴是 `Ctrl+Shift+C` / `Ctrl+Shift+V`**，因为 `Ctrl+C` 被"中断当前命令"占用了。这条踩坑最多，详见 [Ubuntu 快捷键笔记](../ubuntu/README.md)。

## 面试最容易被追问的

| 问题 | 答法 |
|---|---|
| `grep` 和 `find` 区别 | 一个搜**文件内容**，一个搜**文件本身**（按名字/时间/大小） |
| 管道和重定向区别 | 管道把左边输出交给右边**进程**；重定向把输出写到**文件** |
| `chmod 755` 每位含义 | 3 位分别对应属主/组/其他人，每位 = r(4)+w(2)+x(1) |
| `ps aux \| grep xxx` 为什么常配 `grep -v grep` | 因为 grep 自己的进程也含关键字，会混进结果 |
