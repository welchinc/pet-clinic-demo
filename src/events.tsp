import "@typespec/protobuf";

using TypeSpec.Protobuf;

// Asynchronous surface -> Protobuf. These messages are the event payloads
// published to Kafka and registered in the schema registry.
//
// Field names are snake_case to satisfy Protobuf convention (buf STANDARD's
// FIELD_LOWER_SNAKE_CASE). Generated language stubs map these back to the
// idiomatic casing per target (e.g. ownerId in Java/TS).
@package({ name: "petclinic.events.v1" })
namespace PetClinic.Events;

model OwnerRegistered {
  @field(1) owner_id: string;
  @field(2) first_name: string;
  @field(3) last_name: string;
  @field(4) city: string;
  @field(5) occurred_at: int64;
}

model PetRegistered {
  @field(1) pet_id: string;
  @field(2) owner_id: string;
  @field(3) name: string;
  @field(4) species: string;
  @field(5) occurred_at: int64;
}

model VisitScheduled {
  @field(1) visit_id: string;
  @field(2) pet_id: string;
  @field(3) date: string;
  @field(4) description: string;
  @field(5) occurred_at: int64;
}
