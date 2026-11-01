# Contrato — `salidas/plan_remediacion.md`

UTF-8 sin BOM. Plantilla: `docs/plantillas/plan_remediacion.md`.

## Estructura

```markdown
# Plan de remediación

> Generado a partir de los hallazgos revisados (aprobado o corregido). Los comandos, si los
> hay, son propuestos y los ejecuta el auditor solo contra 192.168.56.101.

- **Hallazgos excluidos (pendiente)**: 0
- **Hallazgos excluidos (descartado)**: 0

| Orden | Hallazgo | Evidencias | Severidad | Prioridad | Acción | Responsable sugerido | Plazo | Criterio de cierre | Estado | Fecha de cierre | Evidencia de cierre | Comentario |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | H-001 | EV-900; EV-002 | Media | P2 | … | Administrador del sistema | 90 días | … | abierto | — | — | — |

## Revisión

- **Estado**: pendiente
- **Revisor**:
- **Fecha**:
- **Comentario**:
```

## Reglas

| Regla | Requisito | Comprobación |
|---|---|---|
| Encabezado de la tabla exacto, en ese orden | FR-002 | C23 |
| Las dos líneas de excluidos presentes, enteras y iguales al recuento de hallazgos `pendiente` y `descartado` | FR-007 | C23 |
| Enumerados: `Severidad`, `Prioridad`, `Estado` (`abierto` · `en curso` · `cerrado`) | FR-002, FR-006 | C23 |
| Una fila por hallazgo revisado, sin repetidos ni hallazgos no revisados | FR-002, SC-001 | C24 |
| `Evidencias`, `Severidad`, `Prioridad`, `Acción`, `Responsable sugerido`, `Criterio de cierre` iguales a la matriz (`evidencias` con `;` → `; `) | FR-003, SC-002 | C24 |
| `Orden` = 1…n y filas ordenadas por prioridad, severidad e ID | FR-004 | C24 |
| `Plazo` con formato `N días`; si difiere del derivado, `Comentario` empieza con `Plazo ajustado:` | FR-005 | C25 |
| `cerrado` con `Fecha de cierre` AAAA-MM-DD y `Evidencia de cierre` del inventario; si no, ambas `—` | FR-006 | C25 |
| Ninguna IPv4 distinta de `192.168.56.101` | FR-014 | C25 |
| Bloque Revisión válido | FR-015 | C28 |

Las celdas no pueden contener `|`; si una recomendación lo tiene, se reescribe sin él en la
matriz y en el hallazgo antes de generar el plan.
