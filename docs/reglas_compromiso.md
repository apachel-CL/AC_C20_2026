# Reglas de compromiso

**Proyecto:** AC_C20_2026_v2
**Versión:** 1.0 — 2026-10-29
**Estado:** borrador, pendiente de aprobación del auditor y del propietario del activo
**Relacionado:** [`alcance.md`](alcance.md), [`plantillas/autorizacion_pruebas.md`](plantillas/autorizacion_pruebas.md), constitución (principios I y IV)

Estas reglas aplican a toda acción sobre el activo en alcance. Si una regla no se puede cumplir,
la prueba no empieza o se detiene.

## 1. Autorización previa

- Ninguna prueba (reconocimiento, enumeración o verificación de vulnerabilidades) empieza sin
  la autorización escrita firmada según [`plantillas/autorizacion_pruebas.md`](plantillas/autorizacion_pruebas.md).
- La autorización firmada se guarda **fuera del repositorio**. En el issue #8 solo se registra
  una referencia (fecha, firmantes por rol y ubicación), sin datos personales.
- Una prueba que no esté listada en la autorización está fuera de alcance, aunque el activo sí
  lo esté.

## 2. Activo y red

- Único activo: `192.168.56.101` (host `metasploitable`), según [`alcance.md`](alcance.md).
- La red del laboratorio debe estar aislada: sin ruta a Internet ni a la red del hogar u
  oficina. Modo previsto: host-only de VirtualBox *[INFERENCIA — confirmar en el issue #9]*.
- Antes de cada sesión, el auditor confirma que la IP del objetivo es `192.168.56.101`. Si la
  IP cambió, se detiene y actualiza el alcance antes de seguir.
- Todo tráfico dirigido a otra IP se considera fuera de alcance.

## 3. Datos

- Solo datos ficticios. El activo no debe contener datos personales ni credenciales reales.
- Si aparece un dato que parece real (personal, credencial o de un tercero), no se copia, se
  enmascara en todo entregable y se informa en el issue de la tarea.
- El contenido de `evidencias/` no se versiona (repositorio público).

## 4. Ventana de pruebas

| Campo | Valor |
|---|---|
| Inicio | *por definir (AAAA-MM-DD HH:MM, hora de Chile)* |
| Término | *por definir* |
| Horario permitido | *por definir* |
| Responsable de ejecución | auditor |
| Contacto de detención | propietario del activo *(por definir)* |

Las pruebas fuera de la ventana requieren una autorización nueva o una ampliación escrita.

## 5. Técnicas

**Permitidas**, si la autorización las lista: descubrimiento de servicios y versiones,
enumeración, revisión de configuración (autenticación, bloqueo de cuentas, servicios
innecesarios, exposición de red) y verificación no destructiva de vulnerabilidades.

**Prohibidas:** denegación de servicio, ingeniería social, pruebas físicas, explotación
destructiva, exfiltración de datos y persistencia en el activo después de la ventana.

## 6. Criterio de detención

El auditor detiene la prueba de inmediato y lo registra si ocurre cualquiera de estos casos:

- el activo deja de responder o se degrada de forma inesperada;
- se observa tráfico, respuesta o sistema fuera de `192.168.56.101`;
- aparecen datos que parecen reales;
- la red deja de estar aislada;
- se agota la ventana de pruebas o el propietario pide detener.

Al detener: se anota hora, acción en curso y efecto observado en el issue de la tarea; no se
reanuda hasta que el propietario lo autorice por escrito.

## 7. Rol de Claude

- Claude **no ejecuta** escaneos, exploits ni comandos contra ningún sistema (principio IV).
- Claude trabaja sobre la evidencia entregada en `evidencias/` y, si hace falta verificar,
  **propone** comandos marcados "propuesto: lo ejecuta el auditor", siempre contra
  `192.168.56.101`.
- La ejecución, su registro y la decisión de detener son responsabilidad del auditor.

## 8. Registro

Cada sesión de pruebas deja en el issue correspondiente: fecha y hora, técnicas usadas,
evidencias generadas (`EV-NNN`) e incidentes o detenciones. Las capturas se guardan en
`evidencias/` con el nombre `EV-NNN_<tema>.<ext>`.

## Aprobación

| Rol | Nombre | Fecha | Estado |
|---|---|---|---|
| Auditor | *por completar* | | pendiente |
| Propietario del activo | *por completar* | | pendiente |
