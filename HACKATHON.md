# Nebius x NVIDIA Global AI Hackathon — Physical AI

Submission period: 26 Aug 2026 – 30 Oct 2026, 10:00 AM PT.
Track: Physical AI.

## Built with

- Nebius Token Factory (`https://api.tokenfactory.nebius.com/v1`)
- NVIDIA Nemotron 3.5 Lightning (`nvidia/Nemotron-3_5-Lightning`)
- WHOOP 5.0 MG over BLE (edge sensor, no WHOOP cloud)
- iPhone as the collector and actuator (`WhoopBleClient.buzz`)

## What the rules require, and how this repo meets them

| Gate | This project |
| --- | --- |
| Runtime Token Factory call or AI Cloud compute | Phone and `cloud/narrate.py` call Token Factory chat completions. |
| NVIDIA open-source model | `nvidia/Nemotron-3_5-Lightning` |
| Sense and act on real hardware | WHOOP IMU in; strap buzz out when the model returns `action: buzz`. |
| Public repo + OSS license at the top of the page | MIT `LICENSE` |
| README names Token Factory and Nemotron | This repo's README |
| Video ≥ 1 min of hardware | Film Max wearing the strap. Not in this commit. |

A hosted web demo is not required for Physical AI.

## What existed before the Submission Period

Max Werba / Dog-VV00P3 was already a SwiftUI WHOOP diary: local BLE, sqlite seconds, rest / movement / strain rings. Day notes went through OpenRouter (`upstage/solar-mini4`). That path is gone in this repo.

## What changed during the Submission Period

- New public tree `max-werba` (GitHub will not fork a repo into the same account).
- Inference moved to Nebius Token Factory and NVIDIA Nemotron 3.5 Lightning.
- Nemotron returns a structured `action`. `buzz` vibrates the strap.
- `cloud/narrate.py` is a one-file Token Factory proof that does not need the NPA monorepo.

## Keys

Token Factory and AI Cloud are different products. The phone only needs a Token Factory key in `App/TokenFactory.plist` (gitignored). An AI Cloud key is for a later Serverless Job; it does not go in the iOS app.
