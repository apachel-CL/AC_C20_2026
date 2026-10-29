<#
.SYNOPSIS
    Valida la estructura de las salidas del flujo de análisis de evidencias (funcionalidad 001).

.DESCRIPTION
    Solo lee archivos locales: no usa la red, no ejecuta procesos y no modifica archivos
    (constitución, principio IV; FR-012). Contrato: specs/001-analisis-evidencias/contracts/test-salidas.md

    Cada comprobación (C1…C14) es una función registrada en $script:Comprobaciones y recibe el
    contexto con los archivos ya leídos. Errores: C1–C10. Avisos: C11–C14.

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

# --- Enumerados (data-model.md y contracts/) ---

$script:Clasificaciones = @('hallazgo', 'contexto', 'insuficiente', 'fuera-de-alcance')
$script:Atributos = @('hostname', 'interfaz', 'mac', 'ipv4', 'mascara', 'broadcast', 'ipv6', 'usuario', 'so', 'otro')
$script:Etiquetas = @('[HECHO]', '[INFERENCIA]')
$script:Severidades = @('Crítica', 'Alta', 'Media', 'Baja', 'Informativa')
$script:Certezas = @('Alta', 'Media', 'Baja')
$script:Prioridades = @('P0', 'P1', 'P2', 'P3')
$script:Estados = @('pendiente', 'aprobado', 'corregido', 'descartado')
$script:PrioridadPorSeveridad = @{ 'Crítica' = 'P0'; 'Alta' = 'P1'; 'Media' = 'P2'; 'Baja' = 'P3'; 'Informativa' = 'P3' }
$script:ActivoEnAlcance = '192.168.56.101'
$script:MetadatosHallazgo = @('ID', 'Evidencias', 'Severidad', 'Control ISO', 'Certeza ISO')
$script:MetadatosRecomendacion = @('Acción', 'Prioridad', 'Responsable sugerido', 'Criterio de cierre')
$script:MetadatosRevision = @('Estado', 'Revisor', 'Fecha')

# -cin / -ceq: los enumerados distinguen mayúsculas.
function Test-Enum([string]$Valor, [string[]]$Permitidos) { $Permitidos -ccontains $Valor }

function Test-Vacio([string]$Valor) { [string]::IsNullOrWhiteSpace($Valor) -or $Valor -eq '—' }

function Get-Meta($Hallazgo, [string]$Clave) {
    if ($Hallazgo.Meta.Contains($Clave)) { $Hallazgo.Meta[$Clave] } else { $null }
}

