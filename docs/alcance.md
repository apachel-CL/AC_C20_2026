# Alcance — Auditoría de ciberseguridad híbrida (ethical hacking + cumplimiento)

**Proyecto:** AC_C20_2026_v2
**Fecha:** 2026-10-24
**Auditor:** andrespachecolopez

## Objetivo

Evaluar la seguridad del activo de laboratorio mediante análisis de evidencia técnica controlada y contrastar los resultados con los requisitos normativos aplicables. Cada hallazgo debe ser trazable a evidencia (cadena Observación → Evidencia → Hallazgo → Recomendación) y cerrar con una recomendación accionable y verificable.

## Marco de referencia

| Marco | Uso en esta auditoría |
|---|---|
| ISO/IEC 27001:2022 (Anexo A) | Mapeo de cada hallazgo a controles |
| Ley 21.663 (Marco de Ciberseguridad) | Gestión de riesgos, medidas de seguridad, reporte de incidentes (ANCI/CSIRT) |
| Ley 21.719 (Protección de Datos Personales) | Medidas de seguridad sobre datos personales — *vigencia diferida, verificar entrada en vigor* |
| Ley 21.459 (Delitos informáticos) | Delimita la **autorización** de las pruebas (no es control de seguridad) |

## Activo evaluado

| Campo | Valor | Fuente |
|---|---|---|
| Hostname | `metasploitable` | EV-002 (ifconfig) |
| Usuario observado | `msfadmin` | EV-002 |
| Interfaz / MAC | `eth0` / `08:00:27:cd:02:f4` | EV-002 |
| IPv4 | `192.168.56.101/24` (Bcast `192.168.56.255`) | EV-002 |
| IPv6 | `fe80::a00:27ff:fecd:2f4/64` (Scope:Link) *[parcialmente legible]* | EV-002 |
| Modo de red | Host-only VirtualBox *[INFERENCIA — confirmar]* | EV-002 |
| Propietario | *por definir* | — |

## Dentro del alcance

- Únicamente el activo listado (`192.168.56.101`).
- Análisis de evidencia técnica entregada (capturas y salidas de comandos).
- Reconocimiento, enumeración y verificación de vulnerabilidades **solo con autorización escrita previa**.
- Revisión de configuraciones: autenticación, bloqueo de cuentas, servicios innecesarios, exposición de red.
- Mapeo a controles ISO 27001 y a obligaciones legales aplicables.

## Fuera del alcance

- Activos no listados, terceros o entornos de producción.
- Denegación de servicio, ingeniería social, pruebas físicas.
- Explotación destructiva o exfiltración de datos reales.
- Dictamen jurídico vinculante (los mapeos legales son orientativos y requieren validación de un profesional).

## Reglas de compromiso

Autorización escrita previa; red aislada y datos ficticios; ventana de pruebas definida; detención inmediata ante impacto inesperado. Claude **no** ejecuta escaneos/exploits: trabaja sobre evidencia entregada y, si se pide, *propone* comandos de verificación para que los ejecute el auditor.

Detalle completo: [`reglas_compromiso.md`](reglas_compromiso.md). Plantilla de autorización escrita (Ley 21.459): [`plantillas/autorizacion_pruebas.md`](plantillas/autorizacion_pruebas.md); la copia firmada se guarda fuera del repositorio.

## Entregables

Hallazgos individuales (`H-XXX.md`), matriz de hallazgos (`.csv`), inventario de activos y de evidencias, evidencia insuficiente, resumen ejecutivo y plan de remediación.

## Criterio de éxito

El 100 % de los hallazgos tiene evidencia, severidad, control ISO asociado y recomendación.
