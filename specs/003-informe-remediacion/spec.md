# Feature Specification: Informe y remediación

**Feature Branch**: `feat/003-informe-remediacion` (directorio de la funcionalidad: `specs/003-informe-remediacion`)

**Created**: 2026-10-29

**Status**: Draft

**Input**: User description: "003-informe-remediacion: Épica E5 "Informe y remediación" (issues #23 Resumen ejecutivo y #24 Plan de remediación). A partir de los hallazgos aprobados en salidas/hallazgos/H-NNN.md, la matriz salidas/matriz_hallazgos.csv (18 columnas, con mapeo normativo de 002) y el inventario de activos, generar: (1) salidas/resumen_ejecutivo.md de máximo una página, con riesgos principales y prioridades de remediación, para lectores no técnicos; (2) salidas/plan_remediacion.md con, por hallazgo, acción, responsable sugerido, plazo y forma de validar el cierre, priorizado por severidad. Debe mantener la trazabilidad Observación→Evidencia→Hallazgo→Recomendación, las etiquetas [HECHO]/[INFERENCIA], no inventar datos, enmascarar credenciales y datos personales, tratar el mapeo legal como orientativo, y respetar que Claude no ejecuta comandos. Incluir plantillas en docs/plantillas/, una sección de prompt en docs/flujo_prompt_e_hu.md, nuevas comprobaciones en scripts/Test-Salidas.ps1 con fixtures (compatibles con 001 y 002, que deben seguir pasando), y revisión humana obligatoria antes de dar por cerrado el informe."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Plan de remediación priorizado (Priority: P1)

El auditor ya tiene hallazgos revisados (estado `aprobado` o `corregido`), cada uno con su
recomendación de 001. El flujo genera un **plan de remediación** con una entrada por hallazgo
revisado:

- acción a realizar (la recomendación del hallazgo);
- prioridad y severidad;
- responsable sugerido;
- plazo sugerido;
- criterio de cierre (cómo se valida que quedó resuelto);
- referencia al hallazgo y a sus evidencias.

Las entradas se ordenan por prioridad y, dentro de la misma prioridad, por severidad e ID.

