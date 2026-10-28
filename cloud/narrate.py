#!/usr/bin/env python3
"""One Token Factory Nemotron call for a Max Werba day note.

Reads NEBIUS_TOKEN_FACTORY_KEY from the environment or cloud/.env.
Does not call OpenRouter. Does not need the NPA monorepo.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_BASE = "https://api.tokenfactory.nebius.com/v1"
DEFAULT_MODEL = "nvidia/Nemotron-3_5-Lightning"
SYSTEM = (
    'Reply with JSON only, no markdown: '
    '{"summary":"","dinnerName":"","ingredients":[],"steps":[],"action":"continue"}. '
    "Summary is one short sentence: today's distance target and strain target. "
    "action is rest, continue, or buzz. buzz means the strap should vibrate so "
    "the dog comes in to rest."
)


def load_env() -> None:
    path = ROOT / ".env"
    if not path.is_file():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def main() -> int:
    load_env()
    key = os.environ.get("NEBIUS_TOKEN_FACTORY_KEY", "").strip()
    if len(key) < 20:
        print("missing NEBIUS_TOKEN_FACTORY_KEY", file=sys.stderr)
        return 2
    base = os.environ.get("NEBIUS_TOKEN_FACTORY_BASE_URL", DEFAULT_BASE).rstrip("/")
    model = os.environ.get("NEMOTRON_MODEL", DEFAULT_MODEL)
    prompt = sys.stdin.read().strip() or (
        "Dog: Max, male English bulldog. Today: 0.8 miles, 4h resting, 20m moving. "
        "Strain 6.0 of 21. Yesterday was easy. Week is light. Write today's targets."
    )
    body = {
        "model": model,
        "temperature": 0.3,
        "max_tokens": 500,
        "chat_template_kwargs": {"enable_thinking": False},
        "messages": [
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": prompt},
        ],
    }
    request = urllib.request.Request(
        f"{base}/chat/completions",
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            payload = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        print(f"token factory {exc.code}: {detail}", file=sys.stderr)
        return 1
    message = payload["choices"][0]["message"]
    text = message.get("content") or ""
    print(text)
    print("---", file=sys.stderr)
    print(
        json.dumps({"model": payload.get("model", model), "id": payload.get("id")}, sort_keys=True),
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
