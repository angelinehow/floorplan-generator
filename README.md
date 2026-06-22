# Floor Plan Sheets

Turn a single-unit CAD floor plan (DXF, or DWG via a converter) into a **branded
marketing sheet** (SVG + PNG) — with room labels placed automatically and a
drag-to-fix editor. Built for a non-technical coordinator: upload a file, pick a
property, export a finished sheet. No coordinate entry.

![Example sheet](app/references/EXAMPLE_one-bed-sheet.png)

## What's in this repo

```
app/                              ← the shipping web app (start here)
  backend/      FastAPI service wrapping the rendering engine
  frontend/     Vite + React UI (upload → live preview → export)
  references/   sample CAD/brand inputs + the example output sheet
  rough_work/
    og_scripts/   original prototype engine (reference, not run by the app)
    wip_specs/    engineering spec + the manual workflow it automates
```

The two scripts under [`app/rough_work/og_scripts/`](app/rough_work/og_scripts/)
(`build_floorplan_sheets.py` and `build_floorplan_sheets_with_keyplan.py`) are the
**original prototype** the app was refactored from. `app/backend/engine/render.py`
reproduces their output and is what the app actually runs — the scripts are kept
as the reference, not as dead code.

## Quick start

Two processes. Full setup, troubleshooting, and usage are in
[`app/README.md`](app/README.md) — the short version:

```bash
# 1. backend (port 8000)
cd app/backend
python -m venv .venv && .venv\Scripts\activate    # macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# 2. frontend (port 5173) — in a second terminal
cd app/frontend
npm install
npm run dev
```

Then open http://localhost:5173. The dev server proxies `/api/*` to the backend,
so there's nothing else to configure.

**Native deps:** `cairosvg` needs Cairo for PNG output (Windows: the GTK3
runtime ships it and the engine auto-registers it). DWG input is optional and
needs the ODA File Converter (`ODA_CONVERTER` env var); without it, only DXF is
accepted.

**Tests:** the backend has a hermetic suite (stdlib `unittest`). Run it from
`app/backend/` with `python -m unittest discover -s tests -p "test_*.py"`.

## Documentation

| Doc | What it covers |
| --- | --- |
| [`app/README.md`](app/README.md) | Setup, running, and the full click-by-click workflow |
| [`CLAUDE.md`](CLAUDE.md) | Architecture, cross-cutting contracts, and gotchas for contributors |
| [`app/rough_work/wip_specs/APP_BUILD_SPEC.md`](app/rough_work/wip_specs/APP_BUILD_SPEC.md) | Engineering spec — *why* the app is built the way it is |
| [`app/rough_work/wip_specs/FLOORPLAN_WORKFLOW.md`](app/rough_work/wip_specs/FLOORPLAN_WORKFLOW.md) | The manual coordinator process this automates |

Read the spec and workflow docs before making non-trivial changes — they encode
the reasoning behind most design decisions.

## Status

Internal v1. No multi-user accounts, no in-app wall-geometry editing (fix it in
CAD), and key plans are schematic locators, not exact-scale drawings.
