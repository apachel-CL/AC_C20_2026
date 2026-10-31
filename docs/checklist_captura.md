# Checklist de captura de evidencias

**Proyecto:** AC_C20_2026_v2 · **Issue:** #12 (E2) · **Relacionado:** [`reglas_compromiso.md`](reglas_compromiso.md), [`alcance.md`](alcance.md), constitución (principios I–V)

Las evidencias las genera **el auditor** en el laboratorio. Claude no ejecuta comandos contra
sistemas (principio IV): recibe los archivos de `evidencias/`, los inventaria y los analiza con
el prompt §2a de [`flujo_prompt_e_hu.md`](flujo_prompt_e_hu.md).

## 1. Antes de capturar

- [ ] Autorización escrita firmada ([`plantillas/autorizacion_pruebas.md`](plantillas/autorizacion_pruebas.md)), guardada fuera del repositorio, con su referencia en el issue #8. Obligatoria para todo reconocimiento o enumeración; no para lo que ya se ve en la consola del activo (p. ej. `ifconfig`).
- [ ] Ventana de pruebas definida en `reglas_compromiso.md` §4.
- [ ] Modo de red confirmado y aislado (issue #9): el activo no tiene ruta a Internet ni a la red del hogar u oficina.
- [ ] La IP del objetivo es `192.168.56.101`. Si cambió, detenerse y actualizar el alcance.

## 2. Nombre del archivo

```text
EV-NNN_<comando-o-tema>.<ext>
```

- `EV-NNN`: tres dígitos, único, nunca reutilizado. Un solo archivo por prefijo.
- `<comando-o-tema>`: minúsculas, sin espacios ni tildes, separado por guiones.
- `<ext>`: `.txt` (preferido: salida de comando en texto) o `.png` (captura de pantalla).
- Ejemplos válidos: `EV-002_ifconfig.png`, `EV-003_nmap-servicios.txt`, `EV-004_uname.txt`.
- Inválidos: `captura1.png` (sin ID), `EV-3_nmap.txt` (ID de un dígito), `EV-003 nmap.txt` (espacio).

El validador lo comprueba (C2): `^EV-\d{3}_.+\..+$`.

## 3. Qué debe verse en cada evidencia

| Elemento | En `.txt` | En `.png` |
|---|---|---|
| Comando completo ejecutado | línea `Comando:` del encabezado | visible en el prompt |
| Salida completa, sin recortar | debajo del encabezado | toda la salida en pantalla (varias capturas → varios EV) |
| Fecha y hora (hora de Chile) | línea `Fecha:` | reloj del sistema o `date` antes del comando |
| Host donde se ejecutó | línea `Host origen:` | prompt con el hostname (`msfadmin@metasploitable:~$`) |
| Objetivo | línea `Objetivo:` = `192.168.56.101` | IP visible en el comando o la salida |

Encabezado obligatorio de un `.txt` (UTF-8):

```text
Evidencia: EV-003
Fecha: 2026-11-03 10:15 (hora de Chile)
Host origen: equipo del auditor (red host-only)
Objetivo: 192.168.56.101
Comando: nmap -sV -p- 192.168.56.101
Ejecutado por: auditor
---
<salida completa del comando, sin editar>
```

## 4. Enmascarar antes de guardar

- Contraseñas, hashes, tokens y claves: reemplazar por `****` (p. ej. `msfadmin:****`).
- Datos de personas reales (nombres, correos, RUT): `****`. El laboratorio solo debe tener datos ficticios; si aparece uno real, detenerse y avisar en el issue (reglas §3).
- No enmascarar IPs, MAC, puertos, servicios ni versiones del activo: son la observación.
- Nunca editar la salida más allá del enmascarado. Si se enmascaró algo, agregar al encabezado `Enmascarado: <qué>`.

## 5. Después de capturar

- [ ] Guardar en `evidencias/` (no se versiona: repositorio público).
- [ ] Anotar en el issue de la tarea: fecha, técnica, `EV-NNN` generados e incidentes (reglas §8).
- [ ] Pedir a Claude: "procesa las evidencias nuevas con el prompt §2a". Claude inventaría, clasifica (`hallazgo` · `contexto` · `insuficiente` · `fuera-de-alcance`) y ejecuta el validador.

## 6. Evidencias mínimas del proyecto

| ID | Archivo | Comando o contenido | Requiere autorización | Clasificación esperada | Desbloquea |
|---|---|---|---|---|---|
| EV-002 | `EV-002_ifconfig.png` | `ifconfig` en la consola de `metasploitable` (la captura ya citada en `alcance.md`) | no | contexto | T013 de 001 (#14) |
| EV-003 | `EV-003_nmap-servicios.txt` | `nmap -sV -p- 192.168.56.101` desde el equipo del auditor | sí | hallazgo, si muestra servicios innecesarios o versiones vulnerables | T020 de 001 (#16) y todo E4 y E5 |
| EV-004 | `EV-004_version-so.txt` | `uname -a` y `cat /etc/lsb-release` en la consola del activo | no | contexto | versión del SO en `alcance.md` |

Los comandos son **propuestos: los ejecuta el auditor**, solo contra `192.168.56.101`.
