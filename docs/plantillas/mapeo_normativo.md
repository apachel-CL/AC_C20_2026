## Mapeo normativo

<!--
Plantilla: pegar entre "## Recomendación" y "## Revisión" de cada salidas/hallazgos/H-NNN.md
(specs/002-mapeo-normativo/contracts/mapeo-hallazgo.md). Cada clave es única en el archivo.
- El control ISO principal y su certeza van en los campos `Control ISO` y `Certeza ISO` del encabezado.
  Debe existir en el Anexo A de ISO/IEC 27001:2022 (A.5.1–A.5.37, A.6.1–A.6.8, A.7.1–A.7.14, A.8.1–A.8.34) o ser `verificar`.
- Controles ISO adicionales: `—` o controles separados por "; ", distintos del principal.
- Control ISO anterior: `—` si se confirmó el preliminar (entonces Motivo de corrección = `confirmado`).
- Obligación Ley 21.663: `gestión de riesgos` | `medidas de seguridad` | `reporte de incidentes` | `no aplica`.
  Si no es `no aplica`: la justificación contiene "si la organización fuera entidad obligada" y la certeza es ≤ `Media` (Q1).
- Obligación Ley 21.719: `no aplica` | `pendiente de vigencia` | texto libre.
  Mientras la fila `entrada en vigor` de verificacion_articulos.md no esté `verificado`, usar `pendiente de vigencia`
  y dejar la obligación candidata solo en la justificación. Si no es `no aplica`, completar la advertencia de vigencia.
- Certezas: `Alta` | `Media` | `Baja`.
- Artículo: `—` si no aplica; `verificar` si está pendiente o es `pendiente de vigencia`; si no, el de una fila `verificado`.
  Nunca inventar números de artículo (FR-010).
- Toda justificación lleva [HECHO] o [INFERENCIA] (FR-014).
- La Ley 21.459 no se mapea en el hallazgo: solo aparece en mapa_normativo.md como marco de la autorización.
- Crear o modificar esta sección vuelve la Revisión a `pendiente` (FR-016).
-->

> Mapeo orientativo; no constituye dictamen jurídico.

### ISO/IEC 27001:2022

- **Controles ISO adicionales**: —
- **Control ISO anterior**: —
- **Motivo de corrección**: confirmado
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
- **Ley 21.719 justificación**: [INFERENCIA] …
- **Ley 21.719 vigencia**: —
