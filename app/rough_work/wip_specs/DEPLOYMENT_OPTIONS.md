# Hosting options — letting other people use the tool

**Goal:** a coordinator opens a URL and uses the app. The local two-process setup
(`uvicorn` + `npm run dev`) is for *development only* — it can't be what other
people use.

**Why Vercel 404'd:** Vercel is static-site + serverless. This app is a stateful,
always-on server that needs native libraries and a disk. Wrong tool — that's the
404, not a crash. See the requirements below for what *does* fit.

---

## Hard requirements (these rule hosts in or out)

| Requirement | Why | Consequence |
|---|---|---|
| **Always-on process** | FastAPI/uvicorn is a long-running server | No pure-serverless (Vercel, Lambda) |
| **Native system libs** | `cairosvg` needs Cairo/GTK; `PyMuPDF`, `resvg` | Need Docker or a VM you control |
| **Persistent disk** | properties + saved sheets are files in `data/` | Free/ephemeral tiers lose the library on restart |
| **One URL + HTTPS** | non-technical user, shareable link | Managed hosts give TLS free; on a VM you set it up |
| **Access control** | app has **no login** (auth is out of scope for v1) | Add a password or restrict to your network before exposing |

---

## One-time work needed *regardless* of host

This is the same prep for every option below — I'd do it once:

1. **Serve the frontend from FastAPI** — `npm run build` → static files, mounted by
   FastAPI so the whole app is *one* service on *one* origin (no separate frontend
   host, no CORS, no dev proxy). Small `main.py` change.
2. **Dockerfile** (+ `.dockerignore`) installing the Cairo system libs + Python deps
   + the built frontend. This is what makes it runnable anywhere.
3. **Minimal auth** — HTTP basic / a shared password, before it's reachable publicly.
4. **DWG decision** — ship **DXF-only first**. DWG needs the ODA converter, a licensed
   binary that's painful to bundle in a container. Add later if needed.
5. **Point a persistent volume at `data/`** so the library survives redeploys.

Once that exists, the only difference between the options is *where the container
runs* and *who manages it*.

---

## The options

> Costs are ballpark **as of early 2026** — verify current pricing. All assume low
> traffic (a handful of internal users) and ~512 MB–1 GB RAM.

| Option | ~Monthly cost | Setup effort (you) | End-user access | Maintenance | Best when |
|---|---|---|---|---|---|
| **Render** | ~$7 service + ~$1 disk | **Low** — connect GitHub, add Dockerfile + disk, auto-deploy on push | URL + free HTTPS | **Low** (managed) | You want the least hassle and ~$8/mo is fine |
| **Railway** | ~$5–10 (usage-based; $5 Hobby incl. credit) | **Low** — GitHub deploy, volumes, nice UI | URL + free HTTPS | **Low** (managed) | Similar to Render; usage-billed |
| **Fly.io** | ~$3–5 (can auto-stop to save) | **Medium** — CLI (`fly launch`), volumes | URL + free HTTPS | Low–medium | You're comfortable with a CLI and want cheap + fast |
| **Small VM** (Hetzner / DigitalOcean / Lightsail) | ~$4–6 | **High** — install Docker, run container, set up Caddy/nginx for TLS, restart policy, deploys | URL (you configure HTTPS) | **High** — you own OS updates, TLS renew, backups | You want cheapest long-term + full control and don't mind sysadmin |
| **Office machine on LAN** | **$0** | Medium — run the container on one always-on PC | Only on the office network; no public HTTPS | Medium — machine must stay on | Truly internal, on-site only, zero budget, fragile |

### Notes per option
- **Render / Railway:** the closest to "git push → it's live." Free tiers **sleep**
  after inactivity (slow cold starts) and **lack a persistent disk** — so you need a
  paid instance + a disk add-on, or the saved-sheet library evaporates.
- **Fly.io:** cheapest of the managed three and can scale machines to zero between
  uses; the tradeoff is a CLI-driven setup instead of a dashboard.
- **Small VM:** lowest running cost and most control, but you become the sysadmin —
  TLS, security patches, and "redeploy" is a manual step (or a small script). Hetzner
  is the cheapest (~€4); Lightsail/DO are ~$4–6 with simpler dashboards.
- **LAN:** fine as a stopgap if everyone's in one office, but no HTTPS, no off-site
  access, and it dies when that PC sleeps.

---

## Recommendation (weighting your two factors: cost + ease of access)

- **Best balance → Render.** Lowest setup friction, free HTTPS, GitHub auto-deploy,
  persistent disk add-on, ~$8/mo total. A coordinator just gets a link. This is the
  path I'd take unless budget must be near-zero.
- **If minimizing $ matters more than convenience → small VM (Hetzner ~€4/mo).**
  Cheaper, but you maintain it.
- **Fly.io** is the middle ground: cheaper than Render, slightly more technical.
- **Railway** ≈ Render; pick by whichever dashboard you prefer.

Across all of them the **one-time prep is identical**, so the host choice isn't
locked in — if Render gets annoying you can move the same container to a VM later.

---

## Decisions I need from you

1. **Which host?** (Render recommended.)
2. **Auth model:** shared password / restrict-to-network (VPN) / none-because-internal-trust?
3. **DWG now or DXF-only first?** (DXF-only is much easier to ship.)
4. **Custom domain** (e.g. `floorplans.patryinc.com`) or the host's default URL?

Once you pick, the next step is the one-time prep (static-serving + Dockerfile +
auth), then a short deploy guide for the chosen host.
