# Feature Specification: Flujo de análisis de evidencias del auditor

**Feature Branch**: `chore/speckit-init` (directorio de la funcionalidad: `specs/001-analisis-evidencias`)

**Created**: 2026-10-26

**Status**: Draft

**Input**: User description: "Flujo de análisis de evidencias del auditor. Como auditor quiero transformar cada evidencia técnica de ./evidencias/ (capturas y salidas de comandos) en hallazgos trazables, para entregar resultados verificables. El flujo: (1) inventaria las evidencias y les asigna ID EV-001, EV-002…; (2) registra la observación textual de lo visible (IPs, máscaras, MAC, puertos, servicios, versiones, usuarios, mensajes); (3) clasifica cada evidencia como "de hallazgo", "de contexto" (alimenta el inventario de activos y no genera hallazgo) o "insuficiente" (indicando qué falta); (4) solo para las de hallazgo, redacta el hallazgo H-XXX con severidad (Crítica, Alta, Media, Baja, Informativa) y justificación; (5) propone una recomendación concreta, priorizada y verificable con responsable sugerido y criterio de cierre. Salidas en ./salidas/: inventario_evidencias.md, inventario_activos.md, evidencia_insuficiente.md, hallazgos/H-XXX.md y matriz_hallazgos.csv. Caso de prueba obligatorio: EV-002 (salida de ifconfig del host metasploitable), que es evidencia de contexto. Fuera de alcance de esta funcionalidad: mapeo normativo detallado (funcionalidad 002) y resumen ejecutivo y plan de remediación (funcionalidad 003)."

## Clarifications

### Session 2026-10-26

- Q: ¿Qué criterio decide que una evidencia es "de hallazgo" y no "de contexto"? → A: Es de
  hallazgo si muestra al menos una debilidad concreta visible: servicio inseguro, versión
  vulnerable, configuración débil, credencial por defecto o exposición innecesaria. Si solo
  identifica el activo, es de contexto. Si muestra ambas cosas, se clasifica de hallazgo y sus
  datos del activo igualmente pasan al inventario de activos.
- Q: ¿Qué columnas debe tener matriz_hallazgos.csv? → A: Tiene estas columnas, en este orden:
  `id_hallazgo`, `enunciado`, `evidencias` (EV separadas por `;`), `severidad`, `control_iso`,
  `certeza_iso`, `recomendacion`, `prioridad`, `responsable_sugerido`, `criterio_cierre`,
  `estado_revision`. Formato UTF-8, separador coma y fila de encabezado. Las columnas legales las
  agrega la funcionalidad 002.
- Q: ¿Cómo deben nombrarse los archivos de evidencia en ./evidencias/? → A: Con el formato
  `EV-NNN_<comando-o-tema>.<ext>` (p. ej. `EV-002_ifconfig.png`). A un archivo sin prefijo el
  flujo le asigna el siguiente ID libre y propone renombrarlo; el auditor confirma.
- Q: ¿Cómo se registra la revisión humana de cada hallazgo? → A: Cada `H-NNN.md` tiene un
  bloque "Revisión" con estado (pendiente / aprobado / corregido / descartado), revisor, fecha y
  comentario. `estado_revision` de la matriz replica ese estado. El cambio de estado entra por
  un PR con el checklist de la Definition of Done.
- Q: ¿Qué datos se enmascaran en las salidas? → A: Siempre se enmascaran contraseñas, hashes,
  tokens, claves y los datos de personas reales. Los identificadores técnicos del laboratorio
  (IP, MAC, hostname y usuarios por defecto como `msfadmin`) se transcriben literalmente porque
  son ficticios y necesarios para la trazabilidad.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Inventariar, observar y clasificar evidencias (Priority: P1)

El auditor deja sus capturas y salidas de comandos en `./evidencias/`. El flujo asigna a cada
una un ID `EV-XXX` y registra en el inventario de evidencias:

- la observación textual de lo visible, etiquetada [HECHO];
- la clasificación: de hallazgo, de contexto o insuficiente.

Lo que la evidencia de contexto revela del activo se lleva al inventario de activos. De la
evidencia insuficiente se deja constancia de qué falta.

**Why this priority**: es la base de la cadena de trazabilidad. Sin evidencia inventariada y
clasificada no puede existir ningún hallazgo (Constitución, principio II). Por sí sola ya entrega
valor: el inventario de evidencias y el de activos.

**Independent Test**: se procesa solo EV-002 (salida de `ifconfig` del host `metasploitable`) y
se comprueba que:

- aparece en el inventario de evidencias clasificada como **de contexto**;
- su observación transcribe tal cual hostname, interfaz, MAC, IPv4, máscara y broadcast;
- el inventario de activos contiene esos datos con la fuente EV-002;
- no se generó ningún hallazgo.

