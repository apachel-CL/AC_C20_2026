# Flujo de trabajo del auditor — Prompt para Claude Code (CLI) + Historia de usuario

**Proyecto:** AC_C20_2026_v2
**Fecha:** 2026-10-24

---

## 2a. Prompt para Claude Code (CLI)

Pensado para pegar en la terminal dentro del repo del proyecto. Operacionaliza la cadena Observación → Evidencia → Hallazgo → Recomendación.

```text
Actúa como auditor de ciberseguridad híbrido (ethical hacker + auditor de cumplimiento
ISO/IEC 27001:2022, Ley 21.663, Ley 21.719, Ley 21.459) usando la skill sk-ciberauditor.

CONTEXTO
- Lee primero ./docs/alcance.md. El único activo en alcance es 192.168.56.101.
- Las evidencias están en ./evidencias/. Las salidas van a ./salidas/.
- Usa las plantillas de ./docs/plantillas/ (inventario_evidencias.md, inventario_activos.md,
  evidencia_insuficiente.md, hallazgo.md, matriz_hallazgos.csv) y respeta sus encabezados exactos.
- Metodología obligatoria (cuatro eslabones encadenados):
  Observación → Evidencia → Hallazgo → Recomendación.
  Sin evidencia no hay hallazgo; sin hallazgo no hay recomendación.
- Si ./evidencias/ está vacía, infórmalo y no generes hallazgos ni recomendaciones.

TAREA — procesa cada evidencia en este orden:
1. INVENTARIO (FR-001, FR-002): cada archivo se llama EV-NNN_<comando-o-tema>.<ext>
   (p. ej. EV-002_ifconfig.png). Si un archivo no tiene prefijo, asígnale el siguiente ID libre y
   PROPÓN el renombre; no lo renombres sin mi confirmación. Los IDs ya asignados no cambian y
   nunca se reutilizan. Si dos archivos comparten prefijo, informa el conflicto y no analices
   ninguno de los dos hasta que lo resuelva.
2. OBSERVACIÓN [HECHO] (FR-003): describe SOLO lo visible; transcribe textual IPs, máscaras,
   MAC, puertos, servicios, versiones, usuarios y mensajes. Indica la zona resaltada, si la hay.
3. CLASIFICACIÓN (exactamente una por evidencia, FR-004), evaluada en este orden:
   a) fuera-de-alcance: muestra un activo distinto de 192.168.56.101. Se evalúa primero y
      prevalece; no se analiza y se me informa (FR-015).
   b) hallazgo: muestra al menos una debilidad concreta visible (servicio inseguro, versión
      vulnerable, configuración débil, credencial por defecto o exposición innecesaria).
      Cita la debilidad en "Debilidad / Falta".
   c) contexto: solo identifica el activo; NO genera hallazgos.
   d) insuficiente: ilegible o incompleta; di qué falta en "Debilidad / Falta" y regístrala en
      evidencia_insuficiente.md (FR-006).
   Los datos del activo visibles en evidencia de contexto o de hallazgo van a
   inventario_activos.md con su EV de origen (FR-005).
4. HALLAZGO (solo clase b, FR-007): un archivo salidas/hallazgos/H-NNN.md desde la plantilla,
   con enunciado de una frase, evidencias de origen, severidad (Crítica/Alta/Media/Baja/
   Informativa) y justificación breve. Crea el bloque "Revisión" con Estado: pendiente y
   revisor y fecha vacíos; solo yo cambio ese estado (FR-014).
5. MAPEO NORMATIVO PRELIMINAR (FR-008): control ISO 27001 Anexo A (A.N.NN) con certeza
   (Alta/Media/Baja). No inventes controles ni artículos; si dudas, escribe "verificar".
6. RECOMENDACIÓN (exactamente una por hallazgo, FR-009): acción concreta, prioridad derivada de
   la severidad (Crítica→P0, Alta→P1, Media→P2, Baja/Informativa→P3), responsable sugerido (un
   rol) y criterio de cierre verificable.
7. MATRIZ (FR-010): una fila por hallazgo en salidas/matriz_hallazgos.csv (UTF-8 sin BOM, coma)
   con estas 11 columnas, en este orden: id_hallazgo, enunciado, evidencias (separadas por ";"),
   severidad, control_iso, certeza_iso, recomendacion, prioridad, responsable_sugerido,
   criterio_cierre, estado_revision. Cada columna coincide con su H-NNN.md.

REGLAS
- Etiqueta cada afirmación como [HECHO] (visible) o [INFERENCIA] (a confirmar). No inventes
  hallazgos, versiones, IPs ni datos ausentes de la evidencia (FR-011).
- NO EJECUCIÓN (FR-012): no ejecutes escaneos, exploits ni comandos contra ningún sistema. Un
  "comando contra un sistema" es todo comando que envía tráfico de red a un host o se ejecuta en
  un host, incluido 192.168.56.101. Solo puedes leer evidencias, escribir en ./salidas/ y ejecutar
  el validador local. Si se requiere verificación, PROPÓN los comandos, solo contra
  192.168.56.101, marcados "propuesto: lo ejecuta el auditor".
- REINGRESO (FR-017): el resultado de un comando que yo ejecute entra como evidencia nueva con su
  propio EV-NNN. Si completa una evidencia insuficiente, anota su ID en "Reemplazada por".
- ENMASCARADO (FR-013): enmascara siempre contraseñas, hashes, tokens, claves y datos de personas
  reales (****). Transcribe literalmente los identificadores técnicos del laboratorio: IP, MAC,
  hostname y usuarios por defecto del sistema (como msfadmin).
- Los mapeos legales no son dictamen jurídico. Si falta información, pregunta una cosa a la vez
  antes de asumir.

CIERRE (FR-016)
- Ejecuta el validador de solo lectura y corrige hasta que termine sin [ERROR]:
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1
  Todo [AVISO] C11 (posible secreto en claro) se enmascara o se justifica en el PR.
- Resume lo generado y lista dudas y supuestos, en un bloque listo para pegar en la
  descripción del PR.
```

