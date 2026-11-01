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

---

## 2c. Prompt de mapeo normativo (funcionalidad 002)

Se ejecuta después de §2a, sobre los hallazgos ya generados en `./salidas/hallazgos/`. Formatos:
`specs/002-mapeo-normativo/contracts/`.

```text
Actúa como auditor de cumplimiento (ISO/IEC 27001:2022, Ley 21.663, Ley 21.719, Ley 21.459)
usando la skill sk-ciberauditor. Vas a mapear los hallazgos existentes; no analizas evidencias
nuevas ni creas hallazgos (FR-001).

CONTEXTO
- Lee ./docs/alcance.md y cada ./salidas/hallazgos/H-NNN.md cuyo Estado no sea "descartado".
- Plantillas: ./docs/plantillas/mapeo_normativo.md (sección a insertar entre "## Recomendación"
  y "## Revisión"), verificacion_articulos.md y mapa_normativo.md.
- Todo mapeo legal es orientativo y no constituye dictamen jurídico: incluye la leyenda.

TAREA — para cada hallazgo no descartado:
1. ISO/IEC 27001:2022 (FR-003, FR-004): confirma o corrige el control principal del Anexo A
   (A.5.1–A.5.37, A.6.1–A.6.8, A.7.1–A.7.14, A.8.1–A.8.34) en los campos "Control ISO" y
   "Certeza ISO". Si lo corriges, registra "Control ISO anterior" y "Motivo de corrección"; si lo
   confirmas, "—" y "confirmado". Agrega controles adicionales sin repetir el principal. Ante la
   duda, "verificar". Actualiza control_iso, certeza_iso y controles_iso_adicionales en la matriz.
2. LEY 21.663 (FR-005, FR-006): categoría "gestión de riesgos", "medidas de seguridad",
   "reporte de incidentes" o "no aplica". El mapeo es hipotético: la justificación dice
   "si la organización fuera entidad obligada" y la certeza nunca es "Alta".
3. LEY 21.719 (FR-007): "no aplica" si el hallazgo no afecta datos personales. "Podría
   afectarlos" = expone una base de datos, un directorio o servicio de usuarios, correo,
   archivos compartidos o una aplicación web con cuentas. Si los afecta o podría afectarlos y la
   fila "entrada en vigor" de verificacion_articulos.md NO está "verificado", registra
   "pendiente de vigencia" y deja la obligación candidata solo en la justificación; siempre
   completa la advertencia de vigencia diferida.
4. LEY 21.459 (FR-008): no la mapees en el hallazgo. Solo va en mapa_normativo.md, como marco
   de la autorización de las pruebas.
5. ARTÍCULOS (FR-009, FR-010): deja todo artículo en "verificar" ("—" si no aplica) y agrega una
   fila "pendiente" por referencia en verificacion_articulos.md, más la fila "entrada en vigor"
   de la Ley 21.719 si corresponde. NO inventes números de artículo. Copia un artículo al
   hallazgo y a la matriz solo si su fila está "verificado" (lo hace el auditor).
6. MATRIZ Y MAPA (FR-011, FR-012): completa las 7 columnas legales al final de
   matriz_hallazgos.csv (vacías para hallazgos descartados) y regenera mapa_normativo.md desde
   los hallazgos (sin "no aplica" ni "pendiente de vigencia").

REGLAS
- Etiqueta cada justificación con [HECHO] o [INFERENCIA] (FR-014).
- No ejecutes comandos contra sistemas ni consultes fuentes externas: la verificación de
  artículos la hace el auditor (FR-015).
- REVISIÓN (FR-016): en todo hallazgo cuyo mapeo crees o modifiques, pon Estado: pendiente,
  vacía Revisor y Fecha, conserva el comentario anterior con el prefijo "Revisión previa:" y
  alinea estado_revision en la matriz.

CIERRE (FR-017)
- Ejecuta el validador y corrige hasta que termine sin [ERROR]:
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1
  El [AVISO] C22 lista las referencias pendientes de verificación.
- Resume lo mapeado, cuántas referencias quedan pendientes y las dudas y supuestos, en un
  bloque listo para pegar en la descripción del PR.
```

---

## 2d. Prompt de informe y remediación (funcionalidad 003)

Se ejecuta al final, cuando hay hallazgos revisados por el auditor (Estado `aprobado` o
`corregido`). Formatos: `specs/003-informe-remediacion/contracts/`.

