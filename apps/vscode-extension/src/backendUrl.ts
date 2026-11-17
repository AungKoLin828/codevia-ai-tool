const CURRENT_HOSTED_BACKEND = "https://codevia-ai-tool.netlify.app";

export function normalizeBackendUrl(value: string): string {
  return value
    .trim()
    .replace(/\/+$/, "")
    .replace(
      /^https:\/\/devforge-ai-tool\.netlify\.app(?=\/|$)/i,
      CURRENT_HOSTED_BACKEND,
    );
}
