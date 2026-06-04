# PetClinic Domain Contracts

A spec-first contract layer for domain-bounded microservices. **TypeSpec is the
single source of truth**; OpenAPI, JSON Schema, and Protobuf are *generated*
artifacts. This repo is the pilot domain (**PetClinic**) for the Domain Contract
Platform.

## What you edit vs. what is generated

| You edit (hand-authored)        | Generated (do not hand-edit)                     |
| ------------------------------- | ------------------------------------------------ |
| `src/models.tsp` — entities     | `gen/json-schema/*.json` — validation + tests    |
| `src/service.tsp` — REST surface| `gen/openapi/openapi.yaml` — API gateway contract|
| `src/events.tsp` — event payloads| `gen/protobuf/petclinic/events/v1.proto` — Kafka |
| `main.tsp` / `tspconfig.yaml`   | `packages/*/src` — typed clients (release-time)  |

Everything under `gen/` is committed so changes are reviewable in PRs. CI fails
if `gen/` drifts from a fresh compile (see below) — so never hand-edit it.

## The sync / async carve-out

| File              | Plane           | Emits                              |
| ----------------- | --------------- | ---------------------------------- |
| `src/models.tsp`  | shared entities | JSON Schema 2020-12                |
| `src/service.tsp` | SYNC (REST)     | OpenAPI 3.1                        |
| `src/events.tsp`  | ASYNC (events)  | Protobuf (proto3) → schema registry|

## Local quickstart

```bash
# Regenerate all artifacts from the source of truth
npm install
npm run build            # = tsp compile .

# Generate TypeScript types (from the emitted JSON Schemas)
cd packages/npm && npm install && npm run build
```

## CI enforcement gate (`.github/workflows/ci.yml`)

A schema is only a contract if it is enforced. On every PR:

1. **TypeSpec compile** — sources must compile.
2. **Drift check** — committed `gen/` must match a fresh compile (no hand-edits).
3. **Async** — `buf lint` + `buf breaking` vs `main`.
4. **Sync** — Spectral lint + `oasdiff` breaking-change vs `main`.

## Release / publish (`.github/workflows/release.yml`)

On a published GitHub Release (tag `vX.Y.Z`): regenerate, publish typed clients to
GitHub Packages (TypeScript via npm, Java via Maven), and register Protobuf event
schemas. Required repo secrets: `SCHEMA_REGISTRY_URL` and optionally
`SCHEMA_REGISTRY_AUTH`.

## Toolchain

| Tool | Role |
| ---- | ---- |
| TypeSpec 1.12.0 (`http`, `openapi3`, `json-schema`) + `protobuf` 0.82.0 | source of truth + emitters |
| buf | Protobuf governance (lint/breaking) + Java codegen |
| Spectral | OpenAPI linting |
| oasdiff | OpenAPI breaking-change detection |
| json-schema-to-typescript | TS type generation |
| Confluent-compatible Schema Registry | runtime Protobuf registry for Kafka |

## Roadmap

- Consumer contract tests against published schemas (e.g. Microcks, async side).
- Domain-team consumption patterns (pulling generated clients from GH Packages).
- GraphQL subgraph emitter once it stabilizes in the TypeSpec standard library.
