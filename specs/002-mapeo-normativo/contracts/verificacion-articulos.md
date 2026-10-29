# Contrato — `salidas/verificacion_articulos.md`

UTF-8. Un título `#` y **una** tabla con estos encabezados exactos, en este orden:

```markdown
# Verificación de artículos

> Mapeo orientativo; no constituye dictamen jurídico. Solo el auditor cambia el estado,
> tras consultar la fuente oficial.

| ID | Hallazgo | Ley | Obligación | Artículo | Estado | Fuente | Fecha | Comentario |
|---|---|---|---|---|---|---|---|---|
| VA-001 | — | 21.719 | entrada en vigor | verificar | pendiente | | | |
| VA-002 | H-001 | 21.663 | medidas de seguridad | verificar | pendiente | | | |
```

## Reglas

| Regla | Origen |
|---|---|
| `ID`: `^VA-\d{3}$`, único y no reutilizado | FR-009 |
| `Hallazgo`: un `H-NNN` existente y no descartado, o `—` solo en la fila de entrada en vigor | FR-009 |
| `Ley`: `21.663` \| `21.719` (nunca `21.459`) | FR-008, FR-009 |
| `Estado`: `pendiente` \| `verificado` \| `descartado` | FR-009 |
| `verificado` ⇒ `Fuente` no vacía, `Fecha` `AAAA-MM-DD` y `Artículo` distinto de `verificar` | FR-009 |
| `descartado` ⇒ `Comentario` no vacío | spec, casos borde |
| Exactamente una fila por par (hallazgo, ley) cuya obligación no es `no aplica` | research R5 |
| Si algún hallazgo mapea la Ley 21.719, existe la fila `entrada en vigor` | FR-007, FR-009 |
| La `Obligación` de la fila coincide con la del hallazgo | FR-009 |
