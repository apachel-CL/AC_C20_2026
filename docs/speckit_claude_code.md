# Instrucción para Claude Code — Spec-Driven Development con Spec Kit

**Proyecto:** AC_C20_2026_v2
**Repositorio:** https://github.com/apachel-CL/AC_C20_2026
**Project:** [AC_C20_2026 – Auditoría Ágil](https://github.com/users/apachel-CL/projects/4) (n.º 4)
**Herramienta:** [github/spec-kit](https://github.com/github/spec-kit) v1.2.3 (CLI `specify`)
**Fecha:** 2026-10-26

---

## Cómo se usa

Spec Kit se usa en tres tiempos. Las skills `/speckit-*` solo existen **después** de `specify init`, por eso hay que reiniciar Claude Code entre la Parte A y la Parte B.

| Parte | Dónde | Qué hace |
|---|---|---|
| A | Claude Code (prompt) | Instala `uv` y `specify`, crea una rama e inicializa Spec Kit en el repo |
| — | Terminal | Sales de Claude Code (`/exit`) y vuelves a entrar con `claude` |
| B | Claude Code (skills) | Constitución → especificación → plan → tareas → análisis, una skill a la vez |
| C | Claude Code (prompt) | Vuelca `tasks.md` al Project 4 con Talla y Puntos, sin duplicar los issues #1–#24 |

> El repositorio se llama **spec-kit**, no "sec-kit". No hace falta clonarlo para usarlo: `specify` se instala desde el tag de la versión. La Parte A lo clona fuera del proyecto, solo como referencia de lectura.

---

## Parte A — Preparación (pegar en Claude Code)

```text
Actúa como ingeniero DevOps. Vas a preparar este repositorio (AC_C20_2026_v2, Windows,
PowerShell 5.1, carpeta dentro de OneDrive) para usar Spec Kit con Claude Code.

REGLAS
- Muéstrame el plan y espera mi aprobación antes de ejecutar.
- Nunca uses push --force, reset --hard ni borres archivos que no hayas creado tú.
- Pide confirmación antes de cualquier push.

PASOS
1. Verifica: `git status` limpio en main y sincronizado con origin. Si hay cambios sin
   commitear, detente y muéstramelos.
2. Instala uv si no existe:
     winget install --id astral-sh.uv -e
   (alternativa: powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex")
   Comprueba con `uv --version`. Si el PATH no se actualiza en esta sesión, agrega
   $env:USERPROFILE\.local\bin a $env:Path solo para esta sesión.
3. Instala la CLI de Spec Kit pinneada a la versión 1.2.3:
     uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v1.2.3
   Comprueba con `specify version`.
4. Referencia (opcional, solo lectura): clona el repo FUERA de este proyecto y de OneDrive:
     gh repo clone github/spec-kit "$env:USERPROFILE\src\spec-kit" -- --depth 1
   No ejecutes ningún script de esa carpeta.
5. Crea la rama de adopción: `git switch -c chore/speckit-init`
6. Inicializa Spec Kit en el repo actual:
     specify init --here --force --non-interactive --integration claude --script ps
   --force es necesario porque la carpeta no está vacía. Antes de ejecutarlo, dime qué
   archivos existentes podría tocar (en especial .claude/ y .github/).
7. Revisa el diff (`git status`, `git diff --stat`) y explícame qué se creó:
   .specify/ (memoria, plantillas y scripts) y .claude/skills/speckit-*/ (skills).
   Confirma que .claude/settings.local.json sigue ignorado y que no se commitea.
8. Commit "chore: inicializar Spec Kit (integración claude, scripts ps)" y, con mi
   confirmación, `git push -u origin chore/speckit-init`.
9. Termina diciéndome que salga de Claude Code y vuelva a entrar para cargar las skills,
   y lista las skills /speckit-* detectadas en .claude/skills/.

NO instales la extensión `github` de Spec Kit (`specify extension add github`): requiere el
servidor MCP de GitHub y no conoce los campos Talla/Puntos del Project. Los issues se crean
en la Parte C con gh.
```

---

## Parte B — Flujo SDD (una skill a la vez; revisa cada resultado antes de seguir)

Primera funcionalidad acotada: **el flujo de análisis Observación → Evidencia → Hallazgo → Recomendación** (épicas E2 y E3). El mapeo normativo (E4) y el informe (E5) quedan para las funcionalidades 002 y 003.

### B1. Constitución (una vez por proyecto)

```text
/speckit-constitution Proyecto de auditoría de ciberseguridad híbrida (ethical hacking + cumplimiento ISO/IEC 27001:2022, Ley 21.663, Ley 21.719 y Ley 21.459 de Chile). Usa como evidencia docs/alcance.md, docs/flujo_prompt_e_hu.md y docs/estimacion.md; no inventes reglas que no estén ahí. Principios: (1) Alcance: solo el activo autorizado 192.168.56.101; nada fuera de alcance. (2) Trazabilidad: cadena Observación → Evidencia → Hallazgo → Recomendación; sin evidencia no hay hallazgo y sin hallazgo no hay recomendación. (3) Veracidad: cada afirmación se etiqueta [HECHO] o [INFERENCIA]; no se inventan IPs, versiones, artículos ni datos ausentes; si hay duda se escribe "verificar". (4) No ejecución: Claude no ejecuta escaneos, exploits ni comandos contra sistemas; solo propone comandos para que el auditor los ejecute. (5) Protección de datos: se enmascaran credenciales y datos personales; los mapeos legales son orientativos, no dictamen jurídico. (6) Gestión ágil: todo trabajo se estima con las tallas de docs/estimacion.md (XS=1, S=2, M=3, L=5, XL=8); ninguna tarea XL entra a un sprint; se cumplen la DoR y la DoD de ese documento. (7) Revisión humana obligatoria antes de dar por cerrado un hallazgo. Los entregables son Markdown y CSV, versionados en git.
```

### B2. Especificación

```text
/speckit-specify Flujo de análisis de evidencias del auditor. Como auditor quiero transformar cada evidencia técnica de ./evidencias/ (capturas y salidas de comandos) en hallazgos trazables, para entregar resultados verificables. El flujo: (1) inventaria las evidencias y les asigna ID EV-001, EV-002…; (2) registra la observación textual de lo visible (IPs, máscaras, MAC, puertos, servicios, versiones, usuarios, mensajes); (3) clasifica cada evidencia como "de hallazgo", "de contexto" (alimenta el inventario de activos y no genera hallazgo) o "insuficiente" (indicando qué falta); (4) solo para las de hallazgo, redacta el hallazgo H-XXX con severidad (Crítica, Alta, Media, Baja, Informativa) y justificación; (5) propone una recomendación concreta, priorizada y verificable con responsable sugerido y criterio de cierre. Salidas en ./salidas/: inventario_evidencias.md, inventario_activos.md, evidencia_insuficiente.md, hallazgos/H-XXX.md y matriz_hallazgos.csv. Caso de prueba obligatorio: EV-002 (salida de ifconfig del host metasploitable), que es evidencia de contexto. Fuera de alcance de esta funcionalidad: mapeo normativo detallado (funcionalidad 002) y resumen ejecutivo y plan de remediación (funcionalidad 003).
```

### B3. Aclaraciones

```text
/speckit-clarify Enfócate en: criterios para distinguir evidencia de contexto frente a evidencia de hallazgo, el formato y las columnas de matriz_hallazgos.csv, la convención de nombres de archivos de evidencia y cómo se registra la revisión humana de cada hallazgo.
```

### B4. Plan

```text
/speckit-plan No hay aplicación ni base de datos: los artefactos son Markdown y CSV (UTF-8, separador coma) dentro del repo. Las plantillas de hallazgo y de inventario viven en docs/plantillas/. La automatización, si hace falta, son scripts PowerShell 5.1 en scripts/ que solo validan estructura (IDs únicos, columnas del CSV, que todo H-XXX referencie un EV-XXX existente) y nunca tocan la red. El análisis lo hace Claude Code con la skill sk-ciberauditor y el prompt de docs/flujo_prompt_e_hu.md. La revisión humana se registra con el checklist de la plantilla de PR. Respeta la estructura actual de carpetas (docs/, evidencias/, salidas/, .github/).
```

### B5. Checklist de calidad

```text
/speckit-checklist Verifica que cada requisito sea comprobable, que la cadena de trazabilidad no tenga huecos y que ninguna tarea implique ejecutar comandos contra sistemas.
```

### B6. Tareas

```text
/speckit-tasks Al final de cada tarea agrega su talla y sus puntos según docs/estimacion.md, con el formato "[Talla: M | 3 pts]". Si una tarea sería XL, divídela. Indica en cada tarea a qué épica pertenece (E2 o E3).
```

### B7. Análisis de consistencia

```text
/speckit-analyze
```

Si reporta problemas, corrígelos en `spec.md`, `plan.md` o `tasks.md` y vuelve a ejecutarlo. **No pases a la Parte C hasta que `/speckit-analyze` quede limpio.**

---

## Parte C — Volcar las tareas al Project con tallas (pegar en Claude Code)

```text
Actúa como Scrum Master. Sincroniza el tasks.md de la funcionalidad activa de Spec Kit
(lee .specify/feature.json para ubicarla) con el repo apachel-CL/AC_C20_2026 y el
Project n.º 4 del owner apachel-CL ("AC_C20_2026 – Auditoría Ágil").

CONTEXTO
- Ya existen 24 issues: épicas #1–#5 (E1…E5) y tareas #6–#24 creadas desde
  docs/flujo_prompt_e_hu.md. NO los dupliques.
- Las tallas y la DoR/DoD están en docs/estimacion.md. Las épicas no llevan talla ni puntos.

PASOS
1. Lee los campos del Project con `gh project field-list 4 --owner apachel-CL --format json`
   y obtén los IDs de Talla, Puntos, Épica, Status y Sprint (si existe).
2. Lista los issues con `gh issue list -R apachel-CL/AC_C20_2026 --state all --limit 200`.
3. Construye una tabla de correspondencia: tarea de tasks.md (T001…) → issue existente
   (si su objetivo coincide) o NUEVO. Muéstramela con talla, puntos y épica, y espera mi
   aprobación antes de escribir nada en GitHub.
4. Para cada tarea aprobada:
   - Si corresponde a un issue existente: agrega un comentario con el ID Txxx y el enlace a
     tasks.md, y actualiza Talla y Puntos en el Project solo si están vacíos (si difieren,
     pregúntame).
   - Si es NUEVA: créala con título "Txxx: <descripción>", etiquetas de tipo y dominio,
     criterios de aceptación verificables y un enlace a spec.md; agrégala como sub-issue de
     su épica (mutación GraphQL addSubIssue) y al Project (`gh project item-add`), con
     Épica, Talla, Puntos y Status = Backlog (`gh project item-edit`).
5. Ninguna tarea XL se agrega al Project: avísame para dividirla.
6. Calcula el total de puntos por épica y, si existe el campo Sprint, verifica que lo
   comprometido para el sprint actual no supere 20 puntos (tope del Sprint 1).
7. Agrega en tasks.md, junto a cada tarea, el número de issue (#n). Commit
   "docs(speckit): enlazar tareas con issues" en la rama de la funcionalidad y, con mi
   confirmación, push.

ENTREGA
- Tabla final: Txxx | issue | épica | talla | puntos | nuevo/existente.
- Total de puntos por épica, errores encontrados y pasos manuales pendientes.
```

---

## Después: implementar

Cuando el backlog esté en el Project, la implementación sigue con `/speckit-implement`, de a una fase por vez. Cada fase se cierra con un PR contra `main` que referencia sus issues (`Closes #n`) y registra la talla real frente a la estimada. Al terminar, `/speckit-converge` detecta lo que falta. Las funcionalidades 002 (mapeo normativo) y 003 (informe y remediación) repiten la Parte B desde `/speckit-specify`.
