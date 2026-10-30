# Contrato — Columnas legales de `salidas/matriz_hallazgos.csv`

Extiende `specs/001-analisis-evidencias/contracts/matriz_hallazgos.md`. Mismo formato: UTF-8
sin BOM, coma, RFC 4180.

## Encabezado completo (18 columnas, en este orden)

```csv
id_hallazgo,enunciado,evidencias,severidad,control_iso,certeza_iso,recomendacion,prioridad,responsable_sugerido,criterio_cierre,estado_revision,controles_iso_adicionales,ley_21663_obligacion,ley_21663_articulo,ley_21663_certeza,ley_21719_obligacion,ley_21719_articulo,ley_21719_certeza
```

## Reglas

| Regla | Origen |
|---|---|
| Las 11 primeras columnas son las de 001, sin cambios | FR-011, SC-005 |
| Si hay más de 11 columnas, las columnas 12–18 son exactamente las de arriba, en ese orden | FR-011 |
| Una matriz de 11 columnas sigue siendo válida (salida de 001 sin mapear) | research R4 |
| Columnas después de la 18: aviso C12 | research R4 |
| `controles_iso_adicionales`: `Controles ISO adicionales` con `;` sin espacios, o `—` | FR-011 |
| Las demás columnas legales son iguales al campo homónimo del hallazgo | FR-011 |
| Las 7 columnas legales van vacías si el hallazgo no tiene sección de mapeo o está `descartado` | spec, casos borde |
