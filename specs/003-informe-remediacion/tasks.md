---

description: "Lista de tareas de la funcionalidad 003 — Informe y remediación"
---

# Tasks: Informe y remediación

**Input**: Documentos de diseño en `/specs/003-informe-remediacion/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: igual que en 001 y 002, el plan define fixtures y el runner existente
(`scripts/tests/Invoke-Pruebas.ps1`). Se incluyen como tareas.

**Organization**: las tareas se agrupan por historia de usuario, de modo que cada una se pueda
implementar y probar por separado.

**Estimación**: cada tarea termina con `[E5] [Talla: X | N pts]`, según `docs/estimacion.md`
(XS=1, S=2, M=3, L=5, XL=8). Ninguna tarea es XL ni L. La épica es **E5 Informe y remediación**
(issue #5).

**Regla de no ejecución** (FR-014): ninguna tarea ejecuta comandos contra sistemas ni consulta
fuentes externas desde scripts. Las tareas marcadas `[requiere hallazgos revisados]` necesitan
hallazgos reales en `salidas/hallazgos/` con Revisión `aprobado` o `corregido` (tareas T020 y
T028 de 001). Las marcadas `[requiere al auditor]` necesitan su revisión; Claude no cambia
estados de revisión ni de remediación (FR-006, FR-015).

## Format: `[ID] [P?] [Story] Descripción [Épica] [Talla]`

- **[P]**: se puede ejecutar en paralelo (archivos distintos, sin dependencias pendientes).
- **[Story]**: historia de usuario a la que pertenece (US1, US2, US3).

## Path Conventions

- `docs/plantillas/`
- `docs/flujo_prompt_e_hu.md`
- `scripts/Test-Salidas.ps1`
- `scripts/tests/fixtures/`
- `salidas/`
- `.github/`

---

## Phase 1: Setup (infraestructura compartida)

**Purpose**: plantillas y ajustes de repositorio que usan las tres historias.

- [ ] T001 [P] Crear `docs/plantillas/plan_remediacion.md` con la estructura de `contracts/plan-remediacion.md`.
  - Título `# Plan de remediación` y la nota sobre comandos propuestos solo contra `192.168.56.101`.
  - Líneas `- **Hallazgos excluidos (pendiente)**: 0` y `- **Hallazgos excluidos (descartado)**: 0`.
  - Tabla con el encabezado exacto `| Orden | Hallazgo | Evidencias | Severidad | Prioridad | Acción | Responsable sugerido | Plazo | Criterio de cierre | Estado | Fecha de cierre | Evidencia de cierre | Comentario |`, sin filas.
  - Bloque `## Revisión` (`Estado`: pendiente, `Revisor`, `Fecha`, `Comentario`).
  - Comentario HTML con las reglas: orden "prioridad (P0 → P3), luego severidad (Crítica → Informativa), luego ID"; plazo `N días` (P0 7, P1 30, P2 90, P3 180) o `Comentario` que empieza con `Plazo ajustado:`; `Estado` "`abierto` · `en curso` · `cerrado`"; `cerrado` exige fecha AAAA-MM-DD y `EV-NNN`, si no ambas `—`; responsable como rol, nunca un nombre; celdas sin `|`.

  [E5] [Talla: XS | 1 pts]
- [ ] T002 [P] Crear `docs/plantillas/resumen_ejecutivo.md` con la estructura de `contracts/resumen-ejecutivo.md`: las 7 secciones de nivel 2 en orden (`Objetivo y alcance`, `Resultados por severidad`, `Riesgos principales`, `Prioridades de remediación`, `Implicancias normativas`, `Limitaciones`, `Revisión`), la tabla `| Severidad | Hallazgos |` con las 5 severidades en 0, la leyenda "> Mapeo orientativo; no constituye dictamen jurídico." y un comentario HTML con las reglas: ≤ 500 palabras antes de `## Revisión`; máximo 5 riesgos, cada uno con un `H-NNN` revisado; sin comandos ni IPs; artículos solo `verificado`; `21.719` con "vigencia" mientras la entrada en vigor no esté verificada; `21.459` solo con "autorización"; [INFERENCIA] para lo que no venga de un hallazgo (FR-012) [E5] [Talla: XS | 1 pts]
- [ ] T003 [P] Agregar a la sección "Definition of Done" de `.github/pull_request_template.md` el ítem "- [ ] Plan de remediación y resumen ejecutivo revisados por el auditor (Revisión vuelve a `pendiente` si se regeneraron con cambios)" (research R7, FR-016) [E5] [Talla: XS | 1 pts]

