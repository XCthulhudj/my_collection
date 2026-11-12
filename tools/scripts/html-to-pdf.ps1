<#
.SYNOPSIS
    用 Chrome/Edge 无头模式把本地 HTML 打印成 PDF。

.DESCRIPTION
    优先使用 Chrome，找不到时回落到 Edge。PDF 的页边距、页眉页脚由 HTML 内的
    @page 规则控制（配合 --no-pdf-header-footer 去掉浏览器自带的页码/网址）。
    中文依赖系统已安装字体（如微软雅黑），HTML 中请指定 font-family。

.PARAMETER InputHtml
    输入的本地 HTML 文件路径（相对或绝对）。

.PARAMETER OutputPdf
    输出的 PDF 文件路径，目录不存在会自动创建。

.PARAMETER Browser
    Auto（默认，先 Chrome 后 Edge）/ Chrome / Edge。

.EXAMPLE
    .\html-to-pdf.ps1 -InputHtml ..\..\docs\demo.html -OutputPdf ..\..\docs\demo.pdf
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputHtml,
    [Parameter(Mandatory = $true)][string]$OutputPdf,
    [ValidateSet('Auto', 'Chrome', 'Edge')][string]$Browser = 'Auto'
)

$ErrorActionPreference = 'Stop'

function Resolve-Browser {
    param([string]$Name)
    $candidates = switch ($Name) {
        'Chrome' {
            @(
                "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
            )
        }
        'Edge' {
            @(
                "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
                "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
            )
        }
    }
    foreach ($p in $candidates) { if (Test-Path -LiteralPath $p) { return $p } }
    return $null
}

# 1. 校验输入
$inFile = (Resolve-Path -LiteralPath $InputHtml).Path
if (-not (Test-Path -LiteralPath $inFile -PathType Leaf)) {
    throw "输入文件不存在：$InputHtml"
}

# 2. 准备输出目录
$outFile = [System.IO.Path]::GetFullPath($OutputPdf)
$outDir = Split-Path -Parent $outFile
if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

# 3. 选择浏览器
$browserList = if ($Browser -eq 'Auto') { @('Chrome', 'Edge') } else { @($Browser) }
$exe = $null
foreach ($b in $browserList) {
    $exe = Resolve-Browser -Name $b
    if ($exe) { break }
}
if (-not $exe) {
    throw "未找到可用的 Chrome/Edge，请确认浏览器已安装。"
}

# 4. 每次转换用独立临时用户目录，避免和已打开的浏览器抢占配置锁
$profileDir = Join-Path $env:TEMP ("html-to-pdf-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null

try {
    $fileUri = ([System.Uri]$inFile).AbsoluteUri
    $args = @(
        '--headless=new',
        '--disable-gpu',
        '--no-first-run',
        '--no-default-browser-check',
        '--no-pdf-header-footer',
        "--user-data-dir=$profileDir",
        "--print-to-pdf=$outFile",
        '--virtual-time-budget=8000',
        $fileUri
    )

    Write-Host "浏览器 : $exe"
    Write-Host "输入   : $inFile"
    Write-Host "输出   : $outFile"

    $proc = Start-Process -FilePath $exe -ArgumentList $args -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -ne 0) {
        throw "浏览器进程退出码 $($proc.ExitCode)"
    }

    # 5. 校验产物
    if (-not (Test-Path -LiteralPath $outFile)) {
        throw "转换失败：未生成 PDF。"
    }
    $size = (Get-Item -LiteralPath $outFile).Length
    if ($size -lt 2KB) {
        throw "生成的 PDF 过小（$size 字节），可能渲染失败。"
    }
    # 统计页数：PDF 对象字典以 ASCII 存放 /Type /Page（PS 5.1 没有 Latin1，用 ASCII 解码足够）
    $pdfText = [System.Text.Encoding]::ASCII.GetString([System.IO.File]::ReadAllBytes($outFile))
    $pages = ([regex]::Matches($pdfText, '/Type\s*/Page[^s]')).Count
    Write-Host ("完成   : {0:N1} KB, 约 {1} 页" -f ($size / 1KB), $pages)
}
finally {
    if (Test-Path -LiteralPath $profileDir) {
        Remove-Item -LiteralPath $profileDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