---

## 2b. Historia de usuario (para GitHub Projects)

### Épica principal

> **Como** auditor de ciberseguridad (ethical hacker + cumplimiento),
> **quiero** transformar la evidencia técnica en hallazgos trazables, mapeados a ISO 27001 y a la normativa chilena, con recomendaciones priorizadas,
> **para** entregar un informe verificable que permita remediar riesgos y demostrar cumplimiento.

### Criterios de aceptación

- [ ] Toda evidencia está inventariada y clasificada (hallazgo / contexto / insuficiente).
- [ ] Cada hallazgo referencia evidencia, con severidad, control ISO y recomendación.
- [ ] Las evidencias de contexto alimentan el inventario de activos sin generar hallazgos.
- [ ] Existen la matriz de hallazgos y el resumen ejecutivo.
- [ ] Todo el trabajo se mantiene dentro del alcance autorizado.

### Épicas → issues

| Épica | Issues (tareas) |
|---|---|
| **E1. Alcance y gobierno** | Redactar alcance · Reglas de compromiso · Documentar autorización · Definir modo de red del laboratorio |
| **E2. Evidencias** | Convención de IDs · Carpeta `./evidencias` · Checklist de captura · Inventario de activos |
| **E3. Análisis** | Diseñar y probar el flujo · Clasificar evidencias · Generar hallazgos · Revisión humana |
| **E4. Mapeo normativo** | Mapa ISO 27001 · Mapa Ley 21.663 · Mapa Ley 21.719 · Verificación de artículos |
| **E5. Informe y remediación** | Matriz de hallazgos · Resumen ejecutivo · Plan de remediación |

### Configuración del Project

- **Estados:** Backlog / En curso / En revisión / Hecho
- **Campos:** Sprint · Épica · Severidad · Estimación · Marco normativo · Activo
- **Etiquetas:** `epic` `hallazgo` `evidencia` `normativa` `prompt` `bloqueado`
- **Vistas:** tablero · tabla por épica · roadmap por sprint
- **Sprint 1 sugerido:** E1 completa + inventario de evidencias + prueba del flujo con las primeras capturas (incluida EV-002).
