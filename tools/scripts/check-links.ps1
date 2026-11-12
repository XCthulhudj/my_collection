<#
.SYNOPSIS
    检查 Markdown 中的本地相对链接是否指向真实存在的文件。

.DESCRIPTION
    递归扫描仓库内的 *.md，提取 [文字](目标) 形式的链接，跳过 http(s)、mailto、
    纯锚点（#开头）等外部或页面内链接，只校验相对路径。
    目录链接（指向文件夹）也会检查该目录是否存在。

.PARAMETER Root
    扫描根目录，默认为脚本所在仓库根目录（tools/scripts 的上两级）。

.PARAMETER Quiet
    只输出问题项，正常时不打印逐条结果。

.EXAMPLE
    .\check-links.ps1
#>
[CmdletBinding()]
param(
    [string]$Root,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

if (-not $Root) {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}
$Root = (Resolve-Path -LiteralPath $Root).Path

$files = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.md |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' -and $_.FullName -notmatch '[\\/]node_modules[\\/]' }

# 只匹配 [文字](目标)，并排除图片 ![...]
$pattern = '(?<!!)\[[^\]]*\]\((?<target>[^)\s]+)(?:\s+"[^"]*")?\)'

$problem = 0
$checked = 0

foreach ($file in $files) {
    $text = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $dir = $file.DirectoryName

    foreach ($m in [regex]::Matches($text, $pattern)) {
        $target = $m.Groups['target'].Value

        # 跳过外部链接、邮件、页面锚点
        if ($target -match '^(https?:|mailto:|tel:|#)') { continue }

        # 去掉锚点与查询串，处理 URL 编码的中文和空格
        $path = ($target -split '[#?]')[0]
        if (-not $path) { continue }
        $path = [uri]::UnescapeDataString($path)

        $full = if ([System.IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $dir $path }
        $checked++

        if (-not (Test-Path -LiteralPath $full)) {
            $problem++
            $rel = $file.FullName.Replace($Root + [System.IO.Path]::DirectorySeparatorChar, '')
            Write-Host "缺失: $rel -> $target" -ForegroundColor Red
        }
        elseif (-not $Quiet) {
            $rel = $file.FullName.Replace($Root + [System.IO.Path]::DirectorySeparatorChar, '')
            Write-Host "OK  : $rel -> $target"
        }
    }
}

Write-Host ""
Write-Host "共检查 $($files.Count) 个文件、$checked 个本地链接，问题 $problem 个。"
if ($problem -gt 0) { exit 1 }
