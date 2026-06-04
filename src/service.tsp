import "@typespec/http";
import "./models.tsp";

using TypeSpec.Http;

// Synchronous surface -> OpenAPI 3.1 (feeds the API gateway).
@service(#{ title: "PetClinic Domain API" })
namespace PetClinic;

model OwnerCreate {
  firstName: string;
  lastName: string;
  address: string;
  city: string;
  telephone: string;
}

model PetRegister {
  name: string;
  birthDate: plainDate;
  type: PetType;
}

model VisitSchedule {
  date: plainDate;
  description: string;
}

@route("/owners")
interface Owners {
  @get list(): Owner[];
  @get read(@path ownerId: string): Owner;
  @post create(@body body: OwnerCreate): Owner;
}

@route("/owners/{ownerId}/pets")
interface Pets {
  @get list(@path ownerId: string): Pet[];
  @post register(@path ownerId: string, @body body: PetRegister): Pet;
}

@route("/pets/{petId}/visits")
interface Visits {
  @get list(@path petId: string): Visit[];
  @post schedule(@path petId: string, @body body: VisitSchedule): Visit;
}

@route("/vets")
interface Vets {
  @get list(): Vet[];
}