function Get-IdsEvidencia([string]$Lista) {
    @($Lista -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

# Texto del título "# H-NNN — enunciado" después de la raya.
function Get-Enunciado([string]$Texto) {
    foreach ($linea in ($Texto -split "`r?`n")) {
        if ($linea -match '^# (H-\d{3}) — (.+)$') { return $Matches[2].Trim() }
    }
    $null
}

# Índice ID → fila del inventario de evidencias (la primera aparición, si hay duplicados).
function Get-IndiceEvidencias($Ctx) {
    $indice = @{}
    foreach ($ev in @(if ($null -ne $Ctx.Evidencias) { $Ctx.Evidencias })) {
        if (-not $indice.ContainsKey($ev.ID)) { $indice[$ev.ID] = $ev }
    }
    $indice
}

# Ejecuta una comprobación y escribe [OK] si no agregó errores.
function Invoke-Comprobacion([string]$Id, [string]$Descripcion, [scriptblock]$Cuerpo, $Ctx) {
    $antes = $script:Errores
    & $Cuerpo $Ctx
    if ($script:Errores -eq $antes) { Write-Ok $Id $Descripcion }
}

# --- Registro de comprobaciones (C1…C14) ---

$script:Comprobaciones = @()

# C1 — IDs EV-NNN únicos y con formato válido (FR-001).
$script:Comprobaciones += {
    param($c)
    Invoke-Comprobacion 'C1' 'IDs de evidencia únicos y con formato EV-NNN' {
        param($c)
        $archivo = Join-Path $c.Ruta 'inventario_evidencias.md'
        if ($null -eq $c.Evidencias) {
            if (Test-Path -LiteralPath $archivo) {
                Write-Fallo 'C1' "inventario_evidencias.md no contiene la tabla con el encabezado del contrato."
            }
            elseif ($c.ArchivosEvidencia.Count -gt 0) {
                Write-Fallo 'C1' "Hay evidencias pero no existe inventario_evidencias.md."
            }
            else {
                Write-Output '         No hay evidencias ni inventario: no se generan hallazgos ni recomendaciones.'
            }
            return
        }
        if ($c.Evidencias.Count -eq 0) {
            Write-Output '         No hay evidencias inventariadas: no se generan hallazgos ni recomendaciones.'
        }
        $vistos = @{}
        foreach ($ev in $c.Evidencias) {
            if ($ev.ID -cnotmatch '^EV-\d{3}$') {
                Write-Fallo 'C1' ("ID '{0}' con formato inválido (línea {1})." -f $ev.ID, $ev._Linea)
            }
            elseif ($vistos.ContainsKey($ev.ID)) {
                Write-Fallo 'C1' ("ID '{0}' duplicado (líneas {1} y {2})." -f $ev.ID, $vistos[$ev.ID], $ev._Linea)
            }
            else { $vistos[$ev.ID] = $ev._Linea }
        }
    } $c
}

# C2 — Archivos de evidencias con nombre EV-NNN_*.* e inventariados; sin prefijos repetidos (FR-001, SC-001).
$script:Comprobaciones += {
    param($c)
    if (-not $c.HayEvidencias) { return }  # ya avisado en C0
    Invoke-Comprobacion 'C2' 'Archivos de evidencias con nombre válido, sin conflictos e inventariados' {
        param($c)
        $inventariados = @{}
        foreach ($ev in @(if ($null -ne $c.Evidencias) { $c.Evidencias })) { $inventariados[$ev.Archivo] = $ev.ID }
        $porPrefijo = @{}
        foreach ($f in $c.ArchivosEvidencia) {
            if ($f.Name -cnotmatch '^(EV-\d{3})_.+\..+$') {
                Write-Fallo 'C2' ("'{0}' no sigue el formato EV-NNN_<comando-o-tema>.<ext>; propón el renombre al auditor." -f $f.Name)
                continue
            }
            $prefijo = $Matches[1]
            if (-not $porPrefijo.ContainsKey($prefijo)) { $porPrefijo[$prefijo] = @() }
            $porPrefijo[$prefijo] += $f.Name
            if (-not $inventariados.ContainsKey($f.Name)) {
                Write-Fallo 'C2' ("'{0}' no está en inventario_evidencias.md." -f $f.Name)
            }
            elseif ($inventariados[$f.Name] -cne $prefijo) {
                Write-Fallo 'C2' ("'{0}' está inventariado con el ID '{1}', distinto de su prefijo." -f $f.Name, $inventariados[$f.Name])
            }
        }
        foreach ($p in $porPrefijo.Keys) {
            if ($porPrefijo[$p].Count -gt 1) {
                Write-Fallo 'C2' ("Conflicto: varios archivos con el prefijo {0} ({1}); no se analizan hasta que el auditor lo resuelva." -f $p, ($porPrefijo[$p] -join ', '))
            }
        }
    } $c
}

# C3 — Clasificación válida; Debilidad / Falta presente cuando corresponde (FR-004, FR-006).
$script:Comprobaciones += {
    param($c)
    if ($null -eq $c.Evidencias) { return }
    Invoke-Comprobacion 'C3' 'Clasificaciones válidas y Debilidad / Falta presente cuando corresponde' {
        param($c)
        foreach ($ev in $c.Evidencias) {
            if (-not (Test-Enum $ev.Clasificación $script:Clasificaciones)) {
                Write-Fallo 'C3' ("{0}: clasificación '{1}' inválida." -f $ev.ID, $ev.Clasificación)
            }
            elseif ($ev.Clasificación -in @('hallazgo', 'insuficiente') -and (Test-Vacio $ev.'Debilidad / Falta')) {
                Write-Fallo 'C3' ("{0}: clasificada '{1}' sin Debilidad / Falta." -f $ev.ID, $ev.Clasificación)
            }
        }
    } $c
}

# C4 — evidencia_insuficiente.md coincide 1:1 con las insuficientes del inventario (FR-006, FR-017, SC-004).
$script:Comprobaciones += {
    param($c)
    if ($null -eq $c.Evidencias) { return }
    Invoke-Comprobacion 'C4' 'Registro de evidencia insuficiente coherente con el inventario' {
        param($c)
        $indice = Get-IndiceEvidencias $c
        $esperadas = @($c.Evidencias | Where-Object { $_.Clasificación -ceq 'insuficiente' } | ForEach-Object { $_.ID })
        if ($null -eq $c.Insuficientes) {
            Write-Fallo 'C4' 'No existe evidencia_insuficiente.md o no contiene la tabla del contrato.'
            return
        }
        $registradas = @($c.Insuficientes | ForEach-Object { $_.ID })
        foreach ($id in $esperadas) {
            if ($registradas -cnotcontains $id) { Write-Fallo 'C4' ("{0} es insuficiente pero no está en evidencia_insuficiente.md." -f $id) }
        }
        foreach ($fila in $c.Insuficientes) {
            if ($esperadas -cnotcontains $fila.ID) {
                Write-Fallo 'C4' ("{0} está en evidencia_insuficiente.md pero no está clasificada insuficiente en el inventario." -f $fila.ID)
            }
            if (Test-Vacio $fila.'Qué falta') { Write-Fallo 'C4' ("{0}: 'Qué falta' vacío." -f $fila.ID) }
            $r = $fila.'Reemplazada por'
            if ($r -cne '—' -and -not $indice.ContainsKey($r)) {
                Write-Fallo 'C4' ("{0}: 'Reemplazada por' = '{1}' no es '—' ni una evidencia inventariada." -f $fila.ID, $r)
            }
        }
    } $c
}

# C5 — Fuente de cada activo existe en el inventario; atributo y etiqueta válidos (FR-005).
$script:Comprobaciones += {
    param($c)
    if ($null -eq $c.Evidencias) { return }
    Invoke-Comprobacion 'C5' 'Activos con fuente existente, atributo y etiqueta válidos' {
        param($c)
        if ($null -eq $c.Activos) {
            Write-Fallo 'C5' 'No existe inventario_activos.md o no contiene la tabla del contrato.'
            return
        }
        $indice = Get-IndiceEvidencias $c
        foreach ($a in $c.Activos) {
            if (-not $indice.ContainsKey($a.Fuente)) {
                Write-Fallo 'C5' ("Línea {0}: la fuente '{1}' no está en el inventario de evidencias." -f $a._Linea, $a.Fuente)
            }
            if (-not (Test-Enum $a.Atributo $script:Atributos)) {
                Write-Fallo 'C5' ("Línea {0}: atributo '{1}' inválido." -f $a._Linea, $a.Atributo)
            }
            if (-not (Test-Enum $a.Etiqueta $script:Etiquetas)) {
                Write-Fallo 'C5' ("Línea {0}: etiqueta '{1}' inválida." -f $a._Linea, $a.Etiqueta)
            }
        }
    } $c
}

# C6 — H-NNN.md: nombre = ID, metadatos y enumerados válidos, Recomendación completa (FR-007–FR-009).
$script:Comprobaciones += {
    param($c)
    if ($c.Hallazgos.Count -eq 0) { return }
    Invoke-Comprobacion 'C6' 'Hallazgos con nombre, metadatos y recomendación válidos' {
        param($c)
        foreach ($h in $c.Hallazgos) {
            $n = $h.Archivo
            if ($n -cnotmatch '^(H-\d{3})\.md$') { Write-Fallo 'C6' ("{0}: el nombre no sigue el formato H-NNN.md." -f $n); continue }
            $idArchivo = $Matches[1]
            foreach ($clave in ($script:MetadatosHallazgo + $script:MetadatosRecomendacion)) {
                if (Test-Vacio (Get-Meta $h $clave)) { Write-Fallo 'C6' ("{0}: falta '{1}' o está vacío." -f $n, $clave) }
            }
            $id = Get-Meta $h 'ID'
            if ($null -ne $id -and $id -cne $idArchivo) { Write-Fallo 'C6' ("{0}: el ID declarado '{1}' no coincide con el nombre." -f $n, $id) }
            if ($null -eq (Get-Enunciado $h.Texto)) { Write-Fallo 'C6' ("{0}: falta el título '# {1} — <enunciado>'." -f $n, $idArchivo) }
            $sev = Get-Meta $h 'Severidad'
            if ($null -ne $sev -and -not (Test-Enum $sev $script:Severidades)) { Write-Fallo 'C6' ("{0}: severidad '{1}' inválida." -f $n, $sev) }
            $ctrl = Get-Meta $h 'Control ISO'
            if ($null -ne $ctrl -and $ctrl -cnotmatch '^(A\.\d{1,2}\.\d{1,2}|verificar)$') { Write-Fallo 'C6' ("{0}: control ISO '{1}' inválido." -f $n, $ctrl) }
            $cert = Get-Meta $h 'Certeza ISO'
            if ($null -ne $cert -and -not (Test-Enum $cert $script:Certezas)) { Write-Fallo 'C6' ("{0}: certeza ISO '{1}' inválida." -f $n, $cert) }
            $prio = Get-Meta $h 'Prioridad'
            if (-not (Test-Vacio $prio) -and -not (Test-Enum $prio $script:Prioridades)) { Write-Fallo 'C6' ("{0}: prioridad '{1}' inválida." -f $n, $prio) }
        }
    } $c
}

# C7 — Evidencias citadas existen, al menos una es hallazgo y ninguna es fuera-de-alcance (SC-002, FR-015).
$script:Comprobaciones += {
    param($c)
    if ($c.Hallazgos.Count -eq 0) { return }
    Invoke-Comprobacion 'C7' 'Hallazgos sustentados en evidencias de hallazgo existentes' {
        param($c)
        $indice = Get-IndiceEvidencias $c
        foreach ($h in $c.Hallazgos) {
            $ids = @(Get-IdsEvidencia (Get-Meta $h 'Evidencias'))
            if ($ids.Count -eq 0) { continue }  # ya informado en C6
            $hayHallazgo = $false
            foreach ($id in $ids) {
                if (-not $indice.ContainsKey($id)) { Write-Fallo 'C7' ("{0}: cita '{1}', que no está en el inventario." -f $h.Archivo, $id); continue }
                switch -CaseSensitive ($indice[$id].Clasificación) {
                    'hallazgo' { $hayHallazgo = $true }
                    'fuera-de-alcance' { Write-Fallo 'C7' ("{0}: cita '{1}', clasificada fuera-de-alcance." -f $h.Archivo, $id) }
                }
            }
            if (-not $hayHallazgo) { Write-Fallo 'C7' ("{0}: ninguna evidencia citada está clasificada 'hallazgo'." -f $h.Archivo) }
        }
    } $c
}

# C8 — Encabezado exacto de la matriz (11 primeras columnas), UTF-8 sin BOM (FR-010). C12 — columnas adicionales.
$script:MatrizLegible = $false
$script:Comprobaciones += {
    param($c)
    $path = Join-Path $c.Ruta 'matriz_hallazgos.csv'
    if ($null -eq $c.TextoMatriz) {
        if ($c.Hallazgos.Count -gt 0) { Write-Fallo 'C8' 'Hay hallazgos pero no existe matriz_hallazgos.csv.' }
        return
    }
    Invoke-Comprobacion 'C8' 'Encabezado de la matriz conforme al contrato' {
        param($c)
        $bytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $path).ProviderPath)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-Fallo 'C8' 'matriz_hallazgos.csv tiene BOM; debe ser UTF-8 sin BOM.'
        }
        $primera = ($c.TextoMatriz -split "`r?`n")[0]
        $columnas = @($primera -split ',' | ForEach-Object { $_.Trim().Trim('"') })
        $n = $script:ColumnasMatriz.Count
        $inicio = @($columnas | Select-Object -First $n)
        if (($inicio -join ',') -cne ($script:ColumnasMatriz -join ',')) {
            Write-Fallo 'C8' ("Encabezado inválido: '{0}'. Esperado: '{1}'." -f $primera, ($script:ColumnasMatriz -join ','))
            return
        }
        $script:MatrizLegible = $true
        if ($columnas.Count -gt $n) {
            Write-Aviso 'C12' ("La matriz tiene columnas adicionales: {0}." -f (($columnas | Select-Object -Skip $n) -join ', '))
        }
    } $c
}

