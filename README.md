# lean-llm-starter

A deterministic Lean 4 verification harness that treats the LLM as an untrusted proposal engine and Lean 4 as the trusted kernel.

## Architecture

```text
operator intent
  -> Prolog gate
  -> Granite 4.1 / Llemma inference
  -> schema validation
  -> Lean 4 parse / verify
  -> WORM-ready audit artifacts
```

Trust split:

- `inference/` proposes proof artifacts
- `logic/` blocks unauthorized or malformed runs
- `lean4/` type-checks and verifies
- `infra/verification-loop/` pins deterministic execution
- `eval/` runs reproducible local benchmarks

## Repo Layout

```text
lean-llm-starter/
├── .github/workflows/ci.yml
├── .gitattributes
├── .gitignore
├── LICENSE
├── Makefile
├── README.md
├── docker-compose.yml
├── docs/
│   ├── HUGGINGFACE_PUBLISHING.md
│   └── REPO_MAP.md
├── eval/
│   ├── requirements.txt
│   └── run_minif2f.py
├── fixtures/
│   └── sample_input.jsonl
├── inference/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── prompt.txt
│   └── server.py
├── infra/
│   └── verification-loop/
│       ├── .env.example
│       └── docker-compose.yml
├── lean4/
│   ├── lakefile.toml
│   ├── lean-toolchain
│   ├── MiniF2F.lean
│   ├── VerifyMain.lean
│   └── src/
│       └── SovereignCorpus/
│           ├── Bridge/
│           │   ├── Granite4Parser.lean
│           │   └── Granite4Schema.lean
│           ├── Core.lean
│           └── Tactics/
│               └── PlasmaGate.lean
├── logic/
│   ├── sovereign_verification.pl
│   └── verification_loop.pl
└── hf/
    └── README.md
```

## What This Starter Includes

- Lean 4 harness skeleton
- Granite 4.1 JSON interchange schema
- Lean-side parser scaffold
- Prolog gate and retry loop scaffold
- vLLM / docker compose verification loop
- MiniF2F-style eval harness
- GitHub Actions CI scaffold
- Hugging Face publishing docs and model card template
- sample JSONL parse fixture

## What It Does Not Pretend Yet

- not fully air-gapped out of the box
- not fully air-gapped out of the box
- not a finished proof search system
- not yet shipping weights

Current verified state:

- Lean 4 project builds successfully on this machine with `C:\Users\jessi\.elan\bin\lake.exe`
- Python eval and inference files compile
- parse-mode fixture is present

This is a scaffold you can harden into:

- a GitHub repo
- a Hugging Face model or Space companion repo
- a deterministic local verification loop

## Quick Start

If `lake` is not on your PATH on Windows, use:

```powershell
C:\Users\jessi\.elan\bin\lake.exe
```

### 1. Lean side

```bash
cd lean4
C:\Users\jessi\.elan\bin\lake.exe update
C:\Users\jessi\.elan\bin\lake.exe build
```

### 2. Inference side

```bash
cd inference
docker build -t lean-llm-inference .
docker run -d -p 8080:8080 --name lean-llm-inference lean-llm-inference
```

### 3. Eval side

```bash
cd eval
pip install -r requirements.txt
python run_minif2f.py
```

### 4. Full verification loop

```bash
docker compose --env-file infra/verification-loop/.env.example up -d granite-verifier
swipl -g "verify_with_retries('theorem demo : True := by trivial', 'ED25519_SIG', 3, Result), writeln(Result), halt" logic/verification_loop.pl
```

### 5. Shortcut targets

```bash
make lean-build
make infra-up
make eval
```

### 6. Parse smoke test

```bash
cd lean4
C:\Users\jessi\.elan\bin\lake.exe exe verify -- --parse ../fixtures/sample_input.jsonl
```

## Hugging Face Readiness

This repo is prepared for later Hugging Face publication with:

- `.gitattributes` for LFS-managed weight files
- `hf/README.md` model card template
- `docs/HUGGINGFACE_PUBLISHING.md` publish checklist

Recommended publish modes:

1. code-only harness repo
2. model repo for GGUF / safetensors
3. Space repo for interactive verify loop UI
