# 工具目录（tools）

本目录用于存放本仓库日常使用到的**辅助工具**，例如脚本、配置模板、批处理文件等。
它与仓库主体内容（`README.md` 中的网站导航、`docs/` 中的文档）分开管理，避免工具文件混入内容目录。

## 目录约定

| 路径 | 说明 |
|---|---|
| `tools/scripts/` | 可直接运行的脚本（PowerShell、Python、Node.js、Shell 等） |
| `tools/config/` | 脚本配套的配置样例、模板文件 |
| `tools/README.md` | 本说明文件，新增工具时同步补充下表 |

## 工具清单

| 工具 | 文件 | 用途 | 运行方式 |
|---|---|---|---|
| html-to-pdf | `scripts/html-to-pdf.ps1` | 用 Chrome/Edge 无头模式把 HTML 打印成 PDF，中文正常 | `powershell -ExecutionPolicy Bypass -File tools\scripts\html-to-pdf.ps1 -InputHtml 输入.html -OutputPdf 输出.pdf` |
| pdf-preview | `scripts/pdf-preview.py` | 把 PDF 逐页渲染成 PNG，检查排版/分页 | `python tools\scripts\pdf-preview.py 输入.pdf 输出目录 --dpi 100`（需 `pip install pymupdf`） |
| check-links | `scripts/check-links.ps1` | 校验所有 Markdown 里的本地相对链接是否存在 | `powershell -ExecutionPolicy Bypass -File tools\scripts\check-links.ps1` |

### 环境备注

- 本机 `powershell` 的执行策略为 Restricted，直接运行 `.ps1` 会被拒绝，需加
  `-ExecutionPolicy Bypass`（或在当前会话执行 `Set-ExecutionPolicy -Scope Process Bypass`）。
- Windows PowerShell 5.1 按 ANSI 解析 `.ps1`，含中文的脚本必须保存为 **UTF-8 with BOM**，
  否则会报语法错误；用 VS Code 保存时选择 "UTF-8 with BOM"。
- PDF 排版由 HTML 里的 `@page` 规则控制；分页位置用 `page-break-before` 显式指定。

新增脚本后，请在上面表格中补充一行，注明用途和运行方式。

## 新增工具的要求

1. **命名清晰**：文件名能看出用途，例如 `check-links.ps1`、`gen-index.py`。
2. **自含说明**：脚本开头用注释写明用途、依赖环境和示例用法。
3. **不提交敏感信息**：令牌、密码、内网地址等不要写入本目录，配置使用样例文件（如 `*.example.*`）。
4. **不提交大文件**：生成的临时文件、下载内容、二进制产物请放到临时目录或通过 `.gitignore` 排除。
5. **保持可复现**：依赖的外部工具（如 `git`、`node`、`python`）在说明中写清版本要求。

## 与仓库内容的关系

- 网站导航内容仍然只维护在根目录 [README.md](../README.md)。
- `docs/` 用于文字类文档；工具和脚本统一放在本目录。
