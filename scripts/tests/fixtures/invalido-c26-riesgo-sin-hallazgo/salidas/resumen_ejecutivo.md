# Resumen ejecutivo — Auditoría de ciberseguridad AC_C20_2026

## Objetivo y alcance

Fixture ficticio: se evaluó el activo de laboratorio 192.168.56.101 frente a ISO/IEC 27001:2022
y las leyes chilenas de ciberseguridad y datos personales.

## Resultados por severidad

| Severidad | Hallazgos |
|---|---|
| Crítica | 0 |
| Alta | 0 |
| Media | 1 |
| Baja | 1 |
| Informativa | 0 |

## Riesgos principales

1. Un servicio que no se necesita queda accesible y amplía la superficie de ataque (H-001).
2. Sin registro de eventos no se puede reconstruir qué pasó ante un incidente.

## Prioridades de remediación

- Antes de 90 días: deshabilitar el servicio innecesario (H-001).
- Antes de 180 días: activar el registro de eventos (H-002). Detalle en `plan_remediacion.md`.

## Implicancias normativas

> Mapeo orientativo; no constituye dictamen jurídico.

[INFERENCIA] Si la organización fuera entidad obligada, H-001 se relacionaría con las medidas
de seguridad de la Ley 21.663 (artículo ARTICULO-FICTICIO, inventado para la prueba).
La Ley 21.719 no se cita: su vigencia no está verificada.
La Ley 21.459 solo enmarca la autorización de las pruebas.

## Limitaciones

Fixture ficticio: los datos son de prueba y no describen el activo real.

## Revisión

- **Estado**: aprobado
- **Revisor**: auditor-fixture
- **Fecha**: 2026-10-30
- **Comentario**: Fixture ficticio (003)
