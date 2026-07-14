# Repo Map

## lean4/

Trusted verification kernel.

- `VerifyMain.lean` entrypoint
- `MiniF2F.lean` local benchmark corpus
- `src/SovereignCorpus/Bridge/` Granite interchange types and parser
- `src/SovereignCorpus/Tactics/` verification tactic stubs

## inference/

Untrusted proposal engine.

- `Dockerfile` for local inference runtime
- `server.py` compatibility wrapper
- `prompt.txt` deterministic prompt contract

## logic/

Prolog guardrail layer.

- schema checks
- authorization checks
- retry loop orchestration

## infra/verification-loop/

Deterministic container topology.

- `docker-compose.yml`
- `.env.example`

## eval/

Batch benchmark harness.

## hf/

Hugging Face-facing model card and publication surface.