**Why this priority**: es el entregable accionable de la auditoría (issue #24) y consolida las
recomendaciones que la constitución exige por hallazgo. El resumen ejecutivo (P2) se apoya en él.

**Independent Test**: con dos hallazgos ficticios aprobados de distinta severidad, el flujo
genera el plan con dos entradas en el orden correcto, cada una coincide con su hallazgo y su
fila de la matriz, y el validador termina sin errores.

**Acceptance Scenarios**:

1. **Given** hallazgos aprobados de severidad Alta y Media, **When** se genera el plan,
   **Then** el de severidad Alta aparece primero, con prioridad P1 y plazo sugerido de P1.
2. **Given** un hallazgo `pendiente` o `descartado`, **When** se genera el plan, **Then** no
   aparece como entrada; el plan informa cuántos hallazgos quedaron fuera por estar pendientes.
3. **Given** una entrada del plan, **When** el auditor la lee, **Then** la acción, la prioridad,
   el responsable y el criterio de cierre coinciden con el hallazgo y con la matriz.
4. **Given** una recomendación con comandos propuestos, **When** pasa al plan, **Then** los
   comandos siguen marcados "propuesto: lo ejecuta el auditor" y apuntan solo a
   `192.168.56.101`.

---

### User Story 2 - Resumen ejecutivo de una página (Priority: P2)

El flujo genera un **resumen ejecutivo** para lectores no técnicos (propietario del activo,
dirección), de máximo una página:

- objetivo y alcance en una o dos frases;
- conteo de hallazgos por severidad;
- los riesgos principales en lenguaje no técnico (máximo cinco), cada uno con su hallazgo;
- las prioridades de remediación, tomadas del plan;
- implicancias normativas en una o dos frases, con la leyenda de que el mapeo es orientativo;
- limitaciones (evidencia insuficiente, hallazgos pendientes de revisión, referencias legales
  por verificar).

**Why this priority**: es el entregable de cierre del issue #23, pero depende del plan (P1)
para las prioridades.

**Independent Test**: con los hallazgos ficticios de US1, el resumen cabe en el límite de
extensión, sus conteos coinciden con la matriz y cada riesgo cita un hallazgo existente.

**Acceptance Scenarios**:

1. **Given** hallazgos aprobados, **When** se genera el resumen, **Then** el conteo por
   severidad coincide con la matriz y no supera el límite de extensión.
2. **Given** un riesgo descrito en el resumen, **When** el lector busca su origen, **Then**
   encuentra el ID del hallazgo y, desde él, la evidencia.
3. **Given** que la entrada en vigor de la Ley 21.719 no está verificada, **When** se redacta
   la parte normativa, **Then** la Ley 21.719 no se cita como obligación vigente.
4. **Given** que no hay hallazgos revisados, **When** se genera el resumen, **Then** lo dice
   explícitamente y no inventa riesgos.

---

### User Story 3 - Revisión y cierre del informe (Priority: P3)

El resumen y el plan llevan cada uno un bloque **Revisión** (estado, revisor, fecha,
comentario), igual que los hallazgos. El informe se da por cerrado solo cuando el auditor
aprueba ambos. Si después cambia un hallazgo, la matriz o el plan, la revisión del documento
afectado vuelve a `pendiente`.

**Why this priority**: la constitución (principio VII) exige revisión humana; esta historia la
hace explícita y verificable, pero los documentos ya son útiles como borrador sin ella.

**Independent Test**: con un resumen aprobado, se modifica un hallazgo; al regenerar, el
resumen vuelve a `pendiente` con la revisión anterior conservada en el comentario.

**Acceptance Scenarios**:

1. **Given** un resumen y un plan generados, **When** el flujo termina, **Then** ambos quedan
   en revisión `pendiente`.
2. **Given** un documento `aprobado`, **When** el flujo lo regenera con cambios, **Then** vuelve
   a `pendiente`, se vacían revisor y fecha y el comentario anterior se conserva con el prefijo
   "Revisión previa:".
3. **Given** ambos documentos `aprobado`, **When** se revisa el estado del informe, **Then** el
   informe cuenta como cerrado.

---

### Edge Cases

- **No hay hallazgos revisados:** el plan queda sin entradas, con la nota "sin hallazgos
  revisados"; el resumen lo dice y lista las limitaciones.
- **Todos los hallazgos son `Informativa`:** el plan los incluye con prioridad P3; el resumen
  indica que no hay riesgos de severidad Baja o superior.
- **El auditor ajustó la prioridad en la revisión** (distinta de la derivada de la severidad):
  prevalece la prioridad de la matriz; el plazo sigue a la prioridad ajustada.
- **Recomendación que cubre varios hallazgos:** cada hallazgo mantiene su entrada; el plan
  puede indicar en la acción que se resuelve junto con otro hallazgo, citando su ID.
- **Más de cinco riesgos relevantes:** el resumen muestra los cinco de mayor prioridad y remite
  al plan para el resto.
- **Hallazgo con mapeo normativo sin verificar:** el resumen puede mencionar la obligación
  candidata como orientativa, pero no cita artículos que no estén `verificado` (FR-010 de 002).
- **Dato sensible en una recomendación** (usuario, ruta con nombre de persona): se enmascara
  igual que en el hallazgo.
- **Matriz incompleta o con columnas legales vacías** (funcionalidad 002 no aplicada): el plan
  se genera igual; el resumen omite la parte normativa e indica la limitación.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El flujo MUST usar solo hallazgos existentes con revisión `aprobado` o
  `corregido`, su fila de la matriz y los inventarios de 001. No crea hallazgos, evidencias ni
  recomendaciones nuevas, y no modifica hallazgos ni la matriz.
- **FR-002**: El flujo MUST producir `salidas/plan_remediacion.md` con una entrada por hallazgo
  revisado, con: ID del hallazgo, evidencias, severidad, prioridad, acción, responsable
  sugerido, plazo sugerido, criterio de cierre y estado de remediación.
- **FR-003**: La acción, la prioridad, el responsable sugerido y el criterio de cierre de cada
  entrada MUST coincidir con las columnas `recomendacion`, `prioridad`, `responsable_sugerido`
  y `criterio_cierre` de la matriz, y la severidad con `severidad`.
- **FR-004**: Las entradas del plan MUST ordenarse por prioridad (P0 a P3), luego por severidad
  (Crítica a Informativa) y luego por ID.
- **FR-005**: El plazo sugerido MUST derivarse de la prioridad: P0 → 7 días, P1 → 30 días,
  P2 → 90 días, P3 → 180 días, contados desde la fecha de aprobación del plan. Solo el auditor
  lo ajusta, en la revisión, anotando el motivo en el comentario de la entrada.
- **FR-006**: El estado de remediación de cada entrada MUST ser `abierto`, `en curso` o
  `cerrado`; el flujo lo crea en `abierto` y solo el auditor lo cambia. `cerrado` exige fecha
  (AAAA-MM-DD) y la referencia a la evidencia que valida el cierre.
- **FR-007**: El plan MUST indicar cuántos hallazgos quedaron fuera por estar `pendiente` y
  cuántos por estar `descartado`.
- **FR-008**: El flujo MUST producir `salidas/resumen_ejecutivo.md` de máximo una página
  (≤ 500 palabras, sin contar comentarios ni el bloque Revisión), con las secciones: objetivo y
  alcance, resultados por severidad, riesgos principales (máximo cinco), prioridades de
  remediación, implicancias normativas y limitaciones.
- **FR-009**: El conteo por severidad del resumen MUST coincidir con los hallazgos revisados de
  la matriz. Cada riesgo principal MUST citar al menos un ID de hallazgo revisado.
- **FR-010**: El resumen MUST escribirse en lenguaje no técnico: sin comandos, puertos ni
  versiones salvo que sean imprescindibles para entender el riesgo, y entonces con una frase que
  los explique.
- **FR-011**: La sección de implicancias normativas MUST llevar la leyenda "Mapeo orientativo;
  no constituye dictamen jurídico", citar artículos solo si están `verificado` en
  `salidas/verificacion_articulos.md` y no citar la Ley 21.719 como obligación vigente mientras
  su entrada en vigor no esté verificada. La Ley 21.459 se menciona solo como marco de la
  autorización.
- **FR-012**: Toda afirmación del resumen y del plan que no provenga de un hallazgo revisado o
  de una fuente verificada MUST etiquetarse [INFERENCIA] (constitución, principio III).
- **FR-013**: El resumen y el plan MUST NOT contener contraseñas, hashes, tokens, claves ni
  datos personales sin enmascarar (constitución, principio V).
- **FR-014**: Los comandos que aparezcan en el plan MUST apuntar solo a `192.168.56.101` y
  estar marcados "propuesto: lo ejecuta el auditor". El flujo MUST NOT ejecutar comandos
  (constitución, principio IV). El resumen no incluye comandos.
- **FR-015**: El resumen y el plan MUST tener un bloque "Revisión" con estado (`pendiente`,
  `aprobado`, `corregido`), revisor, fecha (AAAA-MM-DD) y comentario. El flujo los crea en
  `pendiente`; solo el auditor cambia el estado.
- **FR-016**: Si el flujo regenera un documento con revisión `aprobado` o `corregido` y su
  contenido cambia, MUST volver la revisión a `pendiente`, vaciar revisor y fecha y conservar el
  comentario anterior con el prefijo "Revisión previa:".
- **FR-017**: El validador de solo lectura MUST extenderse para comprobar, cuando existan los
  archivos:
  - formato del plan y valores de los enumerados (prioridad, severidad, estado de remediación,
    estado de revisión);
  - que haya una entrada por cada hallazgo revisado y ninguna de otros hallazgos;
  - coincidencia de cada entrada con la matriz (FR-003) y el orden (FR-004);
  - plazo coherente con la prioridad, salvo ajuste con motivo (FR-005);
  - que `cerrado` tenga fecha y evidencia de cierre (FR-006);
  - secciones, extensión, conteos y referencias del resumen (FR-008, FR-009);
  - leyenda y citas legales del resumen (FR-011);
  - bloque Revisión de ambos documentos (FR-015).

  Las comprobaciones de 001 y 002 siguen vigentes y sus fixtures dan el mismo resultado. Si los
  archivos no existen, las comprobaciones nuevas no se ejecutan.
- **FR-018**: El proyecto MUST incluir plantillas de ambos documentos en `docs/plantillas/` y un
  prompt para generarlos en `docs/flujo_prompt_e_hu.md`.
- **FR-019**: Al terminar, el flujo MUST resumir lo generado, los hallazgos excluidos y las
  dudas y supuestos, para la descripción del PR.

### Key Entities

- **Entrada del plan**: una por hallazgo revisado. Atributos: hallazgo, evidencias, severidad,
  prioridad, acción, responsable sugerido, plazo sugerido, criterio de cierre, estado de
  remediación, fecha y evidencia de cierre, comentario.
- **Plan de remediación**: conjunto ordenado de entradas, con el conteo de hallazgos excluidos
  y su bloque Revisión.
- **Riesgo principal**: descripción no técnica de un riesgo, con los hallazgos que lo sustentan
  y su prioridad.
- **Resumen ejecutivo**: documento de una página con objetivo, resultados por severidad,
  riesgos principales, prioridades, implicancias normativas, limitaciones y bloque Revisión.
- **Revisión del documento**: estado, revisor, fecha y comentario, igual que la de un hallazgo.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100 % de los hallazgos revisados tiene exactamente una entrada en el plan, con
  acción, responsable, plazo y criterio de cierre.
- **SC-002**: El 100 % de las entradas del plan coincide con su fila de la matriz en severidad,
  prioridad, acción, responsable y criterio de cierre.
- **SC-003**: El resumen ejecutivo tiene como máximo 500 palabras y lo lee una persona no
  técnica en menos de 3 minutos.
- **SC-004**: El 100 % de los riesgos del resumen cita un hallazgo revisado, y desde él el
  lector llega a la evidencia en menos de 3 minutos.
- **SC-005**: Hay 0 artículos legales citados en el resumen sin fila `verificado`, y 0
  credenciales o datos personales sin enmascarar en ambos documentos.
- **SC-006**: Los fixtures de 001 y 002 dan el mismo resultado que antes de esta funcionalidad.
- **SC-007**: El 100 % de los documentos regenerados con cambios después de aprobarse vuelve a
  revisión `pendiente`.

## Assumptions

- **Dependencia de 001 y 002.** Parte de los hallazgos, la matriz, los inventarios y el mapeo
  normativo. Mientras no haya hallazgos reales (esperan evidencia del auditor), se prueba con
  fixtures ficticios.
- **Hallazgos revisados.** Solo `aprobado` y `corregido` entran al informe; así el informe nunca
  contiene un hallazgo que el auditor no validó (principio VII).
- **Plazos.** Los plazos de FR-005 son una propuesta habitual en remediación por prioridad;
  el auditor puede ajustarlos por entrada.
- **Una página.** Se mide como ≤ 500 palabras de contenido, que en Markdown renderizado o
  exportado a PDF cabe en una página A4/carta.
- **Responsable.** Es un rol (p. ej. "Administrador del sistema"), nunca el nombre de una
  persona, para no publicar datos personales en un repositorio público.
- **Formato.** Markdown versionado en git, como el resto de las salidas; la exportación a PDF o
  Word queda fuera de alcance.
- **Seguimiento de la remediación.** El plan registra el estado de cada entrada, pero ejecutar
  las acciones y obtener la evidencia de cierre es tarea del responsable y del auditor.
