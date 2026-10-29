# Contrato — `scripts/Test-Salidas.ps1`

## Invocación

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1 [-Ruta <dir>] [-Evidencias <dir>]
```

| Parámetro | Por defecto | Uso |
|---|---|---|
| `-Ruta` | `salidas` | Carpeta con los inventarios, `hallazgos/` y la matriz |
| `-Evidencias` | `evidencias` | Carpeta de evidencias. Si existe, comprueba los nombres de archivo y que cada uno esté inventariado (SC-001). Si no existe, como ocurre en un clon del repo público, esa comprobación se omite con un aviso |

## Garantías

- **Solo lectura de archivos locales.** No usa `Invoke-WebRequest`, `Invoke-RestMethod`,
  `Test-NetConnection`, sockets, `Start-Process` ni ningún comando de red, y no modifica
  archivos (constitución, principio IV).
- **Compatibilidad.** Corre en Windows PowerShell 5.1 sin módulos externos.

## Salida

- **Por consola:** una línea por comprobación (`[OK]`, `[ERROR]` o `[AVISO]`) y, al final, un
  resumen con los conteos de evidencias, hallazgos, errores y avisos.
- **Código de salida:** `0` si no hay errores (los avisos no fallan), `1` si hay al menos un
  error.

## Comprobaciones

| # | Comprobación | Nivel | Requisito |
|---|---|---|---|
| C1 | IDs `EV-NNN` únicos y con formato válido en el inventario | error | FR-001 |
| C2 | Cada archivo de `-Evidencias` tiene el nombre `EV-NNN_*.*` y está inventariado; no hay dos archivos con el mismo prefijo `EV-NNN` | error | FR-001, SC-001 |
| C3 | Clasificación válida; `Debilidad / Falta` presente cuando corresponde | error | FR-004, FR-006 |
| C4 | `evidencia_insuficiente.md` coincide con las evidencias insuficientes del inventario; `Reemplazada por` apunta a un EV existente o es `—` | error | FR-006, FR-017, SC-004 |
| C5 | `Fuente` de cada activo existe en el inventario | error | FR-005 |
| C6 | `H-NNN.md`: nombre igual al ID, metadatos obligatorios y enumerados válidos; Recomendación con `Acción`, `Prioridad` (`P0`–`P3`), `Responsable sugerido` y `Criterio de cierre` no vacíos | error | FR-007–FR-009 |
| C7 | Las evidencias de cada hallazgo existen, al menos una es `hallazgo` y ninguna es `fuera-de-alcance` | error | SC-002, FR-015 |
| C8 | Encabezado de la matriz exacto (las 11 primeras columnas) | error | FR-010 |
| C9 | Correspondencia 1:1 entre filas de la matriz y archivos, con columnas coincidentes | error | FR-010 |
| C10 | Revisión: `Revisor` y `Fecha` presentes si el estado no es `pendiente` | error | FR-014, SC-008 |
| C11 | Patrones de secretos en claro (`password=`, `pass:`, `$1$`, `$6$`, `BEGIN … PRIVATE KEY`, cadenas hexadecimales de 32 o más caracteres después de `hash`) | aviso | FR-013, SC-006 |
| C12 | Columnas adicionales en la matriz (con las columnas legales de 002, solo las posteriores a la 18) | aviso | contrato de la matriz |
| C13 | `Prioridad` distinta de la derivada de la severidad (el auditor puede ajustarla) | aviso | FR-009 |
| C14 | `Comandos propuestos` menciona una IPv4 distinta de `192.168.56.101` | aviso | FR-012 |

**Funcionalidad 002:** el mismo script agrega C15–C22 (mapeo normativo); ver
`specs/002-mapeo-normativo/contracts/test-salidas-002.md`.

**C11 y la Definition of Done:** C11 es heurística y no falla, pero un `[AVISO]` C11 sobre
`salidas/` bloquea el PR hasta que el auditor enmascare el dato o justifique el falso positivo
(SC-006).
