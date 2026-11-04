$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

$required = @(
    'README.md',
    'docs/ESTADO_IMPLEMENTACION.md',
    'docs/RUNBOOK_IMPLEMENTACION.md',
    'docs/MATRIZ_EVIDENCIAS.md',
    'configuraciones/lab5.env.example',
    'configuraciones/proxmox/interfaces.vmbr1.example',
    'configuraciones/netplan/50-lab5-web.yaml.example',
    'configuraciones/netplan/50-lab5-db.yaml.example',
    'configuraciones/ssh/99-lab5.conf.example',
    'configuraciones/mysql/99-lab5.cnf.example',
    'configuraciones/apache/lab5-http.conf.example',
    'configuraciones/apache/lab5-https.conf.example',
    'configuraciones/wordpress/wp-config.php.example',
    'scripts/auditar-cliente.sh',
    'scripts/auditar-web.sh',
    'scripts/auditar-db.sh',
    'presentacion/index.html',
    'informe/main.tex'
)

foreach ($relative in $required) {
    $path = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $path)) {
        $failures.Add("Falta: $relative")
    }
}

$forbiddenFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -Force -File |
    Where-Object {
        $_.FullName -notmatch '\\.git\\' -and
        ($_.Extension -in @('.tf', '.tfvars', '.key', '.p12', '.pfx') -or $_.Name -eq '.terraform.lock.hcl')
    }

foreach ($file in $forbiddenFiles) {
    $failures.Add("Archivo prohibido o sensible: $($file.FullName.Substring($repoRoot.Length + 1))")
}

$privateKeyMarker = 'BEGIN ' + 'PRIVATE KEY'
$privateKeyHits = Get-ChildItem -LiteralPath $repoRoot -Recurse -Force -File |
    Where-Object { $_.FullName -notmatch '\\.git\\' } |
    Select-String -SimpleMatch $privateKeyMarker -ErrorAction SilentlyContinue

foreach ($hit in $privateKeyHits) {
    $failures.Add("Posible llave privada: $($hit.Path)")
}

if (Test-Path -LiteralPath (Join-Path $repoRoot 'PLAN_LAB5.md')) {
    $failures.Add('El plan externo fue copiado dentro del repositorio.')
}

if (Get-ChildItem -LiteralPath $repoRoot -File -Filter '*.pdf' | Where-Object Name -Like 'Laboratorio-Servidor*') {
    $failures.Add('El PDF de instrucciones fue copiado dentro del repositorio.')
}

if ($failures.Count -gt 0) {
    Write-Host 'Auditoría fallida:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'Auditoría del repositorio correcta.' -ForegroundColor Green
Write-Host 'No se detectaron archivos Terraform, llaves privadas ni fuentes externas copiadas.'
