# Quickstart — validar la funcionalidad 001

## Requisitos previos

- Windows PowerShell 5.1 y el repositorio clonado en la rama de la funcionalidad.
- Claude Code con la skill `sk-ciberauditor` disponible.
- Para el escenario 1: la captura de EV-002 guardada localmente como
  `evidencias/EV-002_ifconfig.png`. Esa carpeta no se versiona.

## Escenario 0 — El validador funciona (sin evidencias reales)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/Invoke-Pruebas.ps1
```

**Esperado:**
- el fixture `valido/` termina con código 0;
- cada fixture `invalido-*` termina con código 1 y reporta la comprobación (C1–C10) que rompe;
- el runner termina con código 0.

## Escenario 1 — Caso obligatorio EV-002 (historia P1, SC-003)

1. En Claude Code, pega el prompt de `docs/flujo_prompt_e_hu.md` §2a.
2. Revisa las salidas generadas:
   - `salidas/inventario_evidencias.md`: EV-002 con `Clasificación = contexto`.
   - `salidas/inventario_activos.md`: `metasploitable`, `eth0`, `08:00:27:cd:02:f4`,
     `192.168.56.101`, la máscara tal como aparece en la captura, `192.168.56.255` y
     `msfadmin`, todos con fuente EV-002 e idénticos a la captura.
   - La IPv6 aparece marcada "(parcialmente legible)".
   - `salidas/hallazgos/` no contiene ningún hallazgo cuya única evidencia sea EV-002.
3. Ejecuta el validador:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Salidas.ps1
   ```

   **Esperado:** código 0, sin `[ERROR]`.

## Escenario 2 — Hallazgo y recomendación (historias P2 y P3)

1. Agrega una evidencia que muestre una debilidad, con el nombre `EV-NNN_<tema>.<ext>`, y vuelve
   a ejecutar el prompt.
2. **Esperado:**
   - existe `salidas/hallazgos/H-001.md` con el bloque "Revisión" en estado `pendiente`;
   - la matriz tiene una fila H-001 con las 11 columnas;
   - el validador termina con código 0.
3. Para simular la revisión, edita el bloque "Revisión" (`aprobado`, revisor, fecha) y
   `estado_revision` en la matriz. Abre un PR con el checklist de la Definition of Done.
   - **Esperado:** el validador sigue en código 0.
   - Si quitas la fecha, debe fallar C10.

## Escenario 3 — Regla de no ejecución

Revisa en el diff del PR que `scripts/` no contenga comandos de red:

```powershell
Select-String -Path scripts\*.ps1 -Pattern 'Invoke-WebRequest|Invoke-RestMethod|Test-NetConnection|Net\.Sockets|Start-Process'
```

**Esperado:** sin coincidencias.

## Referencias

- Formatos: `contracts/inventarios.md`, `contracts/hallazgo.md` y
  `contracts/matriz_hallazgos.md`.
- Validador: `contracts/test-salidas.md`.
- Entidades: `data-model.md`.
