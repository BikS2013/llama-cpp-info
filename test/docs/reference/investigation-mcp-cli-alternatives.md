# Investigation: CLI Tools for MCP Substitution

## Overview

This investigation explores CLI tools and command-line approaches that can substitute for the Serena LSP MCP tool, focusing on alternatives that provide Model Context Protocol (MCP) functionality through command-line interfaces.

## Investigation Request

**What CLI tools or command-line approaches can substitute for the Serena LSP MCP tool?**

Specifically, we need to understand:
1. What functionality does Serena LSP MCP provide
2. What are the alternative CLI tools that can provide similar MCP functionality
3. How do these CLI tools compare in terms of features, compatibility, and ease of use
4. Are there any direct command-line replacements that can work without needing a running LSP server

## Investigation Findings

### Understanding Serena LSP MCP

The Serena LSP MCP tool is a Language Server Protocol implementation that provides Model Context Protocol (MCP) capabilities. It allows LLMs and other clients to interact with tools and external systems through a standardized protocol. The tool typically runs as a long-lived process that communicate via stdio or HTTP.

### Alternative CLI Approaches

#### 1. **mcp-cli** (Direct MCP Client)
A dedicated command-line interface for direct MCP server communication.

**Key Features:**
- Command-line interface for invoking MCP tools
- Supports both stdio and SSE transport protocols
- Designed for scripting and CI/CD pipeline usage
- Can be installed globally or run via uvx/npx

**Usage Pattern:**
```bash
mcp-cli invoke <tool-name> --arg1=value --arg2=value
```

**Transport:** stdio, SSE, HTTP
**Persistence:** One-shot or connection-based
**Best For:** Scripting, CI/CD, automation

#### 2. **@modelcontextprotocol/inspector**
An MCP protocol inspector and debugging tool that can also invoke tools directly.

**Key Features:**
- Interactive inspection of available MCP tools
- Direct tool invocation from command line
- Protocol-level debugging capabilities
- Useful for testing and development

**Usage Pattern:**
```bash
npx @modelcontextprotocol/inspector
# or for direct invocation
npx @modelcontextprotocol/inspector invoke <tool-name> <arguments>
```

**Transport:** HTTP
**Persistence:** Interactive session
**Best For:** Debugging, testing, development

#### 3. **Direct stdio-based MCP servers**
Many MCP servers support direct stdio transport, allowing them to be invoked like CLI tools.

**Key Features:**
- Native stdio support in many MCP server implementations
- Can be wrapped in shell scripts for CLI-like usage
- No additional proxy process required
- Direct integration with existing tooling

**Usage Pattern:**
```bash
node server.js --stdio
# or
uvx @modelcontextprotocol/server-{github,google,slack} --stdio
```

**Transport:** stdio
**Persistence:** Long-running process
**Best For:** Integration, development workflows

#### 4. **Custom Bash/zsh wrappers**
Shell functions that invoke HTTP endpoints of MCP servers.

**Key Features:**
- Simple to create and customize
- Can be added to shell profiles
- No additional dependencies
- Lightweight solution

**Usage Pattern:**
```bash
# In .zshrc or .bashrc
mcp-tool-name() {
  curl -X POST http://localhost:3000/tools/invoke \
    -H "Content-Type: application/json" \
    -d "{\"tool\": \"$1\", \"arguments\": $2}"
}
```

**Transport:** HTTP
**Persistence:** Short-lived per invocation
**Best For:** Quick automation, ad-hoc tasks

#### 5. **uvx-based invocation**
Using `uvx` to run MCP tools on-demand without installation.

**Key Features:**
- Isolated, version-pinned execution
- No global installation required
- Fast startup via uv's Python package manager
- Automatic dependency management

**Usage Pattern:**
```bash
uvx @modelcontextprotocol/server-github
uvx @modelcontextprotocol/server-google
```

**Transport:** Any (server-specific)
**Persistence:** On-demand
**Best For:** Isolated execution, CI/CD

### Comparison Summary

| Tool | Transport | Persistence | Best For |
|------|-----------|-------------|----------|
| mcp-cli | stdio/SSE | One-shot | Scripting, CI/CD |
| MCP Inspector | HTTP | Interactive | Debugging, testing |
| Direct stdio servers | stdio | Long-running | Integration, dev |
| Bash wrappers | HTTP | Short-lived | Quick automation |
| uvx-based | Any | On-demand | Isolated execution |

## Recommendation

**Research needed**: Yes

To make a final recommendation for your specific use case, we need to understand:

1. **How are you currently using Serena LSP MCP?** (e.g., in scripts, in an IDE, as part of an LLM workflow)
2. **What specific features are you relying on?** (e.g., tool calling, context retrieval, state management)
3. **What environment are you working in?** (e.g., local development, CI/CD, containerized)

### Potential Next Steps

1. **For scripting/CI/CD use**: Consider `mcp-cli` or direct stdio servers wrapped in shell scripts
2. **For development/debugging**: Use `@modelcontextprotocol/inspector`
3. **For integration with existing tooling**: Direct stdio servers or custom bash wrappers
4. **For isolated execution**: `uvx`-based approach

## Context and References

- Model Context Protocol: https://modelcontextprotocol.io/
- MCP GitHub repository: https://github.com/modelcontextprotocol
- Serena LSP documentation (if available)

**Limitation**: This investigation was conducted without external web lookup capabilities. For the most up-to-date information on specific tool versions and features, additional web research is recommended.

## Open Questions

1. What specific functionality does Serena LSP MCP provide in your workflow that needs to be substituted?
2. Are you looking for a drop-in replacement or a different approach to achieve the same end goal?
3. What is your preferred environment and toolchain (Node.js, Python, shell scripting)?