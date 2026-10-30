# Implementation Plan: Informe y remediación

**Branch**: `feat/003-informe-remediacion` (feature `003-informe-remediacion`) | **Date**: 2026-10-29 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-informe-remediacion/spec.md`

## Summary

Consolidar los hallazgos revisados (`aprobado` o `corregido`) en dos entregables de cierre:
`salidas/plan_remediacion.md`, con una entrada por hallazgo ordenada por prioridad, y
`salidas/resumen_ejecutivo.md`, de una página y para lectores no técnicos. Ambos tienen un
bloque Revisión, y el informe se cierra solo cuando el auditor aprueba los dos.

- **Análisis:** igual que en 001 y 002, no hay aplicación. Los documentos los redacta Claude
  Code en sesión con la skill `sk-ciberauditor` y un prompt nuevo (§2d de
  `docs/flujo_prompt_e_hu.md`). Solo leen salidas existentes y no modifican hallazgos ni matriz.
- **Lo que construye esta funcionalidad:**
  - dos plantillas nuevas en `docs/plantillas/`;
  - comprobaciones C23–C28 (error) y C29 (aviso) en `scripts/Test-Salidas.ps1`, con sus
    fixtures;
  - un ítem más en la Definition of Done de la plantilla de PR.

## Technical Context

**Language/Version**: Markdown (UTF-8) para los artefactos; Windows PowerShell 5.1 para la validación.

**Primary Dependencies**: Claude Code + skill `sk-ciberauditor` (redacción); el validador y el runner de 001/002. Sin módulos externos.

**Storage**: archivos versionados en `salidas/` (`plan_remediacion.md`, `resumen_ejecutivo.md`); lee `hallazgos/`, `matriz_hallazgos.csv`, los inventarios y `verificacion_articulos.md`.

**Testing**: el fixture `valido/` se amplía con plan y resumen; nuevos `invalido-c23…c28-*` y `aviso-c29-*`; mismo runner `scripts/tests/Invoke-Pruebas.ps1`.

**Target Platform**: Windows 11, PowerShell 5.1, carpeta dentro de OneDrive.

**Project Type**: flujo documental con validador por línea de comandos.

**Performance Goals**: el validador sigue por debajo de 5 s con ≤ 50 hallazgos.

**Constraints**:
- sin red ni ejecución de comandos contra sistemas;
- no se modifican hallazgos ni matriz;
- compatibilidad: una salida de 001 o 002 sin plan ni resumen sigue dando el mismo resultado;
- ningún artículo legal en el resumen sin fila `verificado` (FR-011).

**Scale/Scope**: un activo, decenas de hallazgos, dos documentos de cierre.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Cómo lo cumple el diseño | Estado |
|---|---|---|
| I. Alcance autorizado | Solo hallazgos existentes, que ya excluyen `fuera-de-alcance` (C7); IPs del plan limitadas a `192.168.56.101` (C25) | ✅ |
| II. Trazabilidad | Cada entrada del plan y cada riesgo del resumen cita un hallazgo revisado, que cita su evidencia (C24, C26) | ✅ |
| III. Veracidad | Plan igual a la matriz (C24); conteos del resumen recalculados (C26); [INFERENCIA] para lo que no viene de un hallazgo (prompt + revisión) | ✅ |
| IV. No ejecución | El validador sigue sin red; el resumen no lleva comandos y el plan no agrega comandos nuevos | ✅ |
| V. Protección de datos y alcance legal | C11 ya recorre todo `salidas/`; responsable como rol; leyenda orientativa y citas legales solo verificadas en el resumen (C27) | ✅ |
| VI. Gestión ágil | Tareas con tallas en `/speckit-tasks`; ninguna XL | ✅ (se verifica en tasks) |
| VII. Revisión humana | Bloque Revisión en ambos documentos (C28); aviso mientras el informe no esté cerrado (C29); regenerar con cambios vuelve a `pendiente` (FR-016, prompt + DoD) | ✅ |

**Re-check después de la Fase 1:** sin violaciones. FR-016 no se puede comprobar con un
validador sin historial; se cubre con el prompt y el checklist del PR (research R7), como
FR-016 de 002. No hace falta llenar Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/003-informe-remediacion/
├── spec.md
├── plan.md              # este archivo
├── research.md          # Fase 0
├── data-model.md        # Fase 1
├── quickstart.md        # Fase 1
├── contracts/           # Fase 1
│   ├── plan-remediacion.md
│   ├── resumen-ejecutivo.md
│   └── test-salidas-003.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Fase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
docs/
├── flujo_prompt_e_hu.md            # MODIFICAR: nueva §2d, prompt de informe y remediación
└── plantillas/
    ├── plan_remediacion.md         # NUEVO
    └── resumen_ejecutivo.md        # NUEVO

scripts/
├── Test-Salidas.ps1                # MODIFICAR: C23–C29
└── tests/fixtures/
    ├── valido/                     # MODIFICAR: + plan y resumen coherentes, ambos aprobados
    ├── invalido-c23…c28-*/         # NUEVO: un caso por regla
    └── aviso-c29-informe-pendiente/  # NUEVO: plan y resumen en pendiente

salidas/                            # generado por el flujo
├── plan_remediacion.md             # NUEVO
└── resumen_ejecutivo.md            # NUEVO

.github/pull_request_template.md    # MODIFICAR: ítem de revisión del informe
README.md                           # MODIFICAR: C23–C29 y los dos archivos nuevos
```

**Structure Decision**: se reutiliza la estructura de 001 y 002 sin carpetas nuevas. El
validador sigue siendo un único script (research R4 de 001).

## Complexity Tracking

No aplica: el Constitution Check no tiene violaciones.
