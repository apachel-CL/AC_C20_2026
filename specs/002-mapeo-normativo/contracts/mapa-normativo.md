# Contrato — `salidas/mapa_normativo.md`

UTF-8. Vista derivada de los hallazgos no descartados que tienen sección de mapeo.

```markdown
# Mapa normativo

> Mapeo orientativo; no constituye dictamen jurídico.

## ISO/IEC 27001:2022

| Control ISO | Hallazgos |
|---|---|
| A.8.20 | H-001; H-003 |

## Ley 21.663

| Obligación Ley 21.663 | Hallazgos |
|---|---|
| medidas de seguridad | H-001 |

## Ley 21.719

| Obligación Ley 21.719 | Hallazgos |
|---|---|

## Ley 21.459

La Ley 21.459 (delitos informáticos) no se mapea como obligación de los hallazgos: delimita la
autorización de las pruebas (`docs/alcance.md`).
```

## Reglas

| Regla | Origen |
|---|---|
| Contiene la leyenda "no constituye dictamen jurídico" | FR-002, FR-012 |
| Tabla ISO: una fila por control citado (principal o adicional), con los hallazgos que lo citan | FR-012 |
| Tablas legales: una fila por obligación distinta de `no aplica`, con sus hallazgos | FR-012 |
| Los hallazgos de cada celda van ordenados y separados por `; ` | research R8 |
| Ninguna fila sobra ni falta respecto de lo recalculado desde los hallazgos (el orden de las filas no importa) | FR-013 |
| Existe la sección `## Ley 21.459` y menciona "autorización" | FR-008 |
