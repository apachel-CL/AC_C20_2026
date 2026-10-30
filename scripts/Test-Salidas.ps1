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

# Funcionalidad 002 (specs/002-mapeo-normativo/contracts/): columnas 12–18 de la matriz y lista de verificación.
$script:ColumnasLegales = @('controles_iso_adicionales', 'ley_21663_obligacion', 'ley_21663_articulo',
    'ley_21663_certeza', 'ley_21719_obligacion', 'ley_21719_articulo', 'ley_21719_certeza')
$script:EncabezadoVerificacion = @('ID', 'Hallazgo', 'Ley', 'Obligación', 'Artículo', 'Estado', 'Fuente', 'Fecha', 'Comentario')

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
        Hallazgos        = @()     # objetos { Archivo, Texto, Meta, TieneMapeo, Mapeo }
        TextoMatriz      = $null
        Verificaciones   = $null   # filas de verificacion_articulos.md (002)
        ExisteVerificacion = $false
        TextoMapa        = $null   # mapa_normativo.md (002)
        Activo002        = $false  # hay sección de mapeo, lista o mapa: se ejecutan C16–C22
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
            # Texto de la sección "## Mapeo normativo" hasta la siguiente sección de nivel 2 (002).
            $mapeo = if ($texto -match '(?ms)^## Mapeo normativo[ \t]*\r?$(.*?)(?=^## |\z)') { $Matches[1] } else { $null }
            [pscustomobject]@{
                Archivo = $_.Name; Texto = $texto; Meta = Get-Metadatos $texto
                TieneMapeo = $null -ne $mapeo; Mapeo = $mapeo
            }
        })
    }

    $pathMatriz = Join-Path $RutaSalidas 'matriz_hallazgos.csv'
    if (Test-Path -LiteralPath $pathMatriz) { $ctx.TextoMatriz = Read-Utf8 $pathMatriz }

    $pathVerificacion = Join-Path $RutaSalidas 'verificacion_articulos.md'
    if (Test-Path -LiteralPath $pathVerificacion) {
        $ctx.ExisteVerificacion = $true
        $ctx.Verificaciones = Get-TablaMarkdown (Read-Utf8 $pathVerificacion) $script:EncabezadoVerificacion
    }
    $pathMapa = Join-Path $RutaSalidas 'mapa_normativo.md'
    if (Test-Path -LiteralPath $pathMapa) { $ctx.TextoMapa = Read-Utf8 $pathMapa }

    $ctx.Activo002 = $ctx.ExisteVerificacion -or ($null -ne $ctx.TextoMapa) -or
        (@($ctx.Hallazgos | Where-Object { $_.TieneMapeo }).Count -gt 0)

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

