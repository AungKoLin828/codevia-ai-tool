const assert = require("node:assert/strict");
const test = require("node:test");
const { normalizeBackendUrl } = require("../out/backendUrl.js");

test("migrates the previous hosted backend hostname", () => {
  assert.equal(
    normalizeBackendUrl("https://devforge-ai-tool.netlify.app/"),
    "https://codevia-ai-tool.netlify.app",
  );
  assert.equal(
    normalizeBackendUrl("https://devforge-ai-tool.netlify.app/api"),
    "https://codevia-ai-tool.netlify.app/api",
  );
});

test("preserves current and custom backend URLs", () => {
  assert.equal(
    normalizeBackendUrl(" https://codevia-ai-tool.netlify.app/ "),
    "https://codevia-ai-tool.netlify.app",
  );
  assert.equal(
    normalizeBackendUrl("https://backend.example.com/"),
    "https://backend.example.com",
  );
});
