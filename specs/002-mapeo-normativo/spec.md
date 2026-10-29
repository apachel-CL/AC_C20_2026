# Feature Specification: Mapeo normativo de hallazgos

**Feature Branch**: `feat/002-mapeo-normativo` (directorio de la funcionalidad: `specs/002-mapeo-normativo`)

**Created**: 2026-10-28

**Status**: Draft

**Input**: User description: "Funcionalidad 002 — Mapeo normativo de hallazgos (épica E4). A partir de los hallazgos H-NNN.md y la matriz de la funcionalidad 001, el flujo produce un mapeo normativo detallado de cada hallazgo: (1) ISO/IEC 27001:2022 Anexo A: confirma o corrige el control preliminar de 001 (puede haber más de un control) con nivel de certeza Alta/Media/Baja y justificación; (2) Ley 21.663 (Marco de Ciberseguridad): obligación aplicable (gestión de riesgos, medidas de seguridad, reporte de incidentes ANCI/CSIRT), con artículo solo si se verifica y si no "verificar"; (3) Ley 21.719 (Protección de Datos Personales): obligación aplicable cuando el hallazgo afecta datos personales, advirtiendo la vigencia diferida y que la entrada en vigor debe verificarse; (4) Ley 21.459 (Delitos informáticos): solo como marco de la autorización de las pruebas, no como control. Los mapeos legales son orientativos y no constituyen dictamen jurídico; no se inventan artículos; toda referencia no verificada queda "verificar" y se registra en una lista de verificación de artículos para el auditor. La matriz salidas/matriz_hallazgos.csv recibe columnas legales AL FINAL, sin cambiar las 11 columnas de 001 (el validador de 001 ya acepta columnas adicionales con aviso C12). Se extiende el validador de solo lectura para comprobar las nuevas columnas y la coherencia con cada H-NNN.md. Rigen la constitución del proyecto (alcance 192.168.56.101, trazabilidad, [HECHO]/[INFERENCIA], no ejecución, enmascarado, estimación por tallas, revisión humana obligatoria). Entregables Markdown y CSV versionados en git."

## Clarifications

### Session 2026-10-28

