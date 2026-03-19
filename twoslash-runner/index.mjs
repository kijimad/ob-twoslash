import { twoslasher } from "twoslash";
import { readFileSync } from "node:fs";

const input = readFileSync(process.argv[2] || "/dev/stdin", "utf-8");

let result;
try {
  result = twoslasher(input, "ts");
} catch (e) {
  process.stdout.write(e.message + "\n");
  process.exit(0);
}

const output = [];

// Collect queries (^?) — show type info
for (const q of result.queries) {
  output.push(`${q.text} (line ${q.line + 1})`);
}

// Collect errors
for (const e of result.errors) {
  const level = e.level || "error";
  const code = e.code ? ` ${e.code}` : "";
  output.push(`[${level}${code}] ${e.text} (line ${e.line + 1})`);
}

process.stdout.write(output.join("\n") + "\n");
