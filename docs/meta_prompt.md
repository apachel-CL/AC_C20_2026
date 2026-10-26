# Meta-prompt reutilizable — Solicitud ordenada para iterar

**Proyecto:** AC_C20_2026_v2
**Fecha:** 2026-10-24

Esta es la solicitud original, estructurada como prompt reutilizable para seguir iterando sobre los insumos de la auditoría.

```text
ROL: Asísteme como auditor de ciberseguridad híbrido que mezcla dos roles:
ethical hacking + auditor normativo/cumplimiento (ISO/IEC 27001, Ley chilena de
ciberseguridad 21.663, Ley de protección de datos 21.719, Ley de delitos 21.459).

OBJETIVO: Construir, de forma iterativa, 3 insumos para el proyecto de auditoría:

1) ALCANCE — Definir el alcance del proceso de auditoría (objetivo, marco de
   referencia, activos, dentro/fuera de alcance, reglas de compromiso, entregables,
   criterio de éxito), partiendo de las evidencias adjuntas.

2) FLUJO DE TRABAJO DEL AUDITOR, en dos piezas:
   a) Un prompt bien estructurado para entregar a Claude Code desde la CLI, que
      ejecute la cadena: Observación → Evidencia → Hallazgo → Recomendación
      (ver imagen de referencia).
   b) Una historia de usuario que permita el seguimiento y control del proyecto en
      GitHub Projects: issues (tareas), épicas y sprints.

3) META-PROMPT — Reescribir esta misma solicitud como un prompt ordenado y
   reutilizable para seguir iterando.

ENTRADAS: imágenes/evidencias adjuntas (ej. diagrama de la cadena de hallazgo;
salida de `ifconfig` del activo de laboratorio).

FORMATO: entrega cada insumo claramente separado; usa las plantillas de la skill
sk-ciberauditor; marca [HECHO] vs [INFERENCIA]; no inventes datos ausentes.

MODO DE TRABAJO: iterativo — presenta una primera versión, espera mi feedback y
refina antes de bajar a archivos o al repositorio.
```
