<!--
Sync Impact Report
- Version change: 1.0.0 → 1.0.1 (PATCH: aclaración del listado de salidas; ningún principio cambia)
- Modified principles: ninguno
- Modified sections: "Flujo de trabajo y calidad" → Salidas: se agregan `verificacion_articulos.md`
  y `mapa_normativo.md`, introducidos por la funcionalidad 002 (specs/002-mapeo-normativo)
- Added sections: ninguna
- Removed sections: ninguna
- Origen: hallazgo L3 de /speckit-analyze sobre 002
- Templates: sin cambios necesarios (.specify/templates/* no listan las salidas)
- Deferred TODOs: ninguno
-->
# Constitución — AC_C20_2026: Auditoría de ciberseguridad híbrida

## Core Principles

### I. Alcance autorizado (NO NEGOCIABLE)

- El único activo en alcance es `192.168.56.101` (host `metasploitable`), según
  `docs/alcance.md`. Todo activo no listado, de terceros o de producción está fuera de alcance.
- Quedan fuera de alcance: denegación de servicio, ingeniería social, pruebas físicas,
  explotación destructiva y exfiltración de datos reales.
- El reconocimiento, la enumeración y la verificación de vulnerabilidades MUST contar con
  autorización escrita previa.

**Razón:** la Ley 21.459 delimita la autorización de las pruebas; actuar fuera de alcance
invalida la auditoría y puede constituir delito.

### II. Trazabilidad de la cadena

- Todo trabajo de análisis sigue la cadena **Observación → Evidencia → Hallazgo →
  Recomendación**.
- Sin evidencia no hay hallazgo; sin hallazgo no hay recomendación.
- Cada evidencia recibe un ID `EV-XXX` y se clasifica en una sola categoría: de hallazgo, de
  contexto (identifica el activo y alimenta el inventario, NO genera hallazgo) o insuficiente
  (indicando qué falta).
- Cada hallazgo `H-XXX` MUST referenciar al menos una evidencia y tener severidad
  (Crítica/Alta/Media/Baja/Informativa), control ISO/IEC 27001:2022 (Anexo A) y recomendación.

**Razón:** el criterio de éxito de la auditoría es que el 100 % de los hallazgos tenga
evidencia, severidad, control ISO asociado y recomendación.

### III. Veracidad

- Cada afirmación se etiqueta **[HECHO]** (visible en la evidencia) o **[INFERENCIA]**
  (a confirmar).
- La observación describe solo lo visible y transcribe textualmente IPs, máscaras, MAC,
  puertos, servicios, versiones, usuarios y mensajes.
- MUST NOT inventarse hallazgos, IPs, versiones, artículos legales ni datos ausentes de la
  evidencia. Ante la duda se escribe "verificar".
- Si falta información, se pregunta una cosa a la vez antes de asumir.

### IV. No ejecución

- Claude MUST NOT ejecutar escaneos, exploits ni comandos contra ningún sistema.
- Claude trabaja sobre la evidencia entregada y, si se requiere verificación, PROPONE los
  comandos para que el auditor los ejecute.

**Razón:** separa el análisis asistido de la acción sobre sistemas, que es responsabilidad
del auditor autorizado.

### V. Protección de datos y alcance legal

- Credenciales y datos personales MUST enmascararse en todo entregable.
- Los mapeos a la Ley 21.663, la Ley 21.719 y la Ley 21.459 son orientativos y requieren
  validación de un profesional; no constituyen dictamen jurídico.
- El mapeo legal indica nivel de certeza (Alta/Media/Baja).
- La vigencia de la Ley 21.719 es diferida y MUST verificarse antes de citarla.

### VI. Gestión ágil y estimación

- Todo trabajo se estima con las tallas de `docs/estimacion.md`:
  XS=1, S=2, M=3, L=5, XL=8 puntos.
- Ninguna tarea XL entra a un sprint: MUST dividirse antes.
- Un ítem pasa a Listo solo si cumple la Definition of Ready, y a Hecho solo si cumple la
  Definition of Done de `docs/estimacion.md`.
- Las épicas no llevan talla ni puntos.

### VII. Revisión humana obligatoria

- Ningún hallazgo se da por cerrado sin revisión humana del auditor.
- La revisión humana forma parte de la Definition of Done.

## Restricciones de seguridad y cumplimiento

- **Marcos de referencia:** ISO/IEC 27001:2022 (Anexo A); Ley 21.663 (Marco de
  Ciberseguridad); Ley 21.719 (Protección de Datos Personales); Ley 21.459 (Delitos
  informáticos, como marco de la autorización y no como control de seguridad).
- **Reglas de compromiso:**
  - autorización escrita previa;
  - red aislada y datos ficticios;
  - ventana de pruebas definida;
  - detención inmediata ante un impacto inesperado.
- **Repositorio público:** el contenido de `evidencias/` no se versiona. Ningún entregable
  versionado puede contener credenciales ni datos personales sin enmascarar.

## Flujo de trabajo y calidad

- **Formato:** los entregables son Markdown y CSV, versionados en git.
- **Salidas** (en `./salidas/`):
  - `inventario_evidencias.md`
  - `inventario_activos.md`
  - `hallazgos/H-XXX.md`
  - `matriz_hallazgos.csv`
  - `evidencia_insuficiente.md`
  - `verificacion_articulos.md` (lista de verificación de artículos legales)
  - `mapa_normativo.md` (mapa normativo consolidado)
  - `resumen_ejecutivo.md` (máximo una página)
- **Recomendaciones:** cada recomendación es una acción concreta, priorizada y verificable,
  con qué hacer, responsable sugerido y cómo validar el cierre.
- **Pull requests:** el trabajo se integra mediante PR que referencia sus issues
  (`Closes #n`) y registra la talla real frente a la estimada.

## Governance

- Esta constitución prevalece sobre cualquier otra práctica del proyecto. Las
  especificaciones, planes y tareas de Spec Kit MUST cumplirla, y `/speckit-analyze` la usa
  como criterio de consistencia.
- **Enmiendas:** se proponen por PR, se documentan en el Sync Impact Report y requieren
  aprobación del auditor responsable.
- **Versionado (SemVer):**
  - MAJOR: eliminar o redefinir un principio.
  - MINOR: agregar un principio o sección, o ampliar materialmente una guía.
  - PATCH: aclaraciones y redacción.
- **Cumplimiento:** cada PR verifica el checklist de la Definition of Done.
- **Fuentes:** ante un conflicto, prevalecen `docs/alcance.md` (alcance y reglas de
  compromiso) y `docs/estimacion.md` (tallas, DoR y DoD).

**Version**: 1.0.1 | **Ratified**: 2026-10-26 | **Last Amended**: 2026-10-28