**Acceptance Scenarios**:

1. **Given** EV-002 está en `./evidencias/`, **When** se ejecuta el flujo, **Then**
   `inventario_evidencias.md` lista EV-002 con su archivo de origen, una observación [HECHO] y la
   clasificación "de contexto".
2. **Given** EV-002 fue clasificada como de contexto, **When** termina el flujo, **Then**
   `inventario_activos.md` registra:
   - hostname `metasploitable`;
   - interfaz `eth0` y MAC `08:00:27:cd:02:f4`;
   - IPv4 `192.168.56.101/24` y broadcast `192.168.56.255`;
   - EV-002 como fuente.

   Además, no existe ningún `H-XXX` cuya única evidencia sea EV-002.
3. **Given** una evidencia en la que un dato es solo parcialmente legible (por ejemplo, la IPv6
   de EV-002), **When** se registra la observación, **Then** el dato se marca como
   "parcialmente legible" y no se completa por suposición.
4. **Given** una evidencia que no permite concluir nada (captura cortada, sin comando visible),
   **When** se clasifica, **Then** queda como "insuficiente" y `evidencia_insuficiente.md`
   indica qué falta para poder analizarla.

---

### User Story 2 - Redactar hallazgos trazables (Priority: P2)

Para cada evidencia clasificada como de hallazgo, el flujo redacta un hallazgo `H-XXX` en su
propio archivo. El hallazgo tiene un enunciado de una frase, las evidencias que lo sustentan,
una severidad y una justificación breve. También lo registra en la matriz de hallazgos.

**Why this priority**: los hallazgos son el resultado principal de la auditoría. Dependen de
que las evidencias estén inventariadas y clasificadas (historia 1).

**Independent Test**: se procesa una evidencia de hallazgo y se comprueba que:

- existe `hallazgos/H-001.md` con enunciado, evidencia, severidad y justificación;
- `matriz_hallazgos.csv` tiene una fila H-001 que referencia un EV-XXX existente en el
  inventario.

**Acceptance Scenarios**:

1. **Given** una evidencia clasificada como de hallazgo, **When** se ejecuta el flujo, **Then**
   se crea `hallazgos/H-XXX.md` con:
   - el enunciado;
   - el o los EV-XXX que lo sustentan;
   - una severidad de la escala Crítica/Alta/Media/Baja/Informativa;
   - la justificación.
2. **Given** se creó un hallazgo, **When** se revisa `matriz_hallazgos.csv`, **Then** existe
   exactamente una fila para ese H-XXX, coherente con su archivo.
3. **Given** un hallazgo recién redactado, **When** el auditor aún no lo ha revisado, **Then**
   su bloque "Revisión" tiene estado `pendiente`, sin revisor ni fecha, y no figura como
   cerrado.
4. **Given** el auditor revisó un hallazgo, **When** registra su decisión, **Then** el bloque
   "Revisión" tiene estado `aprobado`, `corregido` o `descartado`, revisor y fecha, y
   `estado_revision` de la matriz muestra el mismo valor.
5. **Given** el hallazgo contiene una afirmación no visible en la evidencia, **When** se
   redacta, **Then** esa afirmación lleva la etiqueta [INFERENCIA].

---

### User Story 3 - Proponer recomendaciones verificables (Priority: P3)

Para cada hallazgo, el flujo propone una recomendación con cuatro elementos:

- una acción concreta;
- una prioridad derivada de la severidad;
- un responsable sugerido;
- un criterio de cierre que permita verificar que el riesgo fue corregido.

**Why this priority**: cierra la cadena Observación → Evidencia → Hallazgo → Recomendación.
Depende de que existan hallazgos (historia 2).

**Independent Test**: tomando un hallazgo existente, se verifica que su archivo contiene una
recomendación con acción, prioridad, responsable sugerido y criterio de cierre, y que la matriz
refleja esos datos.

**Acceptance Scenarios**:

1. **Given** un hallazgo H-XXX, **When** se genera su recomendación, **Then** incluye acción
   concreta, prioridad, responsable sugerido y criterio de cierre verificable.
2. **Given** la recomendación requiere comprobar algo en el sistema, **When** se redacta,
   **Then** se proponen los comandos para que el auditor los ejecute. El flujo no los ejecuta.
3. **Given** no existe ningún hallazgo, **When** se ejecuta el flujo, **Then** no se genera
   ninguna recomendación. Sin hallazgo no hay recomendación.

---

### Edge Cases

- **`./evidencias/` vacía:** el flujo informa que no hay evidencias y no genera hallazgos ni
  recomendaciones.
- **Evidencia que muestra un activo distinto de `192.168.56.101`:** se marca como fuera de
  alcance, no se analiza y se informa al auditor.
