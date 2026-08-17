/**
 * "Hello world"-level smoke tests confirming:
 *
 *  1. The public Microsoft Learn MCP server exposes all of its tools when called directly.
 *  2. The APIM MCP gateway in front of it only allows the allow-listed subset, per the
 *     Option A static allow-list policy in
 *     .prereqs/AA-tf/modules/mcp_limiter_demo/allowlist-policy.xml.
 *
 * This intentionally does NOT try to validate full MCP protocol correctness, streaming
 * behavior, or realistic in-LLM tool usage - it just confirms the right tools show up (or
 * don't) via tools/list, and that calling them succeeds or is blocked with the expected
 * JSON-RPC error. That's enough to prove the gateway's allow-list is actually doing something.
 *
 * No real/private resource identifiers are hardcoded here - the gateway URL is supplied via
 * an environment variable so this file is safe to keep in a public repo. Get the value from:
 *
 *     terraform -chdir=.prereqs/AA-tf output -raw mcp_server_gateway_url
 *
 * Usage:
 *     $env:MSLEARN_MCP_GATEKEPT_BASE_URL = "https://<your-apim-host>.azure-api.net/mslearn-mcp"
 *     npm test
 */

import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import { McpError } from "@modelcontextprotocol/sdk/types.js";

const MSLEARN_MCP_DIRECT_BASE_URL = "https://learn.microsoft.com/api/mcp";
const MSLEARN_MCP_GATEKEPT_BASE_URL = process.env.MSLEARN_MCP_GATEKEPT_BASE_URL;

async function connect(baseUrl: string): Promise<{ client: Client; transport: StreamableHTTPClientTransport }> {
  const transport = new StreamableHTTPClientTransport(new URL(baseUrl));
  const client = new Client({ name: "vitest-mcp-smoke-test", version: "1.0.0" }, { capabilities: {} });
  await client.connect(transport);
  return { client, transport };
}

async function expectToolCallError(client: Client, toolName: string, args: Record<string, unknown>): Promise<McpError> {
  try {
    await client.callTool({ name: toolName, arguments: args });
  } catch (error) {
    expect(error).toBeInstanceOf(McpError);
    return error as McpError;
  }
  throw new Error(`Expected calling "${toolName}" to be rejected with a JSON-RPC error, but it succeeded.`);
}


describe("Direct Microsoft Learn MCP server (baseline: nothing is blocked)", () => {
  let client: Client;
  let transport: StreamableHTTPClientTransport;

  beforeAll(async () => {
    ({ client, transport } = await connect(MSLEARN_MCP_DIRECT_BASE_URL));
  });

  afterAll(async () => {
    await transport.close();
  });

  it("exposes all three known Microsoft Learn MCP tools via tools/list", async () => {
    const { tools } = await client.listTools();
    const toolNames = tools.map((t) => t.name);

    expect(toolNames).toContain("microsoft_docs_search");
    expect(toolNames).toContain("microsoft_docs_fetch");
    expect(toolNames).toContain("microsoft_code_sample_search");
  });

  it("microsoft_docs_search succeeds when called directly", async () => {
    const result = await client.callTool({
      name: "microsoft_docs_search",
      arguments: { query: "Azure API Management MCP server" },
    });

    expect(result).toBeDefined();
    expect(result.isError).not.toBe(true);
  });

  it("microsoft_docs_fetch succeeds when called directly", async () => {
    const result = await client.callTool({
      name: "microsoft_docs_fetch",
      arguments: { url: "https://learn.microsoft.com/azure/api-management/mcp-server-overview" },
    });

    expect(result).toBeDefined();
    expect(result.isError).not.toBe(true);
  });

  it("microsoft_code_sample_search succeeds when called directly (i.e. it is NOT blocked upstream)", async () => {
    const result = await client.callTool({
      name: "microsoft_code_sample_search",
      arguments: { query: "azapi_resource example", language: "terraform" },
    });

    expect(result).toBeDefined();
    expect(result.isError).not.toBe(true);
  });
});


describe.skipIf(!MSLEARN_MCP_GATEKEPT_BASE_URL)("Gated APIM MCP gateway (Option A static allow-list policy)", () => {
  let client: Client;
  let transport: StreamableHTTPClientTransport;

  beforeAll(async () => {
    ({ client, transport } = await connect(MSLEARN_MCP_GATEKEPT_BASE_URL as string));
  });

  afterAll(async () => {
    await transport.close();
  });

  it("tools/list exposes only the allow-listed tools", async () => {
    const { tools } = await client.listTools();
    const toolNames = tools.map((t) => t.name);

    expect(toolNames).toContain("microsoft_docs_search");
    expect(toolNames).toContain("microsoft_docs_fetch");
    expect(toolNames).not.toContain("microsoft_code_sample_search");
  });

  it("microsoft_docs_search still works end-to-end through the gateway", async () => {
    const result = await client.callTool({
      name: "microsoft_docs_search",
      arguments: { query: "Azure API Management MCP server" },
    });

    expect(result).toBeDefined();
    expect(result.isError).not.toBe(true);
  });

  it("microsoft_docs_fetch still works end-to-end through the gateway", async () => {
    const result = await client.callTool({
      name: "microsoft_docs_fetch",
      arguments: { url: "https://learn.microsoft.com/azure/api-management/mcp-server-overview" },
    });

    expect(result).toBeDefined();
    expect(result.isError).not.toBe(true);
  });

  it("microsoft_code_sample_search is hard-blocked with a JSON-RPC 'method not found' error", async () => {
    const error = await expectToolCallError(client, "microsoft_code_sample_search", {
      query: "azapi_resource example",
      language: "terraform",
    });

    expect(error.code).toBe(-32601);
    expect(error.message).toContain("microsoft_code_sample_search");
  });
});

if (!MSLEARN_MCP_GATEKEPT_BASE_URL) {
  // eslint-disable-next-line no-console
  console.warn(
    "MSLEARN_MCP_GATEKEPT_BASE_URL is not set - skipping the gated-gateway describe block. " +
    "Set it to your APIM MCP server URL (see the header comment in this file) to run those tests.",
  );
}
