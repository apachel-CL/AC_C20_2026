---

description: "Lista de tareas de la funcionalidad 002 — Mapeo normativo de hallazgos"
---

# Tasks: Mapeo normativo de hallazgos

**Input**: Documentos de diseño en `/specs/002-mapeo-normativo/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: igual que en 001, el plan define fixtures y el runner existente
(`scripts/tests/Invoke-Pruebas.ps1`). Se incluyen como tareas.

**Organization**: las tareas se agrupan por historia de usuario, de modo que cada una se pueda
implementar y probar por separado.

**Estimación**: cada tarea termina con `[E4] [Talla: X | N pts]`, según `docs/estimacion.md`
(XS=1, S=2, M=3, L=5, XL=8). Ninguna tarea es XL ni L. La épica es **E4 Mapeo normativo**
(issue #4).

**Regla de no ejecución** (FR-015): ninguna tarea ejecuta comandos contra sistemas ni consulta
fuentes externas desde scripts. Las tareas marcadas `[requiere hallazgos de 001]` necesitan
hallazgos reales en `salidas/hallazgos/` (tareas T013 y T020 de 001). Las marcadas
`[requiere al auditor]` necesitan que el auditor verifique artículos o revise; Claude no fija
números de artículo por su cuenta (FR-010).

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

- [X] T001 [P] Reemplazar el encabezado de `docs/plantillas/matriz_hallazgos.csv` por las 18 columnas de `contracts/matriz-columnas-legales.md`: las 11 de 001 seguidas de `controles_iso_adicionales,ley_21663_obligacion,ley_21663_articulo,ley_21663_certeza,ley_21719_obligacion,ley_21719_articulo,ley_21719_certeza`. UTF-8 sin BOM, solo encabezado [E4] [Talla: XS | 1 pts]
- [X] T002 [P] Agregar a la sección "Definition of Done" de `.github/pull_request_template.md` el ítem "- [ ] Mapeo normativo revisado por el auditor en cada H-NNN.md tocado (Revisión vuelve a `pendiente` si cambió)" (research R6, FR-016) [E4] [Talla: XS | 1 pts]
- [X] T003 [P] Crear `docs/plantillas/mapeo_normativo.md` con la sección `## Mapeo normativo` de `contracts/mapeo-hallazgo.md`, para pegar entre `## Recomendación` y `## Revisión` de cada `H-NNN.md`.
  - Leyenda "> Mapeo orientativo; no constituye dictamen jurídico."
  - Subsecciones ISO/IEC 27001:2022, Ley 21.663 y Ley 21.719 con todas las claves del contrato.
  - Comentario con los enumerados: obligación 21.663 "`gestión de riesgos` | `medidas de seguridad` | `reporte de incidentes` | `no aplica`"; certezas "`Alta` | `Media` | `Baja`"; artículo "`verificar`, `—` si no aplica, o el de una fila `verificado`".
  - Recordatorio: Ley 21.663 con "si la organización fuera entidad obligada" y certeza ≤ `Media` (Q1); Ley 21.719 `pendiente de vigencia` (con la obligación candidata en la justificación) mientras la entrada en vigor no esté verificada, y siempre con advertencia de vigencia; toda justificación con `[HECHO]` o `[INFERENCIA]` (FR-014); la Ley 21.459 no se mapea.

  [E4] [Talla: XS | 1 pts]

---

## Phase 2: Foundational (prerrequisitos bloqueantes)

**Purpose**: la base del validador para 002 y el prompt de trabajo.

**⚠️ CRITICAL**: ninguna historia puede empezar hasta completar esta fase.

