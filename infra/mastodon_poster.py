#!/usr/bin/env python3
"""
mastodon_poster.py — fires a toot to mathstodon.xyz when Lean kernel
returns result(0, verified). Called by verification_loop.pl via shell/2
or directly from the eval pipeline.

Usage:
    python mastodon_poster.py --problem-id <id> --theorem <stmt> --worm <seal>

Env:
    MASTODON_BASE_URL     https://mathstodon.xyz
    MASTODON_ACCESS_TOKEN your token (from .env, never committed)
"""
import argparse
import os
import sys
import urllib.parse
import urllib.request


def post_toot(base_url: str, token: str, status: str) -> dict:
    url = f"{base_url}/api/v1/statuses"
    data = urllib.parse.urlencode({"status": status}).encode()
    req = urllib.request.Request(
        url,
        data=data,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/x-www-form-urlencoded",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        import json
        return json.loads(resp.read())


def build_status(problem_id: str, theorem: str, worm_seal: str) -> str:
    lines = [
        f"✅ VERIFIED — {problem_id}",
        f"",
        f"Theorem: {theorem[:200]}{'…' if len(theorem) > 200 else ''}",
        f"",
        f"Kernel: Lean 4 · zero sorry · WORM sealed",
        f"Seal: {worm_seal[:16]}…" if worm_seal else "",
        f"",
        f"#Lean4 #FormalMath #SnapKitty",
    ]
    return "\n".join(l for l in lines if l is not None)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--problem-id", required=True)
    parser.add_argument("--theorem", required=True)
    parser.add_argument("--worm", default="")
    args = parser.parse_args()

    base_url = os.environ.get("MASTODON_BASE_URL", "https://mathstodon.xyz").rstrip("/")
    token = os.environ.get("MASTODON_ACCESS_TOKEN", "")

    if not token:
        print("error: MASTODON_ACCESS_TOKEN not set", file=sys.stderr)
        sys.exit(1)

    status = build_status(args.problem_id, args.theorem, args.worm)

    try:
        result = post_toot(base_url, token, status)
        print(f"posted: {result.get('url', 'ok')}")
    except Exception as e:
        print(f"post_error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
