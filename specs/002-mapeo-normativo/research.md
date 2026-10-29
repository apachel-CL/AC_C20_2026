# Research — 002 Mapeo normativo de hallazgos

El contexto técnico no dejó ningún "NEEDS CLARIFICATION": la única duda de la spec (Q1,
aplicabilidad de la Ley 21.663) se resolvió en la sesión del 2026-10-28. Este documento registra
las decisiones de diseño derivadas.

## R1. Dónde vive el mapeo de cada hallazgo

- **Decision**: una sección `## Mapeo normativo` dentro del mismo `H-NNN.md`, con líneas
  `- **Clave**: valor` (las que ya parsea el validador de 001). El control principal y su
  certeza siguen en los campos existentes `Control ISO` y `Certeza ISO`; 002 los actualiza.
- **Rationale**: mantiene un archivo por hallazgo (trazabilidad, revisión en un solo PR) y
  reutiliza el parser de 001. Como `Get-Metadatos` conserva la primera aparición de cada clave,
  todas las claves nuevas son únicas en el archivo (p. ej. `Ley 21.663 certeza`, no `Certeza`).
- **Alternatives considered**:
  - *Un archivo `M-NNN.md` por hallazgo*: duplica IDs y obliga a sincronizar dos archivos.
  - *Solo en la matriz*: la matriz no admite justificaciones largas y no es la fuente.

## R2. Control principal: reemplazo del preliminar

- **Decision**: el control principal sobrescribe `Control ISO` en el hallazgo y `control_iso`
  en la matriz. Si cambia, se registran `Control ISO anterior` y `Motivo de corrección`; si no,
  `Control ISO anterior` es `—` y el motivo es `confirmado`.
- **Rationale**: la spec (FR-003) pide que la matriz refleje el control vigente, y C9 de 001 ya
  compara `control_iso` con el hallazgo, así que no hay que tocar C9.

## R3. Lista de controles del Anexo A (2022)

- **Decision**: el validador comprueba que todo control exista en el Anexo A de
  ISO/IEC 27001:2022 por rangos: `A.5.1`–`A.5.37`, `A.6.1`–`A.6.8`, `A.7.1`–`A.7.14` y
  `A.8.1`–`A.8.34` (93 controles). Se aplica al principal y a los adicionales.
- **Rationale**: detecta controles de la versión 2013 (p. ej. `A.12.6.1`) o inventados sin
  incluir el texto de la norma, que tiene derechos de autor. Los nombres de los controles no se
  versionan.
- **Alternatives considered**: tabla con los 93 nombres en el repo; se descarta por derechos y
  porque el formato basta para la comprobación.

## R4. Columnas legales de la matriz

- **Decision**: las 7 columnas de FR-011 se agregan después de `estado_revision`. La plantilla
  de la matriz pasa a 18 columnas, así que un hallazgo de 001 sin mapear tiene las 7 vacías. El
  validador:
  - exige que, si hay más de 11 columnas, las 7 siguientes sean exactamente las de FR-011
    (C15);
  - emite C12 solo para columnas después de la 18;
  - acepta una matriz de 11 columnas (salida antigua de 001) y en ese caso omite C15.
- **Rationale**: una salida de 001 sigue siendo válida (compatibilidad) y la columna 12 en
  adelante tiene un orden fijo.
- **Valores**: `—` cuando la ley "no aplica" en artículo; vacío solo si el hallazgo no tiene
  sección de mapeo o está `descartado`.

## R5. Lista de verificación de artículos

- **Decision**: `salidas/verificacion_articulos.md` con una tabla `VA-NNN`. Cada referencia
  legal (hallazgo × ley con obligación distinta de `no aplica`) tiene exactamente una fila. La
  entrada en vigor de la Ley 21.719 es una fila con hallazgo `—` y obligación
  `entrada en vigor`, que existe si algún hallazgo mapea esa ley.
- **Rationale**: el auditor tiene un único lugar para trabajar las verificaciones y el
  validador puede exigir fuente y fecha a cada `verificado`.
- **Regla de citación**: el campo artículo del hallazgo vale `verificar` mientras la fila esté
  `pendiente`; con `verificado`, vale exactamente el artículo de la fila; con `descartado`, el
  mapeo de esa ley vuelve a `verificar` o pasa a `no aplica`.

## R6. Volver a revisión al cambiar el mapeo (FR-016)

- **Decision**: el prompt de §2c pone `Estado: pendiente` (y vacía revisor y fecha) en todo
  hallazgo cuyo mapeo crea o modifica. La plantilla de PR agrega el ítem "Mapeo normativo
  revisado por el auditor en cada H-NNN.md tocado".
- **Rationale**: el validador lee un solo estado de los archivos y no tiene historial; comparar
  contra git agregaría ejecución de procesos (prohibido en el contrato de 001).
- **Alternatives considered**: guardar un hash del mapeo en el bloque Revisión. Se descarta por
  frágil y poco legible para la revisión humana.

## R7. Límites de certeza (Q1 y Ley 21.719)

- **Decision**:
  - Ley 21.663: certeza ≤ `Media` siempre y justificación que contenga la frase "si la
    organización fuera entidad obligada" (Q1).
  - Ley 21.719 distinta de `no aplica`: certeza ≤ `Media` mientras la fila de entrada en vigor
    no esté `verificado`, y campo `Ley 21.719 vigencia` con la advertencia.
- **Rationale**: es comprobable por texto y aplica la constitución (V).

## R8. Mapa normativo

- **Decision**: `salidas/mapa_normativo.md` con tres tablas de dos columnas
  (`Control ISO | Hallazgos`, `Obligación Ley 21.663 | Hallazgos`,
  `Obligación Ley 21.719 | Hallazgos`), la leyenda de FR-002 y una sección "Ley 21.459" que la
  ubica como marco de la autorización. El validador recalcula las tablas desde los hallazgos y
  compara (C21).
- **Rationale**: el mapa es una vista derivada; recalcularla evita que se desalinee.
- **Alternatives considered**: generarlo con un script. Se descarta porque el plan de 001 fija
  scripts de solo lectura; Claude lo escribe y el validador lo comprueba.

## R9. Prompt de mapeo

- **Decision**: nueva §2c en `docs/flujo_prompt_e_hu.md`, separada de §2a, que se ejecuta
  después de que 001 generó los hallazgos.
- **Rationale**: el mapeo se hace sobre hallazgos ya revisados o pendientes, no al procesar
  evidencias; separarlo mantiene §2a acotado.