```text
Actúa como auditor de ciberseguridad usando la skill sk-ciberauditor. Vas a consolidar los
hallazgos ya revisados en el plan de remediación y el resumen ejecutivo. No analizas evidencias
nuevas ni creas o modificas hallazgos, recomendaciones ni la matriz (FR-001).

CONTEXTO
- Lee ./docs/alcance.md, cada ./salidas/hallazgos/H-NNN.md, ./salidas/matriz_hallazgos.csv,
  los inventarios, ./salidas/evidencia_insuficiente.md y, si existe,
  ./salidas/verificacion_articulos.md.
- Entran al informe solo los hallazgos con Estado "aprobado" o "corregido". Cuenta aparte los
  "pendiente" y los "descartado".
- Plantillas: ./docs/plantillas/plan_remediacion.md y ./docs/plantillas/resumen_ejecutivo.md.

TAREA 1 — PLAN DE REMEDIACIÓN (salidas/plan_remediacion.md)
1. Una fila por hallazgo revisado (FR-002). Copia de la matriz, sin reescribir: evidencias
   (";" → "; "), severidad, prioridad, recomendacion → Acción, responsable_sugerido y
   criterio_cierre (FR-003). Si una celda tendría "|", detente y pide al auditor que la
   reescriba en el hallazgo y la matriz.
2. Ordena por prioridad (P0 → P3), luego severidad (Crítica → Informativa), luego ID, y numera
   Orden 1…n (FR-004).
3. Plazo derivado de la prioridad: P0 "7 días", P1 "30 días", P2 "90 días", P3 "180 días"
   (FR-005). Estado "abierto", Fecha y Evidencia de cierre "—", Comentario "—" (FR-006).
   Si la acción se resuelve junto con otro hallazgo, dilo en el Comentario citando su ID.
4. Completa los recuentos de hallazgos excluidos (FR-007).

TAREA 2 — RESUMEN EJECUTIVO (salidas/resumen_ejecutivo.md)
1. Las 7 secciones de la plantilla, en orden. Máximo 500 palabras antes de "## Revisión" (FR-008).
2. Conteo por severidad igual a los hallazgos revisados de la matriz (FR-009).
3. Riesgos principales: máximo 5, los de mayor prioridad, en lenguaje no técnico y cada uno con
   su H-NNN; si hay más, remite al plan. Sin hallazgos revisados, dilo y no inventes riesgos.
4. Prioridades de remediación: tomadas del plan, agrupadas por plazo, con sus H-NNN.
5. Implicancias normativas (FR-011): incluye la leyenda "Mapeo orientativo; no constituye
   dictamen jurídico". Cita artículos solo si su fila está "verificado". Mientras la fila
   "entrada en vigor" no esté "verificado", la Ley 21.719 no se cita como obligación vigente y
   toda línea que la mencione dice "vigencia". La Ley 21.459 solo como marco de la
   autorización. Si la matriz no tiene columnas legales, omite la parte normativa y anótalo en
   Limitaciones.
6. Limitaciones: evidencia insuficiente, hallazgos pendientes de revisión y referencias legales
   por verificar.

REGLAS
- Lenguaje no técnico en el resumen: sin comandos, puertos ni versiones salvo que sean
  imprescindibles, y entonces explicados en una frase (FR-010).
- Etiqueta [INFERENCIA] todo lo que no provenga de un hallazgo revisado o de una fuente
  verificada (FR-012).
- Enmascara credenciales, hashes, tokens, claves y datos personales (FR-013). El responsable es
  un rol, nunca un nombre.
- Los comandos del plan, si los hay, siguen marcados "propuesto: lo ejecuta el auditor" y
  apuntan solo a 192.168.56.101. El resumen no lleva comandos. No ejecutes nada (FR-014).
- REVISIÓN (FR-015, FR-016): ambos documentos quedan con Estado "pendiente". Si regeneras un
  documento "aprobado" o "corregido" y su contenido cambia, pon Estado "pendiente", vacía
  Revisor y Fecha y conserva el comentario anterior con el prefijo "Revisión previa:". No
  cambies estados de remediación ni plazos: eso lo hace el auditor.

CIERRE (FR-019)
- Ejecuta el validador y corrige hasta que termine sin [ERROR]:
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1
  El [AVISO] C29 indica que el informe aún no está cerrado (falta la revisión del auditor).
- Resume lo generado, los hallazgos excluidos y las dudas y supuestos, en un bloque listo para
  pegar en la descripción del PR.
```
