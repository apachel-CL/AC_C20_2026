# Contrato — `salidas/hallazgos/H-NNN.md`

Nombre de archivo: `H-NNN.md`, con el mismo ID que declara el campo `ID`. Codificación: UTF-8.
Las líneas de metadatos usan el formato `- **Clave**: valor` y el validador las lee con la
expresión regular `^- \*\*(.+?)\*\*: (.*)$`.

```markdown
# H-001 — <enunciado de una frase>

- **ID**: H-001
- **Evidencias**: EV-005; EV-007
- **Severidad**: Alta
- **Control ISO**: A.8.20
- **Certeza ISO**: Media

## Observación

[HECHO] … (solo lo visible en las evidencias citadas)

## Justificación

… ([INFERENCIA] cuando no sea visible)

## Recomendación

- **Acción**: …
- **Prioridad**: P1
- **Responsable sugerido**: Administrador del sistema
- **Criterio de cierre**: …
- **Comandos propuestos**: … (opcional; los ejecuta el auditor)

## Revisión

- **Estado**: pendiente
- **Revisor**:
- **Fecha**:
- **Comentario**:
```

## Reglas

| Regla | Origen |
|---|---|
| `Evidencias`: uno o más `EV-NNN` separados por `; `, todos existentes en el inventario, y al menos uno clasificado `hallazgo` | FR-007, SC-002 |
| `Severidad`: `Crítica` \| `Alta` \| `Media` \| `Baja` \| `Informativa` | FR-007 |
| `Control ISO`: `^A\.\d{1,2}\.\d{1,2}$` o `verificar` | FR-008 |
| `Certeza ISO`: `Alta` \| `Media` \| `Baja` | FR-008 |
| `Prioridad`: `P0` \| `P1` \| `P2` \| `P3` | FR-009 |
| `Estado`: `pendiente` \| `aprobado` \| `corregido` \| `descartado` | FR-014 |
| Si `Estado` ≠ `pendiente`: `Revisor` y `Fecha` (`AAAA-MM-DD`) no vacíos | FR-014, SC-008 |
| Sin contraseñas, hashes, tokens ni claves en claro | FR-013 |
