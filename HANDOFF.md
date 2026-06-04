# Session Handoff — pet-clinic-demo

> Context dump for a fresh Claude Code session to resume without re-discovery.
> Updated 2026-06-04. Delete once absorbed / no longer useful.

## What this repo is

A **spec-first / contract-first** demo for a PetClinic-style system. TypeSpec is
the source of truth; everything in `gen/` is generated. We define HTTP service
contracts, domain models, and an async (event) surface, then emit OpenAPI,
JSON Schema, and Protobuf for downstream clients (TS + Java).

### Layout
- `src/models.tsp`, `src/service.tsp`, `src/events.tsp` — **hand-authored TypeSpec**
- `gen/openapi/openapi.yaml` — generated OpenAPI
- `gen/json-schema/*.json` — generated JSON Schema (entities + event payloads)
- `gen/protobuf/petclinic/events/v1.proto` — generated Protobuf
- `packages/npm/` — TS client (`@welchinc/petclinic-contracts`)
- `packages/java/` — Java client (`com.petclinic.demo:petclinic-contracts`)
- `scripts/register-schemas.sh` — pushes Protobuf schema to a Confluent-compatible registry
- `.github/workflows/ci.yml` — lint + drift check on PRs
- `.github/workflows/release.yml` — publish pipeline (npm + Maven + schema registry)

## Current state (branch `main`, as of 2026-06-04)

`main` is clean. Release `v0.1.0` is live and its publish workflow completed
successfully. Recent history:

```
ab82303 Opt into Node.js 24 for GitHub Actions (setup-java@v4 deprecation)
da2b648 Make publish steps idempotent on 409 Conflict
3b5b587 Bump protobuf-java to 4.29.3
1f48308 Cleanup + release pipeline fixes
26a41ae Add session handoff doc for CLI resume
abeb977 CI hygiene: single run per PR + bump actions to v5
47028f7 Add VisitCompleted event to async surface
2424519 Scaffold PetClinic spec-first domain contracts
```

### What was done this session
- Deleted `test.txt` (demo cruft)
- Fixed npm package scope: `@petclinic-demo/contracts` → `@welchinc/petclinic-contracts`
  (GitHub Packages npm requires scope = repo owner)
- Fixed `buf generate` working directory bug in `release.yml`: was running from
  `packages/java` so `out: packages/java/src/main/java` resolved to a doubly-nested
  path; now runs from repo root
- Made schema registry step skip gracefully when `SCHEMA_REGISTRY_URL` is unset
- Bumped `protobuf-java` from `4.28.2` → `4.29.3` (buf BSR java plugin generates
  code using `GeneratedFile`/`Generated` which were added in 4.29.0)
- Made npm and gradle publish steps idempotent on 409 Conflict (safe to retry)
- Added `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` to the release job ahead of
  GitHub's June 16 forced migration

### Published packages (GitHub Packages)
- **npm**: `@welchinc/petclinic-contracts@0.1.0` at `https://npm.pkg.github.com`
- **Maven**: `com.petclinic.demo:petclinic-contracts:0.1.0` at GitHub Packages Maven

## Open / roadmap items

1. **Schema registry** — `SCHEMA_REGISTRY_URL` and `SCHEMA_REGISTRY_AUTH` secrets
   need to be configured in repo settings to enable the Protobuf registry push step.
   The step skips gracefully when absent but won't actually register schemas.
2. **GraphQL subgraph** — add a GraphQL leg to the spec-first surface.
3. **Consumer contract tests** — Microcks for the async/event side.
4. **Bump `actions/setup-java`** to v5 (when available) to fully resolve the
   Node.js 20 → 24 migration warning; the `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24`
   env var is a stop-gap.

## Conventions / gotchas

- **Spec-first is load-bearing:** never hand-edit `gen/`. Change `.tsp` source,
  then regenerate. CI has a verify-no-drift check.
- **buf generate must run from repo root** — `buf.gen.yaml` has
  `out: packages/java/src/main/java` which is relative to cwd.
- **npm package scope is `@welchinc`** (matches GitHub org/user name).
- **protobuf-java must be ≥ 4.29.0** — older versions lack `GeneratedFile`.
- Keep PRs to a single CI run (the dedup in `ci.yml` is deliberate).
- GitHub repo: `welchinc/pet-clinic-demo`.
