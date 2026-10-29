# Contrato — Comprobaciones de 002 en `scripts/Test-Salidas.ps1`

Extiende `specs/001-analisis-evidencias/contracts/test-salidas.md`. Invocación, garantías de
solo lectura y códigos de salida no cambian. C1–C14 siguen vigentes; C12 pasa a avisar solo
por columnas después de la 18.

## Activación

- Las comprobaciones C15–C22 se ejecutan si algún hallazgo tiene sección `## Mapeo normativo`,
  si la matriz tiene más de 11 columnas o si existe `verificacion_articulos.md` o
  `mapa_normativo.md`.
- Una salida de 001 sin nada de lo anterior no ejecuta C15–C22.

## Comprobaciones

| # | Comprobación | Nivel | Requisito |
|---|---|---|---|
| C15 | Columnas 12–18 de la matriz exactas y en orden; coinciden con el hallazgo; vacías si no hay mapeo o está `descartado` | error | FR-011, SC-005 |
| C16 | Sección de mapeo: claves obligatorias, leyenda, enumerados (obligación 21.663, certezas), justificaciones no vacías | error | FR-002, FR-005, FR-007 |
| C17 | Controles ISO (principal y adicionales) en el Anexo A 2022; adicionales sin repetir el principal; anterior/motivo coherentes | error | FR-003, FR-004 |
| C18 | Certeza 21.663 ≤ `Media` con la frase hipotética; 21.719 con vigencia y certeza ≤ `Media` mientras la entrada en vigor no esté verificada | error | FR-006, FR-007 |
| C19 | Lista de verificación: estructura, enumerados, `verificado` con fuente/fecha/artículo, `descartado` con comentario, cobertura 1:1 de referencias, y artículos citados solo con fila `verificado` | error | FR-009, FR-010, SC-003 |
| C20 | Ninguna obligación ni fila de la lista mapea la Ley 21.459 | error | FR-008, SC-004 |
| C21 | Mapa normativo igual al recalculado desde los hallazgos; leyenda y sección Ley 21.459 presentes | error | FR-012, SC-006 |
| C22 | Referencias de la lista en estado `pendiente` (informa cuántas quedan) | aviso | FR-017 |

## Resumen final

Además de los conteos de 001, informa: hallazgos mapeados / no descartados y referencias
`pendiente` / `verificado` / `descartado`.
