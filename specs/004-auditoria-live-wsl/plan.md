# Plan de implementación — 004 Auditoría en vivo desde WSL

**Fecha**: 2026-11-07 · **Alcance**: solo `192.168.56.101` · **Frontera**: reconocimiento/enumeración, sin explotación.

## Enfoque

1. **Habilitar WSL** (US1): verificar herramientas (`nmap`, `nikto`, `curl`, `nc`), conectividad
   al objetivo y que ningún comando se dirija a otra IP. Registrar el entorno.
2. **Recolección en vivo** (US2): ejecutar desde WSL, guardando cada salida como `EV-NNN`:
   - `EV-020` descubrimiento de host (`nmap -sn`).
   - `EV-021` escaneo completo de puertos TCP (`nmap -p- -T4 --open`).
   - `EV-022` versión/servicio + scripts por defecto (`nmap -sV -sC -p <abiertos>`).
   - `EV-023` enumeración NSE segura (ftp-anon, smb-*, ssl-enum-ciphers, http-*, nfs, vnc, mysql, irc).
   - `EV-024` cabeceras HTTP (`curl -I`, OPTIONS).
   - `EV-025` banners (21/22/23/25, lectura pasiva con `nc`).
   - `EV-026` escaneo web Nikto.
3. **Procesar con la herramienta** (US3): aplicar la metodología de la skill `sk-ciberauditor` a la
   evidencia nueva y actualizar `salidas/` (inventarios, hallazgos, matriz, mapeo normativo, plan,
   resumen). Ejecutar el validador local hasta que no haya `[ERROR]`.

## Controles de seguridad del plan

- Lista de exclusión de scripts/comandos: `*-brute`, `*-exploit`, `*-dos`, backdoors (vsftpd 2.3.4,
  UnrealIRCd, distccd, bindshell 1524), Metasploit, fuerza bruta, cualquier escritura en el objetivo.
- Toda cabecera de evidencia registra fecha y comando exacto para auditabilidad.

## Validación

`powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1` (interop WSL→Windows).
