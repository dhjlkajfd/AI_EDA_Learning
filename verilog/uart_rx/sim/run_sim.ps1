$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

iverilog -g2005 -o uart_rx_sim ../src/uart_rx.v ../tb/tb_uart_rx.v
vvp ./uart_rx_sim
