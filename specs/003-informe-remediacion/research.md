# Research — Informe y remediación (003)

El Technical Context no tiene marcadores NEEDS CLARIFICATION. Estas decisiones fijan los
formatos que el validador puede comprobar.

## R1 — Formato del plan de remediación

- **Decision:** una tabla Markdown con encabezado fijo (`contracts/plan-remediacion.md`), una
  fila por hallazgo revisado, más dos líneas de metadatos con los hallazgos excluidos y el
  bloque `## Revisión`.
- **Rationale:** el validador ya lee tablas con `Get-TablaMarkdown` y metadatos con
  `Get-Metadatos`; una tabla permite comparar fila a fila con la matriz.
- **Alternatives considered:** una sección por hallazgo (más legible, pero duplica el hallazgo
  y es más difícil de validar); CSV (no admite el bloque Revisión ni texto explicativo).

## R2 — Plazo sugerido

- **Decision:** el plazo se escribe como `7 días`, `30 días`, `90 días` o `180 días`, derivado
  de la prioridad (FR-005). Si el auditor lo cambia, el `Comentario` de la fila empieza con
  `Plazo ajustado:` y el motivo; el valor sigue el formato `N días`.
- **Rationale:** un plazo relativo no depende de una fecha que aún no existe (la aprobación) y
  se compara directo con la prioridad.
- **Alternatives considered:** fecha absoluta (exige recalcular al aprobar); plazo libre (no
  verificable).

## R3 — Estado de remediación y cierre

- **Decision:** `Estado` ∈ `abierto` | `en curso` | `cerrado`. `cerrado` exige `Fecha de cierre`
  AAAA-MM-DD y `Evidencia de cierre` con un `EV-NNN` del inventario; en otro estado ambas son
  `—`.
- **Rationale:** cumple la constitución (sin evidencia no hay cierre) y permite seguir la
  remediación sin tocar el hallazgo.
- **Alternatives considered:** cerrar el hallazgo mismo (mezcla la revisión del auditor con la
  remediación del responsable).

## R4 — Estructura y extensión del resumen

- **Decision:** secciones de nivel 2 fijas y en orden: `Objetivo y alcance`, `Resultados por
  severidad` (tabla `| Severidad | Hallazgos |` con las 5 severidades), `Riesgos principales`
  (lista numerada, máximo 5, cada ítem con al menos un `H-NNN`), `Prioridades de remediación`,
  `Implicancias normativas`, `Limitaciones` y `Revisión`. La extensión se cuenta como palabras
  (tokens separados por espacios con al menos una letra o dígito) desde el título hasta
  `## Revisión`, sin comentarios HTML; máximo 500.
- **Rationale:** 500 palabras caben en una página A4/carta; el conteo de palabras es estable y
  no depende del renderizado.
- **Alternatives considered:** contar líneas (depende del ancho); exportar a PDF y contar
  páginas (requiere herramientas externas).

## R5 — Citas legales en el resumen

- **Decision:** reglas por línea en la sección `Implicancias normativas`:
  - debe estar la leyenda "Mapeo orientativo; no constituye dictamen jurídico";
  - toda mención `artículo X` o `art. X` debe usar un artículo con fila `verificado` en
    `verificacion_articulos.md`;
  - si la fila `entrada en vigor` no está `verificado`, cada línea que menciona `21.719` debe
    contener `vigencia`;
  - cada línea que menciona `21.459` debe contener `autorización`.
- **Rationale:** son las mismas reglas de 002 (FR-008, FR-010, FR-007) llevadas a texto libre
  con una heurística simple y explicable.
- **Alternatives considered:** prohibir toda mención legal en el resumen (pierde el aporte
  híbrido); análisis semántico (no es posible con un validador sin dependencias).

## R6 — Activación y numeración

- **Decision:** C23–C25 se ejecutan si existe `plan_remediacion.md`; C26–C27 si existe
  `resumen_ejecutivo.md`; C28 si existe cualquiera de los dos; C29 (aviso) si alguno está en
  `pendiente` o si existe uno de los dos y falta el otro. Sin ninguno de los dos archivos no se
  ejecuta ni se informa nada de 003, aunque haya hallazgos revisados: el informe todavía no se
  generó.
- **Rationale:** mantiene la compatibilidad (SC-006): los fixtures de 001 y 002 no tienen estos
  archivos y no cambian de resultado.
- **Alternatives considered:** exigir ambos archivos apenas haya un hallazgo aprobado (rompería
  `valido/` de 001 y 002 y obligaría a generar el informe antes de tiempo).

## R7 — Vuelta a `pendiente` al regenerar (FR-016)

- **Decision:** se cubre con el prompt §2d y un ítem de la DoD del PR, no con el validador.
- **Rationale:** el validador no tiene historial para saber si el contenido cambió después de
  aprobarse (misma conclusión que R6 de 002).
- **Alternatives considered:** guardar un hash del contenido aprobado en el bloque Revisión
  (frágil y opaco para el auditor).

## R8 — Hallazgos que entran y conteos

- **Decision:** entran los hallazgos con `Estado` `aprobado` o `corregido`. Los excluidos se
  cuentan en el plan con `- **Hallazgos excluidos (pendiente)**: N` y
  `- **Hallazgos excluidos (descartado)**: N`, que el validador recalcula.
- **Rationale:** el informe nunca contiene un hallazgo sin revisión humana (principio VII) y la
  limitación queda visible.
- **Alternatives considered:** incluir los pendientes marcados como tales (mezcla borradores en
  el entregable de cierre).