# C8 — Encabezado exacto de la matriz (11 primeras columnas), UTF-8 sin BOM (FR-010). C12 — columnas
# adicionales: con la matriz extendida de 002, solo las posteriores a la 18 (las 12–18 las comprueba C15).
$script:MatrizLegible = $false
$script:ColumnasLeidas = @()
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
        $script:ColumnasLeidas = $columnas
        $hasta = if ($columnas.Count -gt $n) { $n + $script:ColumnasLegales.Count } else { $n }
        if ($columnas.Count -gt $hasta) {
            Write-Aviso 'C12' ("La matriz tiene columnas adicionales: {0}." -f (($columnas | Select-Object -Skip $hasta) -join ', '))
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

# --- Funcionalidad 002: mapeo normativo (C15–C22, specs/002-mapeo-normativo/contracts/test-salidas-002.md) ---

$script:Obligaciones21663 = @('gestión de riesgos', 'medidas de seguridad', 'reporte de incidentes', 'no aplica')
$script:EstadosVerificacion = @('pendiente', 'verificado', 'descartado')
$script:LeyendaMapeo = 'no constituye dictamen jurídico'
$script:FraseHipotetica = 'si la organización fuera entidad obligada'
$script:PendienteVigencia = 'pendiente de vigencia'
# Último control de cada tema del Anexo A de ISO/IEC 27001:2022 (research R3).
$script:AnexoA2022 = @{ 5 = 37; 6 = 8; 7 = 14; 8 = 34 }
$script:ClavesMapeo = @('Controles ISO adicionales', 'Control ISO anterior', 'Motivo de corrección', 'Justificación ISO',
    'Ley 21.663 obligación', 'Ley 21.663 artículo', 'Ley 21.663 certeza', 'Ley 21.663 justificación',
    'Ley 21.719 obligación', 'Ley 21.719 artículo', 'Ley 21.719 certeza', 'Ley 21.719 justificación',
    'Ley 21.719 vigencia')
# Columna legal de la matriz → clave del hallazgo (controles_iso_adicionales se trata aparte).
$script:ClavePorColumnaLegal = [ordered]@{
    ley_21663_obligacion = 'Ley 21.663 obligación'; ley_21663_articulo = 'Ley 21.663 artículo'
    ley_21663_certeza    = 'Ley 21.663 certeza';    ley_21719_obligacion = 'Ley 21.719 obligación'
    ley_21719_articulo   = 'Ley 21.719 artículo';   ley_21719_certeza    = 'Ley 21.719 certeza'
}

function Test-ControlAnexoA([string]$Control) {
    if ($Control -cnotmatch '^A\.(\d{1,2})\.(\d{1,2})$') { return $false }
    $tema = [int]$Matches[1]; $num = [int]$Matches[2]
    $script:AnexoA2022.ContainsKey($tema) -and $num -ge 1 -and $num -le $script:AnexoA2022[$tema]
}

# Lista "A; B" o "—" → elementos (vacío si es "—").
function Get-ListaMapeo([string]$Valor) {
    if ([string]::IsNullOrWhiteSpace($Valor) -or $Valor.Trim() -eq '—') { return @() }
    @($Valor -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

function Test-Etiquetada([string]$Texto) { $Texto -match '\[(HECHO|INFERENCIA)\]' }

# Hallazgos con sección de mapeo y no descartados: los únicos que 002 comprueba (FR-001).
function Get-HallazgosMapeados($Ctx) {
    @($Ctx.Hallazgos | Where-Object { $_.TieneMapeo -and (Get-Meta $_ 'Estado') -cne 'descartado' })
}

function Get-FilasVerificacion($Ctx) { @(if ($null -ne $Ctx.Verificaciones) { $Ctx.Verificaciones }) }

function Test-VigenciaVerificada($Ctx) {
    @(Get-FilasVerificacion $Ctx | Where-Object {
        $_.Ley -ceq '21.719' -and $_.Obligación -ceq 'entrada en vigor' -and $_.Estado -ceq 'verificado'
    }).Count -gt 0
}

# Referencias legales esperadas en la lista: "H-NNN|ley" → obligación (research R5).
function Get-ReferenciasEsperadas($Ctx) {
    $ref = [ordered]@{}
    foreach ($h in (Get-HallazgosMapeados $Ctx)) {
        $id = $h.Archivo -replace '\.md$', ''
        $o1 = Get-Meta $h 'Ley 21.663 obligación'
        if (-not (Test-Vacio $o1) -and $o1 -cne 'no aplica') { $ref["$id|21.663"] = $o1 }
        $o2 = Get-Meta $h 'Ley 21.719 obligación'
        if (-not (Test-Vacio $o2) -and $o2 -cne 'no aplica' -and $o2 -cne $script:PendienteVigencia) { $ref["$id|21.719"] = $o2 }
    }
    $ref
}

# C15 — Columnas 12–18 de la matriz exactas, en orden y coherentes con cada hallazgo (FR-011, SC-005).
$script:Comprobaciones += {
    param($c)
    $extendida = $script:MatrizLegible -and $script:ColumnasLeidas.Count -gt $script:ColumnasMatriz.Count
    $mapeados = @(Get-HallazgosMapeados $c)
    if (-not $extendida) {
        if ($script:MatrizLegible -and $mapeados.Count -gt 0) {
            Write-Fallo 'C15' 'Hay hallazgos mapeados pero la matriz no tiene las columnas legales (12–18).'
        }
        return
    }
    Invoke-Comprobacion 'C15' 'Columnas legales de la matriz conformes y coherentes con los hallazgos' {
        param($c)
        $n = $script:ColumnasMatriz.Count
        $legales = @($script:ColumnasLeidas | Select-Object -Skip $n -First $script:ColumnasLegales.Count)
        if (($legales -join ',') -cne ($script:ColumnasLegales -join ',')) {
            Write-Fallo 'C15' ("Columnas 12–18 inválidas: '{0}'. Esperado: '{1}'." -f ($legales -join ','), ($script:ColumnasLegales -join ','))
            return
        }
        $porId = @{}
        foreach ($h in $c.Hallazgos) { $porId[$h.Archivo -replace '\.md$', ''] = $h }
        foreach ($f in @($c.TextoMatriz | ConvertFrom-Csv)) {
            $id = $f.id_hallazgo
            if (-not $porId.ContainsKey($id)) { continue }  # informado en C9
            $h = $porId[$id]
            $mapeado = $h.TieneMapeo -and (Get-Meta $h 'Estado') -cne 'descartado'
            if (-not $mapeado) {
                foreach ($col in $script:ColumnasLegales) {
                    if (-not [string]::IsNullOrEmpty([string]$f.$col)) {
                        Write-Fallo 'C15' ("{0}: sin mapeo o descartado, pero la columna '{1}' no está vacía." -f $id, $col)
                    }
                }
                continue
            }
            $adicionales = @(Get-ListaMapeo (Get-Meta $h 'Controles ISO adicionales'))
            $esperado = [ordered]@{ controles_iso_adicionales = if ($adicionales.Count -eq 0) { '—' } else { $adicionales -join ';' } }
            foreach ($col in $script:ClavePorColumnaLegal.Keys) { $esperado[$col] = Get-Meta $h $script:ClavePorColumnaLegal[$col] }
            foreach ($col in $esperado.Keys) {
                if ([string]$f.$col -cne [string]$esperado[$col]) {
                    Write-Fallo 'C15' ("{0}: la columna '{1}' ('{2}') no coincide con el hallazgo ('{3}')." -f $id, $col, $f.$col, $esperado[$col])
                }
            }
        }
    } $c
}

# C16 — Sección de mapeo: leyenda, claves, enumerados y justificaciones etiquetadas (FR-002, FR-005, FR-007, FR-014).
$script:Comprobaciones += {
    param($c)
    if (-not $c.Activo002 -or @(Get-HallazgosMapeados $c).Count -eq 0) { return }
    Invoke-Comprobacion 'C16' 'Secciones de mapeo completas y con enumerados válidos' {
        param($c)
        foreach ($h in (Get-HallazgosMapeados $c)) {
            $n = $h.Archivo
            if ($h.Mapeo -notmatch [regex]::Escape($script:LeyendaMapeo)) {
                Write-Fallo 'C16' ("{0}: falta la leyenda '{1}'." -f $n, $script:LeyendaMapeo)
            }
            foreach ($clave in $script:ClavesMapeo) {
                if ([string]::IsNullOrWhiteSpace((Get-Meta $h $clave))) { Write-Fallo 'C16' ("{0}: falta '{1}' o está vacío." -f $n, $clave) }
            }
            foreach ($clave in @('Justificación ISO', 'Ley 21.663 justificación', 'Ley 21.719 justificación')) {
                $j = Get-Meta $h $clave
                if (-not (Test-Vacio $j) -and -not (Test-Etiquetada $j)) { Write-Fallo 'C16' ("{0}: '{1}' sin [HECHO] ni [INFERENCIA]." -f $n, $clave) }
            }
            $o1 = Get-Meta $h 'Ley 21.663 obligación'
            if ($null -ne $o1 -and -not (Test-Enum $o1 $script:Obligaciones21663)) { Write-Fallo 'C16' ("{0}: obligación 21.663 '{1}' inválida." -f $n, $o1) }
            foreach ($clave in @('Ley 21.663 certeza', 'Ley 21.719 certeza')) {
                $v = Get-Meta $h $clave
                if (-not [string]::IsNullOrWhiteSpace($v) -and -not (Test-Enum $v $script:Certezas)) { Write-Fallo 'C16' ("{0}: '{1}' = '{2}' inválida." -f $n, $clave, $v) }
            }
            foreach ($ley in @('21.663', '21.719')) {
                $o = Get-Meta $h "Ley $ley obligación"
                $a = Get-Meta $h "Ley $ley artículo"
                if ($null -eq $o -or $null -eq $a) { continue }
                if ($o -ceq 'no aplica' -and $a -cne '—') { Write-Fallo 'C16' ("{0}: Ley {1} 'no aplica' con artículo '{2}' (debe ser '—')." -f $n, $ley, $a) }
                elseif ($o -ceq $script:PendienteVigencia -and $a -cne 'verificar') { Write-Fallo 'C16' ("{0}: Ley {1} '{2}' con artículo '{3}' (debe ser 'verificar')." -f $n, $ley, $o, $a) }
                elseif ($o -cne 'no aplica' -and $a -ceq '—') { Write-Fallo 'C16' ("{0}: Ley {1} con obligación y artículo '—' (usar 'verificar')." -f $n, $ley) }
            }
        }
    } $c
}

# C17 — Controles ISO del Anexo A 2022; adicionales sin repetir el principal; anterior y motivo coherentes (FR-003, FR-004).
$script:Comprobaciones += {
    param($c)
    if (-not $c.Activo002 -or @(Get-HallazgosMapeados $c).Count -eq 0) { return }
    Invoke-Comprobacion 'C17' 'Controles ISO existentes en el Anexo A de ISO/IEC 27001:2022' {
        param($c)
        foreach ($h in (Get-HallazgosMapeados $c)) {
            $n = $h.Archivo
            $principal = Get-Meta $h 'Control ISO'
            if ($null -ne $principal -and $principal -cne 'verificar' -and -not (Test-ControlAnexoA $principal)) {
                Write-Fallo 'C17' ("{0}: el control principal '{1}' no existe en el Anexo A 2022." -f $n, $principal)
            }
            $vistos = @{}
            foreach ($a in (Get-ListaMapeo (Get-Meta $h 'Controles ISO adicionales'))) {
                if (-not (Test-ControlAnexoA $a)) { Write-Fallo 'C17' ("{0}: el control adicional '{1}' no existe en el Anexo A 2022." -f $n, $a) }
                if ($a -ceq $principal) { Write-Fallo 'C17' ("{0}: el control adicional '{1}' repite el principal." -f $n, $a) }
                if ($vistos.ContainsKey($a)) { Write-Fallo 'C17' ("{0}: el control adicional '{1}' está repetido." -f $n, $a) }
                $vistos[$a] = $true
            }
            $anterior = Get-Meta $h 'Control ISO anterior'
            $motivo = Get-Meta $h 'Motivo de corrección'
            if ($null -eq $anterior) { continue }  # informado en C16
            if ($anterior -cne '—' -and $anterior -cne 'verificar' -and $anterior -cnotmatch '^A\.\d{1,2}\.\d{1,2}$') {
                Write-Fallo 'C17' ("{0}: 'Control ISO anterior' = '{1}' no es '—', 'verificar' ni un control." -f $n, $anterior)
            }
            if ($anterior -ceq $principal) { Write-Fallo 'C17' ("{0}: 'Control ISO anterior' igual al principal; si se confirmó, usar '—'." -f $n) }
            if ($anterior -ceq '—' -and $motivo -cne 'confirmado') { Write-Fallo 'C17' ("{0}: control confirmado ('—') con motivo distinto de 'confirmado'." -f $n) }
            if ($anterior -cne '—' -and $motivo -ceq 'confirmado') { Write-Fallo 'C17' ("{0}: control corregido sin motivo de corrección." -f $n) }
        }
    } $c
}

# C18 — Ley 21.663 hipotética con certeza ≤ Media (Q1); Ley 21.719 sin citar antes de verificar su vigencia (FR-006, FR-007).
$script:Comprobaciones += {
    param($c)
    if (-not $c.Activo002 -or @(Get-HallazgosMapeados $c).Count -eq 0) { return }
    Invoke-Comprobacion 'C18' 'Límites de certeza y vigencia de las leyes 21.663 y 21.719' {
        param($c)
        $vigente = Test-VigenciaVerificada $c
        foreach ($h in (Get-HallazgosMapeados $c)) {
            $n = $h.Archivo
            $o1 = Get-Meta $h 'Ley 21.663 obligación'
            if (-not (Test-Vacio $o1) -and $o1 -cne 'no aplica') {
                $cert = Get-Meta $h 'Ley 21.663 certeza'
                if ($cert -ceq 'Alta') { Write-Fallo 'C18' ("{0}: certeza 21.663 'Alta'; el mapeo es hipotético y debe ser ≤ Media (Q1)." -f $n) }
                $j = [string](Get-Meta $h 'Ley 21.663 justificación')
                if ($j.IndexOf($script:FraseHipotetica, [StringComparison]::OrdinalIgnoreCase) -lt 0) {
                    Write-Fallo 'C18' ("{0}: la justificación 21.663 no contiene '{1}' (Q1)." -f $n, $script:FraseHipotetica)
                }
            }
            $o2 = Get-Meta $h 'Ley 21.719 obligación'
            if (-not (Test-Vacio $o2) -and $o2 -cne 'no aplica') {
                if (Test-Vacio (Get-Meta $h 'Ley 21.719 vigencia')) { Write-Fallo 'C18' ("{0}: Ley 21.719 sin advertencia de vigencia." -f $n) }
                if (-not $vigente -and $o2 -cne $script:PendienteVigencia) {
                    Write-Fallo 'C18' ("{0}: cita la Ley 21.719 ('{1}') sin entrada en vigor verificada; usar '{2}' (constitución, principio V)." -f $n, $o2, $script:PendienteVigencia)
                }
            }
        }
    } $c
}

# C19 — Lista de verificación de artículos: estructura, estados, cobertura 1:1 y citación (FR-009, FR-010, SC-003).
$script:Comprobaciones += {
    param($c)
    if (-not $c.Activo002) { return }
    Invoke-Comprobacion 'C19' 'Lista de verificación de artículos coherente y artículos citados solo si están verificados' {
        param($c)
        $mapeados = @(Get-HallazgosMapeados $c)
        $esperadas = Get-ReferenciasEsperadas $c
        $requiereVigencia = @($mapeados | Where-Object {
            $o = Get-Meta $_ 'Ley 21.719 obligación'; -not (Test-Vacio $o) -and $o -cne 'no aplica' }).Count -gt 0
        if ($null -eq $c.Verificaciones) {
            if ($c.ExisteVerificacion) { Write-Fallo 'C19' 'verificacion_articulos.md no contiene la tabla con el encabezado del contrato.' }
            elseif ($esperadas.Count -gt 0 -or $requiereVigencia) { Write-Fallo 'C19' 'Hay referencias legales pero no existe verificacion_articulos.md.' }
            return
        }
        $idsMapeados = @($mapeados | ForEach-Object { $_.Archivo -replace '\.md$', '' })
        $vistos = @{}; $porPar = @{}; $filasVigencia = 0
        foreach ($f in $c.Verificaciones) {
            $l = $f._Linea
            if ($f.ID -cnotmatch '^VA-\d{3}$') { Write-Fallo 'C19' ("Línea {0}: ID '{1}' inválido." -f $l, $f.ID) }
            elseif ($vistos.ContainsKey($f.ID)) { Write-Fallo 'C19' ("ID '{0}' duplicado." -f $f.ID) }
            $vistos[$f.ID] = $true
            if ($f.Ley -cne '21.663' -and $f.Ley -cne '21.719' -and $f.Ley -notmatch '21\.459') {  # 21.459: C20
                Write-Fallo 'C19' ("{0}: ley '{1}' inválida." -f $f.ID, $f.Ley)
            }
            if (-not (Test-Enum $f.Estado $script:EstadosVerificacion)) { Write-Fallo 'C19' ("{0}: estado '{1}' inválido." -f $f.ID, $f.Estado) }
            if ($f.Estado -ceq 'verificado') {
                if (Test-Vacio $f.Fuente) { Write-Fallo 'C19' ("{0}: 'verificado' sin fuente." -f $f.ID) }
                if ($f.Fecha -notmatch '^\d{4}-\d{2}-\d{2}$') { Write-Fallo 'C19' ("{0}: 'verificado' sin fecha AAAA-MM-DD." -f $f.ID) }
                if ((Test-Vacio $f.Artículo) -or $f.Artículo -ceq 'verificar') { Write-Fallo 'C19' ("{0}: 'verificado' sin artículo." -f $f.ID) }
            }
            if ($f.Estado -ceq 'descartado' -and (Test-Vacio $f.Comentario)) { Write-Fallo 'C19' ("{0}: 'descartado' sin comentario." -f $f.ID) }
            if ($f.Hallazgo -ceq '—') {
                if ($f.Obligación -cne 'entrada en vigor' -or $f.Ley -cne '21.719') {
                    Write-Fallo 'C19' ("{0}: hallazgo '—' solo se admite en la fila 'entrada en vigor' de la Ley 21.719." -f $f.ID)
                }
                else { $filasVigencia++ }
                continue
            }
            if ($idsMapeados -cnotcontains $f.Hallazgo) {
                Write-Fallo 'C19' ("{0}: el hallazgo '{1}' no existe, no está mapeado o está descartado." -f $f.ID, $f.Hallazgo)
                continue
            }
            $par = "$($f.Hallazgo)|$($f.Ley)"
            if ($porPar.ContainsKey($par)) { Write-Fallo 'C19' ("{0}: referencia repetida para {1} / Ley {2}." -f $f.ID, $f.Hallazgo, $f.Ley); continue }
            $porPar[$par] = $f
            if (-not $esperadas.Contains($par)) {
                if ($f.Estado -cne 'descartado') {
                    Write-Fallo 'C19' ("{0}: {1} no tiene obligación citable de la Ley {2}; la fila sobra o debe quedar 'descartado'." -f $f.ID, $f.Hallazgo, $f.Ley)
                }
            }
            elseif ($f.Obligación -cne $esperadas[$par]) {
                Write-Fallo 'C19' ("{0}: obligación '{1}' distinta de la del hallazgo ('{2}')." -f $f.ID, $f.Obligación, $esperadas[$par])
            }
        }
        foreach ($par in $esperadas.Keys) {
            $h, $ley = $par -split '\|'
            if (-not $porPar.ContainsKey($par)) { Write-Fallo 'C19' ("{0}: falta la fila de la Ley {1} en verificacion_articulos.md." -f $h, $ley); continue }
            $fila = $porPar[$par]
            $art = Get-Meta ($mapeados | Where-Object { $_.Archivo -ceq "$h.md" } | Select-Object -First 1) "Ley $ley artículo"
            if ($fila.Estado -ceq 'verificado') {
                if ($art -cne $fila.Artículo) { Write-Fallo 'C19' ("{0}: el artículo de la Ley {1} ('{2}') no es el verificado en {3} ('{4}')." -f $h, $ley, $art, $fila.ID, $fila.Artículo) }
            }
            elseif ($art -cne 'verificar') {
                Write-Fallo 'C19' ("{0}: cita el artículo '{1}' de la Ley {2} sin fila 'verificado' (FR-010)." -f $h, $art, $ley)
            }
        }
        if ($requiereVigencia -and $filasVigencia -eq 0) { Write-Fallo 'C19' "Falta la fila 'entrada en vigor' de la Ley 21.719." }
        if ($filasVigencia -gt 1) { Write-Fallo 'C19' "La fila 'entrada en vigor' de la Ley 21.719 está repetida." }
    } $c
}

# C20 — La Ley 21.459 no se mapea como obligación (FR-008, SC-004).
$script:Comprobaciones += {
    param($c)
    if (-not $c.Activo002) { return }
    Invoke-Comprobacion 'C20' 'La Ley 21.459 no aparece como obligación de ningún hallazgo' {
        param($c)
        foreach ($h in (Get-HallazgosMapeados $c)) {
            foreach ($linea in ($h.Mapeo -split "`r?`n")) {
                if ($linea -match '^- \*\*(.+?)\*\*: ?(.*)$' -and ($Matches[1] -match '21\.459' -or
                    ($Matches[1] -match 'obligación' -and $Matches[2] -match '21\.459'))) {
                    Write-Fallo 'C20' ("{0}: mapea la Ley 21.459 ('{1}'); solo es marco de la autorización." -f $h.Archivo, $linea.Trim())
                }
            }
        }
        foreach ($f in (Get-FilasVerificacion $c)) {
            if ($f.Ley -match '21\.459') { Write-Fallo 'C20' ("{0}: la lista de verificación incluye la Ley 21.459." -f $f.ID) }
        }
    } $c
}

# C21 — Mapa normativo igual al recalculado desde los hallazgos; leyenda y sección Ley 21.459 (FR-012, SC-006).
$script:Comprobaciones += {
    param($c)
    if (-not $c.Activo002) { return }
    Invoke-Comprobacion 'C21' 'Mapa normativo coherente con los hallazgos' {
        param($c)
        $mapeados = @(Get-HallazgosMapeados $c)
        if ($null -eq $c.TextoMapa) {
            if ($mapeados.Count -gt 0) { Write-Fallo 'C21' 'Hay hallazgos mapeados pero no existe mapa_normativo.md.' }
            return
        }
        if ($c.TextoMapa -notmatch [regex]::Escape($script:LeyendaMapeo)) { Write-Fallo 'C21' ("mapa_normativo.md: falta la leyenda '{0}'." -f $script:LeyendaMapeo) }
        if ($c.TextoMapa -notmatch '(?ms)^## Ley 21\.459[ \t]*\r?$(.*?)(?=^## |\z)' -or $Matches[1] -notmatch 'autorización') {
            Write-Fallo 'C21' "mapa_normativo.md: falta la sección '## Ley 21.459' que la ubica como marco de la autorización."
        }
        $esperado = @{ 'Control ISO' = @{}; 'Obligación Ley 21.663' = @{}; 'Obligación Ley 21.719' = @{} }
        foreach ($h in $mapeados) {
            $id = $h.Archivo -replace '\.md$', ''
            $controles = @(Get-Meta $h 'Control ISO') + (Get-ListaMapeo (Get-Meta $h 'Controles ISO adicionales'))
            foreach ($k in $controles) { if ($k -and $k -cne 'verificar') { $esperado['Control ISO'][$k] += @($id) } }
            $o1 = Get-Meta $h 'Ley 21.663 obligación'
            if (-not (Test-Vacio $o1) -and $o1 -cne 'no aplica') { $esperado['Obligación Ley 21.663'][$o1] += @($id) }
            $o2 = Get-Meta $h 'Ley 21.719 obligación'
            if (-not (Test-Vacio $o2) -and $o2 -cne 'no aplica' -and $o2 -cne $script:PendienteVigencia) { $esperado['Obligación Ley 21.719'][$o2] += @($id) }
        }
        foreach ($tabla in @('Control ISO', 'Obligación Ley 21.663', 'Obligación Ley 21.719')) {
            $filas = Get-TablaMarkdown $c.TextoMapa @($tabla, 'Hallazgos')
            if ($null -eq $filas) { Write-Fallo 'C21' ("mapa_normativo.md: falta la tabla '| {0} | Hallazgos |'." -f $tabla); continue }
            $leidas = @{}
            foreach ($f in $filas) {
                $clave = $f.$tabla
                $leidas[$clave] = $true
                if (-not $esperado[$tabla].ContainsKey($clave)) { Write-Fallo 'C21' ("Tabla '{0}': la fila '{1}' no corresponde a ningún hallazgo mapeado." -f $tabla, $clave); continue }
                $valor = (@($esperado[$tabla][$clave] | Sort-Object -Unique) -join '; ')
                if ($f.Hallazgos -cne $valor) { Write-Fallo 'C21' ("Tabla '{0}', fila '{1}': '{2}' (esperado '{3}')." -f $tabla, $clave, $f.Hallazgos, $valor) }
            }
            foreach ($clave in $esperado[$tabla].Keys) {
                if (-not $leidas.ContainsKey($clave)) { Write-Fallo 'C21' ("Tabla '{0}': falta la fila '{1}'." -f $tabla, $clave) }
            }
        }
    } $c
}

# C22 — Referencias pendientes de verificación (FR-017). Solo avisa.
$script:Comprobaciones += {
    param($c)
    $pendientes = @(Get-FilasVerificacion $c | Where-Object { $_.Estado -ceq 'pendiente' })
    if ($pendientes.Count -gt 0) {
        Write-Aviso 'C22' ("{0} referencias legales pendientes de verificación por el auditor: {1}." -f $pendientes.Count, (($pendientes | ForEach-Object { $_.ID }) -join ', '))
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
    if ($contexto.Activo002) {
        $noDescartados = @($contexto.Hallazgos | Where-Object { (Get-Meta $_ 'Estado') -cne 'descartado' }).Count
        $filas = Get-FilasVerificacion $contexto
        $cuenta = { param($e) @($filas | Where-Object { $_.Estado -ceq $e }).Count }
        Write-Output ("Mapeo: {0} de {1} hallazgos no descartados mapeados; referencias: {2} pendiente, {3} verificado, {4} descartado" -f `
            @(Get-HallazgosMapeados $contexto).Count, $noDescartados, (& $cuenta 'pendiente'), (& $cuenta 'verificado'), (& $cuenta 'descartado'))
    }
}

Write-Output ("Resultado: {0} errores, {1} avisos" -f $script:Errores, $script:Avisos)
if ($script:Errores -gt 0) { exit 1 }
exit 0
