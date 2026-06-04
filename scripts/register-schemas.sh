#!/usr/bin/env bash
set -euo pipefail

PROTO_FILE="gen/protobuf/petclinic/events/v1.proto"
SUBJECT="${SCHEMA_SUBJECT:-petclinic.events.v1-value}"

# Pack the .proto into a JSON string payload for the registry REST API.
SCHEMA_JSON=$(jq -Rs '{schemaType:"PROTOBUF", schema:.}' < "$PROTO_FILE")

AUTH_ARGS=()
if [[ -n "${SCHEMA_REGISTRY_AUTH:-}" ]]; then
  AUTH_ARGS=(-u "$SCHEMA_REGISTRY_AUTH")
fi

curl -sf "${AUTH_ARGS[@]}" \
  -X POST "$SCHEMA_REGISTRY_URL/subjects/$SUBJECT/versions" \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d "$SCHEMA_JSON"
