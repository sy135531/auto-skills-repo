# GTX 750 超频脚本
# 注意：超频有风险，请谨慎使用

Write-Host "=== GTX 750 超频配置 ===" -ForegroundColor Cyan
Write-Host ""

# 检查 nvidia-smi
$nvidiaSmi = "C:\Windows\System32\nvidia-smi.exe"
if (-not (Test-Path $nvidiaSmi)) {
    Write-Host "错误: nvidia-smi 未找到" -ForegroundColor Red
    exit 1
}

# 显示当前 GPU 状态
Write-Host "当前 GPU 状态:" -ForegroundColor Yellow
& $nvidiaSmi
Write-Host ""

# GTX 750 超频建议值 (保守超频)
# 核心频率: +50MHz (保守) 到 +150MHz (激进)
# 显存频率: +100MHz (保守) 到 +300MHz (激进)
# 功耗限制: 可提升至 110W (+10%)

Write-Host "=== 超频建议 ===" -ForegroundColor Cyan
Write-Host "GTX 750 保守超频参数:"
Write-Host "  核心频率: +50 MHz"
Write-Host "  显存频率: +100 MHz"
Write-Host "  功耗限制: 110W (默认 100W)"
Write-Host ""
Write-Host "GTX 750 激进超频参数:"
Write-Host "  核心频率: +100 MHz"
Write-Host "  显存频率: +200 MHz"
Write-Host "  功耗限制: 120W"
Write-Host ""

# 设置功耗限制 (需要管理员权限)
Write-Host "尝试设置功耗限制..." -ForegroundColor Yellow
$setPower = Start-Process -FilePath $nvidiaSmi -ArgumentList "-pl 110" -Verb RunAs -PassThru -Wait
Write-Host "功耗限制已设置为 110W"
Write-Host ""

# 提示用户手动设置频率偏移
Write-Host "=== 手动操作步骤 ===" -ForegroundColor Cyan
Write-Host "1. 打开 NVIDIA 控制面板 (右键桌面 -> NVIDIA 控制面板)"
Write-Host "2. 进入 '管理 3D 设置' -> '电源管理模式' -> '最高性能优先'"
Write-Host "3. 使用 MSI Afterburner 或 EVGA Precision 进行频率超频"
Write-Host ""
Write-Host "推荐工具:"
Write-Host "  - MSI Afterburner: https://www.msi.com/Landing/afterburner"
Write-Host "  - EVGA Precision X1: https://www.evga.com/precision/"
Write-Host ""

Write-Host "=== 超频脚本完成 ===" -ForegroundColor Green