# C9 — Correspondencia 1:1 entre filas y archivos H-NNN.md, con columnas coincidentes (FR-010).
$script:Comprobaciones += {
    param($c)
    if (-not $script:MatrizLegible) { return }
    Invoke-Comprobacion 'C9' 'Matriz coherente 1:1 con los archivos de hallazgos' {
        param($c)
        $filas = @($c.TextoMatriz | ConvertFrom-Csv)
        $porId = @{}
        foreach ($h in $c.Hallazgos) { $porId[$h.Archivo -replace '\.md$', ''] = $h }
        $vistas = @{}
        foreach ($f in $filas) {
            $id = $f.id_hallazgo
            if ($vistas.ContainsKey($id)) { Write-Fallo 'C9' ("Fila duplicada para '{0}'." -f $id); continue }
            $vistas[$id] = $true
            if (-not $porId.ContainsKey($id)) { Write-Fallo 'C9' ("Fila '{0}' sin archivo hallazgos/{0}.md." -f $id); continue }
            $h = $porId[$id]
            $esperado = [ordered]@{
                enunciado            = Get-Enunciado $h.Texto
                evidencias           = (Get-IdsEvidencia (Get-Meta $h 'Evidencias')) -join ';'
                severidad            = Get-Meta $h 'Severidad'
                control_iso          = Get-Meta $h 'Control ISO'
                certeza_iso          = Get-Meta $h 'Certeza ISO'
                recomendacion        = Get-Meta $h 'Acción'
                prioridad            = Get-Meta $h 'Prioridad'
                responsable_sugerido = Get-Meta $h 'Responsable sugerido'
                criterio_cierre      = Get-Meta $h 'Criterio de cierre'
            }
            foreach ($col in $esperado.Keys) {
                if ([string]$f.$col -cne [string]$esperado[$col]) {
                    Write-Fallo 'C9' ("{0}: la columna '{1}' ('{2}') no coincide con el archivo ('{3}')." -f $id, $col, $f.$col, $esperado[$col])
                }
            }
        }
        foreach ($id in $porId.Keys) {
            if (-not $vistas.ContainsKey($id)) { Write-Fallo 'C9' ("hallazgos/{0}.md no tiene fila en la matriz." -f $id) }
        }
    } $c
}

