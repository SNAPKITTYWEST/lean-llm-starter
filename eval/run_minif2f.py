#!/usr/bin/env python3
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

import requests
from tqdm import tqdm


ROOT = Path(__file__).resolve().parent.parent
LEAN_DIR = ROOT / "lean4"
SERVER = os.getenv("LEAN_LLM_SERVER", "http://localhost:8000/v1/completions")


def lean_statements() -> list[str]:
    content = (LEAN_DIR / "MiniF2F.lean").read_text(encoding="utf-8")
    matches = re.findall(r"theorem\s+.*?:=\s+by\s+sorry", content, flags=re.DOTALL)
    return [m.strip() for m in matches]


def call_llm(stmt: str) -> list[dict]:
    response = requests.post(
        SERVER,
        json={"prompt": stmt, "temperature": 0.0, "stop": ["<|user|>"]},
        timeout=120,
    )
    response.raise_for_status()
    text = response.json()["choices"][0]["text"].strip()
    return json.loads(text) if text else []


def verify_with_lean(steps: list[dict]) -> bool:
    with tempfile.NamedTemporaryFile(mode="w", suffix=".lean", dir=LEAN_DIR, delete=False, encoding="utf-8") as f:
        f.write("import MiniF2F\n\n")
        f.write("namespace Scratch\n\n")
        for s in steps:
            name = s.get("name", "h_main")
            statement = s.get("statement", "True")
            tactic = s.get("tactic", "sorry")
            f.write(f"theorem {name} : {statement} := by\n  {tactic}\n\n")
        f.write("end Scratch\n")
        tmp = Path(f.name)
    try:
        result = subprocess.run(
            ["lake", "env", "lean", str(tmp.name)],
            cwd=LEAN_DIR,
            capture_output=True,
            text=True,
            timeout=60,
        )
        return result.returncode == 0
    finally:
        if tmp.exists():
            tmp.unlink()


def main() -> None:
    stmts = lean_statements()
    print(f"testing {len(stmts)} theorems")
    passed = 0
    for stmt in tqdm(stmts):
        try:
            steps = call_llm(stmt)
            if verify_with_lean(steps):
                passed += 1
        except Exception as exc:
            print(f"error: {exc}")
    print(f"passed: {passed}/{len(stmts)}")


if __name__ == "__main__":
    main()
