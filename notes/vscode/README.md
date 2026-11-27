# VS Code 扩展推荐

[← 返回笔记索引](../README.md)

按用途分组给一套"够用就好"的扩展清单。装多了只会变慢，先按下面「必装」那一组来，缺什么再补。

## 1. 怎么装

**图形界面：** `Ctrl + Shift + X` 打开扩展面板，搜名字点安装。

**命令行（推荐，可一键复制到新机器）：**

```powershell
code --install-extension ms-vscode.cpptools
```

前提是 `code` 在 PATH 里——安装 VS Code 时勾选 "Add to PATH"，或者手动把 `...\Microsoft VS Code\bin` 加进 PATH。导出当前已装列表：

```powershell
code --list-extensions > my-extensions.txt
```

## 2. 通用必装

| 扩展 | 扩展 ID | 作用 |
|---|---|---|
| Chinese (Simplified) Language Pack | `ms-ceintl.vscode-language-pack-zh-hans` | 中文界面，看菜单/设置不费劲 |
| EditorConfig for VS Code | `editorconfig.editorconfig` | 统一缩进、换行风格（配合 `.editorconfig`） |
| Error Lens | `usernamehw.errorlens` | 错误直接显示在出错行尾，不用悬停 |
| Todo Tree | `gruntfuggly.todo-tree` | 汇总所有 `TODO` / `FIXME`，一眼看全 |
| Path Intellisense | `christian-kohler.path-intellisense` | 输入路径时自动补全文件名 |
| Better Comments | `aaron-bond.better-comments` | 注释按 `TODO` `!` `?` 上色，扫代码更快 |
| indent-rainbow | `oderwat.indent-rainbow` | 缩进层级上色，嵌套深的代码不迷路 |
| GitLens | `eamodio.gitlens` | 每行谁改的、什么时候改的，看历史很省事 |
| Git Graph | `mhutchie.git-graph` | 图形化提交历史，分支合并关系一目了然 |

> Error Lens 装上会明显提高可读性；GitLens 功能多，嫌重可以只在需要看 blame 的时候开。

## 3. C / C++ 与构建

| 扩展 | 扩展 ID | 作用 | 备注 |
|---|---|---|---|
| C/C++ | `ms-vscode.cpptools` | IntelliSense、跳转、调试 | **必装**，微软官方 |
| C/C++ Extension Pack | `ms-vscode.cpptools-extension-pack` | 打包 C/C++ + CMake Tools | 图省事装这个 |
| CMake Tools | `ms-vscode.cmake-tools` | 识别 `CMakeLists.txt`，一键 configure/build/debug | 用 CMake 的项目必备 |
| Makefile Tools | `ms-vscode.makefile-tools` | 解析 Makefile，提供编译配置 | 写 make 的工程用 |
| clangd | `llvm-vs-code-extensions.vscode-clangd` | 更快的 C++ 语言服务 | **和 C/C++ 的 IntelliSense 二选一**，别同时开 |
| CodeLLDB | `vadimcn.vscode-lldb` | 用 LLDB 调试（配合 clangd） | 需要调试时再装 |

配 MinGW 的话，`C_Cpp.default.compilerPath` 指向本机的 `g++.exe` 即可（见第 7 节配置）。

## 4. 嵌入式 / 单片机

| 扩展 | 扩展 ID | 作用 |
|---|---|---|
| Cortex-Debug | `marus25.cortex-debug` | 调试 Cortex-M，配合 OpenOCD / J-Link / ST-Link，看寄存器和外设 |
| STM32 VS Code Extension | `stmicroelectronics.stm32-vscode-extension` | ST 官方，从 CubeMX 工程导入、配置交叉编译 |
| PlatformIO IDE | `platformio.platformio-ide` | 一站式嵌入式开发（自带工具链、库管理、串口监视） |
| Hex Editor | `ms-vscode.hexeditor` | 看 `.bin` / `.hex` 原始数据，核对烧录内容 |

