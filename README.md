# AC_C20_2026 — Auditoría de ciberseguridad híbrida

Auditoría de ciberseguridad híbrida (ethical hacking + cumplimiento) sobre un activo de laboratorio. Los resultados se contrastan con ISO/IEC 27001:2022 y con las leyes chilenas 21.663, 21.719 y 21.459.

## Metodología

Cada hallazgo debe ser trazable a evidencia mediante una cadena de cuatro eslabones:

**Observación → Evidencia → Hallazgo → Recomendación**

Sin evidencia no hay hallazgo; sin hallazgo no hay recomendación.

## Estructura

```
docs/
  alcance.md              Alcance, reglas de compromiso y entregables
  flujo_prompt_e_hu.md    Prompt de trabajo para Claude Code + historia de usuario y épicas
  meta_prompt.md          Meta-prompt reutilizable
  integracion_github.md   Instrucciones de integración con GitHub y el Project
  estimacion.md           Tallas, puntos, DoR, DoD y velocidad
  plantillas/             Plantillas de inventarios, hallazgo (H-NNN.md) y matriz CSV
  referencias/            Material de referencia del curso
evidencias/               Capturas y salidas de comandos (no se versionan: repo público)
salidas/                  Inventarios, hallazgos, matriz, verificación de artículos, mapa normativo, plan de remediación y resumen ejecutivo
scripts/
  Test-Salidas.ps1        Validador de solo lectura de salidas/ (comprobaciones C1–C29)
  tests/                  Runner Invoke-Pruebas.ps1 y fixtures ficticios del validador
specs/                    Especificaciones Spec Kit (spec, plan, contratos, tareas)
.github/                  Plantillas de issues y de pull request
```

## Validación de las salidas

El validador solo lee archivos locales: no usa la red ni ejecuta comandos contra sistemas.
Termina con código 0 si no hay errores (los avisos no fallan) y con 1 si hay alguno.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/Invoke-Pruebas.ps1
```

Comprobaciones:

- **C1–C14** (funcionalidad 001: inventarios, hallazgos, matriz, revisión y avisos): [specs/001-analisis-evidencias/contracts/test-salidas.md](specs/001-analisis-evidencias/contracts/test-salidas.md).
- **C15–C22** (funcionalidad 002: mapeo normativo, `salidas/verificacion_articulos.md` y `salidas/mapa_normativo.md`): [specs/002-mapeo-normativo/contracts/test-salidas-002.md](specs/002-mapeo-normativo/contracts/test-salidas-002.md).
- **C23–C29** (funcionalidad 003: `salidas/plan_remediacion.md` y `salidas/resumen_ejecutivo.md`; solo se ejecutan si existe alguno de los dos): [specs/003-informe-remediacion/contracts/test-salidas-003.md](specs/003-informe-remediacion/contracts/test-salidas-003.md).

## Gestión del trabajo

- Project: [AC_C20_2026 – Auditoría Ágil](https://github.com/users/apachel-CL/projects/4)
- Estimación por tallas y cálculo de velocidad: [docs/estimacion.md](docs/estimacion.md)
