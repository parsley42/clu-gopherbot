# Clu AI vNext Plan

This document captures the implementation slices for migrating Clu's AI catchall from Ruby to external Go/yaegi.

## Goals

- Preserve existing catchall semantics:
  - Full-name/direct unmatched messages go to AI.
  - Alias-mode unmatched commands keep fallback/help behavior.
- Preserve multi-user threaded conversation behavior.
- Add queue-aware busy handling and streaming paragraph output.
- Remove runtime dependency on Ruby/openai gem for primary AI plugin.

## Slice Plan

1. Slice 1: Scaffold external Go AI plugin and switch plugin path.
2. Slice 2: Conversation state model and per-conversation serialization via `Exclusive(tag, true)`.
3. Slice 3: OpenAI SSE streaming with paragraph-chunk output and trailing ` (...)` for non-final chunks.
4. Slice 4: UX controls and hardening (`status`, `close`, `debug`, busy acknowledgements, token/context handling).
5. Slice 5: Verification with gopherbot-mcp (including multi-user simulation), docs updates, and invariants check.

## Concurrency Stance

No plugin goroutines are required for the core flow. The plugin can run a synchronous stream loop per invocation while engine-level pipeline concurrency is serialized per conversation via `Exclusive`.

## Rollback

Rollback is straightforward by restoring `ExternalPlugins.ai.Path` in `conf/robot.yaml` back to `plugins/ai.rb`.
