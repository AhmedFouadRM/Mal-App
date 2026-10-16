# Mal · مال — Round 6

Palette: emerald #047857 / #059669, mint #6EE7B7, #A7F3D0 glow, ink #0B1A13. Icons: emerald gradient field (#059669 to #047857), glyph in a pale-mint gradient (#ECFDF5 to #A7F3D0) with a flat #6EE7B7 coin accent. Two gradient pairs per icon. Glyphs sit in the 21..87 safe zone; cut-outs use SVG masks so fg/mono do not depend on the background.

Per concept X: `icon_X_full|fg|bg|mono|notif.svg`. Open `review.html` (self-contained, SVGs embedded as data URIs).

## Icon concepts
| | Metaphor | Principle risk |
|---|---|---|
| A | Wallet with a coin peeking out (gap-cut so it reads in mono) | Wallets are a common finance cue; the clasp dot is the smallest detail (about 2.5 px at 24 px) |
| B | Coin dropping onto a deposit slot (engraved ring coin over a pill slot) | Most abstract: two plain shapes, can read as a target/radio dot or "upload"; weakest "money" cue |
| C | Sprout growing from a coin | "Growth" can imply investing (the app is a tracker); leaf gaps are tight at 24 px; reads as a plant/eco app |
| D | Shield with a keyhole (round head echoes a coin) | Reads as security/VPN, the money cue is weakest; strongest silhouette at 24 px |

## Wordmarks (`wordmark_T_ar|en.svg`, T = 1..3)
1. Plain emerald #047857.
2. Emerald + small brand-coin accent (emerald coin, mint ring) at the start of the word (left in EN, right in AR).
3. Mint (#6EE7B7) to emerald gradient; the mint end is low contrast on light backgrounds.

Text is live `<text>` with the stack Thmanyah Sans / IBM Plex Sans Arabic / Noto Kufi Arabic (or Inter / Segoe UI for English), weight 700, same colour in both languages. Final art must be outlined from Thmanyah (fonts are gitignored, so do not commit them); the preview here uses whatever fallback font the viewer has, so letter spacing and the coin offset in treatment 2 will need re-tuning after outlining.

## Recommendation
Icon A (wallet + coin). It is the only concept whose metaphor says "my money, kept on my phone" immediately, it keeps the coin from the old brand, and the coin/wallet split gives depth without detail; it stays recognisable at 48 px and in the mono and notification versions. C is the best alternate if a more distinctive, friendlier silhouette is wanted; D is the safest at tiny sizes but least about money.
Wordmark: treatment 1 (plain emerald) as the primary lockup, since it works equally for Arabic and English and on light and dark; treatment 2 is a good secondary for the feature graphic once outlined (use the coin as a standalone mark).
