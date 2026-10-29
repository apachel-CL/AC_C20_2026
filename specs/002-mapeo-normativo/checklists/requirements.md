# Specification Quality Checklist: Mapeo normativo de hallazgos

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-10-28
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- **Iteración 1.** Pasan todos los ítems salvo el marcador de FR-006 (aplicabilidad de la
  Ley 21.663).
- **Iteración 2.** El auditor eligió el mapeo hipotético ("si fuera entidad obligada", certeza
  ≤ `Media`). FR-006 y el caso borde quedan actualizados; pasan todos los ítems.
- **Nombres de archivo y columnas.** `verificacion_articulos.md`, `mapa_normativo.md` y las
  columnas legales de FR-011 son entregables del proyecto, igual que en 001; no son detalles de
  implementación.
- **Validador (FR-013).** Se nombra porque la descripción pide extenderlo; la spec dice qué
  comprueba, no cómo.
- **Sin artículos en la spec.** A propósito no se citan números de artículo: la spec exige que
  los fije el auditor tras verificarlos (FR-010).
- **Iteración 3 (`/speckit-analyze`).** Se resolvieron los 11 hallazgos del análisis:
  - D1 (CRITICAL, principio V): la Ley 21.719 queda `pendiente de vigencia` y no se cita hasta
    verificar su entrada en vigor (FR-007, C18, C21);
  - I1: C15 se activa con la matriz extendida y C16–C22 con el mapeo, la lista o el mapa;
  - I2: FR-016 define la transición `aprobado | corregido → pendiente` como excepción a FR-014
    de 001;
  - A1 (SC-005), A2 (criterio de "podría afectar datos personales"), U1 (excepciones de FR-001),
    C1 ([HECHO]/[INFERENCIA] en C16 y en el prompt), C2 (medición de SC-006), L1 (frase
    hipotética solo si no es `no aplica`) y L2 (motivo en `Comentario`).
  - L3 (salidas en la constitución) queda para una enmienda aparte.
