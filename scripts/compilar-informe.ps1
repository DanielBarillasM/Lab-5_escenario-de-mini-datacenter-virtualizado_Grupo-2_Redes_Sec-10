$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$reportDir = Join-Path $repoRoot 'informe'
$outputDir = Join-Path $reportDir 'output'

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Push-Location $reportDir
try {
    & latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
    if ($LASTEXITCODE -ne 0) { throw "latexmk terminó con código $LASTEXITCODE" }
    Copy-Item -LiteralPath (Join-Path $reportDir 'main.pdf') -Destination (Join-Path $outputDir 'informe-lab5.pdf') -Force
    Write-Host 'Informe compilado en informe/output/informe-lab5.pdf' -ForegroundColor Green
}
finally {
    Pop-Location
}
