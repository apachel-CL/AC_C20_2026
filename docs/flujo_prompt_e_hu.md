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
- Lee primero ./docs/alcance.md. No actúes fuera del alcance autorizado.
- Las evidencias están en ./evidencias/. Las salidas van a ./salidas/.
- Metodología obligatoria (cuatro eslabones encadenados):
  Observación → Evidencia → Hallazgo → Recomendación.
  Sin evidencia no hay hallazgo; sin hallazgo no hay recomendación.

TAREA — procesa cada evidencia en este orden:
1. INVENTARIO: lista las evidencias y asígnales ID (EV-001, EV-002, ...).
2. OBSERVACIÓN [HECHO]: describe SOLO lo visible; transcribe textual IPs, máscaras,
   MAC, puertos, servicios, versiones, usuarios y mensajes. Indica la zona resaltada.
3. CLASIFICACIÓN (una por evidencia): (a) de hallazgo, (b) de contexto
   (identifica el activo, NO genera hallazgo), (c) insuficiente (di qué falta).
4. HALLAZGO (solo clase a): enúncialo en una frase, con severidad
   (Crítica/Alta/Media/Baja/Informativa) y justificación breve.
5. MAPEO NORMATIVO: control ISO 27001 Anexo A y, si aplica, obligación legal chilena,
   con nivel de certeza (Alta/Media/Baja). No inventes artículos; si dudas, escribe "verificar".
6. RECOMENDACIÓN: acción concreta, priorizada y verificable (qué hacer, responsable
   sugerido, cómo validar el cierre).

REGLAS
- Etiqueta cada afirmación como [HECHO] (visible) o [INFERENCIA] (a confirmar).
- No inventes hallazgos, versiones, IPs ni datos ausentes de la evidencia.
- No ejecutes escaneos, exploits ni comandos contra ningún sistema; si se requiere
  verificación, PROPÓN los comandos para que yo los ejecute.
- Enmascara credenciales y datos personales. Los mapeos legales no son dictamen jurídico.
- Si falta información, pregunta una cosa a la vez antes de asumir.

SALIDAS (en ./salidas/)
- inventario_evidencias.md, inventario_activos.md
- hallazgos/H-XXX.md (uno por hallazgo) y matriz_hallazgos.csv
- evidencia_insuficiente.md
- resumen_ejecutivo.md (máx. 1 página)
Al terminar, resume lo generado y lista dudas y supuestos.
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
