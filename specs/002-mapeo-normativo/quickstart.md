# Quickstart — validar la funcionalidad 002

## Requisitos previos

- Windows PowerShell 5.1 y el repositorio en la rama de la funcionalidad.
- La funcionalidad 001 integrada (validador C1–C14, runner y fixtures).
- Para los escenarios 2 y 3: al menos un hallazgo real en `salidas/hallazgos/` (tareas T013 y
  T020 de 001, que requieren evidencia del auditor).

## Escenario 0 — Compatibilidad y fixtures (sin hallazgos reales)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/Invoke-Pruebas.ps1
```

**Esperado:**
- los fixtures de 001 siguen dando el mismo código;
- `valido-sin-mapeo/` (matriz de 18 columnas con las legales vacías) termina con 0, con
  `[OK] C15` y sin C16–C22;
- `valido/` (H-001 mapeado, lista y mapa) termina con 0;
- cada `invalido-c15…c21-*` termina con 1 y reporta su comprobación;
- el aviso C22 aparece en el fixture con referencias pendientes, con código 0;
- el runner termina con 0.

## Escenario 1 — Mapeo de un hallazgo (historias P1 y P2)

1. En Claude Code, pega el prompt de `docs/flujo_prompt_e_hu.md` §2c.
2. Revisa `salidas/hallazgos/H-001.md`:
   - tiene la sección "Mapeo normativo" con la leyenda;
   - `Control ISO` es un control del Anexo A 2022 o `verificar`, con justificación;
   - la Ley 21.663 dice "si la organización fuera entidad obligada" y su certeza es ≤ `Media`;
   - la Ley 21.719 es `no aplica` o `pendiente de vigencia` con su advertencia (no se cita
     mientras la entrada en vigor no esté verificada);
   - cada justificación lleva [HECHO] o [INFERENCIA];
   - los artículos están en `verificar`;
   - el bloque Revisión está en `pendiente`.
3. Revisa que `salidas/matriz_hallazgos.csv` tenga 18 columnas y que las 11 primeras no
   cambiaron (salvo `control_iso` si se corrigió y `estado_revision`).
4. Ejecuta el validador:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1
   ```

   **Esperado:** código 0; `[AVISO] C22` con las referencias pendientes.

## Escenario 2 — Verificación de un artículo (historia P3)

1. En `salidas/verificacion_articulos.md`, marca una fila `verificado` con artículo, fuente
   oficial y fecha, y copia el artículo al hallazgo y a la matriz.
2. **Esperado:** el validador sigue en 0 y C22 informa una referencia pendiente menos.
3. Quita la fuente de esa fila. **Esperado:** falla C19.
4. Escribe un artículo en el hallazgo sin fila `verificado`. **Esperado:** falla C19.

## Escenario 3 — Mapa normativo y Ley 21.459

1. Revisa `salidas/mapa_normativo.md`: cada control y obligación lista sus hallazgos, y la
   sección "Ley 21.459" la ubica como marco de la autorización.
2. Agrega a mano una fila que no corresponda a ningún hallazgo. **Esperado:** falla C21.
3. Agrega una fila de la Ley 21.459 en la lista de verificación. **Esperado:** falla C20.
4. Mide el recorrido de SC-006: parte de una fila del mapa, abre el hallazgo y llega a la
   evidencia citada en el inventario. **Esperado:** menos de 3 minutos; anota el tiempo en el PR.

## Escenario 4 — Regla de no ejecución

```powershell
Select-String -Path scripts\*.ps1, scripts\tests\*.ps1 -Pattern 'Invoke-WebRequest|Invoke-RestMethod|Test-NetConnection|Net\.Sockets|Start-Process'
```

**Esperado:** sin coincidencias.

## Referencias

- Formatos: `contracts/mapeo-hallazgo.md`, `contracts/matriz-columnas-legales.md`,
  `contracts/verificacion-articulos.md` y `contracts/mapa-normativo.md`.
- Validador: `contracts/test-salidas-002.md`.
- Entidades: `data-model.md`.