---

## Phase 2: Foundational (prerrequisitos bloqueantes)

**Purpose**: la base del validador para 003 y el prompt de trabajo.

**⚠️ CRITICAL**: ninguna historia puede empezar hasta completar esta fase.

- [ ] T004 Preparar `scripts/Test-Salidas.ps1` para 003 (`contracts/test-salidas-003.md`, research R6).
  - En `Get-Contexto`: leer `plan_remediacion.md` (metadatos con `Get-Metadatos`, tabla con `Get-TablaMarkdown`, bloque Revisión) y `resumen_ejecutivo.md` (texto, secciones de nivel 2 y bloque Revisión), si existen.
  - Calcular el conjunto de hallazgos revisados (`Estado` `aprobado` o `corregido`) y los recuentos de `pendiente` y `descartado`.
  - Banderas: `HayPlan` activa C23–C25; `HayResumen` activa C26–C27; cualquiera de las dos activa C28 y C29.
  - Sin ninguno de los dos archivos, nada de 003 se ejecuta ni se imprime: todos los fixtures de 001 y 002 dan el mismo código y la misma salida (SC-006; el runner sigue en 0).

  [E5] [Talla: M | 3 pts]
- [ ] T005 [P] Agregar a `docs/flujo_prompt_e_hu.md` una sección "2d. Prompt de informe y remediación" que:
  - use solo hallazgos `aprobado` o `corregido`, su fila de la matriz y los inventarios; no cree ni modifique hallazgos, evidencias, recomendaciones ni la matriz (FR-001);
  - genere `salidas/plan_remediacion.md` desde `docs/plantillas/plan_remediacion.md`, copiando acción, prioridad, severidad, responsable y criterio de cierre de la matriz (FR-003), con el orden de FR-004, el plazo derivado de FR-005, `Estado` `abierto` y los recuentos de excluidos (FR-007);
  - genere `salidas/resumen_ejecutivo.md` desde `docs/plantillas/resumen_ejecutivo.md`, en lenguaje no técnico (FR-010), ≤ 500 palabras, máximo 5 riesgos con su `H-NNN`, la leyenda normativa y citas legales solo `verificado` (FR-011);
  - etiquete [INFERENCIA] lo que no provenga de un hallazgo revisado (FR-012) y enmascare credenciales y datos personales (FR-013);
  - mantenga los comandos del plan como "propuesto: lo ejecuta el auditor" contra `192.168.56.101` y no ejecute nada (FR-014);
  - deje ambos documentos en Revisión `pendiente` y, si regenera uno `aprobado` o `corregido` con cambios, vacíe revisor y fecha y conserve el comentario como "Revisión previa:" (FR-015, FR-016);
  - cierre con el validador y un resumen para el PR: lo generado, hallazgos excluidos, dudas y supuestos (FR-019).

  [E5] [Talla: S | 2 pts]

**Checkpoint**: validador preparado sin cambiar resultados de 001 y 002, y prompt §2d listo.

---

## Phase 3: User Story 1 — Plan de remediación priorizado (Priority: P1) 🎯 MVP

**Goal**: `salidas/plan_remediacion.md` con una entrada por hallazgo revisado, igual a la
matriz, ordenada por prioridad, severidad e ID, con plazo y estado de remediación.

**Independent Test**: el runner pasa con los fixtures de C23–C25. Con dos hallazgos ficticios
aprobados de distinta severidad, el plan tiene dos filas en el orden correcto y el validador
termina con 0.

### Validación de US1

- [ ] T006 [US1] Implementar C23 en `scripts/Test-Salidas.ps1` (`contracts/plan-remediacion.md`): encabezado de la tabla exacto y en orden; las dos líneas de excluidos presentes, enteras e iguales al recuento de hallazgos `pendiente` y `descartado` (FR-007); `Severidad` ∈ "`Crítica` | `Alta` | `Media` | `Baja` | `Informativa`"; `Prioridad` ∈ "`P0`…`P3`"; `Estado` ∈ "`abierto` · `en curso` · `cerrado`" [E5] [Talla: S | 2 pts]
- [ ] T007 [US1] Implementar C24 en `scripts/Test-Salidas.ps1`.
  - Exactamente una fila por hallazgo revisado; ningún `H-NNN` repetido, inexistente, `pendiente` o `descartado` (FR-002, SC-001).
  - `Evidencias` igual a `evidencias` de la matriz con `;` → `; `; `Severidad`, `Prioridad`, `Acción` (= `recomendacion`), `Responsable sugerido` y `Criterio de cierre` iguales a la matriz (FR-003, SC-002).
  - `Orden` = 1…n consecutivo y filas ordenadas por prioridad (P0 → P3), severidad (Crítica → Informativa) e ID (FR-004).

  [E5] [Talla: M | 3 pts]
