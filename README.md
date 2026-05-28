# aareGuru

DankMaterialShell plugin showing live Aare river conditions in the bar.

Data source: [aareguru.existenz.ch](https://aareguru.existenz.ch) — refreshed every 5 minutes.

## Bar pill

Shows current water temperature and flow rate:

```
⋅ 16.3°C  (196.0 m³/s)
```

Click the pill to open a popout with full details:

- Location name
- Temperature and flow
- Temperature description (e.g. "Aqua Incognita / Ender früsch")
- Flow description (e.g. "ganz gäbig")
- 2h forecast temperature and description

## Installation

```bash
git clone https://github.com/paulhaider/dms-aare \
  ~/.config/DankMaterialShell/plugins/aareGuru
dms restart
```

Then: Settings → Plugins → Scan for Plugins → enable **aareGuru** → add to DankBar layout.

## Requirements

- DankMaterialShell >= 1.4.0
- Network access to `aareguru.existenz.ch`
