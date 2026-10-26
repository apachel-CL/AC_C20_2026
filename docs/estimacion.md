# Estimación, Definition of Ready / Done y velocidad

Este documento es la **fuente de verdad** de las tallas. El valor oficial de cada ítem vive en los campos **Talla** y **Puntos** del GitHub Project; los dropdowns de las plantillas de issues son solo orientativos.

## Tallas

| Talla | Puntos | Esfuerzo orientativo | Regla |
|---|---|---|---|
| XS | 1 | < 2 h | cambio trivial |
| S | 2 | ~ medio día | una tarea clara, sin dudas |
| M | 3 | 1–2 días | algo de incertidumbre |
| L | 5 | 3–5 días | varias partes; evaluar dividir |
| XL | 8 | > 1 semana | **NO entra a un sprint: debe dividirse** |

Las épicas no llevan talla ni puntos: su tamaño es la suma de sus sub-issues. Así la velocidad no se cuenta dos veces.

## Definition of Ready (DoR)

Un ítem puede pasar de **Backlog** a **Listo** cuando:

- [ ] Tiene criterios de aceptación verificables.
- [ ] Tiene talla asignada y es **≤ L** (un XL se divide antes).
- [ ] Tiene épica asignada (campo Épica y sub-issue de su épica).

## Definition of Done (DoD)

Un ítem pasa a **Hecho** cuando:

- [ ] Todos los criterios de aceptación están cumplidos.
- [ ] Tuvo revisión humana.
- [ ] Si aplica, la evidencia (EV-XXX) o el hallazgo (H-XXX) está enlazado.

## Sprints y velocidad

- **Duración del sprint:** 2 semanas, de lunes a domingo de la semana siguiente.
- **Velocidad del sprint:** suma del campo **Puntos** de los ítems en estado **Hecho** con ese **Sprint**.
- **Planificación:** se comprometen ítems en estado Listo hasta la velocidad media de los últimos sprints. Para el Sprint 1, que no tiene historial, el tope es de **20 puntos**.
- Al cerrar un PR, registra la talla real frente a la estimada (plantilla de PR) para calibrar las próximas estimaciones.
