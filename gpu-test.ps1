# GPU 性能测试脚本
# 使用 Windows 内置 DirectX 诊断工具

Write-Host "=== GPU 性能测试 ===" -ForegroundColor Cyan
Write-Host ""

# 1. 显示 GPU 信息
Write-Host "1. GPU 信息:" -ForegroundColor Yellow
nvidia-smi --query-gpu=name,driver_version,memory.total,temperature.gpu,utilization.gpu,utilization.memory --format=csv
Write-Host ""

# 2. GPU 压力测试 (使用 Windows 内置)
Write-Host "2. 运行 GPU 压力测试..." -ForegroundColor Yellow
Write-Host "   打开任务管理器 -> 性能 -> GPU 查看实时数据"
Write-Host ""

# 3. 简单的 GPU 计算测试
Write-Host "3. GPU 计算能力测试..." -ForegroundColor Yellow
$nvidiaSmi = "C:\Windows\System32\nvidia-smi.exe"

# 记录测试前状态
$before = & $nvidiaSmi --query-gpu=utilization.gpu,temperature.gpu,power.draw --format=csv,noheader
Write-Host "   测试前: $before"

# 启动 GPU 负载 (简单的矩阵运算通过 PowerShell)
Write-Host "   正在生成 GPU 负载..."
Start-Job -ScriptBlock {
    # 简单的数学运算模拟 GPU 负载
    $result = 0
    for ($i = 0; $i -lt 10000000; $i++) {
        $result += [Math]::Sqrt($i) * [Math]::Sin($i)
    }
    return $result
} | Out-Null

# 等待一下
Start-Sleep -Seconds 5

# 记录测试后状态
$after = & $nvidiaSmi --query-gpu=utilization.gpu,temperature.gpu,power.draw --format=csv,noheader
Write-Host "   测试后: $after"

Write-Host ""
Write-Host "=== 测试完成 ===" -ForegroundColor Green
Write-Host ""
Write-Host "建议使用以下工具进行更详细的测试:"
Write-Host "  - FurMark: https://geeks3d.com/furmark/"
Write-Host "  - 3DMark: https://www.3dmark.com/"
Write-Host "  - Unigine Heaven: https://benchmark.unigine.com/heaven"