- Q: ¿Bajo qué supuesto se evalúa la aplicabilidad de la Ley 21.663, si `docs/alcance.md` no
  dice si la organización es entidad obligada? → A: En forma hipotética ("si la organización
  fuera entidad obligada"), con [INFERENCIA] y certeza no mayor que `Media`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Confirmar el mapeo ISO/IEC 27001:2022 de cada hallazgo (Priority: P1)

El auditor ya tiene hallazgos `H-NNN.md` generados por la funcionalidad 001, cada uno con un
control ISO **preliminar**. El flujo revisa cada hallazgo y registra en él un mapeo ISO
detallado:

- el control principal del Anexo A, que confirma o corrige el preliminar;
- controles adicionales, si los hay;
- la certeza (Alta/Media/Baja) y una justificación breve de por qué el control aplica a la
  debilidad observada.

Si el control preliminar se corrige, queda constancia del valor anterior y del motivo.

**Why this priority**: la constitución (principio II) exige un control ISO por hallazgo, y el
de 001 es preliminar. Es el mapeo con menos riesgo de error jurídico y por sí solo ya entrega un
"Mapa ISO 27001" útil para el informe.

**Independent Test**: con un hallazgo ficticio que tiene `Control ISO: verificar`, el flujo
deja un control principal válido del Anexo A con certeza y justificación, actualiza la columna
`control_iso` de la matriz y el validador termina sin errores.

**Acceptance Scenarios**:

1. **Given** un hallazgo con control preliminar correcto, **When** se mapea, **Then** el
   control principal queda igual, se agrega la justificación y la corrección se registra como
   "confirmado".
2. **Given** un hallazgo cuyo control preliminar no corresponde a la debilidad, **When** se
   mapea, **Then** el control principal se corrige, se conserva el valor anterior y el motivo,
   y la matriz refleja el nuevo control.
3. **Given** un hallazgo que se relaciona con varios controles, **When** se mapea, **Then**
   queda un control principal y los demás como adicionales, sin repetir el principal.
4. **Given** dudas razonables sobre el control, **When** se mapea, **Then** la certeza es
   `Baja` o el control queda `verificar`, nunca un control inventado.

---

### User Story 2 - Mapear obligaciones de las leyes 21.663 y 21.719 (Priority: P2)

Para cada hallazgo, el flujo registra la obligación legal chilena que podría verse afectada:

- **Ley 21.663 (Marco de Ciberseguridad):** la categoría de obligación (gestión de riesgos,
  medidas de seguridad o reporte de incidentes a la ANCI/CSIRT), con su certeza.
- **Ley 21.719 (Protección de Datos Personales):** solo si el hallazgo afecta o podría afectar
  datos personales; si no, "no aplica". Siempre advierte que su vigencia es diferida y que la
  entrada en vigor debe verificarse antes de citarla.

Cada referencia lleva artículo solo si el auditor lo verificó contra el texto oficial; si no,
queda `verificar`. Todo el mapeo legal se etiqueta como orientativo, no como dictamen jurídico.

**Why this priority**: es el aporte diferencial de la auditoría híbrida, pero depende del mapeo
ISO (P1) para ubicar la debilidad y tiene más riesgo de error, por eso va segundo.

**Independent Test**: con un hallazgo ficticio, el flujo agrega la obligación 21.663 con
certeza, marca 21.719 como "no aplica" o con su advertencia de vigencia, deja los artículos en
`verificar`, y la matriz recibe las columnas legales al final sin alterar las 11 de 001.

**Acceptance Scenarios**:

1. **Given** un hallazgo sin datos personales involucrados, **When** se mapea, **Then** la
   Ley 21.719 queda "no aplica" con justificación [INFERENCIA].
2. **Given** un hallazgo que expone un servicio con posibles datos personales, **When** se
   mapea, **Then** la Ley 21.719 registra la obligación, la advertencia de vigencia diferida y
   certeza no mayor que `Media` mientras la vigencia no esté verificada.
3. **Given** que el auditor no verificó un artículo, **When** se mapea, **Then** el artículo
   queda `verificar` y entra en la lista de verificación de artículos.
4. **Given** cualquier hallazgo, **When** se mapea, **Then** la Ley 21.459 no aparece como
   obligación del hallazgo.

---

### User Story 3 - Verificar artículos y consolidar el mapa normativo (Priority: P3)

El flujo mantiene una **lista de verificación de artículos** con cada referencia legal
pendiente (`verificar`): qué hallazgo la usa, qué ley y qué obligación. El auditor consulta la
fuente oficial y registra el artículo verificado, la fuente y la fecha. Al verificarse, el
artículo se propaga al hallazgo y a la matriz.

Además, el flujo produce un **mapa normativo** consolidado: una vista por marco (ISO, 21.663,
21.719) con los hallazgos que afectan a cada control u obligación, y una nota única que ubica a
la Ley 21.459 como marco de la autorización de las pruebas.

**Why this priority**: cierra el ciclo de veracidad (principio III) y prepara el insumo del
informe (funcionalidad 003), pero el mapeo por hallazgo ya es útil sin él.

**Independent Test**: con una referencia `verificar` en la lista, el auditor registra artículo,
fuente y fecha; el hallazgo y la matriz muestran el artículo y el validador comprueba que
coinciden. El mapa normativo lista ese hallazgo bajo su control y su obligación.

**Acceptance Scenarios**:

1. **Given** una referencia pendiente, **When** el auditor la verifica, **Then** la lista la
   marca verificada con fuente y fecha, y el artículo aparece en el hallazgo y en la matriz.
2. **Given** que no quedan referencias pendientes, **When** se revisa la lista, **Then** todas
   están verificadas o descartadas con motivo.
3. **Given** el mapa normativo, **When** el auditor parte de un control o de una obligación,
   **Then** llega a los hallazgos que lo afectan y, desde ellos, a la evidencia.

---

### Edge Cases

- **No hay hallazgos:** el flujo informa que no hay nada que mapear y no genera mapeos; el mapa
  normativo y la lista de verificación quedan vacíos, salvo la nota sobre la Ley 21.459.
- **Hallazgo `descartado` en la revisión de 001:** se conserva sin mapear y la matriz deja sus
  columnas legales vacías; no entra al mapa normativo.
- **Hallazgo ya mapeado que se vuelve a procesar:** el mapeo existente se conserva; solo se
  completa lo vacío o lo que el auditor pidió corregir.
- **Control ISO que no existe en el Anexo A de la versión 2022** (p. ej. un control de la
  versión 2013): se rechaza y queda `verificar`.
- **Obligación 21.663 que depende de que la organización sea entidad obligada:** se registra
  en forma hipotética, con certeza no mayor que `Media` y [INFERENCIA] (FR-006).
- **Matriz con las columnas legales en otro orden o intercaladas con las de 001:** se informa
  como error; las 11 columnas de 001 siempre van primero y en su orden.
- **El auditor verifica un artículo distinto del propuesto:** prevalece el verificado y la
  lista conserva el motivo del cambio.
- **Referencia legal que resulta no aplicable al verificarla:** se marca "descartada" con motivo
  en la lista y el hallazgo vuelve a `verificar` o "no aplica", según corresponda.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El flujo MUST procesar solo hallazgos existentes de la funcionalidad 001 en estado
  distinto de `descartado`. No crea hallazgos ni evidencias nuevas, y la cadena Observación →
  Evidencia → Hallazgo → Recomendación de 001 no se modifica salvo el control ISO principal
  (FR-003).
- **FR-002**: Cada hallazgo mapeado MUST incluir una sección "Mapeo normativo", con:
  - mapeo ISO (FR-003, FR-004);
  - mapeo Ley 21.663 (FR-005, FR-006);
  - mapeo Ley 21.719 (FR-007);
  - la leyenda "Mapeo orientativo; no constituye dictamen jurídico" (constitución, principio V).
- **FR-003**: El mapeo ISO MUST tener exactamente un control principal del Anexo A de
  ISO/IEC 27001:2022 (o `verificar`), con certeza (Alta/Media/Baja) y justificación. El control
  principal reemplaza al preliminar en el campo `Control ISO` del hallazgo y en la columna
  `control_iso` de la matriz; si cambia, se registran el valor anterior y el motivo.
- **FR-004**: El mapeo ISO MAY incluir controles adicionales del Anexo A, distintos del
  principal. Todo control MUST existir en el Anexo A de la versión 2022.
- **FR-005**: El mapeo de la Ley 21.663 MUST indicar una categoría de obligación: `gestión de
  riesgos`, `medidas de seguridad`, `reporte de incidentes` o `no aplica`, con certeza y
  justificación. El artículo se cita solo si está verificado (FR-009); si no, `verificar`.
- **FR-006**: La aplicabilidad de la Ley 21.663 MUST evaluarse en forma hipotética: "si la
  organización dueña del activo fuera entidad obligada" (prestadora de servicios esenciales u
  operador de importancia vital). Cada mapeo 21.663 MUST incluir esa frase, etiquetarse
  [INFERENCIA] y tener certeza no mayor que `Media`, porque `docs/alcance.md` no define el tipo
  de organización.
