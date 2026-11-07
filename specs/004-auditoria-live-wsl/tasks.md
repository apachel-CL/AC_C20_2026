# Tareas — 004 Auditoría en vivo desde WSL

Orden por dependencias. Cada tarea cierra con evidencia o archivo en `salidas/`.

## US1 — Habilitar WSL y validar alcance
- [x] T001 Verificar herramientas de reconocimiento en WSL (`nmap`, `nikto`, `curl`, `nc`).
- [x] T002 Verificar conectividad a `192.168.56.101` y que no haya otros objetivos en alcance.
- [x] T003 Registrar entorno de ejecución (kernel, distro, interop Windows) en la bitácora.

## US2 — Recolección de evidencia en vivo (solo reconocimiento)
- [x] T004 `EV-020` descubrimiento de host (`nmap -sn`).
- [x] T005 `EV-021` escaneo completo de puertos TCP (`nmap -p- -T4 --open`).
- [x] T006 `EV-022` versión/servicio + scripts por defecto (`nmap -sV -sC`).
- [x] T007 `EV-023` enumeración NSE segura (sin exploits).
- [x] T008 `EV-024` cabeceras HTTP (`curl -I`, OPTIONS).
- [x] T009 `EV-025` banners de 21/22/23/25 (lectura pasiva).
- [x] T010 `EV-026` escaneo web Nikto.

## US3 — Procesar con la herramienta y entregables
- [ ] T011 Actualizar `inventario_evidencias.md` con `EV-020`…`EV-026` (clasificación y observación).
- [ ] T012 Actualizar `inventario_activos.md` con datos del activo observados en vivo.
- [ ] T013 Crear/actualizar hallazgos `H-NNN.md` desde la evidencia nueva (nuevos puertos/servicios).
- [ ] T014 Actualizar `matriz_hallazgos.csv` (una fila por hallazgo, columnas completas).
- [ ] T015 Actualizar `mapa_normativo.md` y `verificacion_articulos.md` si hay hallazgos nuevos.
- [ ] T016 Actualizar `plan_remediacion.md` y `resumen_ejecutivo.md`.
- [ ] T017 Ejecutar el validador `Test-Salidas.ps1` hasta `exit 0` (sin `[ERROR]`).
- [ ] T018 Redactar el resumen para la descripción del PR (generado, dudas, supuestos).
