import "@typespec/json-schema";

using TypeSpec.JsonSchema;

// Canonical domain entities. The JSON Schema emitter turns each into a
// .json schema used for validation + consumer contract tests.
@jsonSchema
namespace PetClinic;

model Owner {
  @key id: string;
  firstName: string;
  lastName: string;
  address: string;
  city: string;
  telephone: string;
}

enum PetType {
  cat,
  dog,
  bird,
  hamster,
}

model Pet {
  @key id: string;
  name: string;
  birthDate: plainDate;
  type: PetType;
  ownerId: string;
}

model Vet {
  @key id: string;
  firstName: string;
  lastName: string;
  specialties: string[];
}

model Visit {
  @key id: string;
  petId: string;
  date: plainDate;
  description: string;
}
