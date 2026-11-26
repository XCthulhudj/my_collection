# 定义清理函数
function Clean-Dir($dir) {

    # 判断目录是否存在
    if (Test-Path $dir) {

        # 删除目录
        Remove-Item $dir -Recurse -Force

        Write-Host "Deleted: $dir"
    }
    else {
        Write-Host "Not Found: $dir"
    }
}

# 定义需要清理的目录
$dirs = @("build", "bin")

# 遍历并清理
foreach ($dir in $dirs) {
    Clean-Dir $dir
}

Write-Host "Clean completed!"
