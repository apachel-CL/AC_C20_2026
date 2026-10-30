# Contrato — `salidas/resumen_ejecutivo.md`

UTF-8 sin BOM. Plantilla: `docs/plantillas/resumen_ejecutivo.md`. Máximo una página
(≤ 500 palabras antes de `## Revisión`, sin comentarios HTML; research R4).

## Estructura

```markdown
# Resumen ejecutivo — Auditoría de ciberseguridad AC_C20_2026

## Objetivo y alcance

Una o dos frases: qué se evaluó (activo de laboratorio 192.168.56.101) y con qué marcos.

## Resultados por severidad

| Severidad | Hallazgos |
|---|---|
| Crítica | 0 |
| Alta | 0 |
| Media | 1 |
| Baja | 0 |
| Informativa | 0 |

## Riesgos principales

1. Riesgo en lenguaje no técnico (H-001).

## Prioridades de remediación

- Antes de 90 días: … (H-001). Detalle en `plan_remediacion.md`.

## Implicancias normativas

> Mapeo orientativo; no constituye dictamen jurídico.

…

## Limitaciones

…

## Revisión

- **Estado**: pendiente
- **Revisor**:
- **Fecha**:
- **Comentario**:
```

## Reglas

| Regla | Requisito | Comprobación |
|---|---|---|
| Las 7 secciones de nivel 2, en ese orden, y las 6 primeras no vacías | FR-008 | C26 |
| ≤ 500 palabras antes de `## Revisión` | FR-008, SC-003 | C26 |
| Tabla de severidades con las 5 filas y conteos iguales a los hallazgos revisados de la matriz | FR-009 | C26 |
| `Riesgos principales`: 1–5 ítems numerados, cada uno con un `H-NNN` revisado; 0 ítems solo si no hay revisados | FR-008, FR-009, SC-004 | C26 |
| `Prioridades de remediación`: todo `H-NNN` citado está en el plan | FR-008 | C26 |
| Leyenda en `Implicancias normativas` | FR-011 | C27 |
| `artículo X` / `art. X` solo con un artículo `verificado` en la lista de verificación | FR-011, SC-005 | C27 |
| Si la entrada en vigor de la Ley 21.719 no está `verificado`, cada línea con `21.719` contiene `vigencia` | FR-011 | C27 |
| Cada línea con `21.459` contiene `autorización` | FR-011 | C27 |
| Sin IPv4 distinta de `192.168.56.101` y sin la marca `propuesto: lo ejecuta el auditor` (el resumen no lleva comandos) | FR-010, FR-014 | C27 |
| Bloque Revisión válido | FR-015 | C28 |

El lenguaje no técnico (FR-010) y la etiqueta [INFERENCIA] (FR-012) los comprueba el auditor en
la revisión; el validador no los puede evaluar.
