// Generates TypeScript types from the emitted JSON Schemas (canonical entity shapes).
import { compileFromFile } from "json-schema-to-typescript";
import { readdirSync, mkdirSync, writeFileSync } from "fs";
import { join } from "path";

const schemaDir = join("..", "..", "gen", "json-schema");
const srcDir = "src";
mkdirSync(srcDir, { recursive: true });

const files = readdirSync(schemaDir).filter((f) => f.endsWith(".json"));
const seen = new Set();
let barrel = "";

for (const f of files) {
  const ts = await compileFromFile(join(schemaDir, f), { cwd: schemaDir, bannerComment: "" });
  const base = f.replace(/\.json$/, "");
  writeFileSync(join(srcDir, base + ".ts"), ts);
  // json-schema-to-typescript inlines referenced types, so dedupe across files.
  const names = [...ts.matchAll(/export (?:type|interface) (\w+)/g)]
    .map((m) => m[1])
    .filter((n) => !seen.has(n));
  names.forEach((n) => seen.add(n));
  if (names.length) {
    barrel += "export type { " + names.join(", ") + " } from \"./" + base + "\";\n";
  }
}
writeFileSync(join(srcDir, "index.ts"), barrel);
console.log("Generated " + files.length + " TypeScript modules.");