- [X] T004 Preparar `scripts/Test-Salidas.ps1` para 002 (`contracts/test-salidas-002.md`, research R4).
  - Constante `$script:ColumnasLegales` con las 7 columnas de FR-011.
  - En `Get-Contexto`: leer `verificacion_articulos.md` (tabla `| ID | Hallazgo | Ley | Obligación | Artículo | Estado | Fuente | Fecha | Comentario |`) y `mapa_normativo.md` (texto), y marcar en cada hallazgo si tiene sección `## Mapeo normativo`.
  - Banderas: `MatrizExtendida` (la matriz tiene más de 11 columnas) activa C15; `Activo002` (algún hallazgo tiene la sección o existe alguno de los dos archivos nuevos) activa C16–C22.
  - En C8/C12: aceptar 11 columnas o 18; si hay más de 11, C12 avisa solo por las columnas posteriores a la 18.
  - Resumen final con "hallazgos mapeados / no descartados".
  - Sin cambiar el resultado de ningún fixture de 001 (el runner sigue en 0).

  [E4] [Talla: M | 3 pts]
- [X] T005 [P] Agregar a `docs/flujo_prompt_e_hu.md` una sección "2c. Prompt de mapeo normativo" (research R9) que:
  - procese solo hallazgos existentes y no `descartado` (FR-001);
  - use `docs/plantillas/mapeo_normativo.md`, `verificacion_articulos.md` y `mapa_normativo.md`;
  - confirme o corrija el control ISO principal, registre `Control ISO anterior` y `Motivo de corrección` y actualice `control_iso` de la matriz (FR-003);
  - aplique Q1 (21.663 hipotética, certeza ≤ `Media`); registre la 21.719 como `pendiente de vigencia` (obligación candidata solo en la justificación) mientras la fila `entrada en vigor` no esté `verificado`, con la advertencia de vigencia y el criterio de "podría afectar datos personales" de FR-007; deje la 21.459 solo en el mapa (FR-006–FR-008);
  - etiquete `[HECHO]` o `[INFERENCIA]` cada justificación (FR-014);
  - deje todo artículo en `verificar` y agregue su fila `pendiente` a la lista; prohíba inventar artículos y consultar fuentes externas (FR-010, FR-015);
  - en todo hallazgo cuyo mapeo cree o modifique, vuelva la Revisión a `pendiente`, vacíe revisor y fecha, conserve el comentario como "Revisión previa:" y alinee `estado_revision` en la matriz (FR-016);
  - cierre con el validador y un resumen para el PR con las referencias pendientes (FR-017).

  [E4] [Talla: S | 2 pts]
- [X] T006 [P] Crear el fixture `scripts/tests/fixtures/valido-sin-mapeo/`: copia de `valido/` con la matriz en 18 columnas y las 7 legales vacías, sin sección de mapeo, sin lista ni mapa. Debe terminar con 0, con `[OK] C15` (columnas legales vacías) y sin ejecutar C16–C22 (compatibilidad con 001) [E4] [Talla: XS | 1 pts]

**Checkpoint**: validador listo para las comprobaciones de 002, prompt §2c y caso de
compatibilidad.

---

## Phase 3: User Story 1 — Confirmar el mapeo ISO/IEC 27001:2022 (Priority: P1) 🎯 MVP

**Goal**: cada hallazgo con control ISO principal válido, controles adicionales y
justificación, y la matriz con `control_iso` y `controles_iso_adicionales` coherentes.

**Independent Test**: el runner pasa con los fixtures de C15–C17. Un hallazgo con
`Control ISO: verificar` queda con un control del Anexo A 2022 y el validador en 0.

### Validación de US1

- [X] T007 [US1] Implementar C15 en `scripts/Test-Salidas.ps1` (`contracts/matriz-columnas-legales.md`).
  - Si la matriz tiene más de 11 columnas, las columnas 12–18 son exactamente `$script:ColumnasLegales`, en orden.
  - Hallazgo sin sección de mapeo o `descartado`: las 7 columnas vacías.
  - Hallazgo mapeado: `controles_iso_adicionales` = `Controles ISO adicionales` con `;` sin espacios (o `—`), y cada columna legal = su campo homónimo (`Ley 21.663 obligación`, `Ley 21.663 artículo`, …).

  [E4] [Talla: M | 3 pts]