- **FR-007**: El mapeo de la Ley 21.719 MUST ser `no aplica` (con justificación) si el hallazgo
  no afecta datos personales. Si los afecta o podría afectarlos, MUST indicar la obligación, la
  advertencia de vigencia diferida y una certeza no mayor que `Media` mientras la entrada en
  vigor no esté verificada en la lista de verificación.
- **FR-008**: La Ley 21.459 MUST NOT mapearse como obligación ni control de un hallazgo. Se
  menciona solo en el mapa normativo, como marco de la autorización de las pruebas
  (`docs/alcance.md`).
- **FR-009**: El flujo MUST mantener `salidas/verificacion_articulos.md` con una fila por cada
  referencia legal: hallazgo, ley, obligación, artículo propuesto o `verificar`, estado
  (`pendiente`, `verificado`, `descartado`), fuente oficial, fecha (AAAA-MM-DD) y comentario.
  Solo el auditor cambia el estado; `verificado` requiere fuente y fecha. La entrada en vigor de
  la Ley 21.719 es una fila más de esta lista.
- **FR-010**: Un artículo MUST aparecer en un hallazgo o en la matriz solo si su fila en la lista
  de verificación está `verificado`. Mientras tanto, el valor es `verificar`. MUST NOT
  inventarse números de artículo (constitución, principio III).
- **FR-011**: `salidas/matriz_hallazgos.csv` MUST conservar las 11 columnas de 001 primero y en
  su orden, y agregar al final, en este orden: `controles_iso_adicionales` (separados por `;`),
  `ley_21663_obligacion`, `ley_21663_articulo`, `ley_21663_certeza`, `ley_21719_obligacion`,
  `ley_21719_articulo`, `ley_21719_certeza`. Cada columna MUST coincidir con el hallazgo.
- **FR-012**: El flujo MUST producir `salidas/mapa_normativo.md` con una tabla por marco
  (ISO/IEC 27001:2022, Ley 21.663, Ley 21.719) que liste cada control u obligación con sus
  hallazgos, más la nota sobre la Ley 21.459 (FR-008) y la leyenda de FR-002.
