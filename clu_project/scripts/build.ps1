param([string]$QuartusRoot = 'C:\altera_lite\25.1std')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$quartus = Join-Path $QuartusRoot 'quartus\bin64\quartus_sh.exe'
if (!(Test-Path -LiteralPath $quartus)) { throw "Cannot find Quartus: $quartus. Pass -QuartusRoot with your install folder." }
Push-Location $projectRoot
try {
    & $quartus --flow compile clu_project
    if ($LASTEXITCODE -ne 0) { throw 'Compilation failed. Read output_files\clu_project.flow.rpt and the Quartus messages.' }
    Write-Host "Built: $projectRoot\output_files\clu_project.sof"
} finally { Pop-Location }
