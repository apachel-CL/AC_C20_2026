---

description: "Lista de tareas de la funcionalidad 001 — Flujo de análisis de evidencias"
---

# Tasks: Flujo de análisis de evidencias del auditor

**Input**: Documentos de diseño en `/specs/001-analisis-evidencias/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: el plan (research R5) define fixtures y un runner para el validador. Se incluyen como
tareas. No hay pruebas de "aplicación", porque no la hay.

**Organization**: las tareas se agrupan por historia de usuario, de modo que cada una se pueda
implementar y probar por separado.

**Estimación**: cada tarea termina con `[E2|E3] [Talla: X | N pts]`, según
`docs/estimacion.md` (XS=1, S=2, M=3, L=5, XL=8). Ninguna tarea es XL ni L. Las épicas son
**E2 Evidencias** y **E3 Análisis**.

**Regla de no ejecución** (FR-012, FR-018): ninguna tarea ejecuta escaneos, exploits ni
comandos contra sistemas. Las tareas marcadas `[requiere evidencia del auditor]` necesitan que
el auditor entregue un archivo en `evidencias/`; Claude solo lo lee.

## Format: `[ID] [P?] [Story] Descripción [Épica] [Talla]`

- **[P]**: se puede ejecutar en paralelo (archivos distintos, sin dependencias pendientes).
- **[Story]**: historia de usuario a la que pertenece (US1, US2, US3).

## Path Conventions

Estructura del repositorio según plan.md:

- `docs/plantillas/`
- `scripts/`
- `scripts/tests/fixtures/`
- `salidas/`
- `.github/`

---

## Phase 1: Setup (infraestructura compartida)

**Purpose**: carpetas y ajustes de repositorio que necesitan todas las historias.

- [ ] T001 Crear `docs/plantillas/`, `scripts/tests/fixtures/` y `salidas/hallazgos/.gitkeep`. En `.gitignore`, anclar la regla de evidencias a la raíz para que no ignore las de los fixtures: reemplazar `evidencias/*` por `/evidencias/*` y `!evidencias/.gitkeep` por `!/evidencias/.gitkeep`. Comprobar con `git check-ignore -v scripts/tests/fixtures/valido/evidencias/x.txt` (no debe aparecer como ignorado) [E2] [Talla: XS | 1 pts]
- [ ] T002 [P] Agregar a la sección "Definition of Done" de `.github/pull_request_template.md` estos dos ítems: "- [ ] Bloque Revisión actualizado en cada H-NNN.md tocado (estado, revisor, fecha)" y "- [ ] `scripts/Test-Salidas.ps1` termina sin errores y sin `[AVISO]` C11 pendientes" (research R6, FR-014, SC-006) [E3] [Talla: XS | 1 pts]

---

## Phase 2: Foundational (prerrequisitos bloqueantes)

**Purpose**: el esqueleto del validador, su runner de pruebas y el prompt de trabajo, que usan
las tres historias.

**⚠️ CRITICAL**: ninguna historia puede empezar hasta completar esta fase.

- [ ] T003 Crear el esqueleto de `scripts/Test-Salidas.ps1` según `contracts/test-salidas.md`.
  - Parámetros `-Ruta` (por defecto `salidas`) y `-Evidencias` (por defecto `evidencias`).
  - Lectura UTF-8 con `[IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)`.
  - Parser de la tabla Markdown que la ubica por su fila de encabezado.
  - Parser de metadatos con la regex `^- \*\*(.+?)\*\*: (.*)$`.
  - Funciones de reporte `[OK]`/`[ERROR]`/`[AVISO]`, resumen final con conteos, y código de salida 0 sin errores o 1 con errores.
  - Sin `Invoke-WebRequest`, `Invoke-RestMethod`, `Test-NetConnection`, `Net.Sockets` ni `Start-Process`, y sin escribir archivos.

  [E3] [Talla: M | 3 pts]
- [ ] T004 [P] Crear `scripts/tests/Invoke-Pruebas.ps1`. Recorre cada subcarpeta de `scripts/tests/fixtures/` y ejecuta `Test-Salidas.ps1 -Ruta <fixture>/salidas -Evidencias <fixture>/evidencias`. El código esperado es 0 si el nombre empieza con `valido` o `aviso-`, y 1 si empieza con `invalido-`. Imprime una tabla fixture/esperado/obtenido y termina con 0 solo si todos coinciden (research R5) [E3] [Talla: S | 2 pts]
- [ ] T005 [P] Actualizar el prompt de `docs/flujo_prompt_e_hu.md` §2a con todo lo siguiente:
  - nombres `EV-NNN_<comando-o-tema>.<ext>` y propuesta de renombre con confirmación (FR-001);
  - la observación textual de lo visible, indicando la zona resaltada si la hay (FR-003);
  - las cuatro clasificaciones, con `fuera-de-alcance` evaluada primero, y el criterio de "debilidad concreta visible" (FR-004, Q1);
  - el uso de las plantillas de `docs/plantillas/`;
  - las 11 columnas de la matriz (FR-010);
  - hallazgos con bloque "Revisión" en `pendiente` (FR-014);
  - la regla de enmascarado de Q5 (FR-013);
  - la definición de "comando contra un sistema" y que los comandos propuestos van solo a `192.168.56.101`, marcados "propuesto: lo ejecuta el auditor" (FR-012);
  - el reingreso de resultados como evidencia nueva (FR-017);
  - el cierre con la ejecución de `scripts/Test-Salidas.ps1` y un resumen para el PR (FR-016).

  [E3] [Talla: S | 2 pts]

**Checkpoint**: validador ejecutable (sin comprobaciones aún), runner listo y prompt alineado
con la spec.

---

## Phase 3: User Story 1 — Inventariar, observar y clasificar evidencias (Priority: P1) 🎯 MVP

**Goal**: inventario de evidencias, inventario de activos y registro de evidencia insuficiente,
con el caso EV-002 resuelto como evidencia de contexto.

**Independent Test**: `scripts/tests/Invoke-Pruebas.ps1` pasa con los fixtures de C1–C5. Al
procesar EV-002, `Test-Salidas.ps1` termina con 0 y se cumplen SC-001, SC-003 y SC-004.

### Plantillas de US1

- [ ] T006 [P] [US1] Crear `docs/plantillas/inventario_evidencias.md` con la tabla `| ID | Archivo | Observación | Clasificación | Debilidad / Falta |`. Clasificación: "`hallazgo` | `contexto` | `insuficiente` | `fuera-de-alcance`". `fuera-de-alcance` se evalúa primero y prevalece (`contracts/inventarios.md`) [E2] [Talla: XS | 1 pts]
- [ ] T007 [P] [US1] Crear `docs/plantillas/inventario_activos.md` con la tabla `| Activo | Atributo | Valor | Etiqueta | Fuente |`. Atributo: "`hostname` · `interfaz` · `mac` · `ipv4` · `mascara` · `broadcast` · `ipv6` · `usuario` · `so` · `otro`". Etiqueta: "`[HECHO]` · `[INFERENCIA]`" (data-model.md) [E2] [Talla: XS | 1 pts]
- [ ] T008 [P] [US1] Crear `docs/plantillas/evidencia_insuficiente.md` con la tabla `| ID | Qué falta | Cómo obtenerlo (comando propuesto) | Reemplazada por |`. Incluir una nota de que los comandos solo se proponen contra `192.168.56.101` y que `Reemplazada por` es un `EV-NNN` existente o `—` (FR-012, FR-017) [E2] [Talla: XS | 1 pts]

### Validación de US1

- [ ] T009 [US1] Implementar en `scripts/Test-Salidas.ps1` las comprobaciones C1–C3:
  - **C1:** IDs `^EV-\d{3}$` únicos.
  - **C2:** si existe `-Evidencias`, cada archivo cumple `EV-NNN_*.*` y está inventariado, y no hay dos archivos con el mismo prefijo `EV-NNN` (error de conflicto, FR-001); si no existe, `[AVISO]`.
  - **C3:** clasificación válida y `Debilidad / Falta` no vacía para `hallazgo` e `insuficiente`.

  [E2] [Talla: M | 3 pts]
- [ ] T010 [US1] Implementar en `scripts/Test-Salidas.ps1` las comprobaciones C4–C5:
  - **C4:** `evidencia_insuficiente.md` coincide 1:1 con las evidencias `insuficiente` del inventario, y `Reemplazada por` es un EV existente o `—`.
  - **C5:** la `Fuente` de cada activo existe en el inventario de evidencias.

  [E2] [Talla: S | 2 pts]
- [ ] T011 [P] [US1] Crear el fixture `scripts/tests/fixtures/valido/`.
  - `salidas/`: EV-002 como `contexto` y sus siete datos copiados de `docs/alcance.md` (hostname, interfaz, MAC, IPv4, máscara "tal como en la captura", broadcast, usuario `msfadmin`), con la IPv6 marcada "(parcialmente legible)".
  - `evidencias/EV-002_ifconfig.txt`: un archivo de texto marcado "fixture ficticio".

  [E2] [Talla: S | 2 pts]
- [ ] T012 [P] [US1] Crear en `scripts/tests/fixtures/` seis fixtures inválidos, cada uno con una sola regla rota: `invalido-c1-id-duplicado/`, `invalido-c2-archivo-sin-inventariar/`, `invalido-c2-prefijo-duplicado/`, `invalido-c3-clasificacion-invalida/`, `invalido-c4-insuficiente-desalineada/` e `invalido-c5-fuente-inexistente/`. Crear además el fixture `valido-vacio/` (evidencias e inventarios vacíos: debe terminar con 0 e informar que no hay evidencias) [E2] [Talla: S | 2 pts]

### Ejecución del flujo en US1

- [ ] T013 [US1] Procesar EV-002 con el prompt actualizado (T005) y la skill `sk-ciberauditor`, y generar `salidas/inventario_evidencias.md`, `salidas/inventario_activos.md` y `salidas/evidencia_insuficiente.md` a partir de las plantillas. Comprobar que `Test-Salidas.ps1` termina con 0, que EV-002 queda `contexto` sin hallazgos y que los siete datos coinciden con la captura (SC-003) [requiere evidencia del auditor: `evidencias/EV-002_ifconfig.<ext>`] [E3] [Talla: M | 3 pts]

**Checkpoint**: US1 funcional y validada; es el MVP entregable.

---

## Phase 4: User Story 2 — Redactar hallazgos trazables (Priority: P2)

**Goal**: archivos `H-NNN.md` con bloque "Revisión" y una matriz coherente con ellos.

**Independent Test**: el runner pasa con los fixtures de C6–C10. Un hallazgo real queda con
estado `pendiente`, una fila en la matriz y el validador en 0 (SC-002, SC-005, SC-008).

### Plantillas de US2

- [ ] T014 [P] [US2] Crear `docs/plantillas/hallazgo.md` según `contracts/hallazgo.md`.
  - Metadatos `ID`, `Evidencias` (separadas por `; `), `Severidad` ("`Crítica` | `Alta` | `Media` | `Baja` | `Informativa`"), `Control ISO` ("`^A\.\d{1,2}\.\d{1,2}$` o `verificar`") y `Certeza ISO` ("`Alta` | `Media` | `Baja`").
  - Secciones Observación, Justificación y Recomendación.
  - Bloque Revisión con `Estado: pendiente` y revisor y fecha vacíos.

  [E3] [Talla: S | 2 pts]
- [ ] T015 [P] [US2] Crear `docs/plantillas/matriz_hallazgos.csv` con solo el encabezado `id_hallazgo,enunciado,evidencias,severidad,control_iso,certeza_iso,recomendacion,prioridad,responsable_sugerido,criterio_cierre,estado_revision`, en UTF-8 sin BOM (`contracts/matriz_hallazgos.md`) [E3] [Talla: XS | 1 pts]

### Validación de US2

- [ ] T016 [US2] Implementar C6–C7 en `scripts/Test-Salidas.ps1`.
  - **C6:** el nombre `H-NNN.md` es igual al `ID`; los metadatos obligatorios están presentes; los enumerados `Severidad`, `Control ISO` y `Certeza ISO` son válidos.
  - **C7:** cada EV citado existe en el inventario, al menos uno está clasificado `hallazgo` y ninguno está clasificado `fuera-de-alcance` (FR-015).

  [E3] [Talla: M | 3 pts]
- [ ] T017 [US2] Implementar C8–C9 en `scripts/Test-Salidas.ps1`.
  - Leer la matriz con `ConvertFrom-Csv` sobre texto UTF-8 (research R3).
  - **C8:** las 11 primeras columnas coinciden exactamente con el encabezado del contrato.
  - **C9:** hay correspondencia 1:1 entre filas y archivos `H-NNN.md`, y cada columna coincide con su campo, incluido `enunciado` (el título después de `—`) y `evidencias` (separadas por `;` sin espacios).

  [E3] [Talla: M | 3 pts]
- [ ] T018 [US2] Implementar C10 en `scripts/Test-Salidas.ps1`.
  - El `Estado` debe ser "`pendiente` | `aprobado` | `corregido` | `descartado`".
  - Si no es `pendiente`, `Revisor` y `Fecha` (`^\d{4}-\d{2}-\d{2}$`) no pueden estar vacíos.
  - `estado_revision` de la matriz debe ser igual al `Estado`.

  [E3] [Talla: S | 2 pts]
- [ ] T019 [US2] Extender `scripts/tests/fixtures/valido/` con una evidencia ficticia `EV-900` clasificada `hallazgo` y un `H-001.md` ficticio en estado `aprobado` con revisor y fecha, más su fila en la matriz. Crear los fixtures `invalido-c6-enumerado/`, `invalido-c7-solo-contexto/`, `invalido-c7-cita-fuera-de-alcance/`, `invalido-c8-encabezado/`, `invalido-c9-fila-huerfana/` e `invalido-c10-sin-fecha/` [E3] [Talla: M | 3 pts]

### Ejecución del flujo en US2

- [ ] T020 [US2] Procesar la primera evidencia que muestre una debilidad. Generar `salidas/hallazgos/H-001.md` desde la plantilla, con estado `pendiente`, y su fila en `salidas/matriz_hallazgos.csv`. Registrar también en `salidas/inventario_activos.md` los datos del activo visibles en esa evidencia (FR-005, Q1). Etiquetar [INFERENCIA] lo que no sea visible y comprobar que `Test-Salidas.ps1` termina con 0 [requiere evidencia del auditor: `evidencias/EV-NNN_<tema>.<ext>`] [E3] [Talla: M | 3 pts]

**Checkpoint**: US1 y US2 funcionan cada una por separado.

---

## Phase 5: User Story 3 — Proponer recomendaciones verificables (Priority: P3)

**Goal**: cada hallazgo con exactamente una recomendación completa y verificable.

**Independent Test**: el runner pasa con el fixture de recomendación incompleta. Los hallazgos
de `salidas/` tienen acción, prioridad, responsable y criterio de cierre, y la matriz los
refleja (SC-005).

- [ ] T021 [US3] Ampliar C6 en `scripts/Test-Salidas.ps1` para validar la sección Recomendación.
  - `Acción`, `Responsable sugerido` y `Criterio de cierre` no pueden estar vacíos.
  - `Prioridad` debe ser "`P0` | `P1` | `P2` | `P3`".
  - **C13:** emitir `[AVISO]` si la prioridad difiere de la derivada de la severidad (Crítica→P0, Alta→P1, Media→P2, Baja/Informativa→P3), porque el auditor puede ajustarla (FR-009).
  - **C14:** emitir `[AVISO]` si `Comandos propuestos` menciona una IPv4 distinta de `192.168.56.101` (FR-012).

  [E3] [Talla: S | 2 pts]
- [ ] T022 [P] [US3] Crear el fixture `scripts/tests/fixtures/invalido-recomendacion-incompleta/` (falta el `Criterio de cierre`) y el fixture `scripts/tests/fixtures/aviso-prioridad-ajustada/` (prioridad distinta de la derivada; debe terminar con 0 y mostrar `[AVISO]`) [E3] [Talla: XS | 1 pts]
- [ ] T023 [US3] Completar la sección Recomendación de cada `salidas/hallazgos/H-NNN.md`: exactamente una por hallazgo, con prioridad derivada de la severidad y comandos propuestos solo contra `192.168.56.101`, marcados "propuesto: lo ejecuta el auditor". Actualizar las columnas `recomendacion`, `prioridad`, `responsable_sugerido` y `criterio_cierre` de `salidas/matriz_hallazgos.csv` y comprobar que el validador termina con 0 [E3] [Talla: S | 2 pts]

**Checkpoint**: la cadena Observación → Evidencia → Hallazgo → Recomendación queda completa.

---

## Phase 6: Polish y aspectos transversales

**Purpose**: protección de datos, documentación y cierre con revisión humana.

- [ ] T024 [P] Implementar C11 y C12 en `scripts/Test-Salidas.ps1`, ambas como `[AVISO]`. C11 es heurística y puede dar falsos positivos, por eso no falla; pero un `[AVISO]` C11 en `salidas/` bloquea el PR hasta que el auditor lo resuelva (T028, SC-006).
  - **C11:** detectar en `salidas/` patrones de secretos en claro: `password=`, `pass:`, `$1$`, `$6$`, `BEGIN … PRIVATE KEY` y una cadena hexadecimal de 32 o más caracteres después de `hash` (FR-013, SC-006).
  - **C12:** columnas adicionales en la matriz (`contracts/matriz_hallazgos.md`).

  [E3] [Talla: S | 2 pts]
- [ ] T025 [P] Crear el fixture `scripts/tests/fixtures/aviso-secreto/` con el valor ficticio `password=FIXTURE_FICTICIO` en una observación, y un `LEEME.md` que diga que es un dato de prueba inventado y no una credencial (los fixtures no son entregables; constitución, principio V). Debe terminar con 0 y mostrar `[AVISO]` C11 [E3] [Talla: XS | 1 pts]
- [ ] T026 [P] Actualizar la sección "Estructura" de `README.md` con `docs/plantillas/`, `scripts/` y `specs/`, y con el comando del validador [E2] [Talla: XS | 1 pts]
- [ ] T027 Ejecutar los escenarios 0–3 de `specs/001-analisis-evidencias/quickstart.md`, incluida la búsqueda de comandos de red en `scripts/*.ps1` (debe dar 0 coincidencias). Medir con `Measure-Command` el tiempo del validador sobre `salidas/` (meta del plan: < 5 s). Pegar el resultado, las dudas y los supuestos en la descripción del PR (FR-016) [E3] [Talla: S | 2 pts]
- [ ] T028 Revisión humana: el auditor completa el bloque "Revisión" de cada `salidas/hallazgos/H-NNN.md` (estado, revisor, fecha) y alinea `estado_revision` en la matriz. Resolver todo `[AVISO]` C11 sobre `salidas/` (enmascarar o justificar el falso positivo en el PR). Abrir el PR contra `main` con el checklist de la DoD y `Closes #n` de los issues cubiertos [E3] [Talla: S | 2 pts]

---

## Resumen de estimación

| Fase | Tareas | Puntos |
|---|---|---|
| Setup | T001–T002 | 2 |
| Foundational | T003–T005 | 7 |
| US1 (P1, MVP) | T006–T013 | 15 |
| US2 (P2) | T014–T020 | 17 |
| US3 (P3) | T021–T023 | 5 |
| Polish | T024–T028 | 8 |
| **Total** | **28** | **54** |

| Épica | Tareas | Puntos |
|---|---|---|
| E2 Evidencias | T001, T006–T012, T026 | 14 |
| E3 Análisis | T002–T005, T013–T025, T027, T028 | 40 |

Tallas: 9 XS · 12 S · 7 M · 0 L · 0 XL.

---

## Dependencies & Execution Order

### Dependencias entre fases

- **Setup (fase 1):** sin dependencias.
- **Foundational (fase 2):** depende de T001 y bloquea todas las historias.
- **US1 (fase 3):** depende de la fase 2.
- **US2 (fase 4):** depende de la fase 2. Para T019–T020 necesita el inventario de evidencias (plantilla T006 y comprobación C1 de T009), porque C7 cruza hallazgos con evidencias.
- **US3 (fase 5):** depende de US2, porque las recomendaciones viven dentro de `H-NNN.md`.
- **Polish (fase 6):** depende de las historias que se quieran entregar. T028 va al final.

### Dentro de cada historia

- Las plantillas van antes que la ejecución del flujo (T006–T008 antes de T013; T014–T015 antes de T020).
- Las comprobaciones del validador van antes que sus fixtures inválidos, para comprobar que fallan por la razón correcta.
- Las tareas que tocan `scripts/Test-Salidas.ps1` son secuenciales: T003 → T009 → T010 → T016 → T017 → T018 → T021 → T024.

### Parallel Opportunities

- **Fase 1:** T002 en paralelo con T001.
- **Fase 2:** T004 y T005 en paralelo con T003.
- **US1:** T006, T007 y T008 en paralelo; T011 y T012 en paralelo con T009–T010.
- **US2:** T014 y T015 en paralelo.
- **Polish:** T024, T025 y T026 en paralelo.

---

## Parallel Example: User Story 1

```text
Task: "T006 Crear docs/plantillas/inventario_evidencias.md"
Task: "T007 Crear docs/plantillas/inventario_activos.md"
Task: "T008 Crear docs/plantillas/evidencia_insuficiente.md"
# en paralelo con la implementación de C1–C5 (T009–T010):
Task: "T011 Fixture valido/ con EV-002"
Task: "T012 Fixtures invalido-c1…c5"
```

---

## Implementation Strategy

### MVP primero (solo US1)

1. Fases 1 y 2 (9 pts).
2. Fase 3: US1 (15 pts). **Subtotal: 24 pts**, por encima del tope de 20 del Sprint 1.
3. **Detenerse y validar:** el runner pasa y EV-002 queda correcta.

Para respetar el tope hay que mover al menos 4 pts al Sprint 2. Por ejemplo, T012 (fixtures
inválidos, 2 pts) y T010 (C4–C5, 2 pts) dejan el Sprint 1 en 20 pts y conservan EV-002 (T013).
El Sprint 1 del Project ya tiene 15 pts comprometidos (E1 y otros), así que el reparto final se
decide en la Parte C.

### Entrega incremental

1. Setup + Foundational → validador y prompt listos.
2. US1 → inventarios y EV-002 (MVP) → PR.
3. US2 → hallazgos y matriz → PR.
4. US3 → recomendaciones → PR.
5. Polish → protección de datos, README, quickstart y revisión humana → PR final.

---

## Notes

- `[P]` = archivos distintos y sin dependencias pendientes.
- Hacer commit después de cada tarea o grupo lógico; un PR por fase o historia, con `Closes #n`.
- Las tareas `[requiere evidencia del auditor]` quedan bloqueadas hasta que el auditor entregue el archivo; Claude no genera ni obtiene evidencia por su cuenta.
- La correspondencia T00x → issues #6–#24 del Project se hace en la Parte C, sin duplicar issues.
