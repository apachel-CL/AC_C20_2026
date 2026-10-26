# Instrucción para Claude Code — Integración con GitHub + Project ágil con tallas

**Proyecto:** AC_C20_2026_v2
**Repositorio destino:** https://github.com/apachel-CL/AC_C20_2026
**Fecha:** 2026-10-26

---

## Antes de pegar el prompt (lo haces tú, una sola vez)

Claude Code no puede completar inicios de sesión interactivos, así que estos pasos van primero, en PowerShell:

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
# Cierra y vuelve a abrir la terminal
gh auth login                 # GitHub.com → HTTPS → Login with a web browser
gh auth refresh -s project    # permiso para crear y editar Projects
gh auth status                # debe mostrar los scopes: repo, project
```

Después abre Claude Code en la carpeta del proyecto (`claude`, **sin** `--dangerously-skip-permissions`) y pega el bloque siguiente.

---

## Prompt

```text
Actúa como ingeniero DevOps y Scrum Master. Trabaja en la carpeta actual
(AC_C20_2026_v2, dentro de OneDrive en Windows, shell PowerShell 5.1).

OBJETIVO
1) Versionar este proyecto local y publicarlo en https://github.com/apachel-CL/AC_C20_2026
2) Crear un GitHub Project (v2) enlazado al repo para gestionar épicas, historias y tareas con Scrum.
3) Estimar el trabajo por talla (XS, S, M, L, XL) con puntos asociados, de forma que se pueda medir la velocidad por sprint.

REGLAS GENERALES
- Primero entra en modo plan: inspecciona, muéstrame el plan completo y espera mi aprobación.
- Pide confirmación explícita antes de: el primer push, cualquier operación sobre contenido remoto
  existente, y la subida de PDFs o de la carpeta evidencias/.
- Nunca uses push --force, reset --hard ni borres contenido remoto.
- Si un paso no se puede automatizar con gh o la API GraphQL, no lo simules: agrégalo a una lista
  "PASOS MANUALES" con instrucciones exactas para la interfaz web.
- Al final entrega un resumen: qué se creó (con URLs), qué falló y los pasos manuales pendientes.

FASE 0 — VERIFICACIÓN
- Comprueba `git --version`, `gh --version` y `gh auth status` (los scopes deben incluir repo y project).
  Si falta algo, detente y dime exactamente qué comando ejecutar.
- `gh repo view apachel-CL/AC_C20_2026 --json name,visibility,isEmpty,defaultBranchRef`
  Informa la visibilidad (pública o privada) y si el repo ya tiene commits.

FASE 1 — REPOSITORIO LOCAL
- `git init -b main` (si no existe .git).
- Autoría: user.name = "apachel-CL"; user.email = el correo noreply de GitHub
  (`<id>+apachel-CL@users.noreply.github.com`, obtén el id con `gh api user --jq .id`).
  Configúralo solo a nivel de repositorio (sin --global).
- Crea un .gitignore que excluya: .claude/settings.local.json, Thumbs.db, desktop.ini, ~$*,
  *.tmp, .vscode/ (excepto settings compartidos si existen), y cualquier archivo de credenciales.
- Propón (sin ejecutar hasta que lo apruebe) esta estructura, coherente con el prompt de
  02_flujo_prompt_cli_e_historia_usuario.md, que espera ./docs, ./evidencias y ./salidas:
    docs/alcance.md               ← 01_alcance.md
    docs/flujo_prompt_e_hu.md     ← 02_flujo_prompt_cli_e_historia_usuario.md
    docs/meta_prompt.md           ← 03_meta_prompt_reutilizable.md
    docs/integracion_github.md    ← este archivo
    docs/estimacion.md            (nuevo, ver FASE 3)
    docs/referencias/Guia_S01.pdf ← "Guía S01.pdf"
    evidencias/.gitkeep
    salidas/.gitkeep
  Usa `git mv` si los archivos ya están versionados. Si no apruebo la reestructuración,
  conserva los nombres actuales.
- Si el repo es PÚBLICO: pregúntame si subir el PDF y si evidencias/ debe ignorarse
  (las evidencias pueden contener IPs, MAC y usuarios).
- Crea un README.md breve: propósito, estructura de carpetas, cadena
  Observación → Evidencia → Hallazgo → Recomendación, enlace al Project y a docs/estimacion.md.

FASE 2 — PUBLICACIÓN
- `git remote add origin https://github.com/apachel-CL/AC_C20_2026.git`
- Si el remoto está vacío: commit inicial "chore: estructura inicial del proyecto" y,
  con mi confirmación, `git push -u origin main`.
- Si el remoto tiene commits: `git fetch origin`, muéstrame qué contiene y propón integrarlo con
  `git merge origin/<rama> --allow-unrelated-histories`. Resuelve conflictos conmigo antes del push.

