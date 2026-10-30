# Contrato — Comprobaciones de 003 en `scripts/Test-Salidas.ps1`

Extiende `specs/001-analisis-evidencias/contracts/test-salidas.md` y
`specs/002-mapeo-normativo/contracts/test-salidas-002.md`. Invocación, garantías de solo
lectura y códigos de salida no cambian. C1–C22 siguen vigentes.

## Activación (research R6)

- **C23–C25** se ejecutan si existe `plan_remediacion.md`.
- **C26–C27** se ejecutan si existe `resumen_ejecutivo.md`.
- **C28** se ejecuta si existe cualquiera de los dos.
- **C29** avisa, si existe al menos uno de los dos archivos, cuando falta el otro o alguno
  está en revisión `pendiente`.
- Sin ninguno de los dos archivos, nada de 003 se ejecuta ni se informa: los fixtures de 001 y
  002 dan el mismo resultado y la misma salida (SC-006).

## Comprobaciones

| # | Comprobación | Nivel | Requisito |
|---|---|---|---|
| C23 | Plan: encabezado de la tabla, líneas de excluidos con su recuento y enumerados | error | FR-002, FR-006, FR-007 |
| C24 | Plan: una fila por hallazgo revisado, columnas iguales a la matriz, `Orden` y orden correctos | error | FR-002–FR-004, SC-001, SC-002 |
| C25 | Plan: plazo derivado o ajustado con motivo; cierre con fecha y evidencia; IPs solo del activo | error | FR-005, FR-006, FR-014 |
| C26 | Resumen: secciones, extensión, conteos por severidad, riesgos y prioridades con hallazgos válidos | error | FR-008, FR-009, SC-003, SC-004 |
| C27 | Resumen: leyenda, artículos solo verificados, Ley 21.719 con vigencia, Ley 21.459 como autorización, sin comandos ni IPs ajenas | error | FR-010, FR-011, FR-014, SC-005 |
| C28 | Bloque Revisión de plan y resumen: estado (`pendiente` · `aprobado` · `corregido`), revisor y fecha si no es `pendiente` | error | FR-015 |
| C29 | Informe no cerrado: falta un documento o alguno está `pendiente` | aviso | FR-015, US3 |

## Resumen final

Además de los conteos de 001 y 002, si hay plan o resumen informa: entradas del plan por estado
(`abierto` / `en curso` / `cerrado`), palabras del resumen y si el informe está cerrado.
