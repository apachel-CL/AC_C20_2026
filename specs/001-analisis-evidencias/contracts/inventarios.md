# Contrato — Inventarios y evidencia insuficiente

Codificación: UTF-8. Cada archivo empieza con un título `#` y contiene **una** tabla Markdown
con los encabezados exactos indicados, en ese orden. El validador ubica la tabla por su fila
de encabezado.

## `salidas/inventario_evidencias.md`

```markdown
# Inventario de evidencias

| ID | Archivo | Observación | Clasificación | Debilidad / Falta |
|---|---|---|---|---|
| EV-002 | EV-002_ifconfig.png | [HECHO] … | contexto | — |
```

- `ID`: `^EV-\d{3}$`, único.
- `Clasificación`: `hallazgo` | `contexto` | `insuficiente` | `fuera-de-alcance`.
  `fuera-de-alcance` se evalúa primero y prevalece (FR-004, FR-015).
- `Debilidad / Falta`: no vacío si la clasificación es `hallazgo` o `insuficiente`; `—` en
  los demás casos.

## `salidas/inventario_activos.md`

```markdown
# Inventario de activos

| Activo | Atributo | Valor | Etiqueta | Fuente |
|---|---|---|---|---|
| metasploitable | hostname | metasploitable | [HECHO] | EV-002 |
```

- `Atributo`: enumerado de `data-model.md`.
- `Etiqueta`: `[HECHO]` | `[INFERENCIA]`.
- `Fuente`: un `EV-NNN` existente en el inventario de evidencias.

## `salidas/evidencia_insuficiente.md`

```markdown
# Evidencia insuficiente

| ID | Qué falta | Cómo obtenerlo (comando propuesto) | Reemplazada por |
|---|---|---|---|
```

- Cada `ID` aparece en el inventario de evidencias con `Clasificación = insuficiente`, y
  viceversa.
- La tercera columna solo **propone** comandos para el auditor, dirigidos a `192.168.56.101` y
  marcados "propuesto: lo ejecuta el auditor" (FR-012).
- `Reemplazada por`: el `EV-NNN` de la evidencia nueva que completa lo que faltaba (FR-017), o
  `—`. Si no es `—`, debe existir en el inventario de evidencias.