- **Evidencia con credenciales o datos de personas reales visibles:** la observación los
  enmascara según FR-013. El archivo original no se versiona (el repositorio es público).
- **Dos archivos con la misma evidencia (duplicado):** se inventarían por separado y se anota
  que están duplicados. No se generan hallazgos duplicados.
- **Evidencia mixta (identifica el activo y además muestra una debilidad):** se clasifica de
  hallazgo, y sus datos del activo igualmente pasan al inventario de activos.
- **Una evidencia que sustenta varios hallazgos, o un hallazgo con varias evidencias:** se
  admiten las dos relaciones y la matriz refleja todas las referencias.
- **Volver a ejecutar el flujo con evidencias nuevas:** los IDs EV-XXX y H-XXX ya asignados se
  conservan y los nuevos continúan la numeración.
- **Archivo sin prefijo `EV-NNN_`:** recibe el siguiente ID libre y el flujo propone el nuevo
  nombre al auditor.
- **Dos archivos con el mismo prefijo `EV-NNN`:** se informa el conflicto y ninguno de los dos
  se analiza hasta que el auditor lo resuelva.
- **Evidencia ilegible o en un formato que no se puede leer:** se clasifica como insuficiente e
  indica qué falta.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Cada archivo de `./evidencias/` MUST tener un ID único y estable con formato
  `EV-NNN`, que viaja en el nombre del archivo: `EV-NNN_<comando-o-tema>.<ext>` (p. ej.
  `EV-002_ifconfig.png`). Para un archivo sin prefijo, el flujo le asigna el siguiente ID libre y
  propone al auditor renombrarlo; no lo renombra sin confirmación. Un ID asignado no cambia en
  ejecuciones posteriores, y dos archivos con el mismo ID se informan como conflicto.
- **FR-002**: El flujo MUST registrar en `salidas/inventario_evidencias.md` cada evidencia con:
  - su ID;
  - el archivo de origen;
  - la observación;
  - la clasificación.
- **FR-003**: La observación MUST transcribir textualmente solo lo visible (IPs, máscaras, MAC,
  puertos, servicios, versiones, usuarios, mensajes) y etiquetarlo [HECHO]. Debe indicar la zona
  resaltada, si la hay.
- **FR-004**: El flujo MUST clasificar cada evidencia en exactamente una categoría: "de
  hallazgo", "de contexto" o "insuficiente". Es "de hallazgo" si muestra al menos una debilidad
  concreta visible: servicio inseguro, versión vulnerable, configuración débil, credencial por
  defecto o exposición innecesaria. Es "de contexto" si solo identifica el activo. La
  clasificación MUST citar la debilidad observada cuando es "de hallazgo".
- **FR-005**: Los datos del activo visibles en evidencia de contexto **o de hallazgo** MUST
  registrarse en `salidas/inventario_activos.md`, con la evidencia de origen. La evidencia de
  contexto MUST NOT generar hallazgos.
- **FR-006**: Cada evidencia insuficiente MUST quedar registrada en
  `salidas/evidencia_insuficiente.md` indicando qué falta para analizarla.
- **FR-007**: El flujo MUST crear un hallazgo solo a partir de evidencia clasificada "de
  hallazgo". El hallazgo va en `salidas/hallazgos/H-NNN.md` e incluye:
  - un enunciado de una frase;
  - las evidencias de origen;
  - la severidad (Crítica, Alta, Media, Baja o Informativa);
  - una justificación breve.
- **FR-008**: Cada hallazgo MUST incluir un control preliminar de ISO/IEC 27001:2022 (Anexo A)
  con su nivel de certeza (Alta/Media/Baja), o "verificar" si hay duda. El mapeo normativo
  detallado y legal queda para la funcionalidad 002.
- **FR-009**: Cada hallazgo MUST incluir una recomendación con:
  - acción concreta;
  - prioridad;
  - responsable sugerido;
  - criterio de cierre verificable.
- **FR-010**: El flujo MUST mantener `salidas/matriz_hallazgos.csv` con una fila por hallazgo,
  coherente con los archivos `H-NNN.md`. Cada fila referencia solo evidencias existentes en el
  inventario. Formato: UTF-8, separador coma, fila de encabezado. Columnas, en este orden:
  `id_hallazgo`, `enunciado`, `evidencias` (IDs separados por `;`), `severidad`,
  `control_iso`, `certeza_iso`, `recomendacion`, `prioridad`, `responsable_sugerido`,
  `criterio_cierre`, `estado_revision`.
- **FR-011**: Toda afirmación no visible directamente en la evidencia MUST etiquetarse
  [INFERENCIA]. No se inventan IPs, versiones, artículos ni datos ausentes.
