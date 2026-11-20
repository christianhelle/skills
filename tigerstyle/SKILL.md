---
name: tigerstyle
description: Applies TigerStyle principles to software design, implementation, refactoring, and review. Use when explicitly asked for "tiger style", "tigerstyle", "use tigerstyle", or "implement using tiger style".
---

# TigerStyle

Apply the principles of [TigerBeetle's TigerStyle](https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md), prioritizing safety, performance, and developer experience, in that order. Adapt them to the language, framework, and project rather than treating TigerBeetle's operational constraints as universal.

## Workflow

1. Understand the task, existing conventions, and expected behavior. Identify failure modes, resource limits, and relevant invariants before changing the design or code.
2. Choose a simple design that makes control flow, resource usage, and error handling explicit. Consider performance early, especially for costly or frequently used operations.
3. Implement or review against the principles below. For reviews, report actionable deviations and their consequences rather than modifying code unless asked.
4. Verify behavior at boundaries, including invalid input and failure paths, with focused tests and the project's existing tools. Explain meaningful exceptions or conflicts with TigerStyle.

## Safety

- Keep control flow straightforward and abstractions justified. Bound loops, queues, input sizes, retries, and other work where appropriate; document intentionally long-running loops and their termination or shutdown behavior.
- Validate external inputs and handle expected operational errors explicitly. Use assertions for programmer errors and internal preconditions, postconditions, and invariants, not as a substitute for input validation or error handling.
- Check important invariants at meaningful boundaries, including both valid and invalid cases. Where useful, check the same property independently at both producer and consumer boundaries.
- Minimize variable scope and mutable state. Make ownership, allocation, and cleanup clear; use fixed-size types and explicit units where they matter.
- Test boundary conditions, invalid data, and error paths as well as successful cases. Enable the project's available compiler and lint checks.

## Performance

- Consider network, disk, memory, and CPU costs, including latency, bandwidth, and frequency. Make rough estimates when they can influence the design; measure where practical before optimizing.
- Reduce expensive operations and batch work when appropriate without compromising correctness, latency requirements, or resource bounds.
- Make hot paths predictable and avoid unnecessary allocations or copies when evidence and context justify it. Prefer simple designs over speculative optimization.

## Developer experience

- Use descriptive, domain-specific names and include units or qualifiers where ambiguity matters. Follow the language and repository's naming and formatting conventions.
- Keep functions focused and readable, use small scopes, and make important behavior and options explicit when defaults could obscure intent or change behavior.
- Explain the rationale behind non-obvious decisions and tradeoffs. Prefer a small set of useful dependencies and abstractions over unnecessary complexity.

## Applying the rules in context

TigerBeetle's stricter choices include no recursion, no allocations after initialization, an average of two assertions per function, 70-line functions, 100-column lines, Zig naming, and minimal dependencies. Treat these as design prompts, not universal mandates. Preserve required behavior and established project conventions; explain material departures and their safety or performance implications.

For example, when processing a user-supplied batch, validate its size and return an ordinary error if it exceeds the supported limit; assert internal invariants after validation, and test empty, maximum-size, and oversized batches.