用 Arm GNU Toolchain 交叉编译的话，配合 Cortex-Debug 是最常见的组合；烧录一般交给 OpenOCD 或 STM32CubeProgrammer。

## 5. Python / 仿真

| 扩展 | 扩展 ID | 作用 |
|---|---|---|
| Python | `ms-python.python` | 语法、调试、虚拟环境管理（装它会自动带上 Pylance） |
| Pylance | `ms-python.vscode-pylance` | 类型检查与补全，Python 体验的一半靠它 |
| Jupyter | `ms-toolsai.jupyter` | 直接在 VS Code 里跑 `.ipynb`，做仿真数据分析很方便 |

装 MuJoCo 时建议用虚拟环境，VS Code 右下角选解释器指向 `.venv\Scripts\python.exe`，别用全局的。

## 6. 配置 / 文档 / 其他

| 扩展 | 扩展 ID | 作用 |
|---|---|---|
| YAML | `redhat.vscode-yaml` | YAML 校验和补全（schema 支持） |
| Even Better TOML | `tamasfe.even-better-toml` | TOML 高亮校验 |
| Rainbow CSV | `mechatroner.rainbow-csv` | CSV 按列上色，看日志/数据表舒服 |
| Markdown All in One | `yzhang.markdown-all-in-one` | 目录、快捷键、表格格式化 |
| markdownlint | `davidanson.vscode-markdownlint` | Markdown 风格检查 |
| Remote - SSH | `ms-vscode-remote.remote-ssh` | 直接编辑远程开发板 / 服务器的代码 |
| Remote - WSL | `ms-vscode-remote.remote-wsl` | 在 WSL 里开发，Linux 工具链直接用 |

## 7. 推荐设置（settings.json）

`Ctrl + Shift + P` → `Preferences: Open User Settings (JSON)`，按需抄：

```json
{
  "editor.formatOnSave": true,
  "files.autoSave": "onFocusChange",
  "files.encoding": "utf8",
  "editor.tabSize": 4,
  "editor.renderWhitespace": "boundary",
  "editor.rulers": [100],

  "terminal.integrated.defaultProfile.windows": "PowerShell",

  "C_Cpp.default.compilerPath": "D:/App/mingw64/bin/g++.exe",
  "C_Cpp.default.cppStandard": "c++17",
  "C_Cpp.default.cStandard": "c17",
  "C_Cpp.default.intelliSenseMode": "windows-gcc-x64",

  "cmake.generator": "MinGW Makefiles",
  "cmake.configureOnOpen": true,

  "files.associations": {
    "*.h": "c"
  }
}
```

几点说明：

- `files.encoding` 设 `utf8`，避免中文注释乱码；
- `renderWhitespace: boundary` 能看出 Tab 和空格的区别（写 Makefile 时救命）；
- `C_Cpp.default.compilerPath` 换成你本机 g++ 的实际路径；
- 只想对某个项目生效，就把这些写进项目里的 `.vscode/settings.json`。

## 8. 项目级推荐（团队/多机）

在项目里建 `.vscode/extensions.json`，别人打开项目会收到"是否安装推荐扩展"的提示：

```json
{
  "recommendations": [
    "ms-vscode.cpptools",
    "ms-vscode.cmake-tools",
    "redhat.vscode-yaml",
    "editorconfig.editorconfig"
  ]
}
```

## 9. 注意事项

| 问题 | 说明 |
|---|---|
| 装太多变卡 | 扩展跑在独立进程，但大工程里 IntelliSense 仍然吃内存；不用的禁掉 |
| clangd 和 C/C++ 打架 | 两个都提供 C++ 语言服务，选一个；同时开会出现重复补全、跳转错乱 |
| 扩展更新后行为变化 | 关键工程可以锁扩展版本（扩展页右键 → "Install Another Version"） |
| 公司网络装不上 | 扩展市场走 HTTPS；可配置代理 `http.proxy`，或离线 VSIX 安装 |
| 中文乱码 | 设置 `files.encoding: utf8`，并确认文件本身是 UTF-8 |