- **FR-012**: El flujo MUST NOT ejecutar escaneos, exploits ni comandos contra ningún sistema.
  Si hace falta verificar algo, propone los comandos al auditor.
- **FR-013**: Las salidas MUST enmascarar siempre contraseñas, hashes, tokens, claves y los
  datos de personas reales (por ejemplo, `****`). Los identificadores técnicos del laboratorio
  se transcriben literalmente: IP, MAC, hostname y usuarios por defecto del sistema (como
  `msfadmin`).
- **FR-014**: Cada `H-NNN.md` MUST incluir un bloque "Revisión" con:
  - estado: `pendiente`, `aprobado`, `corregido` o `descartado`;
  - revisor;
  - fecha (AAAA-MM-DD);
  - comentario.

  El flujo crea todo hallazgo con estado `pendiente`; solo el auditor cambia ese estado.
  `estado_revision` de la matriz MUST coincidir con el bloque. Un cambio de estado se integra
  mediante un PR con el checklist de la Definition of Done. Un hallazgo cuenta como cerrado solo
  si está `aprobado` o `corregido`.
- **FR-015**: Las evidencias que muestren activos fuera del alcance (cualquier activo distinto
  de `192.168.56.101`) MUST marcarse como fuera de alcance y no analizarse.
- **FR-016**: Al terminar, el flujo MUST resumir lo generado y listar dudas y supuestos.

### Key Entities

- **Evidencia (EV-NNN)**: captura o salida de comando entregada por el auditor. Atributos:
  - ID;
  - archivo de origen;
  - observación;
  - clasificación (de hallazgo / de contexto / insuficiente / fuera de alcance);
  - qué falta (solo si es insuficiente).
- **Activo**: sistema evaluado e identificado por evidencia de contexto. Atributos:
  - hostname;
  - interfaces;
  - MAC;
  - direcciones IP;
  - usuario observado;
  - evidencia de origen.
- **Hallazgo (H-NNN)**: debilidad sustentada por una o más evidencias. Atributos:
  - enunciado;
  - evidencias;
  - severidad;
  - justificación;
  - control ISO preliminar y su certeza;
  - estado de revisión.
- **Recomendación**: acción asociada a un hallazgo, con prioridad, responsable sugerido y
  criterio de cierre.
- **Matriz de hallazgos**: vista tabular con una fila por hallazgo y las 11 columnas definidas
  en FR-010. La funcionalidad 002 le agrega las columnas legales.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100 % de los archivos de `./evidencias/` aparece en el inventario con ID y
  exactamente una clasificación.
- **SC-002**: El 100 % de los hallazgos referencia al menos una evidencia existente. Hay 0
  hallazgos cuya única evidencia sea de contexto.
- **SC-003**: Caso de prueba EV-002:
  - queda clasificada como de contexto;
  - genera 0 hallazgos;
  - sus seis datos visibles (hostname, interfaz, MAC, IPv4/máscara, broadcast, usuario) aparecen
    en el inventario de activos idénticos a la captura.
- **SC-004**: El 100 % de las evidencias insuficientes indica qué falta.
- **SC-005**: El 100 % de los hallazgos tiene severidad, justificación, control ISO preliminar y
  recomendación con responsable y criterio de cierre.
- **SC-006**: Las salidas contienen 0 contraseñas, hashes, tokens, claves o datos de personas
  reales sin enmascarar.
- **SC-007**: Partiendo de cualquier fila de la matriz, el auditor llega a la evidencia de
  origen en menos de 2 minutos.
- **SC-008**: El 100 % de los hallazgos marcados como cerrados tiene registrada la revisión
  humana.

## Assumptions

- **Origen de las evidencias.** El auditor deposita las evidencias en `./evidencias/` y estas no
  se versionan, porque el repositorio es público. Las salidas en `./salidas/` sí se versionan,
  ya enmascaradas.
- **EV-002.** El ID EV-002 ya está asignado a la salida de `ifconfig` de `metasploitable`
  (referenciada en `docs/alcance.md`). La numeración respeta los IDs ya usados.
- **Control ISO en esta funcionalidad.** La constitución exige un control ISO por hallazgo, así
  que aquí se registra uno preliminar. El mapeo detallado ISO y legal, con verificación de
  artículos, corresponde a la funcionalidad 002.
- **Resumen ejecutivo y plan de remediación.** Corresponden a la funcionalidad 003. Esta
  funcionalidad solo entrega la recomendación individual por hallazgo.
- **Prioridad de la recomendación.** Se deriva de la severidad del hallazgo, salvo que el
  auditor la ajuste en la revisión.
- **Análisis y revisión.** El análisis lo realiza Claude Code bajo la constitución del proyecto;
  la revisión humana la realiza el auditor.
