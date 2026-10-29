# Implementation Plan: Mapeo normativo de hallazgos

**Branch**: `feat/002-mapeo-normativo` (feature `002-mapeo-normativo`) | **Date**: 2026-10-28 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-mapeo-normativo/spec.md`

## Summary

Agregar a cada hallazgo `H-NNN.md` de la funcionalidad 001 un mapeo normativo detallado
(ISO/IEC 27001:2022, Ley 21.663 y Ley 21.719), una lista de verificación de artículos que solo
el auditor cierra, un mapa normativo consolidado y 7 columnas legales al final de la matriz.

- **Análisis:** igual que en 001, no hay aplicación. El mapeo lo propone Claude Code en sesión
  con la skill `sk-ciberauditor` y un prompt nuevo (§2c de `docs/flujo_prompt_e_hu.md`). Los
  artículos los fija el auditor tras consultar la fuente oficial.
- **Lo que construye esta funcionalidad:**
  - plantillas nuevas en `docs/plantillas/` (sección de mapeo, lista de verificación, mapa
    normativo) y la matriz con 18 columnas;
  - comprobaciones C15–C21 (error) y C22 (aviso) en `scripts/Test-Salidas.ps1`, con sus fixtures;
  - un ítem más en la plantilla de PR para la revisión del mapeo.

## Technical Context

**Language/Version**: Markdown y CSV (UTF-8) para los artefactos; Windows PowerShell 5.1 para la validación.

**Primary Dependencies**: Claude Code + skill `sk-ciberauditor` (mapeo); el validador y el runner de 001. Sin módulos externos.

**Storage**: archivos versionados en `salidas/` (`hallazgos/H-NNN.md`, `matriz_hallazgos.csv`, `verificacion_articulos.md`, `mapa_normativo.md`).

**Testing**: los fixtures de 001 se amplían; nuevos `invalido-c15…c21` y `aviso-*`; mismo runner `scripts/tests/Invoke-Pruebas.ps1`.

**Target Platform**: Windows 11, PowerShell 5.1, carpeta dentro de OneDrive.

**Project Type**: flujo documental con validador por línea de comandos.

**Performance Goals**: el validador sigue por debajo de 5 s con ≤ 50 hallazgos.

**Constraints**:
- sin red, sin consultar fuentes externas desde scripts y sin ejecutar comandos contra sistemas;
- ningún número de artículo sin fila `verificado` (FR-010);
- las 11 columnas de 001 no cambian;
- compatibilidad: una salida de 001 sin mapeo sigue siendo válida.

**Scale/Scope**: un activo, decenas de hallazgos, dos leyes mapeadas por hallazgo.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Cómo lo cumple el diseño | Estado |
|---|---|---|
| I. Alcance autorizado | Solo se mapean hallazgos de 001, que ya excluyen `fuera-de-alcance` (C7) | ✅ |
| II. Trazabilidad | El mapa normativo lleva de control/obligación a hallazgo y de ahí a evidencia (C21) | ✅ |
| III. Veracidad | Artículos solo con fila `verificado` (C19); controles ISO contra la lista del Anexo A 2022 (C17); [INFERENCIA] en todo mapeo legal | ✅ |
| IV. No ejecución | El validador sigue sin red; la verificación de artículos la hace el auditor | ✅ |
| V. Protección de datos y alcance legal | Leyenda "no constituye dictamen jurídico" obligatoria (C16); certeza ≤ `Media` para 21.663 (Q1) y para 21.719 sin vigencia verificada (C18); 21.459 nunca como obligación (C20) | ✅ |
| VI. Gestión ágil | Tareas con tallas en `/speckit-tasks`; ninguna XL | ✅ (se verifica en tasks) |
| VII. Revisión humana | Mapear un hallazgo aprobado lo vuelve a `pendiente` (FR-016, prompt + DoD) | ✅ |

**Re-check después de la Fase 1:** sin violaciones. FR-016 no se puede comprobar con un
validador sin historial; se cubre con el prompt y el checklist del PR (research R6). No hace
falta llenar Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/002-mapeo-normativo/
├── spec.md
├── plan.md              # este archivo
├── research.md          # Fase 0
├── data-model.md        # Fase 1
├── quickstart.md        # Fase 1
├── contracts/           # Fase 1
│   ├── mapeo-hallazgo.md
│   ├── matriz-columnas-legales.md
│   ├── verificacion-articulos.md
│   ├── mapa-normativo.md
│   └── test-salidas-002.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Fase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
docs/
├── flujo_prompt_e_hu.md            # MODIFICAR: nueva §2c, prompt de mapeo normativo
└── plantillas/
    ├── mapeo_normativo.md          # NUEVO: sección para agregar a H-NNN.md
    ├── verificacion_articulos.md   # NUEVO
    ├── mapa_normativo.md           # NUEVO
    └── matriz_hallazgos.csv        # MODIFICAR: 11 + 7 columnas

scripts/
├── Test-Salidas.ps1                # MODIFICAR: C15–C22; C12 pasa a contar desde la columna 19
└── tests/fixtures/
    ├── valido/                     # MODIFICAR: H-001 mapeado + lista + mapa
    ├── valido-sin-mapeo/           # NUEVO: salida de 001 con 18 columnas y legales vacías
    ├── invalido-c15…c21-*/         # NUEVO: un caso por comprobación
    └── aviso-*/                    # NUEVO: referencias pendientes

salidas/                            # generado por el flujo
├── hallazgos/H-NNN.md              # + sección "Mapeo normativo"
├── matriz_hallazgos.csv            # + 7 columnas legales
├── verificacion_articulos.md       # NUEVO
└── mapa_normativo.md               # NUEVO

.github/pull_request_template.md    # MODIFICAR: ítem de revisión del mapeo
```

**Structure Decision**: se reutiliza la estructura de 001 sin carpetas nuevas. El validador
sigue siendo un único script (research R4 de 001).

## Complexity Tracking

No aplica: el Constitution Check no tiene violaciones.
