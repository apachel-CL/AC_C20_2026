# Contrato — `salidas/matriz_hallazgos.csv`

- **Formato**: UTF-8 sin BOM, separador coma, fin de línea LF o CRLF, una fila de encabezado.
- **Comillas**: los campos con coma, comillas o salto de línea van entre comillas dobles, y las
  comillas internas se duplican (RFC 4180).

## Encabezado (exacto, en este orden)

```csv
id_hallazgo,enunciado,evidencias,severidad,control_iso,certeza_iso,recomendacion,prioridad,responsable_sugerido,criterio_cierre,estado_revision
```

## Reglas por columna

| Columna | Valor | Debe coincidir con `H-NNN.md` |
|---|---|---|
| `id_hallazgo` | `H-NNN`, único | nombre del archivo e `ID` |
| `enunciado` | texto | título después de `—` |
| `evidencias` | `EV-NNN` separados por `;` (sin espacios) | `Evidencias` |
| `severidad` | enum | `Severidad` |
| `control_iso` | `A.N.NN` o `verificar` | `Control ISO` |
| `certeza_iso` | `Alta`/`Media`/`Baja` | `Certeza ISO` |
| `recomendacion` | texto | `Acción` |
| `prioridad` | `P0`–`P3` | `Prioridad` |
| `responsable_sugerido` | texto | `Responsable sugerido` |
| `criterio_cierre` | texto | `Criterio de cierre` |
| `estado_revision` | enum | `Estado` del bloque Revisión |

## Correspondencia

Hay exactamente una fila por cada archivo `salidas/hallazgos/H-NNN.md` y ninguna fila sin
archivo.

## Extensión futura

La funcionalidad 002 agrega columnas legales **al final**. El validador de 001 exige que las 11
primeras columnas coincidan, y solo advierte (sin fallar) si hay columnas adicionales.
