<#
.SYNOPSIS
    Valida la estructura de las salidas del flujo de análisis de evidencias (funcionalidad 001).

.DESCRIPTION
    Solo lee archivos locales: no usa la red, no ejecuta procesos y no modifica archivos
    (constitución, principio IV; FR-012). Contrato: specs/001-analisis-evidencias/contracts/test-salidas.md

    Cada comprobación (C1…C14) es una función registrada en $script:Comprobaciones y recibe el
    contexto con los archivos ya leídos. Las tareas T009–T024 agregan las comprobaciones.

.PARAMETER Ruta
    Carpeta con los inventarios, hallazgos/ y la matriz. Por defecto: salidas

.PARAMETER Evidencias
    Carpeta de evidencias. Si no existe (por ejemplo, en un clon del repositorio público),
    las comprobaciones que la necesitan se omiten con un aviso.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1

.NOTES
    Código de salida: 0 sin errores (los avisos no fallan); 1 con al menos un error.
    Requiere Windows PowerShell 5.1, sin módulos externos.
#>
[CmdletBinding()]
param(
    [string]$Ruta = 'salidas',
    [string]$Evidencias = 'evidencias'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

# --- Encabezados de los contratos (contracts/inventarios.md y contracts/matriz_hallazgos.md) ---

$script:EncabezadoEvidencias  = @('ID', 'Archivo', 'Observación', 'Clasificación', 'Debilidad / Falta')
$script:EncabezadoActivos     = @('Activo', 'Atributo', 'Valor', 'Etiqueta', 'Fuente')
$script:EncabezadoInsuficiente = @('ID', 'Qué falta', 'Cómo obtenerlo (comando propuesto)', 'Reemplazada por')
$script:ColumnasMatriz = @('id_hallazgo', 'enunciado', 'evidencias', 'severidad', 'control_iso',
    'certeza_iso', 'recomendacion', 'prioridad', 'responsable_sugerido', 'criterio_cierre',
    'estado_revision')

# --- Reporte ---

$script:Errores = 0
$script:Avisos = 0

function Write-Ok([string]$Id, [string]$Mensaje) {
    Write-Output ('[OK]     {0,-4} {1}' -f $Id, $Mensaje)
}

function Write-Fallo([string]$Id, [string]$Mensaje) {
    $script:Errores++
    Write-Output ('[ERROR]  {0,-4} {1}' -f $Id, $Mensaje)
}

function Write-Aviso([string]$Id, [string]$Mensaje) {
    $script:Avisos++
    Write-Output ('[AVISO]  {0,-4} {1}' -f $Id, $Mensaje)
}

# --- Lectura y parseo ---

# PowerShell 5.1 asume ANSI si el archivo no tiene BOM; se lee explícitamente como UTF-8 (research R3).
function Read-Utf8([string]$Path) {
    [IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path).ProviderPath, [Text.Encoding]::UTF8)
}

function Split-FilaMarkdown([string]$Linea) {
    $l = $Linea.Trim()
    if ($l.StartsWith('|')) { $l = $l.Substring(1) }
    if ($l.EndsWith('|')) { $l = $l.Substring(0, $l.Length - 1) }
    # Las barras escapadas (\|) forman parte del contenido de la celda.
    $celdas = $l -split '(?<!\\)\|' | ForEach-Object { $_.Trim().Replace('\|', '|') }
    , @($celdas)
}

# Devuelve las filas de la primera tabla cuyo encabezado coincide exactamente con $Encabezado,
# como objetos con una propiedad por columna. Devuelve $null si no encuentra la tabla.
function Get-TablaMarkdown([string]$Texto, [string[]]$Encabezado) {
    $lineas = $Texto -split "`r?`n"
    for ($i = 0; $i -lt $lineas.Count; $i++) {
        if (-not $lineas[$i].TrimStart().StartsWith('|')) { continue }
        $celdas = Split-FilaMarkdown $lineas[$i]
        if (($celdas -join "`t") -ne ($Encabezado -join "`t")) { continue }

        $filas = New-Object System.Collections.Generic.List[object]
        # $i + 1 es la fila separadora |---|---|
        for ($j = $i + 2; $j -lt $lineas.Count; $j++) {
            if (-not $lineas[$j].TrimStart().StartsWith('|')) { break }
            $valores = Split-FilaMarkdown $lineas[$j]
            $fila = [ordered]@{ '_Linea' = $j + 1 }
            for ($k = 0; $k -lt $Encabezado.Count; $k++) {
                $fila[$Encabezado[$k]] = if ($k -lt $valores.Count) { $valores[$k] } else { '' }
            }
            $filas.Add([pscustomobject]$fila)
        }
        return , $filas.ToArray()
    }
    $null
}

