# Contrato — Sección "Mapeo normativo" de `salidas/hallazgos/H-NNN.md`

Se agrega después de `## Recomendación` y antes de `## Revisión`. Las líneas usan el formato de
metadatos de 001 (`^- \*\*(.+?)\*\*: (.*)$`); cada clave es única en el archivo. El control
principal y su certeza siguen en los campos `Control ISO` y `Certeza ISO` del encabezado
(`specs/001-analisis-evidencias/contracts/hallazgo.md`).

```markdown
## Mapeo normativo

> Mapeo orientativo; no constituye dictamen jurídico.

### ISO/IEC 27001:2022

- **Controles ISO adicionales**: A.8.9; A.5.15
- **Control ISO anterior**: verificar
- **Motivo de corrección**: el preliminar quedó en "verificar"; la debilidad es de configuración
- **Justificación ISO**: [INFERENCIA] …

### Ley 21.663

- **Ley 21.663 obligación**: medidas de seguridad
- **Ley 21.663 artículo**: verificar
- **Ley 21.663 certeza**: Media
- **Ley 21.663 justificación**: [INFERENCIA] si la organización fuera entidad obligada, …

### Ley 21.719

- **Ley 21.719 obligación**: no aplica
- **Ley 21.719 artículo**: —
- **Ley 21.719 certeza**: Media
- **Ley 21.719 justificación**: [INFERENCIA] el servicio expuesto no trata datos personales visibles
- **Ley 21.719 vigencia**: —
```

## Reglas

| Regla | Origen |
|---|---|
| La sección contiene la leyenda "no constituye dictamen jurídico" | FR-002, principio V |
| `Controles ISO adicionales`: `—` o controles separados por `; `, cada uno del Anexo A 2022 y distinto del principal | FR-004, research R3 |
| `Control ISO anterior`: `—`, `verificar` o un control; si es `—`, `Motivo de corrección` = `confirmado` | FR-003, research R2 |
| `Justificación ISO` y las dos justificaciones legales no vacías | FR-003, FR-005, FR-007 |
| `Ley 21.663 obligación` ∈ `gestión de riesgos` \| `medidas de seguridad` \| `reporte de incidentes` \| `no aplica` | FR-005 |
| `Ley 21.663 certeza` ≤ `Media`; la justificación contiene "si la organización fuera entidad obligada" (salvo `no aplica`) | FR-006 (Q1) |
| `Ley 21.719 obligación` distinta de `no aplica` ⇒ `Ley 21.719 vigencia` no vacía y certeza ≤ `Media` mientras la entrada en vigor no esté `verificado` | FR-007 |
| Artículo = `—` si la obligación es `no aplica`; si no, `verificar` o el artículo de su fila `verificado` | FR-010 |
| Ninguna clave ni obligación menciona la Ley 21.459 | FR-008 |
| Crear o modificar la sección deja `Estado: pendiente` en Revisión | FR-016 |