- [X] T008 [US1] Implementar en `scripts/Test-Salidas.ps1` la parte ISO de C16 y C17.
  - **C16 (ISO):** la sección contiene "no constituye dictamen jurídico"; `Controles ISO adicionales`, `Control ISO anterior`, `Motivo de corrección` y `Justificación ISO` presentes y no vacíos; `Justificación ISO` contiene `[HECHO]` o `[INFERENCIA]` (FR-014).
  - **C17:** todo control (principal y adicionales) cumple `^A\.\d{1,2}\.\d{1,2}$` y está en el Anexo A 2022: "`A.5.1`–`A.5.37`, `A.6.1`–`A.6.8`, `A.7.1`–`A.7.14` y `A.8.1`–`A.8.34`" (research R3); el principal también admite `verificar`; los adicionales no repiten el principal ni se repiten entre sí; si `Control ISO anterior` es `—`, `Motivo de corrección` es `confirmado`.

  [E4] [Talla: S | 2 pts]
- [X] T009 [P] [US1] Extender `scripts/tests/fixtures/valido/`: H-001 con sección de mapeo (parte ISO completa, partes legales en `no aplica` con artículo `—`), matriz en 18 columnas coherente, y crear los fixtures `invalido-c15-columnas-desordenadas/`, `invalido-c16-sin-leyenda/`, `invalido-c17-control-2013/` (p. ej. `A.12.6.1`) e `invalido-c17-adicional-repetido/`. Cada inválido rompe una sola regla [E4] [Talla: S | 2 pts]

### Ejecución del flujo en US1