- **FR-013**: El validador de solo lectura de 001 MUST extenderse para comprobar:
  - presencia y orden de las columnas legales de FR-011, y su coincidencia con cada hallazgo;
  - valores de los enumerados (categoría 21.663, certezas, estado de verificación);
  - que todo control ISO tenga formato válido y no repita el principal;
  - que ningún artículo aparezca sin su fila `verificado` en la lista (FR-010);
  - que `verificado` tenga fuente y fecha;
  - que ningún hallazgo mapee la Ley 21.459 como obligación;
  - que el mapa normativo y la matriz sean coherentes.

  Las comprobaciones de 001 siguen vigentes. Con la funcionalidad 002 activa, las columnas
  legales dejan de generar el aviso C12.
- **FR-014**: Toda afirmación del mapeo que no esté sustentada en la evidencia o en una fuente
  verificada MUST etiquetarse [INFERENCIA] (constitución, principio III).
- **FR-015**: El flujo MUST NOT ejecutar comandos contra sistemas ni consultar fuentes externas
  por su cuenta: la verificación de artículos la hace el auditor (constitución, principio IV).
- **FR-016**: Un cambio en el mapeo de un hallazgo con revisión `aprobado` o `corregido` MUST
  volver su bloque "Revisión" a `pendiente` hasta que el auditor lo revise de nuevo
  (constitución, principio VII).
- **FR-017**: Al terminar, el flujo MUST resumir lo mapeado, la cantidad de referencias
  pendientes de verificación y las dudas y supuestos, para la descripción del PR.

### Key Entities

- **Mapeo ISO**: pertenece a un hallazgo. Atributos:
  - control principal (y valor preliminar anterior, si cambió);
  - controles adicionales;
  - certeza;
  - justificación.
- **Mapeo legal**: pertenece a un hallazgo, uno por ley (21.663 y 21.719). Atributos:
  - obligación (categoría) o "no aplica";
  - artículo verificado o `verificar`;
  - certeza;
  - justificación;
  - advertencia de vigencia (solo 21.719).
- **Referencia por verificar**: fila de la lista de verificación de artículos. Atributos:
  - hallazgo y ley;
  - obligación;
  - artículo propuesto o `verificar`;
  - estado (`pendiente`, `verificado`, `descartado`);
  - fuente oficial, fecha y comentario.
- **Mapa normativo**: vista consolidada por marco, que relaciona controles y obligaciones con
  hallazgos.
- **Fila de la matriz (extendida)**: las 11 columnas de 001 más las 7 columnas legales de
  FR-011.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100 % de los hallazgos no descartados tiene un control ISO principal con
  certeza y justificación.
- **SC-002**: El 100 % de los hallazgos no descartados tiene mapeo de la Ley 21.663 y de la
  Ley 21.719 (obligación o "no aplica"), con certeza y justificación.
- **SC-003**: Hay 0 artículos citados en hallazgos o en la matriz sin una fila `verificado`
  con fuente y fecha en la lista de verificación.
- **SC-004**: Hay 0 hallazgos que mapeen la Ley 21.459 como obligación.
- **SC-005**: Las 11 primeras columnas de la matriz son idénticas a las de 001, y el 100 % de
  las columnas legales coincide con su hallazgo.
- **SC-006**: Partiendo de cualquier control u obligación del mapa normativo, el auditor llega
  a la evidencia de origen en menos de 3 minutos.
- **SC-007**: El 100 % de los hallazgos con mapeo modificado después de su aprobación vuelve a
  revisión `pendiente`.

## Assumptions

- **Dependencia de 001.** Esta funcionalidad parte de los hallazgos, la matriz y el validador
  de 001. Mientras no haya hallazgos reales (sus tareas T013 y T020 esperan evidencia del
  auditor), se prueba con fixtures ficticios.
- **Textos legales.** El repositorio no contiene los textos oficiales de las leyes ni la norma
  ISO. Claude propone categorías de obligación y controles a partir de su conocimiento, siempre
  con certeza y [INFERENCIA]; los números de artículo solo los fija el auditor tras consultar la
  fuente oficial.
- **Ley 21.719.** Su vigencia es diferida (`docs/alcance.md`); hasta verificarla, ninguna
  obligación de esa ley se presenta como exigible.
- **Ley 21.459.** No es un control de seguridad: delimita la autorización de las pruebas
  (constitución, sección de restricciones).
- **Datos del laboratorio.** Los datos del activo son ficticios; "afecta datos personales" se
  evalúa según el tipo de servicio o información expuesta, no según datos reales.
- **Resumen ejecutivo y plan de remediación.** Corresponden a la funcionalidad 003, que usará
  el mapa normativo como insumo.
- **Columnas legales.** Los nombres de FR-011 son una propuesta; el validador de 001 ya admite
  columnas adicionales al final.