FASE 3 — PLANTILLAS Y CONVENCIONES ÁGILES (en el repo, en un commit "chore: plantillas ágiles")
- docs/estimacion.md, con la tabla de tallas que es la fuente de verdad:
    Talla | Puntos | Esfuerzo orientativo | Regla
    XS    | 1      | < 2 h                | cambio trivial
    S     | 2      | ~ medio día          | una tarea clara, sin dudas
    M     | 3      | 1–2 días             | algo de incertidumbre
    L     | 5      | 3–5 días             | varias partes; evaluar dividir
    XL    | 8      | > 1 semana           | NO entra a un sprint: debe dividirse
  Incluye: Definition of Ready (tiene criterios de aceptación, talla ≤ L y épica asignada),
  Definition of Done (criterios cumplidos, revisión humana, evidencia enlazada si aplica),
  cómo se calcula la velocidad (suma de Puntos en estado Hecho por Sprint) y la duración del
  sprint (2 semanas).
- .github/ISSUE_TEMPLATE/ (issue forms en YAML):
    historia.yml  → "Como / quiero / para", criterios de aceptación (checklist), dropdown Talla, épica.
    tarea.yml     → descripción, definición de hecho, dropdown Talla, historia padre.
    hallazgo.yml  → ID H-XXX, evidencia EV-XXX, severidad, control ISO 27001, recomendación.
    config.yml    → blank_issues_enabled: false.
  Los dropdowns de Talla son orientativos: el valor oficial vive en el campo Talla del Project.
- .github/pull_request_template.md con "Closes #", checklist DoD y talla real vs. estimada.

FASE 4 — ETIQUETAS (gh label create … --force)
  tipo:      epic, historia, tarea, hallazgo
  dominio:   evidencia, normativa, prompt, docs
  estado:    bloqueado
  Usa colores distintos por grupo. No dupliques las etiquetas por defecto de GitHub.

FASE 5 — GITHUB PROJECT (v2)
- `gh project create --owner apachel-CL --title "AC_C20_2026 – Auditoría Ágil"` y enlázalo con
  `gh project link <n> --owner apachel-CL --repo apachel-CL/AC_C20_2026`.
- Campo Status: reemplaza sus opciones por Backlog, Listo, En curso, En revisión, Hecho usando la
  mutación GraphQL updateProjectV2Field (singleSelectOptions). Si falla, pásalo a PASOS MANUALES.
- Campos (gh project field-create):
    Talla           SINGLE_SELECT  XS, S, M, L, XL
    Puntos          NUMBER         (según la tabla de docs/estimacion.md)
    Prioridad       SINGLE_SELECT  P0-Crítica, P1-Alta, P2-Media, P3-Baja
    Épica           SINGLE_SELECT  E1 Alcance y gobierno, E2 Evidencias, E3 Análisis,
                                   E4 Mapeo normativo, E5 Informe y remediación
    Severidad       SINGLE_SELECT  Crítica, Alta, Media, Baja, Informativa
    Marco normativo SINGLE_SELECT  ISO 27001, Ley 21.663, Ley 21.719, Ley 21.459
    Inicio / Fin    DATE
- Campo Sprint (ITERATION, 2 semanas, inicio el próximo lunes, 4 iteraciones): intenta
  createProjectV2Field con iterationConfiguration por GraphQL; si no es posible, pásalo a PASOS MANUALES.

FASE 6 — BACKLOG INICIAL (a partir de docs/flujo_prompt_e_hu.md, sección "Épicas → issues")
- Crea 5 issues épicos (etiqueta epic) y, bajo cada uno, los issues de la tabla como sub-issues
  (mutación GraphQL addSubIssue; si no está disponible, usa una tasklist "- [ ] #n" en la épica).
- Cada issue: etiqueta de tipo y dominio, cuerpo con criterios de aceptación verificables, y
  agregado al Project (`gh project item-add`) con Épica, Talla y Puntos sugeridos.
  Asigna la talla con criterio y explícamela en una tabla para que pueda ajustarla.
- Sprint 1 (si el campo Sprint existe): toda E1, el inventario de evidencias y la prueba del flujo
  con EV-002. Comprueba que la suma de puntos del Sprint 1 sea razonable (≤ 20) y avísame si no.
- Status: Sprint 1 → Listo; resto → Backlog.

FASE 7 — PASOS MANUALES (entrégalos como checklist; gh no crea vistas ni automatizaciones)
- Vistas: "Tablero sprint" (Board por Status, filtro sprint:@current), "Backlog por épica"
  (Table agrupada por Épica, suma de Puntos visible), "Roadmap" (por Sprint/Inicio–Fin),
  "Por talla" (Table agrupada por Talla).
- Workflows del Project: auto-add de issues del repo, item cerrado → Hecho, PR fusionado → Hecho.
- Insights: gráfico de velocidad (suma de Puntos, eje X Sprint, filtro Status = Hecho) y
  gráfico de distribución por Talla.

ENTREGA FINAL
- URL del repo y del Project, lista de commits, tabla del backlog (issue, épica, talla, puntos,
  sprint), errores encontrados y checklist de PASOS MANUALES.
```

---

## Notas

- **OneDrive y Git:** la carpeta `.git` dentro de OneDrive funciona, pero la sincronización puede bloquear archivos mientras git escribe. Si ves errores de "permission denied" o "index.lock", pausa la sincronización de OneDrive durante los commits o mueve el proyecto fuera de OneDrive.
- **Por qué tallas + puntos:** la talla es la conversación rápida en el refinamiento; los puntos (1-2-3-5-8) permiten sumar y graficar la velocidad en Insights, cosa que un campo de texto o de selección no permite.
