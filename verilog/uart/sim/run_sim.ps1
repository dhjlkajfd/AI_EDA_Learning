# UART TX simulation script for Windows PowerShell

$BuildDir = "build"
$OutputFile = "$BuildDir/uart_tx_tb.vvp"

if (!(Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

Write-Host "Compiling UART TX testbench..."

iverilog -g2005 -Wall -o $OutputFile ../src/uart_tx.v ../tb/tb_uart_tx.v

if ($LASTEXITCODE -ne 0) {
    Write-Host "FAIL: Compilation failed."
    exit 1
}

Write-Host "Running UART TX simulation..."

vvp $OutputFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "FAIL: Simulation failed."
    exit 1
}

Write-Host "PASS: Simulation finished."