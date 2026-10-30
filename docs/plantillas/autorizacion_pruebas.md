# Autorización de pruebas de seguridad

> **Plantilla.** Complete una copia **fuera del repositorio**, fírmela y guárdela en un lugar
> privado. No versione la copia firmada: contiene datos personales. En el issue #8 registre
> solo la fecha, los firmantes por rol y dónde quedó guardada.
>
> Marco: la Ley 21.459 (delitos informáticos) sanciona el acceso a un sistema informático sin
> autorización. Este documento deja constancia de la autorización. Es orientativo y no reemplaza
> la revisión de un profesional del derecho.

## 1. Partes

| Rol | Nombre | Identificación | Contacto |
|---|---|---|---|
| Propietario o responsable del activo (autoriza) | | | |
| Auditor (ejecuta) | | | |

## 2. Activo autorizado

| Campo | Valor |
|---|---|
| Hostname | `metasploitable` |
| IPv4 | `192.168.56.101/24` |
| Entorno | laboratorio virtual aislado, sin datos reales |
| Propiedad | *declarar que el firmante es dueño o responsable del activo* |

Ningún otro sistema, red o servicio queda autorizado.

## 3. Pruebas autorizadas

Marque solo las que autoriza:

- [ ] Descubrimiento de servicios y versiones
- [ ] Enumeración de servicios y cuentas
- [ ] Revisión de configuración
- [ ] Verificación no destructiva de vulnerabilidades
- [ ] Otra (detallar): ____________________

Quedan **excluidas** en todo caso: denegación de servicio, ingeniería social, pruebas físicas,
explotación destructiva, exfiltración de datos y persistencia después de la ventana.

## 4. Ventana de pruebas

| Campo | Valor |
|---|---|
| Inicio (AAAA-MM-DD HH:MM) | |
| Término (AAAA-MM-DD HH:MM) | |
| Horario permitido | |

## 5. Condiciones

1. Las pruebas siguen `docs/reglas_compromiso.md` del repositorio AC_C20_2026_v2.
2. El auditor detiene las pruebas de inmediato ante un impacto inesperado y avisa al
   propietario.
3. Los resultados se tratan como confidenciales; los entregables versionados enmascaran
   credenciales y datos personales.
4. El propietario puede revocar esta autorización por escrito en cualquier momento.

## 6. Firmas

| Rol | Firma | Fecha |
|---|---|---|
| Propietario o responsable del activo | | |
| Auditor | | |

## Registro en el issue (sin datos personales)

```text
Autorización firmada: AAAA-MM-DD
Firmantes: propietario del activo, auditor
Ventana: AAAA-MM-DD HH:MM – AAAA-MM-DD HH:MM
Ubicación de la copia firmada: <lugar privado, sin ruta pública>
```
