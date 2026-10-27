# Implementation Plan: Flujo de análisis de evidencias del auditor

**Branch**: `chore/speckit-init` (feature `001-analisis-evidencias`) | **Date**: 2026-10-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-analisis-evidencias/spec.md`

## Summary

Convertir cada evidencia de `./evidencias/` en una cadena trazable Observación → Evidencia →
Hallazgo → Recomendación. Las salidas son Markdown y CSV en `./salidas/`.

- **Análisis:** no hay aplicación. Lo hace Claude Code en sesión con la skill
  `sk-ciberauditor` y el prompt de `docs/flujo_prompt_e_hu.md`, que se actualiza con las
  aclaraciones de la spec.
- **Lo que construye esta funcionalidad:**
  - plantillas de salida en `docs/plantillas/`;
  - el validador estructural `scripts/Test-Salidas.ps1` (PowerShell 5.1, solo lectura, sin
    red) con fixtures de prueba;
  - un ajuste a la plantilla de PR para registrar la revisión humana.

## Technical Context

**Language/Version**: Markdown y CSV (UTF-8) para los artefactos; Windows PowerShell 5.1 para la validación.

**Primary Dependencies**: Claude Code + skill `sk-ciberauditor` (análisis); ninguna dependencia de PowerShell más allá de lo incluido en 5.1.

**Storage**: archivos en el repositorio. `salidas/` se versiona; `evidencias/` no (repositorio público).

**Testing**: fixtures en `scripts/tests/fixtures/` + runner `scripts/tests/Invoke-Pruebas.ps1` (código de salida esperado por caso).

**Target Platform**: Windows 11, PowerShell 5.1, carpeta dentro de OneDrive.

**Project Type**: flujo documental con validador por línea de comandos (sin aplicación ni base de datos).

**Performance Goals**: el validador procesa un conjunto de laboratorio (≤ 100 evidencias, ≤ 50 hallazgos) en menos de 5 s.

**Constraints**:
- sin red ni ejecución contra sistemas;
- sin módulos externos;
- UTF-8 con tildes correctas en PowerShell 5.1;
- nada sensible en `salidas/`.

**Scale/Scope**: un activo (`192.168.56.101`), decenas de evidencias. Caso de prueba obligatorio: EV-002.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Cómo lo cumple el diseño | Estado |
|---|---|---|
| I. Alcance autorizado | La clasificación `fuera-de-alcance` (FR-015) impide analizar otros activos | ✅ |
| II. Trazabilidad | Los contratos exigen evidencias en cada hallazgo; el validador comprueba C7 y C9 | ✅ |
| III. Veracidad | La plantilla obliga a usar [HECHO]/[INFERENCIA]; `control_iso` admite `verificar` | ✅ |
| IV. No ejecución | El validador es de solo lectura y sin red; los comandos solo se proponen; el escenario 3 del quickstart lo verifica | ✅ |
| V. Protección de datos | `evidencias/` no se versiona; regla de enmascarado Q5; aviso C11 | ✅ |
| VI. Gestión ágil | Las tareas se estimarán con tallas en `/speckit-tasks`; ninguna XL | ✅ (se verifica en tasks) |
| VII. Revisión humana | Bloque "Revisión" + C10 + checklist de PR | ✅ |

**Re-check después de la Fase 1:** sin violaciones. No hace falta llenar Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/001-analisis-evidencias/
├── spec.md
├── plan.md              # este archivo
├── research.md          # Fase 0
├── data-model.md        # Fase 1
├── quickstart.md        # Fase 1
├── contracts/           # Fase 1
│   ├── inventarios.md
│   ├── hallazgo.md
│   ├── matriz_hallazgos.md
│   └── test-salidas.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Fase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
docs/
├── flujo_prompt_e_hu.md          # MODIFICAR §2a: convenciones Q1–Q5, plantillas y validador
└── plantillas/                   # NUEVO
    ├── hallazgo.md               # contracts/hallazgo.md
    ├── inventario_evidencias.md  # contracts/inventarios.md
    ├── inventario_activos.md
    ├── evidencia_insuficiente.md
    └── matriz_hallazgos.csv      # solo encabezado

scripts/                          # NUEVO
├── Test-Salidas.ps1              # validador (contracts/test-salidas.md)
└── tests/
    ├── Invoke-Pruebas.ps1
    └── fixtures/
        ├── valido/               # incluye EV-002 de contexto + un hallazgo de ejemplo
        └── invalido-*/           # un caso por comprobación C1–C10

salidas/                          # generado por el flujo (versionado, enmascarado)
├── inventario_evidencias.md
├── inventario_activos.md
├── evidencia_insuficiente.md
├── matriz_hallazgos.csv
└── hallazgos/H-NNN.md

evidencias/                       # NO versionado: EV-NNN_<tema>.<ext>

.github/pull_request_template.md  # MODIFICAR: ítems de revisión y validador
```

**Structure Decision**: se respeta la estructura existente (`docs/`, `evidencias/`, `salidas/`,
`.github/`). Solo se agregan `docs/plantillas/` y `scripts/`, como pidió el usuario. No se
crean `src/` ni `tests/` de aplicación.

## Complexity Tracking

No aplica: el Constitution Check no tiene violaciones.
