param([string]$QuartusRoot = 'C:\altera_lite\25.1std')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$vsim = Join-Path $QuartusRoot 'questa_fse\win64\vsim.exe'
if (!(Test-Path -LiteralPath $vsim)) { throw "Cannot find Questa: $vsim. Pass -QuartusRoot with your install folder." }
New-Item -ItemType Directory -Path (Join-Path $projectRoot 'evidence') -Force | Out-Null
Push-Location (Join-Path $projectRoot 'sim')
try {
    & $vsim -c -nolog -do 'do run_all.do'
    if ($LASTEXITCODE -ne 0) { throw 'Simulation failed. Read the simulator output above.' }
    Write-Host 'ALL THREE SIMULATIONS PASSED'
} finally { Pop-Location }
