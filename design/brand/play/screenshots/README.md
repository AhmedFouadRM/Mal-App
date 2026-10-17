# Play Store phone screenshots

1080 × 1920 (9:16), 24-bit PNG with no alpha. Upload them in file order: `en/` to the en-US listing, `ar/` to the ar listing.

The source is the Figma board **Mal · Play Store screenshots** on page *11 · Brand & Release*.
Both languages show the same six screens in the same order, alternating light and dark.
Each shot holds a live clone of the app screen at 2×, with the Color variable mode set to the shot's theme. The canvas comes from the `Play / Background` component (Theme=Light / Dark).

| # | Theme | Screen | English | Arabic |
|---|---|---|---|---|
| 1 | Light | Transactions (wallet Me) | Your money, clearly. | فلوسك، بوضوح |
| 2 | Dark | Analytics (all wallets) | See where it all goes | اعرف أين تذهب فلوسك |
| 3 | Light | Budgets | Budgets that warn you early | ميزانيات تنبهك مبكرًا |
| 4 | Dark | Add from SMS | Bank SMS become transactions | رسائل البنك تصبح معاملات |
| 5 | Light | Recurring expenses | Bills that log themselves | فواتير تُسجَّل وحدها |
| 6 | Dark | Lock screen | Private, and fully offline | خاص ويعمل دون إنترنت |

## Arabic copy

Figma's cloud runtime can't use locally installed fonts, so the Arabic headlines and sublines are Thmanyah Sans outlines. The brand slogan is made the same way.
To change a line, edit `source/ar_copy.json` and run the script below. It needs `uharfbuzz` and `fontTools`, plus Thmanyah Sans installed in `C:/Windows/Fonts`. Then upload the SVGs to Figma and swap them into the shot's `copy` frame.

```bash
python source/outline_ar.py source/ar_copy.json ar_svgs.json
```

Headlines are Bold 80/112 and sublines Regular 40/60. They are right-aligned in an 888 px box. The colours are #064E3B / #3E5A4D on light and #ECFDF5 / #8FD1B9 on dark.
