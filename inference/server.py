from fastapi import FastAPI
from pydantic import BaseModel
import os
import requests


app = FastAPI(title="lean-llm-starter inference wrapper")
LLAMA_URL = os.getenv("LLAMA_URL", "http://localhost:8080")
PROMPT_PATH = os.getenv("PROMPT_PATH", "prompt.txt")


class CompletionRequest(BaseModel):
    prompt: str
    max_tokens: int = 1024
    temperature: float = 0.0
    stop: list[str] = ["<|user|>"]


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/v1/completions")
def complete(req: CompletionRequest) -> dict:
    template = open(PROMPT_PATH, encoding="utf-8").read()
    prompt = template.replace("{{THEOREM_STATEMENT}}", req.prompt)
    response = requests.post(
        f"{LLAMA_URL}/completion",
        json={
            "prompt": prompt,
            "n_predict": req.max_tokens,
            "temperature": req.temperature,
            "stop": req.stop,
        },
        timeout=120,
    )
    response.raise_for_status()
    payload = response.json()
    return {"choices": [{"text": payload.get("content", "")}]}
