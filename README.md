# Max Werba

Physical AI movement diary for one English bulldog and one WHOOP 5.0 MG strap. The phone app is the edge collector. The brain is **NVIDIA Nemotron 3.5 Lightning** on **Nebius Token Factory**. The strap stays on the dog. There is no WHOOP account and no cloud sync.

Sense: IMU seconds over Bluetooth. Think: Token Factory `nvidia/Nemotron-3_5-Lightning`. Act: the model returns `rest`, `continue`, or `buzz`; `buzz` vibrates the strap so Max comes in to rest.

Today shows three labeled circles: Rest out of 12 hours, Movement out of a 3 mile day, and Strain out of 21. Export writes a one-page dark PDF. The bone at the top left, while he is resting, opens a short chat about today's distance.

## Hackathon

Built for the [Nebius x NVIDIA Global AI Hackathon](https://nebiusglobalaihackathon.devpost.com/) Physical AI track. License is MIT (this file's sibling `LICENSE`). What changed during the Submission Period is in `HACKATHON.md`.

## Token Factory key

Copy the example, then put your real key in the gitignored file. Do not commit it.

```
cp App/TokenFactory.example.plist App/TokenFactory.plist
# paste the Token Factory key (from https://tokenfactory.nebius.com/) into APIKey
```

The same key works from a Mac:

```
cp cloud/.env.example cloud/.env
# paste NEBIUS_TOKEN_FACTORY_KEY
python3 cloud/narrate.py
```

AI Cloud credentials are separate from Token Factory. They are not used by the iPhone binary.

## Build

Open `VV00P.xcodeproj` in Xcode. The app target is VV00P, bundle id `com.jaredwerba.vv00p`.

WhoopBLE is a local Swift package:

```
../src/Asherlc__whoop-ble-swift
```

Clone [jaredwerba/Asherlc__whoop-ble-swift](https://github.com/jaredwerba/Asherlc__whoop-ble-swift) at that path before building. The diary calls `WhoopBleClient.buzz(seconds:)`.

The screen font is John Sauter's OCR-A (public domain, SourceForge project `ocr-a-font`), in `App/Fonts`.

`swift run pace-check` runs the motion and history checks.
