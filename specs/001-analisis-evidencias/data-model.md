# Data Model — 001 Flujo de análisis de evidencias

No hay base de datos: cada entidad se persiste como archivo en `salidas/`. Los formatos exactos
están en `contracts/`.

## Evidencia

**Persistencia**: el archivo físico está en `evidencias/` (no versionado). Su registro va en
`salidas/inventario_evidencias.md`.

| Campo | Tipo | Regla |
|---|---|---|
| `id` | `EV-NNN` | Único y estable; coincide con el prefijo del archivo (FR-001) |
| `archivo` | texto | `EV-NNN_<comando-o-tema>.<ext>` |
| `observacion` | texto | Solo lo visible, etiquetado [HECHO]; sin credenciales (FR-003, FR-013) |
| `clasificacion` | enum | `hallazgo` · `contexto` · `insuficiente` · `fuera-de-alcance` |
| `debilidad` | texto | Obligatoria si `clasificacion = hallazgo` (FR-004) |
| `falta` | texto | Obligatoria si `clasificacion = insuficiente` (FR-006) |

**Transiciones**: sin clasificar → una de las cuatro clasificaciones. Una reclasificación solo
ocurre en la revisión humana.

## Activo

**Persistencia**: `salidas/inventario_activos.md`, una fila por dato observado.

| Campo | Tipo | Regla |
|---|---|---|
| `activo` | texto | Hostname o IP del activo en alcance (`192.168.56.101`) |
| `atributo` | enum | `hostname` · `interfaz` · `mac` · `ipv4` · `mascara` · `broadcast` · `ipv6` · `usuario` · `so` · `otro` |
| `valor` | texto | Transcripción literal (Q5); agrega "(parcialmente legible)" si aplica |
| `etiqueta` | enum | `[HECHO]` · `[INFERENCIA]` |
| `fuente` | `EV-NNN` | Debe existir en el inventario de evidencias |

## Hallazgo

**Persistencia**: `salidas/hallazgos/H-NNN.md`, un archivo por hallazgo.

| Campo | Tipo | Regla |
|---|---|---|
| `id` | `H-NNN` | Único; igual al nombre del archivo |
| `enunciado` | texto | Una frase |
| `evidencias` | lista `EV-NNN` | ≥ 1; todas existen y al menos una es `hallazgo` (SC-002) |
| `severidad` | enum | `Crítica` · `Alta` · `Media` · `Baja` · `Informativa` |
| `justificacion` | texto | Breve |
| `control_iso` | texto | Control del Anexo A (`A.N.NN`) o `verificar` (FR-008) |
| `certeza_iso` | enum | `Alta` · `Media` · `Baja` |
| `recomendacion` | Recomendación | Ver abajo (FR-009) |
| `revision` | Revisión | Ver abajo (FR-014) |

**Relaciones**: un hallazgo se apoya en N evidencias, y una evidencia puede sustentar N
hallazgos.

## Recomendación

Va embebida en el hallazgo.

| Campo | Tipo | Regla |
|---|---|---|
| `accion` | texto | Concreta |
| `prioridad` | enum | `P0` · `P1` · `P2` · `P3`; por defecto se deriva de la severidad |
| `responsable_sugerido` | texto | Rol, no persona |
| `criterio_cierre` | texto | Verificable |
| `comandos_propuestos` | texto | Opcional; solo propuestos, nunca ejecutados (FR-012) |

**Prioridad derivada de la severidad** (supuesto de la spec; el auditor la puede ajustar):

| Severidad | Prioridad |
|---|---|
| Crítica | P0 |
| Alta | P1 |
| Media | P2 |
| Baja | P3 |
| Informativa | P3 |

## Revisión

Va embebida en el hallazgo.

| Campo | Tipo | Regla |
|---|---|---|
| `estado` | enum | `pendiente` · `aprobado` · `corregido` · `descartado` |
| `revisor` | texto | Vacío si `pendiente`; obligatorio en los demás estados |
| `fecha` | `AAAA-MM-DD` | Igual que `revisor` |
| `comentario` | texto | Opcional |

**Transiciones**:

```
pendiente ──(auditor)──▶ aprobado | corregido | descartado
corregido ──(auditor)──▶ aprobado
```

- **Cerrado** = `aprobado` o `corregido` (FR-014).
- El flujo solo crea hallazgos en estado `pendiente`.

## Fila de la matriz

**Persistencia**: `salidas/matriz_hallazgos.csv`, una fila por hallazgo. Es la proyección de
Hallazgo + Recomendación + `revision.estado` en las 11 columnas de FR-010.

**Regla**: cada columna MUST coincidir con el archivo `H-NNN.md` correspondiente, y la
correspondencia entre filas y archivos es 1:1.
