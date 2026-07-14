# Hugging Face Publishing

## Recommended Split

### Option 1: Code Repo Only

Publish this repository as the harness source and keep weights elsewhere.

Best for:

- auditability
- open-source orchestration
- reproducible local verification loops

### Option 2: Separate Model Repo

Store GGUF or safetensors weights in a dedicated Hugging Face model repository.

Best for:

- large artifacts
- cleaner LFS separation
- versioned checkpoints

### Option 3: Space Repo

Use a Hugging Face Space for interactive theorem verification demos.

Best for:

- operator-facing UI
- public demos
- benchmark explorer

## Pre-Publish Checklist

- replace placeholder model IDs
- pin Docker image tags and Lean toolchain versions
- confirm license for model weights
- add real benchmark metadata
- scrub local absolute paths
- add reproducible example commands
- decide whether to publish Granite, Llemma, or both as supported backends

## Files Already Added For HF Readiness

- `.gitattributes`
- `hf/README.md`
- code/infra split suitable for model companion repos
