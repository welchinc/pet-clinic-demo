# Session Handoff — pet-clinic-demo

> Context dump so a fresh Claude Code (CLI) session can resume without re-discovery.
> Created 2026-06-04. Delete this file once you've absorbed it / when no longer useful.

## What this repo is

A **spec-first / contract-first** demo for a PetClinic-style system. The source of
truth is TypeSpec; everything in `gen/` is generated. We define HTTP service
contracts, domain models, and an async (event) surface, then emit OpenAPI,
JSON Schema, and Protobuf for downstream clients (TS + Java).

### Layout
- `src/models.tsp`, `src/service.tsp`, `src/events.tsp` — **hand-authored TypeSpec source of truth**.
- `main.tsp`, `tspconfig.yaml` — TypeSpec entrypoint + emitter config.
- `gen/openapi/openapi.yaml` — generated OpenAPI.
- `gen/json-schema/*.json` — generated JSON Schema (incl. event payloads:
  `OwnerRegistered`, `PetRegistered`, `VisitScheduled`, `VisitCompleted`).
- `gen/protobuf/petclinic/events/v1.proto` — generated protobuf for the event surface.
- `buf.yaml`, `buf.gen.yaml` — buf lint/generate config for the proto.
- `.spectral.yaml` — Spectral lint ruleset for the OpenAPI doc.
- `packages/npm/` — TS client package (generate.mjs builds types from schemas).
- `packages/java/` — Java client (Gradle), publishes to GitHub Packages.
- `scripts/register-schemas.sh` — pushes schemas to a schema registry (needs secrets).
- `.github/workflows/ci.yml` — lint + generate + verify-no-drift on PRs.
- `.github/workflows/release.yml` — on tag: build & publish TS/Java clients + register schemas.

## Current state (branch `main`)

`main` is clean and current. Recent history (rebased clean — earlier demo/revert
noise was removed):

```
abeb977 CI hygiene: single run per PR + bump actions to v5
47028f7 Add VisitCompleted event to async surface
2424519 Scaffold PetClinic spec-first domain contracts
b76451c Add greeting to test.txt
```

### Recently completed (this session)
- **Scaffolded the spec-first contracts** (TypeSpec → OpenAPI/JSON Schema/Protobuf).
- **Added `VisitCompleted`** to the async/event surface (model + generated schema + proto).
- **CI hygiene** (commit `abeb977`):
  - Single workflow run per PR — deduped triggers so a PR no longer kicks two runs.
    Verified via the Actions API returning `total_count: 1` for a PR head SHA.
  - Bumped GitHub Actions to `@v5` (e.g. `actions/checkout`, setup actions).
- **PR #2** (the work above) was **rebase-merged into `main` and is closed**. History
  was intentionally rebuilt into the two clean commits `47028f7` + `abeb977`;
  the old demo/revert commits are gone. Do not try to reopen/re-merge it.

## Open / roadmap items (nothing in flight)

1. **Release pipeline shakedown** — cut a `v0.1.0` tag to exercise `release.yml`
   (publishes TS + Java clients to GitHub Packages). The schema-registry step
   (`scripts/register-schemas.sh`) needs registry secrets configured first.
2. **GraphQL subgraph** — add a GraphQL leg to the spec-first surface.
3. **Consumer contract tests** — Microcks for the async/event side.
4. **Cleanup (low effort):**
   - Remove the stray `test.txt` (contains just `hi`) — it's demo cruft.
   - Refresh stale event field names in the source doc / README so they match the
     current generated schemas (some event payload fields drifted from docs).

## Conventions / gotchas
- **Spec-first is load-bearing:** never hand-edit anything under `gen/`. Change the
  `.tsp` source, then regenerate. CI has a verify-no-drift check that fails if
  `gen/` doesn't match what the source produces — so always regenerate and commit
  the output together.
- Keep PRs to a **single CI run**; the dedup in `ci.yml` is deliberate.
- Work branch used in the web session was `claude/github-repo-access-rO1TT`, but
  everything landed on `main`. For new CLI work, branch from `main`.
- GitHub repo: `welchinc/pet-clinic-demo`.

## Suggested first move for CLI session
Knock out the cleanup (item 4) as a warmup, or pick item 1 (release pipeline) if
the goal is to see end-to-end client publishing. Confirm with the user which
roadmap thread to pull.
