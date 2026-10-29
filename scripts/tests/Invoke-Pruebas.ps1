<#
.SYNOPSIS
    Ejecuta scripts/Test-Salidas.ps1 contra cada fixture de scripts/tests/fixtures/ (research R5).

.DESCRIPTION
    Código esperado según el nombre del fixture: 0 si empieza con "valido" o "aviso-"; 1 si empieza
    con "invalido-". Imprime una tabla fixture/esperado/obtenido y termina con 0 solo si todos
    coinciden. Solo lee archivos locales (constitución, principio IV).

.PARAMETER Detalle
    Muestra la salida completa del validador para cada fixture.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/Invoke-Pruebas.ps1
#>
[CmdletBinding()]
param(
    [switch]$Detalle
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$validador = Join-Path $PSScriptRoot '..\Test-Salidas.ps1'
$dirFixtures = Join-Path $PSScriptRoot 'fixtures'
$resultados = @()

foreach ($f in @(Get-ChildItem -LiteralPath $dirFixtures -Directory | Sort-Object Name)) {
    $esperado = if ($f.Name -like 'invalido-*') { 1 }
                elseif ($f.Name -like 'valido*' -or $f.Name -like 'aviso-*') { 0 }
                else { $null }
    if ($null -eq $esperado) {
        Write-Warning "Fixture '$($f.Name)' sin prefijo reconocido (valido, aviso-, invalido-); se omite."
        continue
    }

    # Se invoca en un proceso aparte porque Test-Salidas.ps1 termina con exit.
    $salida = & powershell -NoProfile -ExecutionPolicy Bypass -File $validador `
        -Ruta (Join-Path $f.FullName 'salidas') -Evidencias (Join-Path $f.FullName 'evidencias')
    $obtenido = $LASTEXITCODE
    if ($Detalle) { Write-Output "--- $($f.Name)"; $salida | Write-Output }

    $resultados += [pscustomobject]@{
        Fixture   = $f.Name
        Esperado  = $esperado
        Obtenido  = $obtenido
        Resultado = if ($obtenido -eq $esperado) { 'OK' } else { 'FALLA' }
        Mensajes  = (@($salida | Where-Object { $_ -match '^\[(ERROR|AVISO)\]' }) | ForEach-Object { $_ -replace '\s+', ' ' }) -join ' | '
    }
}

$resultados | Format-Table Fixture, Esperado, Obtenido, Resultado -AutoSize | Out-String -Width 200 | Write-Output

$fallas = @($resultados | Where-Object { $_.Resultado -ne 'OK' })
foreach ($r in $fallas) { Write-Output ("FALLA {0}: {1}" -f $r.Fixture, $r.Mensajes) }
Write-Output ("{0} fixtures, {1} fallas" -f $resultados.Count, $fallas.Count)
if ($fallas.Count -gt 0 -or $resultados.Count -eq 0) { exit 1 }
exit 0
