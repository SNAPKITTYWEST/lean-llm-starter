.PHONY: lean-build parse-only inference-up infra-up eval

LEAN_LAKE := C:\Users\jessi\.elan\bin\lake.exe

lean-build:
	cd lean4 && "$(LEAN_LAKE)" build

parse-only:
	cd lean4 && "$(LEAN_LAKE)" exe verify -- --parse ../fixtures/sample_input.jsonl

inference-up:
	docker build -t lean-llm-inference ./inference
	docker run -d -p 8080:8080 --name lean-llm-inference lean-llm-inference

infra-up:
	docker compose --env-file ./infra/verification-loop/.env.example up -d granite-verifier

eval:
	cd eval && python run_minif2f.py