- [ ] T008 [US1] Implementar C25 en `scripts/Test-Salidas.ps1`: `Plazo` cumple `^\d+ días$`; si difiere del derivado (P0 7, P1 30, P2 90, P3 180), `Comentario` empieza con `Plazo ajustado:` (FR-005); `cerrado` ⇒ `Fecha de cierre` `^\d{4}-\d{2}-\d{2}$` y `Evidencia de cierre` = un `EV-NNN` del inventario; en otro estado ambas `—` (FR-006); ninguna IPv4 distinta de `192.168.56.101` en el archivo (FR-014) [E5] [Talla: S | 2 pts]
- [ ] T009 [P] [US1] Extender `scripts/tests/fixtures/valido/`.
  - Agregar `H-002` ficticio aprobado de severidad `Baja`, prioridad `P3`, con evidencia `EV-900`, mapeo ISO completo y legal en `no aplica`, y su fila coherente en la matriz y en `mapa_normativo.md` (C1–C22 siguen en OK).
  - Agregar `salidas/plan_remediacion.md` con `H-001` (Media, P2, 90 días) y `H-002` (Baja, P3, 180 días) en ese orden, estado `abierto`, Revisión `aprobado` con revisor y fecha.
  - Crear `invalido-c23-encabezado/`, `invalido-c23-excluidos-mal-contados/`, `invalido-c24-fila-faltante/`, `invalido-c24-accion-distinta/`, `invalido-c24-orden/`, `invalido-c25-plazo-sin-motivo/`, `invalido-c25-cerrado-sin-evidencia/` e `invalido-c25-ip-ajena/`; cada uno rompe una sola regla y explica cuál en su `LEEME.md`.

  [E5] [Talla: M | 3 pts]

### Ejecución del flujo en US1