# Lee las líneas "- **Clave**: valor" de un hallazgo (contracts/hallazgo.md). Si una clave se
# repite se conserva la primera aparición.
function Get-Metadatos([string]$Texto) {
    $meta = [ordered]@{}
    foreach ($linea in ($Texto -split "`r?`n")) {
        if ($linea -match '^- \*\*(.+?)\*\*: ?(.*)$') {
            $clave = $Matches[1].Trim()
            if (-not $meta.Contains($clave)) { $meta[$clave] = $Matches[2].Trim() }
        }
    }
    $meta
}

# --- Contexto compartido por las comprobaciones ---

function Get-Contexto([string]$RutaSalidas, [string]$RutaEvidencias) {
    $ctx = [ordered]@{
        Ruta             = $RutaSalidas
        RutaEvidencias   = $RutaEvidencias
        HayEvidencias    = Test-Path -LiteralPath $RutaEvidencias -PathType Container
        ArchivosEvidencia = @()
        Evidencias       = $null   # filas de inventario_evidencias.md
        Activos          = $null   # filas de inventario_activos.md
        Insuficientes    = $null   # filas de evidencia_insuficiente.md
        Hallazgos        = @()     # objetos { Archivo, Texto, Meta }
        TextoMatriz      = $null
    }

    if ($ctx.HayEvidencias) {
        $ctx.ArchivosEvidencia = @(Get-ChildItem -LiteralPath $RutaEvidencias -File |
            Where-Object { $_.Name -ne '.gitkeep' })
    }

    $tablas = @(
        @{ Clave = 'Evidencias';    Archivo = 'inventario_evidencias.md';  Encabezado = $script:EncabezadoEvidencias },
        @{ Clave = 'Activos';       Archivo = 'inventario_activos.md';     Encabezado = $script:EncabezadoActivos },
        @{ Clave = 'Insuficientes'; Archivo = 'evidencia_insuficiente.md'; Encabezado = $script:EncabezadoInsuficiente }
    )
    foreach ($t in $tablas) {
        $path = Join-Path $RutaSalidas $t.Archivo
        if (Test-Path -LiteralPath $path) {
            $ctx[$t.Clave] = Get-TablaMarkdown (Read-Utf8 $path) $t.Encabezado
        }
    }

    $dirHallazgos = Join-Path $RutaSalidas 'hallazgos'
    if (Test-Path -LiteralPath $dirHallazgos) {
        $ctx.Hallazgos = @(Get-ChildItem -LiteralPath $dirHallazgos -File -Filter '*.md' | ForEach-Object {
            $texto = Read-Utf8 $_.FullName
            [pscustomobject]@{ Archivo = $_.Name; Texto = $texto; Meta = Get-Metadatos $texto }
        })
    }

    $pathMatriz = Join-Path $RutaSalidas 'matriz_hallazgos.csv'
    if (Test-Path -LiteralPath $pathMatriz) { $ctx.TextoMatriz = Read-Utf8 $pathMatriz }

    [pscustomobject]$ctx
}

# --- Registro de comprobaciones (C1…C14, agregadas por T009–T024) ---

$script:Comprobaciones = @()

# --- Ejecución ---

Write-Output "Validando '$Ruta' (evidencias: '$Evidencias')"

if (-not (Test-Path -LiteralPath $Ruta -PathType Container)) {
    Write-Fallo 'C0' "No existe la carpeta de salidas '$Ruta'."
}
else {
    $contexto = Get-Contexto $Ruta $Evidencias
    if (-not $contexto.HayEvidencias) {
        Write-Aviso 'C0' "No existe la carpeta de evidencias '$Evidencias'; se omiten las comprobaciones que la requieren."
    }
    foreach ($comprobacion in $script:Comprobaciones) { & $comprobacion $contexto }

    $nEvidencias = if ($null -ne $contexto.Evidencias) { $contexto.Evidencias.Count } else { 0 }
    Write-Output ''
    Write-Output ("Resumen: {0} evidencias, {1} hallazgos, {2} comprobaciones registradas" -f `
        $nEvidencias, $contexto.Hallazgos.Count, $script:Comprobaciones.Count)
}

Write-Output ("Resultado: {0} errores, {1} avisos" -f $script:Errores, $script:Avisos)
if ($script:Errores -gt 0) { exit 1 }
exit 0
