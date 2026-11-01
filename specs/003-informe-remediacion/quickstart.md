# Quickstart — validar la funcionalidad 003

## Requisitos previos

- Windows PowerShell 5.1 y el repositorio en la rama de la funcionalidad.
- Las funcionalidades 001 y 002 integradas (validador C1–C22, runner y fixtures).
- Para los escenarios 1–3: al menos un hallazgo real revisado (`aprobado` o `corregido`) en
  `salidas/hallazgos/`, lo que requiere evidencia y revisión del auditor.

## Escenario 0 — Compatibilidad y fixtures (sin hallazgos reales)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/Invoke-Pruebas.ps1
```

**Esperado:**
- los fixtures de 001 y 002 siguen dando el mismo código y no muestran C23–C29;
- `valido/` (con plan y resumen aprobados) termina con 0;
- cada `invalido-c23…c28-*` termina con 1 y reporta su comprobación;
- `aviso-c29-informe-pendiente/` termina con 0 y muestra `[AVISO] C29`;
- el runner termina con 0.

## Escenario 1 — Plan de remediación (historia P1)

1. En Claude Code, pega el prompt de `docs/flujo_prompt_e_hu.md` §2d.
2. Revisa `salidas/plan_remediacion.md`:
   - una fila por hallazgo revisado, en orden de prioridad, severidad e ID;
   - acción, responsable y criterio de cierre iguales a la matriz;
   - plazo según la prioridad y estado `abierto`;
   - recuento de hallazgos excluidos;
   - bloque Revisión en `pendiente`.
3. Cambia el plazo de una fila sin comentario. **Esperado:** falla C25. Agrega
   `Plazo ajustado: <motivo>` al comentario. **Esperado:** C25 vuelve a OK.

## Escenario 2 — Resumen ejecutivo (historia P2)

1. Revisa `salidas/resumen_ejecutivo.md`: las 7 secciones, conteos iguales a la matriz,
   máximo cinco riesgos con su hallazgo y la leyenda normativa.
2. Ejecuta el validador:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1
   ```

   **Esperado:** código 0, `[AVISO] C29` (informe pendiente) y el número de palabras del
   resumen en el resumen final.
3. Pide a una persona no técnica que lo lea y mide el tiempo (SC-003: < 3 minutos). Anótalo en
   el PR.

## Escenario 3 — Revisión y cierre (historia P3)

1. Completa el bloque Revisión de ambos documentos (`aprobado`, revisor, fecha).
   **Esperado:** el validador termina con 0, sin C29, e informa "informe cerrado".
2. Cambia un hallazgo y vuelve a pegar el prompt §2d. **Esperado:** el documento afectado vuelve
   a `pendiente` con "Revisión previa:" en el comentario, y reaparece C29.

## Escenario 4 — Regla de no ejecución

```powershell
Select-String -Path scripts\*.ps1, scripts\tests\*.ps1 -Pattern 'Invoke-WebRequest|Invoke-RestMethod|Test-NetConnection|Net\.Sockets|Start-Process'
```

**Esperado:** sin coincidencias.

## Referencias

- Formatos: `contracts/plan-remediacion.md` y `contracts/resumen-ejecutivo.md`.
- Validador: `contracts/test-salidas-003.md`.
- Entidades: `data-model.md`.
