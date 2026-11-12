# Git 常用命令速查

[← 返回笔记索引](../README.md)

整理自日常使用中遇到的几个问题：首次推送、分支重命名、提交说明、云端仓库改名后如何处理。

## 文件

| 文件 | 说明 |
|---|---|
| [Git常用命令速查.pdf](Git常用命令速查.pdf) | 成品，A4 两页，适合打印或手机查看 |
| [git-cheatsheet.html](git-cheatsheet.html) | 源文件，改样式或内容后重新生成 PDF |

## 内容结构

1. 主线流程：工作区 → `add` → 暂存区 → `commit` → 本地仓库 → `push` → 远程仓库
2. 常用命令速查表（仓库、提交、分支、远程、回退对比）
3. `-u` / `-m` / `-M` / `commit -m` 参数辨析
4. 两种典型场景：本地项目首次上传、云端改名后改远程地址
5. 提交说明的常见写法

## 重新生成 PDF

在仓库根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File tools\scripts\html-to-pdf.ps1 `
  -InputHtml notes\git\git-cheatsheet.html `
  -OutputPdf "notes\git\Git常用命令速查.pdf"
```

排版说明：PDF 分页由 HTML 里的 `@page` 规则与 `page-break-before` 控制，
第二页固定从「三、三个容易混淆的参数」开始。
