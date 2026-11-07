# Feature Specification: Auditoría en vivo desde WSL (reconocimiento, sin explotación)

**Feature Branch**: `feat/004-auditoria-live-wsl` (directorio de la funcionalidad: `specs/004-auditoria-live-wsl`)

**Created**: 2026-11-07

**Status**: In progress

**Input**: User description: "Con la herramienta construida con spec-driven, realizar una auditoría completa a la máquina objetivo (Metasploitable2; IP 192.168.56.101). Auditar solo esa máquina y ninguna otra. Lanzar la auditoría desde WSL; habilitar WSL para las ejecuciones. Solamente auditoría (reconocimiento/enumeración), sin explotación de ningún hallazgo. El resultado final son los entregables definidos por la herramienta."

## Contexto y diferencia con las funcionalidades 001–003

Las funcionalidades 001 (análisis de evidencias), 002 (mapeo normativo) y 003 (informe y
remediación) operan sobre evidencia **entregada/rescatada** (reporte del Grupo 01, `EV-001`…`EV-019`)
y aplican la regla FR-012 "NO EJECUCIÓN": el flujo de Claude no envía tráfico a los sistemas.

Esta funcionalidad 004 cubre la fase previa de **recolección de evidencia de primera mano**: el
auditor ejecuta el reconocimiento en vivo **desde WSL** contra el único activo en alcance y el
resultado de cada comando reingresa como evidencia nueva (`EV-020`+), que luego se procesa con la
herramienta (skill `sk-ciberauditor`) para regenerar los entregables. La frontera se mantiene:
**reconocimiento y enumeración sí; explotación no.**

## Autorización y reglas de compromiso (habilitación de WSL)

- **Activo único en alcance**: `192.168.56.101` (Metasploitable 2, laboratorio aislado host-only
  de VirtualBox). Ningún otro host, red o tercero.
- **Entorno de ejecución autorizado**: WSL2 (Ubuntu) con `nmap`, `nikto`, `curl`, `nc`. El auditor
  ejecuta los comandos desde WSL; la interoperabilidad con Windows se usa solo para el validador
  local (`powershell.exe … Test-Salidas.ps1`).
- **Permitido**: descubrimiento de host, escaneo de puertos, detección de versión/servicio,
  scripts NSE de categoría `default`/`safe`/`discovery`, lectura de banners, cabeceras HTTP y
  escaneo web de Nikto (enumeración de configuración y versiones).
- **Prohibido**: explotación, fuerza bruta de credenciales, prueba de exploits (incluido el backdoor
  de vsftpd 2.3.4, UnrealIRCd, distccd, bindshell 1524, etc.), denegación de servicio, modificación
  o exfiltración de datos. Ante cualquier impacto inesperado, detención inmediata.
- **Trazabilidad**: cada comando ejecutado se guarda íntegro en `evidencias/EV-NNN_<tema>.txt` con
  cabecera de fecha y comando. Se conserva la numeración previa; `EV-020`+ para esta campaña.

## User Scenarios & Testing *(mandatory)*

### Épica — Auditoría en vivo de Metasploitable 2 desde WSL

Como auditor de ciberseguridad quiero ejecutar un reconocimiento controlado desde WSL contra
`192.168.56.101` y convertir sus salidas en los entregables trazables de la herramienta, para
entregar una auditoría completa y verificable sin explotar ningún hallazgo.

### User Story 1 — Habilitar WSL y validar el alcance (Priority: P1)

Como auditor quiero confirmar que WSL está listo (herramientas, conectividad) y que el único
objetivo alcanzable es `192.168.56.101`, para ejecutar con seguridad y dentro del alcance.

**Acceptance**: se registra el entorno (kernel, distro, herramientas), el objetivo responde, y no
se dirige ningún comando a otra IP.

### User Story 2 — Recolectar evidencia en vivo (Priority: P1)

Como auditor quiero ejecutar descubrimiento de host, escaneo completo de puertos TCP, detección de
versión/servicio con scripts seguros, enumeración web y lectura de banners, para obtener evidencia
de primera mano.

**Acceptance**: cada salida se guarda como `EV-020`+ con cabecera de comando y fecha; ningún comando
es de explotación.

### User Story 3 — Procesar evidencia y regenerar entregables (Priority: P1)

Como auditor quiero procesar la evidencia nueva con la herramienta y actualizar inventarios,
hallazgos, matriz, mapeo normativo, plan de remediación y resumen ejecutivo, para obtener los
entregables definidos.

**Acceptance**: cada hallazgo tiene evidencia, severidad, control ISO y recomendación; el validador
`Test-Salidas.ps1` termina sin `[ERROR]`.

## Requirements *(mandatory)*

- **FR-101**: El reconocimiento se ejecuta desde WSL y solo contra `192.168.56.101`.
- **FR-102**: Solo comandos de reconocimiento/enumeración; ninguno de explotación (deroga FR-012
  únicamente para la fase de recolección, y solo para comandos no destructivos).
- **FR-103**: Cada comando ejecutado se persiste como `EV-NNN` con su cabecera (fecha + comando);
  los IDs previos no cambian ni se reutilizan.
- **FR-104**: La evidencia nueva se procesa con la metodología Observación → Evidencia → Hallazgo →
  Recomendación y las plantillas de `docs/plantillas/`.
- **FR-105**: Los entregables de `salidas/` se actualizan y el validador local termina sin errores.
- **FR-106**: Se preserva el enmascarado (FR-013) y la frontera de no-explotación en todo momento.

## Entregables

Los definidos por la herramienta, en `salidas/`: `inventario_evidencias.md`,
`inventario_activos.md`, `evidencia_insuficiente.md`, `hallazgos/H-NNN.md`, `matriz_hallazgos.csv`,
`mapa_normativo.md`, `verificacion_articulos.md`, `plan_remediacion.md`, `resumen_ejecutivo.md`.
