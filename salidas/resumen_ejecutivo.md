# Resumen ejecutivo — Auditoría de ciberseguridad AC_C20_2026

## Objetivo y alcance

Se evaluó un equipo de laboratorio aislado (192.168.56.101), sin datos reales. En el ciclo en vivo (004) el reconocimiento se ejecutó desde WSL el 7 de noviembre de 2026, solo con escaneo y enumeración; no se intentó explotar ninguna debilidad. Los resultados se contrastaron con ISO/IEC 27001:2022 y con las leyes chilenas de ciberseguridad y de datos personales.

## Resultados por severidad

| Severidad | Hallazgos |
|---|---|
| Crítica | 2 |
| Alta | 5 |
| Media | 6 |
| Baja | 1 |
| Informativa | 0 |

## Riesgos principales

1. Una vía de acceso al equipo se identifica como acceso de administrador y podría permitir su control total sin contraseña (H-001).
2. El servicio de transferencia de archivos usa una versión con una falla pública de severidad crítica (H-002).
3. El equipo comparte su almacenamiento por red sin control: expone el disco completo por NFS y mantiene recursos que cualquiera puede leer y escribir (H-012, H-013).
4. Las herramientas de administración remota no cifran la información, por lo que las contraseñas podrían leerse en la red (H-004).
5. El servicio para compartir archivos está obsoleto y no protege la integridad de sus mensajes (H-007).

Los demás hallazgos están en `plan_remediacion.md`.

## Prioridades de remediación

Los plazos se cuentan desde la aprobación del plan.

- Antes de 7 días: cerrar el acceso de administrador y reemplazar o retirar el servicio de archivos (H-001, H-002).
- Antes de 30 días: retirar la administración sin cifrado, restringir el servicio de compilación, actualizar el servicio para compartir archivos y cerrar el acceso por red al almacenamiento (H-004, H-005, H-007, H-012, H-013).
- Antes de 90 días: quitar el acceso anónimo a archivos, retirar o actualizar el servicio de chat, renovar el cifrado, ordenar el servidor web, limitar bases de datos y administración remota, y actualizar el servidor de aplicaciones (H-003, H-006, H-008, H-009, H-010, H-014).
- Antes de 180 días: evitar que el correo confirme qué cuentas existen (H-011).

## Implicancias normativas

> Mapeo orientativo; no constituye dictamen jurídico.

Cada hallazgo se asoció a un control de ISO/IEC 27001:2022.

[INFERENCIA] Si la organización fuera entidad obligada por la Ley 21.663, once hallazgos se relacionarían con sus medidas de seguridad y tres con la gestión de riesgos.

[INFERENCIA] Si el equipo tratara datos personales, once hallazgos se relacionarían con el deber de adoptar medidas de seguridad de la Ley 21.719.

La Ley 21.719 aún no tiene vigencia: rige desde el 1 de diciembre de 2026. El Boletín 18623-07, en trámite al 7 de noviembre de 2026, propone postergarla; actualizar antes de difundir. Los artículos están en `verificacion_articulos.md`. La Ley 21.459 solo enmarca la autorización de las pruebas.

## Limitaciones

- El ciclo en vivo (004) sumó siete evidencias de primera mano (EV-020–EV-026) capturadas desde WSL, que corroboran los hallazgos y aportan tres nuevos (H-012, H-013, H-014).
- Las evidencias EV-003 a EV-019 se rescataron de un reporte previo y no son los archivos originales.
- Varias conclusiones se deducen de lo que cada servicio declara: no se confirmó que las debilidades sean explotables. El propietario del activo sigue por definir.

## Revisión

- **Estado**: aprobado
- **Revisor**: Auditor Líder - Andrés Pacheco + Auditor técnico: Juan Francisco Serey
- **Fecha**: 2026-11-07
- **Comentario**: Aprobado con la incorporación de los hallazgos del ciclo en vivo
