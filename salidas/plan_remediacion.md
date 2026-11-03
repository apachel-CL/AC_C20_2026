# Plan de remediación

> Generado a partir de los hallazgos revisados (aprobado o corregido). Los comandos, si los
> hay, son propuestos y los ejecuta el auditor solo contra 192.168.56.101.

- **Hallazgos excluidos (pendiente)**: 0
- **Hallazgos excluidos (descartado)**: 0

| Orden | Hallazgo | Evidencias | Severidad | Prioridad | Acción | Responsable sugerido | Plazo | Criterio de cierre | Estado | Fecha de cierre | Evidencia de cierre | Comentario |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | H-001 | EV-003; EV-008; EV-007; EV-017 | Crítica | P0 | Deshabilitar el servicio que escucha en 1524/tcp y bloquear el puerto | Administrador del sistema | 7 días | Un nuevo escaneo de servicios no muestra el puerto 1524/tcp abierto | abierto | — | — | — |
| 2 | H-002 | EV-003; EV-008; EV-011 | Crítica | P0 | Reemplazar vsftpd 2.3.4 por la versión vigente de la distribución o deshabilitar el servicio si no se usa | Administrador del sistema | 7 días | Un nuevo banner o escaneo del puerto 21 no muestra vsftpd 2.3.4 | abierto | — | — | — |
| 3 | H-004 | EV-003; EV-007; EV-013; EV-017 | Alta | P1 | Deshabilitar Telnet y los servicios rexec, rlogin y rsh, y administrar el equipo solo por SSH | Administrador del sistema | 30 días | Un nuevo escaneo no muestra abiertos los puertos 23, 512, 513 ni 514 | abierto | — | — | — |
| 4 | H-005 | EV-003 | Alta | P1 | Deshabilitar distccd o limitarlo a clientes autorizados con su lista de acceso y el firewall | Administrador del sistema | 30 días | Un nuevo escaneo no muestra 3632/tcp abierto, o la configuración muestra la restricción de clientes | abierto | — | — | — |
| 5 | H-007 | EV-008 | Alta | P1 | Actualizar Samba a una versión con soporte y habilitar la firma de mensajes SMB | Administrador del sistema | 30 días | Un nuevo escaneo muestra una versión de Samba vigente y la firma de mensajes habilitada | abierto | — | — | — |
| 6 | H-003 | EV-008 | Media | P2 | Deshabilitar el acceso anónimo en la configuración del servidor FTP | Administrador del sistema | 90 días | Un nuevo escaneo del puerto 21 no informa acceso anónimo permitido | abierto | — | — | Se resuelve junto con H-002 si se deshabilita el servicio FTP |
| 7 | H-006 | EV-003; EV-008 | Media | P2 | Deshabilitar UnrealIRCd si no tiene uso o identificar su versión y actualizarla | Administrador del sistema | 90 días | Un nuevo escaneo no muestra 6667/tcp ni 6697/tcp abiertos, o muestra una versión vigente | abierto | — | — | — |
| 8 | H-008 | EV-008 | Media | P2 | Deshabilitar SSLv2 y los cifrados débiles, y renovar los certificados de SMTP y PostgreSQL | Administrador del sistema | 90 días | Un nuevo escaneo no informa SSLv2 y muestra certificados vigentes | abierto | — | — | — |
| 9 | H-009 | EV-009; EV-010 | Media | P2 | Actualizar Apache y PHP, retirar phpinfo.php, deshabilitar TRACE y el listado de directorios, y restringir phpMyAdmin | Administrador del sistema | 90 días | Un nuevo escaneo web no informa esos elementos y las cabeceras no muestran versiones obsoletas | abierto | — | — | — |
| 10 | H-010 | EV-003; EV-008 | Media | P2 | Restringir con firewall estos servicios a los equipos autorizados y deshabilitar los que no se usen | Administrador del sistema | 90 días | Un nuevo escaneo desde un equipo no autorizado no muestra esos puertos abiertos | abierto | — | — | — |
| 11 | H-011 | EV-008 | Baja | P3 | Deshabilitar el comando VRFY en la configuración de Postfix | Administrador del sistema | 180 días | Un nuevo escaneo del puerto 25 no lista VRFY entre los comandos | abierto | — | — | — |

## Revisión

- **Estado**: aprobado
- **Revisor**: Auditor líder
- **Fecha**: 2026-11-02
- **Comentario**: Aprobado sin cambios
