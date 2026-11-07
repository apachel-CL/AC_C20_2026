# Issues / Épica para GitHub Projects — 004 Auditoría en vivo desde WSL

> Borrador listo para crear en el Project [AC_C20_2026 – Auditoría Ágil](https://github.com/users/apachel-CL/projects/4).
> No se crean automáticamente; el auditor los publica con `gh issue create` cuando corresponda.

## ÉPICA — Auditoría en vivo de Metasploitable 2 desde WSL (reconocimiento, sin explotación)

**Descripción**: Ejecutar un reconocimiento controlado desde WSL contra `192.168.56.101` y convertir
sus salidas en los entregables trazables de la herramienta, sin explotar ningún hallazgo.
**Alcance**: solo `192.168.56.101`. **Fuera**: explotación, fuerza bruta, DoS, otros activos.

### HU-004.1 — Habilitar WSL y validar alcance (P1)
Como auditor quiero confirmar que WSL está listo y que el único objetivo alcanzable es
`192.168.56.101`, para ejecutar con seguridad y dentro del alcance.
- **DoD**: entorno registrado; herramientas presentes; objetivo responde; ningún otro host.

### HU-004.2 — Recolectar evidencia en vivo (P1)
Como auditor quiero ejecutar descubrimiento, escaneo de puertos, versión/servicio, enumeración NSE
segura, cabeceras y banners, para obtener evidencia de primera mano (`EV-020`+).
- **DoD**: cada salida guardada como `EV-NNN` con cabecera; ningún comando de explotación.

### HU-004.3 — Procesar evidencia y regenerar entregables (P1)
Como auditor quiero procesar la evidencia con la herramienta y actualizar inventarios, hallazgos,
matriz, mapeo normativo, plan y resumen, para entregar la auditoría.
- **DoD**: cada hallazgo con evidencia, severidad, control ISO y recomendación; validador sin `[ERROR]`.

### Comandos sugeridos (los ejecuta el auditor)
```bash
gh issue create --title "ÉPICA: Auditoría en vivo Metasploitable 2 desde WSL" --body-file - <<'EOF'
... (pegar la descripción de la épica)
EOF
gh issue create --title "HU-004.1 Habilitar WSL y validar alcance" --label "user story,P1"
gh issue create --title "HU-004.2 Recolectar evidencia en vivo" --label "user story,P1"
gh issue create --title "HU-004.3 Procesar evidencia y regenerar entregables" --label "user story,P1"
```