- [ ] T010 [US1] Ejecutar el prompt §2d (parte plan) y generar `salidas/plan_remediacion.md` con una fila por hallazgo revisado, plazo derivado, estado `abierto`, recuento de excluidos y Revisión `pendiente`. Comprobar que el validador termina con 0 (SC-001, SC-002) [requiere hallazgos revisados] (#24) [E5] [Talla: S | 2 pts]

**Checkpoint**: US1 funcional y validada; es el MVP entregable ("Plan de remediación").

---

## Phase 4: User Story 2 — Resumen ejecutivo de una página (Priority: P2)

**Goal**: `salidas/resumen_ejecutivo.md` de ≤ 500 palabras, con conteos iguales a la matriz,
riesgos trazables a hallazgos y citas legales solo verificadas.

**Independent Test**: el runner pasa con los fixtures de C26–C27. Con los hallazgos de US1,
el resumen no supera 500 palabras, sus conteos coinciden con la matriz y cada riesgo cita un
hallazgo existente (SC-003, SC-004, SC-005).

### Validación de US2

- [ ] T011 [US2] Implementar C26 en `scripts/Test-Salidas.ps1` (`contracts/resumen-ejecutivo.md`, research R4).
  - Las 7 secciones de nivel 2 en orden y las 6 primeras no vacías.
  - Palabras (tokens separados por espacios con al menos una letra o dígito) desde el título hasta `## Revisión`, sin comentarios HTML: máximo 500.
  - Tabla `| Severidad | Hallazgos |` con las 5 severidades y conteos iguales a los hallazgos revisados de la matriz.
  - `Riesgos principales`: 1–5 ítems numerados, cada uno con al menos un `H-NNN` revisado; 0 ítems solo si no hay revisados.
  - `Prioridades de remediación`: todo `H-NNN` citado está en el plan (si no hay plan, error).
  - Agregar al resumen final las palabras del resumen.

  [E5] [Talla: M | 3 pts]
- [ ] T012 [US2] Implementar C27 en `scripts/Test-Salidas.ps1` (research R5): en `Implicancias normativas`, la leyenda "Mapeo orientativo; no constituye dictamen jurídico"; toda mención `artículo X` o `art. X` usa un artículo con fila `verificado` en `verificacion_articulos.md`; si la fila `entrada en vigor` no está `verificado` (o no existe la lista), cada línea con `21.719` contiene `vigencia`; cada línea con `21.459` contiene `autorización`. En todo el archivo: ninguna IPv4 distinta de `192.168.56.101` y ninguna marca `propuesto: lo ejecuta el auditor` [E5] [Talla: S | 2 pts]
- [ ] T013 [P] [US2] Agregar a `scripts/tests/fixtures/valido/` el `salidas/resumen_ejecutivo.md` coherente con H-001 y H-002 (Media 1, Baja 1; dos riesgos; leyenda; 21.719 con "vigencia"; Revisión `aprobado`) y crear `invalido-c26-seccion-faltante/`, `invalido-c26-mas-de-500-palabras/`, `invalido-c26-conteo-distinto/`, `invalido-c26-riesgo-sin-hallazgo/`, `invalido-c27-sin-leyenda/`, `invalido-c27-articulo-no-verificado/`, `invalido-c27-21719-sin-vigencia/` e `invalido-c27-comando-en-resumen/`; cada uno rompe una sola regla y lo explica en su `LEEME.md` [E5] [Talla: M | 3 pts]

### Ejecución del flujo en US2

- [ ] T014 [US2] Ejecutar el prompt §2d (parte resumen) y generar `salidas/resumen_ejecutivo.md` desde la plantilla, con conteos de la matriz, riesgos con su hallazgo, prioridades del plan, implicancias normativas orientativas y limitaciones; Revisión `pendiente`. Comprobar que el validador termina con 0 y `[AVISO]` C29 [requiere hallazgos revisados] (#23) [E5] [Talla: S | 2 pts]

**Checkpoint**: US1 y US2 funcionan; el informe tiene plan y resumen trazables a los hallazgos.

---

## Phase 5: User Story 3 — Revisión y cierre del informe (Priority: P3)

**Goal**: ambos documentos con bloque Revisión válido y un aviso mientras el informe no esté
cerrado.

**Independent Test**: el runner pasa con los fixtures de C28 y C29. Con plan y resumen
`aprobado`, el validador termina con 0, sin C29, e informa "informe cerrado".

### Validación de US3

- [ ] T015 [US3] Implementar C28 y C29 en `scripts/Test-Salidas.ps1`.
  - **C28:** en cada documento existente, bloque `## Revisión` con `Estado` ∈ "`pendiente` · `aprobado` · `corregido`" (`descartado` no aplica); si no es `pendiente`, `Revisor` no vacío y `Fecha` `^\d{4}-\d{2}-\d{2}$` (FR-015).
  - **C29:** `[AVISO]` si existe uno de los dos documentos y falta el otro, o si alguno está `pendiente`.
  - Resumen final: entradas del plan por estado (`abierto` / `en curso` / `cerrado`) y "informe cerrado" o "informe no cerrado".

  [E5] [Talla: S | 2 pts]
- [ ] T016 [P] [US3] Crear `invalido-c28-aprobado-sin-revisor/`, `invalido-c28-estado-descartado/`, `aviso-c29-informe-pendiente/` (plan y resumen en `pendiente`, termina con 0 y `[AVISO]` C29) y `aviso-c29-falta-resumen/` (solo plan, termina con 0 y `[AVISO]` C29) en `scripts/tests/fixtures/`; comprobar que `valido/` (ambos `aprobado`) no muestra C29 [E5] [Talla: S | 2 pts]

### Ejecución del flujo en US3

- [ ] T017 [US3] Revisión humana: el auditor revisa `salidas/plan_remediacion.md` y `salidas/resumen_ejecutivo.md` (lenguaje no técnico, [INFERENCIA], enmascaramiento, plazos), ajusta plazos con `Plazo ajustado:` si corresponde, completa ambos bloques Revisión y mide la lectura del resumen por una persona no técnica (SC-003, < 3 min). Abrir el PR contra `main` con el checklist de la DoD y `Closes #23`, `Closes #24` [requiere al auditor] [requiere hallazgos revisados] (#23, #24) [E5] [Talla: S | 2 pts]

**Checkpoint**: el informe queda cerrado con revisión humana; la cadena llega de la evidencia
al plan y al resumen.

---

## Phase 6: Polish y aspectos transversales

**Purpose**: documentación y medición.

- [ ] T018 [P] Actualizar la sección de validación de `README.md` con C23–C29 y los dos archivos nuevos de `salidas/`, y agregar en `specs/001-analisis-evidencias/contracts/test-salidas.md` una nota que remita a `specs/003-informe-remediacion/contracts/test-salidas-003.md` [E5] [Talla: XS | 1 pts]
- [ ] T019 Ejecutar los escenarios 0 y 4 de `specs/003-informe-remediacion/quickstart.md` (y 1–3 si hay hallazgos revisados). Medir con `Measure-Command` el validador sobre `salidas/` y sobre `scripts/tests/fixtures/valido/` (meta < 5 s). Pegar el resultado, dudas y supuestos en la descripción del PR (FR-019) [E5] [Talla: S | 2 pts]

---

## Resumen de estimación

| Fase | Tareas | Puntos |
|---|---|---|
| Setup | T001–T003 | 3 |
| Foundational | T004–T005 | 5 |
| US1 (P1, MVP) | T006–T010 | 12 |
| US2 (P2) | T011–T014 | 10 |
| US3 (P3) | T015–T017 | 6 |
| Polish | T018–T019 | 3 |
| **Total** | **19** | **39** |

Todas las tareas son de la épica **E5 Informe y remediación**.

Tallas: 4 XS · 10 S · 5 M · 0 L · 0 XL.

Sin hallazgos revisados ni al auditor se pueden completar 15 tareas (31 pts); quedan bloqueadas
T010, T014, T017 y T019 (parcial: escenarios 1–3).

---

## Dependencies & Execution Order

### Dependencias entre fases

- **Setup (fase 1):** sin dependencias.
- **Foundational (fase 2):** T004 bloquea todas las tareas del validador. T005 es independiente.
- **US1 (fase 3):** depende de la fase 2.
- **US2 (fase 4):** depende de la fase 2; C26 cruza con el plan, así que sus fixtures (T013) parten del `valido/` de T009.
- **US3 (fase 5):** depende de US1 y US2 (revisa ambos documentos).
- **Polish (fase 6):** depende de las historias que se entreguen.
- **Ejecución sobre `salidas/`** (T010, T014, T017): depende además de hallazgos reales revisados (T020 y T028 de 001) y, para la parte normativa, de T010, T014 y T020 de 002.

### Dentro de cada historia

- Las comprobaciones del validador van antes que sus fixtures inválidos, para comprobar que fallan por la razón correcta.
- Las tareas que tocan `scripts/Test-Salidas.ps1` son secuenciales: T004 → T006 → T007 → T008 → T011 → T012 → T015.
- Las tareas que tocan `scripts/tests/fixtures/valido/` son secuenciales: T009 → T013 → T016.

### Parallel Opportunities

- **Fase 1:** T001, T002 y T003 en paralelo.
- **Fase 2:** T005 en paralelo con T004.
- **US1:** T009 en paralelo con T008, una vez hecho T007.
- **US2:** T013 en paralelo con T012, una vez hecho T011.
- **Polish:** T018 en paralelo con T019.

---

## Parallel Example: Setup y Foundational

```text
Task: "T001 Crear docs/plantillas/plan_remediacion.md"
Task: "T002 Crear docs/plantillas/resumen_ejecutivo.md"
Task: "T003 Ítem de DoD en .github/pull_request_template.md"
# en paralelo con la preparación del validador (T004):
Task: "T005 Sección 2d en docs/flujo_prompt_e_hu.md"
```

---

## Implementation Strategy

### MVP primero (solo US1)

1. Fases 1 y 2 (8 pts).
2. Fase 3: US1 (12 pts). **Subtotal: 20 pts**, dentro del tope de 20 por sprint.
3. **Detenerse y validar:** el runner pasa y `valido/` tiene un plan con dos filas en el orden
   correcto.

### Entrega incremental

1. Setup + Foundational → plantillas, prompt §2d y validador preparado sin romper 001/002 → PR.
2. US1 → plan de remediación (MVP) → PR.
3. US2 → resumen ejecutivo → PR.
4. US3 → revisión y cierre → PR.
5. Polish → documentación y medición → PR final.

---

## Notes

- `[P]` = archivos distintos y sin dependencias pendientes.
- Hacer commit después de cada tarea o grupo lógico; un PR por fase o historia, con `Closes #n`.
- Las tareas de ejecución usan los issues existentes #23 y #24 de la épica E5; las demás se
  crean en el Project sin duplicarlos. #22 (Matriz de hallazgos) ya está cerrado.
- Ningún fixture contiene artículos legales reales sin verificar: si hace falta uno, se usa
  `ARTICULO-FICTICIO` como en 002 (FR-011).
