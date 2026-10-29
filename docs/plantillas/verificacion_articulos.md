# Verificación de artículos

<!--
Plantilla: copiar a salidas/verificacion_articulos.md (specs/002-mapeo-normativo/contracts/verificacion-articulos.md).
- Una fila por referencia legal: cada par (hallazgo, ley) con obligación distinta de `no aplica` y de `pendiente de vigencia`.
- Fila `entrada en vigor` (Hallazgo `—`, Ley `21.719`) si algún hallazgo tiene una obligación 21.719 distinta de `no aplica`.
- ID: `^VA-\d{3}$`, único y no reutilizado.
- Ley: `21.663` | `21.719` (nunca 21.459).
- Estado: `pendiente` | `verificado` | `descartado`. Solo el auditor lo cambia, tras consultar la fuente oficial.
  - `verificado`: Artículo, Fuente oficial y Fecha AAAA-MM-DD obligatorios; copiar el artículo al hallazgo y a la matriz.
  - `descartado`: Comentario con el motivo obligatorio.
  - Si el artículo verificado difiere del propuesto, anotar el motivo en Comentario.
- Claude no inventa números de artículo ni consulta fuentes externas: propone `verificar` (FR-010, FR-015).
-->

> Mapeo orientativo; no constituye dictamen jurídico. Solo el auditor cambia el estado,
> tras consultar la fuente oficial.

| ID | Hallazgo | Ley | Obligación | Artículo | Estado | Fuente | Fecha | Comentario |
|---|---|---|---|---|---|---|---|---|