- [ ] T010 [US1] Ejecutar el prompt §2c (parte ISO) sobre cada `salidas/hallazgos/H-NNN.md` no descartado: control principal, adicionales, anterior, motivo y justificación; actualizar `control_iso` y `controles_iso_adicionales` en `salidas/matriz_hallazgos.csv`; dejar la Revisión en `pendiente`. Comprobar que el validador termina con 0 (SC-001) [requiere hallazgos de 001] (#18) [E4] [Talla: S | 2 pts]

**Checkpoint**: US1 funcional y validada; es el MVP entregable ("Mapa ISO 27001").

---

## Phase 4: User Story 2 — Mapear obligaciones de las leyes 21.663 y 21.719 (Priority: P2)

**Goal**: cada hallazgo con mapeo 21.663 y 21.719 (obligación o `no aplica`), certeza acotada
y artículos en `verificar`, sin mapear la 21.459.

**Independent Test**: el runner pasa con los fixtures de C16 (legal), C18 y C20. Un hallazgo
mapeado tiene la frase hipotética de Q1 y el validador termina con 0 (SC-002, SC-004).

### Validación de US2

- [X] T011 [US2] Ampliar C16 en `scripts/Test-Salidas.ps1` con la parte legal: las claves `Ley 21.663 obligación|artículo|certeza|justificación` y `Ley 21.719 obligación|artículo|certeza|justificación|vigencia` presentes; `Ley 21.663 obligación` ∈ "`gestión de riesgos` | `medidas de seguridad` | `reporte de incidentes` | `no aplica`"; `Ley 21.719 obligación` ∈ "`no aplica` | `pendiente de vigencia` | texto libre"; certezas ∈ "`Alta` | `Media` | `Baja`"; justificaciones no vacías y con `[HECHO]` o `[INFERENCIA]` (FR-014); artículo = `—` si la obligación es `no aplica` y `verificar` si es `pendiente de vigencia` (FR-005, FR-007, FR-010) [E4] [Talla: S | 2 pts]
- [X] T012 [US2] Implementar C18 y C20 en `scripts/Test-Salidas.ps1`.
  - **C18:** si `Ley 21.663 obligación` ≠ `no aplica`, certeza ≤ `Media` y la justificación contiene "si la organización fuera entidad obligada" (Q1); si `Ley 21.719 obligación` ≠ `no aplica`, `Ley 21.719 vigencia` no vacía; si la fila `entrada en vigor` de la lista no está `verificado`, la obligación MUST ser `pendiente de vigencia` (FR-007, constitución V).
  - **C20:** ninguna clave de la sección ni valor de obligación menciona `21.459`, y ninguna fila de la lista tiene `Ley = 21.459` (FR-008, SC-004).

  [E4] [Talla: S | 2 pts]
- [X] T013 [P] [US2] Completar en `scripts/tests/fixtures/valido/` el mapeo legal de H-001 (21.663 `medidas de seguridad` con la frase de Q1, certeza `Media`, artículo `verificar`; 21.719 `no aplica`) y crear `invalido-c16-obligacion-invalida/`, `invalido-c18-certeza-alta-21663/`, `invalido-c18-sin-frase-hipotetica/`, `invalido-c18-21719-citada-sin-vigencia/` (obligación 21.719 de texto libre con la fila `entrada en vigor` en `pendiente`) e `invalido-c20-ley-21459/` [E4] [Talla: S | 2 pts]

### Ejecución del flujo en US2

- [ ] T014 [US2] Ejecutar el prompt §2c (parte legal) sobre cada hallazgo mapeado en US1: obligaciones 21.663 y 21.719 con certeza, justificación [INFERENCIA] y artículos en `verificar`; actualizar las columnas `ley_21663_*` y `ley_21719_*` de la matriz; Revisión en `pendiente`. Comprobar que el validador termina con 0 (SC-002) [requiere hallazgos de 001] (#19, #20) [E4] [Talla: S | 2 pts]

**Checkpoint**: US1 y US2 funcionan; cada hallazgo tiene mapeo ISO y legal.

---

## Phase 5: User Story 3 — Verificar artículos y consolidar el mapa normativo (Priority: P3)

**Goal**: lista de verificación 1:1 con las referencias legales, artículos citados solo tras
verificarse y un mapa normativo coherente con los hallazgos.

**Independent Test**: el runner pasa con los fixtures de C19, C21 y C22. Marcar una fila
`verificado` con fuente y fecha y copiar el artículo mantiene el validador en 0 (SC-003, SC-006).

### Plantillas de US3

- [X] T015 [P] [US3] Crear `docs/plantillas/verificacion_articulos.md` según `contracts/verificacion-articulos.md`: título, leyenda, la tabla `| ID | Hallazgo | Ley | Obligación | Artículo | Estado | Fuente | Fecha | Comentario |` y un comentario con las reglas: `ID` "`^VA-\d{3}$`"; `Ley` "`21.663` | `21.719`"; `Estado` "`pendiente` | `verificado` | `descartado`"; `verificado` exige fuente oficial, fecha AAAA-MM-DD y artículo; `descartado` exige comentario; fila `entrada en vigor` con hallazgo `—` para la Ley 21.719 [E4] [Talla: XS | 1 pts]
- [X] T016 [P] [US3] Crear `docs/plantillas/mapa_normativo.md` según `contracts/mapa-normativo.md`: leyenda, las tablas `| Control ISO | Hallazgos |`, `| Obligación Ley 21.663 | Hallazgos |` y `| Obligación Ley 21.719 | Hallazgos |`, y la sección `## Ley 21.459` que la ubica como marco de la autorización de las pruebas [E4] [Talla: XS | 1 pts]

### Validación de US3

- [X] T017 [US3] Implementar C19 en `scripts/Test-Salidas.ps1` (`contracts/verificacion-articulos.md`).
  - Estructura y enumerados de la tabla; IDs `VA-NNN` únicos.
  - `verificado` ⇒ `Fuente` no vacía, `Fecha` `^\d{4}-\d{2}-\d{2}$` y `Artículo` ≠ `verificar`; `descartado` ⇒ `Comentario` no vacío.
  - `Hallazgo` existe y no está `descartado`, o es `—` solo con `Obligación = entrada en vigor`.
  - Cobertura: exactamente una fila por par (hallazgo, ley) con obligación ≠ `no aplica` y ≠ `pendiente de vigencia`, con la misma obligación; fila `entrada en vigor` si algún hallazgo tiene obligación 21.719 ≠ `no aplica`.
  - Citación (FR-010): el artículo del hallazgo y de la matriz es `—`, `verificar` o igual al de su fila `verificado`.

  [E4] [Talla: M | 3 pts]
- [X] T018 [US3] Implementar C21 y C22 en `scripts/Test-Salidas.ps1`.
  - **C21:** recalcular desde los hallazgos mapeados y no descartados las tres tablas del mapa (controles principal y adicionales; obligaciones ≠ `no aplica` y ≠ `pendiente de vigencia`), con hallazgos ordenados y separados por `; `, y compararlas con `mapa_normativo.md` sin importar el orden de las filas; exigir la leyenda y la sección `## Ley 21.459` con la palabra "autorización".
  - **C22:** `[AVISO]` con la cantidad de filas `pendiente` de la lista; agregar al resumen final los conteos `pendiente` / `verificado` / `descartado`.

  [E4] [Talla: M | 3 pts]
- [X] T019 [P] [US3] Completar `scripts/tests/fixtures/valido/` con `verificacion_articulos.md` (fila de H-001 21.663 `verificado` con el artículo ficticio `ARTICULO-FICTICIO`, fuente "fixture ficticio" y fecha, también copiado al hallazgo y a la matriz) y `mapa_normativo.md` coherente. Crear `invalido-c19-verificado-sin-fuente/`, `invalido-c19-articulo-sin-verificar/`, `invalido-c19-referencia-faltante/`, `invalido-c21-fila-sobrante/`, `invalido-c21-sin-seccion-21459/` y `aviso-c22-referencias-pendientes/` (debe terminar con 0 y mostrar `[AVISO]` C22). Indicar en cada `LEEME.md` que el artículo es inventado para la prueba [E4] [Talla: M | 3 pts]

### Ejecución del flujo en US3

- [ ] T020 [US3] Generar `salidas/verificacion_articulos.md` y `salidas/mapa_normativo.md` desde las plantillas, con una fila `pendiente` por referencia legal de los hallazgos mapeados y la fila `entrada en vigor` si corresponde. Comprobar que el validador termina con 0 y `[AVISO]` C22 [requiere hallazgos de 001] (#21) [E4] [Talla: S | 2 pts]

**Checkpoint**: la cadena se extiende a Hallazgo → Mapeo normativo → Verificación, y el mapa
lleva de vuelta a la evidencia.

---

## Phase 6: Polish y aspectos transversales

**Purpose**: documentación, medición y cierre con revisión humana.

- [X] T021 [P] Actualizar `specs/001-analisis-evidencias/contracts/test-salidas.md` (nota: C12 avisa solo después de la columna 18 cuando la matriz tiene columnas legales; ver `specs/002-mapeo-normativo/contracts/test-salidas-002.md`), la transición `aprobado | corregido → pendiente` (FR-016 de 002) en `specs/001-analisis-evidencias/data-model.md`, y la sección de validación de `README.md` con C15–C22 y los dos archivos nuevos de `salidas/` [E4] [Talla: XS | 1 pts]
- [ ] T022 Ejecutar los escenarios 0 y 4 de `specs/002-mapeo-normativo/quickstart.md` (y 1–3 si hay hallazgos reales). Medir con `Measure-Command` el validador sobre `salidas/` y sobre `scripts/tests/fixtures/valido/` (meta < 5 s) y, si hay hallazgos reales, el recorrido manual de SC-006 (mapa → hallazgo → evidencia, meta < 3 min). Pegar el resultado, dudas y supuestos en la descripción del PR (FR-017) [E4] [Talla: S | 2 pts]
- [ ] T023 Revisión humana: el auditor verifica en la fuente oficial cada fila de `salidas/verificacion_articulos.md` (artículo, fuente, fecha, o `descartado` con motivo; si el artículo difiere del propuesto, el motivo en `Comentario`), incluida la entrada en vigor de la Ley 21.719, y pasa a obligación registrada toda 21.719 `pendiente de vigencia` si la vigencia quedó verificada; copia los artículos verificados a los hallazgos y a la matriz; revisa el mapeo y completa el bloque Revisión de cada `H-NNN.md`. Abrir el PR contra `main` con el checklist de la DoD y `Closes #n` de los issues cubiertos [requiere al auditor] (#21) [E4] [Talla: S | 2 pts]

---

## Resumen de estimación

| Fase | Tareas | Puntos |
|---|---|---|
| Setup | T001–T003 | 3 |
| Foundational | T004–T006 | 6 |
| US1 (P1, MVP) | T007–T010 | 9 |
| US2 (P2) | T011–T014 | 8 |
| US3 (P3) | T015–T020 | 13 |
| Polish | T021–T023 | 5 |
| **Total** | **23** | **44** |

Todas las tareas son de la épica **E4 Mapeo normativo**.

Tallas: 7 XS · 11 S · 5 M · 0 L · 0 XL.

Sin hallazgos reales ni al auditor se pueden completar 18 tareas (34 pts); quedan bloqueadas
T010, T014, T020, T022 (parcial) y T023.

---

## Dependencies & Execution Order

### Dependencias entre fases

- **Setup (fase 1):** sin dependencias.
- **Foundational (fase 2):** T004 bloquea todas las tareas del validador. T005 y T006 son independientes.
- **US1 (fase 3):** depende de la fase 2.
- **US2 (fase 4):** depende de la fase 2; sus fixtures (T013) extienden el `valido/` de T009.
- **US3 (fase 5):** depende de US2, porque la lista de verificación cubre las referencias legales y el mapa usa los controles de US1.
- **Polish (fase 6):** depende de las historias que se entreguen. T023 va al final.
- **Ejecución sobre `salidas/`** (T010, T014, T020): depende además de T013 y T020 de la funcionalidad 001.

### Dentro de cada historia

- Las comprobaciones del validador van antes que sus fixtures inválidos, para comprobar que fallan por la razón correcta.
- Las tareas que tocan `scripts/Test-Salidas.ps1` son secuenciales: T004 → T007 → T008 → T011 → T012 → T017 → T018.
- Las tareas que tocan `scripts/tests/fixtures/valido/` son secuenciales: T009 → T013 → T019 (T006 copia `valido/` antes de T009).

### Parallel Opportunities

- **Fase 1:** T001, T002 y T003 en paralelo.
- **Fase 2:** T005 y T006 en paralelo con T004.
- **US1:** T009 en paralelo con T008, una vez hecho T007.
- **US3:** T015 y T016 en paralelo con T017.
- **Polish:** T021 en paralelo con T022.

---

## Parallel Example: User Story 3

```text
Task: "T015 Crear docs/plantillas/verificacion_articulos.md"
Task: "T016 Crear docs/plantillas/mapa_normativo.md"
# en paralelo con la implementación de C19 (T017):
Task: "T017 Implementar C19 en scripts/Test-Salidas.ps1"
```

---

## Implementation Strategy

### MVP primero (solo US1)

1. Fases 1 y 2 (9 pts).
2. Fase 3: US1 (9 pts). **Subtotal: 18 pts**, dentro del tope de 20 por sprint.
3. **Detenerse y validar:** el runner pasa y el fixture con `Control ISO: verificar` queda
   mapeado.

### Entrega incremental

1. Setup + Foundational → validador preparado, prompt §2c y compatibilidad con 001 → PR.
2. US1 → mapa ISO (MVP) → PR.
3. US2 → mapeo legal → PR.
4. US3 → verificación de artículos y mapa normativo → PR.
5. Polish → documentación, medición y revisión humana → PR final.

---

## Notes

- `[P]` = archivos distintos y sin dependencias pendientes.
- Hacer commit después de cada tarea o grupo lógico; un PR por fase o historia, con `Closes #n`.
- Las tareas de ejecución usan los issues existentes #18–#21 de la épica E4; las demás se
  crean en el Project sin duplicarlos.
- Además de los fixtures de T019 se agregó `aviso-c22-21719-pendiente-vigencia/`, caso positivo de D1
  (Ley 21.719 `pendiente de vigencia`, código 0 con `[AVISO]` C22).
- T022 (parcial, 2026-10-28): escenarios 0 y 4 hechos (35 fixtures, 0 fallas; 0 comandos de red;
  validador 0,44 s sobre `salidas/` y 0,80 s sobre `valido/`). Faltan los escenarios 1–3 y SC-006,
  que requieren hallazgos reales.
- Ningún fixture ni salida contiene números de artículo reales sin verificar: los fixtures usan
  `ARTICULO-FICTICIO` (FR-010).
