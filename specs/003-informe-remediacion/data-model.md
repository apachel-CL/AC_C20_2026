# Data Model — Informe y remediación (003)

Amplía `specs/001-analisis-evidencias/data-model.md` y `specs/002-mapeo-normativo/data-model.md`.
Las entidades de 001 y 002 no cambian.

## Hallazgo revisado

Hallazgo de 001 con `Estado` del bloque Revisión `aprobado` o `corregido`. Es la única fuente
de las entradas del plan y de los riesgos del resumen.

## Entrada del plan

Fila de la tabla de `salidas/plan_remediacion.md`.

| Campo | Tipo | Regla |
|---|---|---|
| `Orden` | entero | 1…n, consecutivo, según el orden de FR-004 |
| `Hallazgo` | ID | `H-NNN` revisado; una sola fila por hallazgo |
| `Evidencias` | lista | igual a `evidencias` de la matriz |
| `Severidad` | enum | igual a `severidad` de la matriz |
| `Prioridad` | enum | `P0`…`P3`, igual a `prioridad` de la matriz |
| `Acción` | texto | igual a `recomendacion` de la matriz |
| `Responsable sugerido` | texto | igual a `responsable_sugerido`; un rol, no un nombre |
| `Plazo` | texto | `N días`; por defecto P0 7, P1 30, P2 90, P3 180 (research R2) |
| `Criterio de cierre` | texto | igual a `criterio_cierre` de la matriz |
| `Estado` | enum | `abierto` · `en curso` · `cerrado` |
| `Fecha de cierre` | fecha | AAAA-MM-DD si `cerrado`; si no, `—` |
| `Evidencia de cierre` | ID | `EV-NNN` del inventario si `cerrado`; si no, `—` |
| `Comentario` | texto | empieza con `Plazo ajustado:` si el plazo difiere del derivado |

**Orden (FR-004):** prioridad (P0 → P3), luego severidad (Crítica → Informativa), luego ID.

**Transiciones del estado de remediación** (solo el auditor):

```text
abierto → en curso → cerrado
abierto → cerrado
cerrado → en curso   (reapertura, con motivo en Comentario)
```

## Plan de remediación

| Campo | Regla |
|---|---|
| `Hallazgos excluidos (pendiente)` | entero = hallazgos con Estado `pendiente` |
| `Hallazgos excluidos (descartado)` | entero = hallazgos con Estado `descartado` |
| Entradas | una por hallazgo revisado |
| Revisión | bloque como el de un hallazgo (`Estado`, `Revisor`, `Fecha`, `Comentario`) |

## Resumen ejecutivo

| Sección | Regla |
|---|---|
| `Objetivo y alcance` | no vacía |
| `Resultados por severidad` | tabla `| Severidad | Hallazgos |` con las 5 severidades; conteo = hallazgos revisados por severidad |
| `Riesgos principales` | 0–5 ítems numerados; cada uno cita ≥ 1 `H-NNN` revisado; 0 ítems solo si no hay hallazgos revisados |
| `Prioridades de remediación` | todo `H-NNN` citado está en el plan |
| `Implicancias normativas` | leyenda; citas legales según research R5 |
| `Limitaciones` | no vacía |
| `Revisión` | bloque como el de un hallazgo |

**Extensión:** ≤ 500 palabras antes de `## Revisión` (research R4).

## Revisión del documento

Igual que la de un hallazgo (001), con estados `pendiente` · `aprobado` · `corregido`
(`descartado` no aplica a un documento).

```text
pendiente → aprobado | corregido          (solo el auditor)
aprobado | corregido → pendiente          (el flujo, al regenerar con cambios; FR-016)
```

**Informe cerrado:** plan y resumen en `aprobado` o `corregido`.
