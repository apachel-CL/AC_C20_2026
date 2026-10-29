# Data Model — 002 Mapeo normativo de hallazgos

Igual que en 001, no hay base de datos: cada entidad vive en un archivo de `salidas/`. Los
formatos exactos están en `contracts/`. Las entidades de 001 (Evidencia, Activo, Hallazgo,
Recomendación, Revisión) no cambian, salvo el control ISO principal (R2).

## Mapeo ISO

**Persistencia**: en `H-NNN.md`, campos `Control ISO` y `Certeza ISO` (de 001) más la sección
`## Mapeo normativo`.

| Campo | Tipo | Regla |
|---|---|---|
| `control_principal` | `A.N.N` o `verificar` | Existe en el Anexo A 2022 (research R3); reemplaza al preliminar (FR-003) |
| `certeza` | enum | `Alta` · `Media` · `Baja` |
| `controles_adicionales` | lista `A.N.N` | Opcional (`—` si no hay); cada uno existe en el Anexo A 2022 y ninguno repite el principal (FR-004) |
| `control_anterior` | `A.N.N` · `verificar` · `—` | `—` si el preliminar se confirmó |
| `motivo_correccion` | texto | `confirmado` si `control_anterior = —`; si no, el motivo |
| `justificacion_iso` | texto | No vacía |

## Mapeo legal

**Persistencia**: en la sección `## Mapeo normativo` de `H-NNN.md`, un grupo de campos por ley.

| Campo | Ley 21.663 | Ley 21.719 |
|---|---|---|
| `obligacion` | `gestión de riesgos` · `medidas de seguridad` · `reporte de incidentes` · `no aplica` | `no aplica` · `pendiente de vigencia` · texto libre (solo si la entrada en vigor está `verificado`) |
| `articulo` | `verificar`, `—` (si no aplica) o el artículo de una fila `verificado` | igual; `verificar` si `pendiente de vigencia` |
| `certeza` | `Alta` · `Media` · `Baja`; siempre ≤ `Media` (Q1) | `Alta` · `Media` · `Baja` |
| `justificacion` | [HECHO] o [INFERENCIA]; si `obligacion ≠ no aplica`, contiene "si la organización fuera entidad obligada" | [HECHO] o [INFERENCIA]; si `no aplica`, por qué; si `pendiente de vigencia`, la obligación candidata |
| `vigencia` | — | advertencia de vigencia diferida, obligatoria si `obligacion ≠ no aplica` |

**Ley 21.459**: no es un campo del hallazgo (FR-008). Solo aparece en el mapa normativo.

**Leyenda**: la sección incluye "Mapeo orientativo; no constituye dictamen jurídico".

## Referencia por verificar

**Persistencia**: `salidas/verificacion_articulos.md`, una fila por referencia.

| Campo | Tipo | Regla |
|---|---|---|
| `id` | `VA-NNN` | Único; no se reutiliza |
| `hallazgo` | `H-NNN` o `—` | `—` solo para la fila de entrada en vigor de la Ley 21.719 |
| `ley` | enum | `21.663` · `21.719` |
| `obligacion` | texto | Igual a la del hallazgo, o `entrada en vigor` |
| `articulo` | texto | Propuesto o `verificar`; fijado por el auditor si `verificado` |
| `estado` | enum | `pendiente` · `verificado` · `descartado` |
| `fuente` | texto | Obligatoria si `verificado` (fuente oficial, p. ej. BCN) |
| `fecha` | `AAAA-MM-DD` | Obligatoria si `verificado` |
| `comentario` | texto | Obligatorio si `descartado` (motivo) |

**Transiciones** (solo el auditor):

```
pendiente ──▶ verificado | descartado
```

**Cardinalidad**: exactamente una fila por par (hallazgo, ley) con obligación distinta de
`no aplica` y de `pendiente de vigencia`, más una fila de entrada en vigor si algún hallazgo
tiene una obligación 21.719 distinta de `no aplica`.

**Artículo verificado distinto del propuesto**: el auditor anota el motivo en `comentario`.

## Mapa normativo

**Persistencia**: `salidas/mapa_normativo.md`. Vista derivada de los hallazgos no descartados
y con sección de mapeo.

| Tabla | Clave | Valor |
|---|---|---|
| ISO | cada control (principal o adicional) | hallazgos que lo citan, separados por `; ` |
| Ley 21.663 | cada obligación distinta de `no aplica` | hallazgos |
| Ley 21.719 | cada obligación distinta de `no aplica` y de `pendiente de vigencia` | hallazgos |

Más la leyenda y la sección "Ley 21.459".

## Fila de la matriz (extendida)

Las 11 columnas de 001 seguidas de:

| Columna | Origen en `H-NNN.md` |
|---|---|
| `controles_iso_adicionales` | `Controles ISO adicionales`, separados por `;` sin espacios; `—` si no hay |
| `ley_21663_obligacion` | `Ley 21.663 obligación` |
| `ley_21663_articulo` | `Ley 21.663 artículo` |
| `ley_21663_certeza` | `Ley 21.663 certeza` |
| `ley_21719_obligacion` | `Ley 21.719 obligación` |
| `ley_21719_articulo` | `Ley 21.719 artículo` |
| `ley_21719_certeza` | `Ley 21.719 certeza` |

Las 7 columnas van vacías si el hallazgo no tiene sección de mapeo o está `descartado`.

## Estado de un hallazgo respecto del mapeo

```
sin mapeo ──(flujo §2c)──▶ mapeado, Revisión = pendiente ──(auditor)──▶ aprobado | corregido
aprobado | corregido ──(flujo §2c, al cambiar el mapeo)──▶ pendiente
```

La segunda transición amplía las de 001 (FR-016): el flujo vacía `Revisor` y `Fecha`, conserva
el comentario con el prefijo "Revisión previa:" y alinea `estado_revision` en la matriz.
