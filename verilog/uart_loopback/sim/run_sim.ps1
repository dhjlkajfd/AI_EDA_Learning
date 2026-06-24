$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$Iverilog = Get-Command iverilog -ErrorAction SilentlyContinue
if (-not $Iverilog) {
    Write-Host "FAIL: iverilog not found. Please install Icarus Verilog and add it to PATH."
    exit 1
}

$Vvp = Get-Command vvp -ErrorAction SilentlyContinue
if (-not $Vvp) {
    Write-Host "FAIL: vvp not found. Please install Icarus Verilog and add it to PATH."
    exit 1
}

$BuildDir = Join-Path $ScriptDir "build"
if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

$SimOut = Join-Path $BuildDir "uart_loopback_tb.vvp"

iverilog -g2005 -Wall -o $SimOut `
    ../src/uart_tx.v `
    ../src/uart_rx.v `
    ../src/uart_loopback.v `
    ../tb/tb_uart_loopback.v

if ($LASTEXITCODE -ne 0) {
    Write-Host "FAIL: iverilog compile failed."
    exit 1
}

vvp $SimOut
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAIL: vvp simulation failed."
    exit 1
}

Write-Host "PASS: Simulation finished."