# C10 — Bloque Revisión: estado válido, revisor y fecha si no es pendiente, matriz alineada (FR-014, SC-008).
$script:Comprobaciones += {
    param($c)
    if ($c.Hallazgos.Count -eq 0) { return }
    Invoke-Comprobacion 'C10' 'Bloque Revisión completo y alineado con la matriz' {
        param($c)
        $estadoMatriz = @{}
        if ($script:MatrizLegible) {
            foreach ($f in @($c.TextoMatriz | ConvertFrom-Csv)) { $estadoMatriz[$f.id_hallazgo] = $f.estado_revision }
        }
        foreach ($h in $c.Hallazgos) {
            $n = $h.Archivo
            foreach ($clave in $script:MetadatosRevision) {
                if (-not $h.Meta.Contains($clave)) { Write-Fallo 'C10' ("{0}: falta la línea '{1}' del bloque Revisión." -f $n, $clave) }
            }
            $estado = Get-Meta $h 'Estado'
            if ($null -eq $estado) { continue }
            if (-not (Test-Enum $estado $script:Estados)) { Write-Fallo 'C10' ("{0}: estado '{1}' inválido." -f $n, $estado); continue }
            if ($estado -cne 'pendiente') {
                if (Test-Vacio (Get-Meta $h 'Revisor')) { Write-Fallo 'C10' ("{0}: estado '{1}' sin revisor." -f $n, $estado) }
                if ((Get-Meta $h 'Fecha') -notmatch '^\d{4}-\d{2}-\d{2}$') { Write-Fallo 'C10' ("{0}: estado '{1}' sin fecha AAAA-MM-DD." -f $n, $estado) }
            }
            $id = $n -replace '\.md$', ''
            if ($estadoMatriz.ContainsKey($id) -and $estadoMatriz[$id] -cne $estado) {
                Write-Fallo 'C10' ("{0}: estado_revision de la matriz ('{1}') distinto del bloque Revisión ('{2}')." -f $id, $estadoMatriz[$id], $estado)
            }
        }
    } $c
}

