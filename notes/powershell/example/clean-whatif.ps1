# 加一个 -WhatIf 开关，先看要删什么，不动手
param([switch]$WhatIf)

function Clean-Dir($dir) {
    if (Test-Path $dir) {
        if ($WhatIf) {
            Write-Host "Would delete: $dir"
        }
        else {
            Remove-Item $dir -Recurse -Force
            Write-Host "Deleted: $dir"
        }
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
