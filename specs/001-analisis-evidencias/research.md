# Research — 001 Flujo de análisis de evidencias

El contexto técnico no dejó ningún "NEEDS CLARIFICATION": el usuario fijó el stack en la
entrada de `/speckit-plan`, y las cinco aclaraciones de la spec resolvieron los formatos. Este
documento registra las decisiones de diseño derivadas.

## R1. Motor del análisis

- **Decision**: el análisis (observación, clasificación, hallazgo, recomendación) lo hace Claude
  Code en sesión, con la skill `sk-ciberauditor` y el prompt de `docs/flujo_prompt_e_hu.md` §2a.
  No se escribe código de análisis.
- **Rationale**: el valor está en el juicio del auditor asistido. La constitución (IV) prohíbe
  ejecutar comandos contra sistemas, así que no hay nada que automatizar del lado del activo.
- **Alternatives considered**:
  - *Parsers de `ifconfig`/`nmap` en scripts*: se descartan porque la mayoría de las evidencias
    son capturas de pantalla y el parseo no aporta criterio.
  - *Una aplicación*: se descarta porque el usuario la excluyó.

## R2. Formato de inventarios y hallazgos

- **Decision**: los inventarios son Markdown con una tabla por archivo, con encabezados fijos
  (ver `contracts/inventarios.md`). Cada hallazgo es un Markdown con un bloque de metadatos en
  formato "clave: valor" dentro de una lista, más secciones fijas (ver `contracts/hallazgo.md`).
- **Rationale**: son legibles en GitHub, se pueden revisar en un PR y el validador los parsea
  con expresiones regulares sin dependencias.
- **Alternatives considered**:
  - *YAML front-matter*: PowerShell 5.1 no trae parser YAML y agregar un módulo es una
    dependencia.
  - *JSON*: es poco legible para la revisión humana.

## R3. Matriz CSV

- **Decision**: UTF-8 sin BOM, separador coma, encabezado con las 11 columnas de FR-010, y
  comillas dobles en los campos con comas o saltos de línea (RFC 4180). El validador la lee con
  `Import-Csv`, que en 5.1 acepta UTF-8 sin BOM si se lee el contenido con
  `[IO.File]::ReadAllText(..., UTF8)` y se pasa a `ConvertFrom-Csv`.
- **Rationale**: `Import-Csv -Encoding UTF8` en PowerShell 5.1 funciona, pero
  `Export-Csv -Encoding UTF8` escribe BOM. Leer el texto explícitamente evita problemas de
  codificación con tildes.
- **Alternatives considered**: punto y coma como separador (habitual en Excel en español). Se
  descarta porque el usuario fijó la coma.

## R4. Validación estructural

- **Decision**: un único script `scripts/Test-Salidas.ps1` (PowerShell 5.1, sin módulos
  externos) que solo lee archivos locales. Comprueba lo siguiente:
  - IDs únicos de evidencia y de hallazgo;
  - que el nombre de cada archivo `H-NNN.md` coincida con el ID que declara;
  - encabezado exacto de la matriz;
  - correspondencia 1:1 entre filas de la matriz y archivos `H-NNN.md`;
  - que toda referencia `EV-NNN` exista en el inventario;
  - que ningún hallazgo se apoye solo en evidencia de contexto;
  - valores de los enumerados;
  - que `estado_revision` coincida con el bloque "Revisión";
  - que un hallazgo cerrado tenga revisor y fecha;
  - patrones de credenciales sin enmascarar (como advertencia).

  Termina con código 0 si todo pasa y 1 si hay errores, e imprime un reporte legible. La lista
  completa y vigente de comprobaciones (C1–C14) está en `contracts/test-salidas.md`.
- **Rationale**: cubre SC-001, SC-002, SC-005, SC-006 y SC-008 de forma repetible y sin red,
  como exige la constitución (IV).
- **Alternatives considered**:
  - *Pester*: PowerShell 5.1 trae Pester 3.4, que es antiguo y con otra sintaxis. Se descarta
    para el validador; los casos de prueba se cubren con fixtures (ver R5).
  - *Varios scripts pequeños*: se descarta porque complica la ejecución en el PR.

## R5. Pruebas del validador

- **Decision**: fixtures en `scripts/tests/fixtures/` (un caso `valido/` y varios casos
  `invalido-*`) y un runner `scripts/tests/Invoke-Pruebas.ps1`. El runner ejecuta el validador
  contra cada fixture y compara el código de salida esperado.
- **Rationale**: no tiene dependencias, cada regla tiene un caso que la rompe y corre en
  PowerShell 5.1.
- **Alternatives considered**: Pester 5. Se descarta porque requiere instalar un módulo.

## R6. Registro de la revisión humana

- **Decision**: el bloque "Revisión" va en `H-NNN.md` (aclaración Q4). La plantilla de PR
  (`.github/pull_request_template.md`) suma dos ítems:
  - "bloque Revisión actualizado (revisor y fecha)";
  - "`Test-Salidas.ps1` sin errores".
- **Rationale**: git registra quién y cuándo, y el PR deja la evidencia de la revisión exigida
  por la DoD y por la constitución (VII).
- **Alternatives considered**: un issue por hallazgo. Se descartó en la aclaración Q4.

## R7. Prompt de trabajo

- **Decision**: actualizar `docs/flujo_prompt_e_hu.md` §2a para que el prompt incluya:
  - la convención de nombres `EV-NNN_<tema>.<ext>`;
  - el criterio de clasificación (Q1);
  - las 11 columnas de la matriz;
  - el bloque "Revisión" con estado `pendiente`;
  - la regla de enmascarado (Q5);
  - el uso de las plantillas de `docs/plantillas/`;
  - la ejecución final de `scripts/Test-Salidas.ps1`.
- **Rationale**: el prompt actual es anterior a las aclaraciones. Sin actualizarlo, Claude
  produciría salidas que el validador rechaza.

## R8. Datos del caso de prueba EV-002

- **Decision**: el archivo real de EV-002 vive en `evidencias/`, que no se versiona. Para
  probar el validador se usa un fixture con los datos de EV-002 tal como figuran en
  `docs/alcance.md`, que ya es público. Esto no viola la constitución (V), porque la aclaración
  Q5 dice que los identificadores del laboratorio se transcriben literalmente.
- **Rationale**: así la prueba de SC-003 es reproducible en cualquier clon del repositorio.