# C11 — Patrones de secretos en claro en las salidas (FR-013, SC-006). Heurística: solo avisa.
$script:PatronesSecreto = @(
    @{ Nombre = 'password=';            Regex = '(?i)password=' },
    @{ Nombre = 'pass:';                Regex = '(?i)\bpass:' },
    @{ Nombre = '$1$ (hash MD5-crypt)'; Regex = '\$1\$' },
    @{ Nombre = '$6$ (hash SHA-512-crypt)'; Regex = '\$6\$' },
    @{ Nombre = 'clave privada';        Regex = 'BEGIN [A-Z ]*PRIVATE KEY' },
    @{ Nombre = 'hash hexadecimal';     Regex = '(?i)hash\W{1,20}[0-9a-f]{32,}' }
)
$script:Comprobaciones += {
    param($c)
    $antes = $script:Avisos
    foreach ($f in @(Get-ChildItem -LiteralPath $c.Ruta -File -Recurse | Where-Object { $_.Extension -in @('.md', '.csv', '.txt') })) {
        $lineas = (Read-Utf8 $f.FullName) -split "`r?`n"
        for ($i = 0; $i -lt $lineas.Count; $i++) {
            foreach ($p in $script:PatronesSecreto) {
                if ($lineas[$i] -match $p.Regex) {
                    Write-Aviso 'C11' ("{0}:{1}: posible secreto en claro ({2}); enmascarar o justificar el falso positivo en el PR." -f $f.Name, ($i + 1), $p.Nombre)
                }
            }
        }
    }
    if ($script:Avisos -eq $antes) { Write-Ok 'C11' 'Sin patrones de secretos en claro' }
}

# C13 — Prioridad distinta de la derivada de la severidad (FR-009). C14 — comandos fuera del activo en alcance (FR-012).
$script:Comprobaciones += {
    param($c)
    foreach ($h in $c.Hallazgos) {
        $sev = Get-Meta $h 'Severidad'
        $prio = Get-Meta $h 'Prioridad'
        if ($null -ne $sev -and $script:PrioridadPorSeveridad.ContainsKey($sev) -and -not (Test-Vacio $prio) -and
            $prio -cne $script:PrioridadPorSeveridad[$sev]) {
            Write-Aviso 'C13' ("{0}: prioridad {1} distinta de la derivada de la severidad {2} ({3}); confirmar el ajuste del auditor." -f $h.Archivo, $prio, $sev, $script:PrioridadPorSeveridad[$sev])
        }
        $cmd = Get-Meta $h 'Comandos propuestos'
        if ($null -ne $cmd) {
            foreach ($m in [regex]::Matches($cmd, '\b\d{1,3}(\.\d{1,3}){3}\b')) {
                if ($m.Value -ne $script:ActivoEnAlcance) {
                    Write-Aviso 'C14' ("{0}: 'Comandos propuestos' menciona {1}, fuera del activo en alcance ({2})." -f $h.Archivo, $m.Value, $script:ActivoEnAlcance)
                }
            }
        }
    }
}

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
