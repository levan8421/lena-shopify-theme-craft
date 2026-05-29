# CLAUDE.md — Lena Handicrafts Craft Theme

## What This Is

Shopify Craft theme (v15.4.1) customized for Lena Handicrafts — a one-of-a-kind handmade goods store. Based on the V2 prototype design (`docs/lena_prototype_v2.html`) which uses the brand's logo DNA: navy/blue/amber palette with rotated diamond motifs.

## Development

```bash
shopify theme dev          # Local preview (requires Shopify CLI + store connection)
shopify theme push --unpublished  # Push as unpublished theme for review
```

## Design System

**Fonts:** Josefin Sans (headings), Libre Franklin (body) — both from Shopify's font library

**Color Palette (V2 Prototype):**
- Navy: `#0E2240` (dark backgrounds, hero, spotlight, footer)
- Blue Deep: `#1B4F8A` (buttons, headings)
- Blue Bright: `#2E8FD9` (primary accent, CTAs, links)
- Blue Sky: `#5AAEE6` (gradient highlights)
- Amber: `#D4A853` / `#E8B867` (secondary accent, badge text, eyebrow text)
- Snow: `#FAFBFC` (default background)
- Ink: `#141A24` (footer background)

**Color Scheme Mapping:**
- scheme-1: Snow (default sections)
- scheme-2: White (alternate light sections)
- scheme-3: Amber (accent badges)
- scheme-4: Navy (hero, announcement bar, footer, spotlight)
- scheme-5: Navy-mid (newsletter)

**Key Motif:** Rotated diamond shapes (`.dm` class) — derived from the logo's diamond icons. Used as bullets, separators, decorative elements, and the artisan spotlight photo frame.

## Structure

- `config/settings_data.json` — Theme colors, fonts, card/badge settings
- `templates/index.json` — Homepage section stack (8 sections)
- `sections/header-group.json` — Announcement bar + header config
- `sections/footer-group.json` — Newsletter + footer config
- `snippets/card-product.liquid` — Product card (customized with 1-of-1 badges, scarcity text)
- `assets/lena-custom.css` — All visual overrides (~300 lines)
- `layout/theme.liquid` — Main layout (loads lena-custom.css)
- `docs/` — Research report, implementation plan, HTML prototypes

## Homepage Section Stack

1. **Hero** (`custom-liquid`) — Navy bg, mosaic grid, "One piece at a time. Yours alone."
2. **Trust Strip** (`custom-liquid`) — 3 diamond icons: Handmade / 1 of 1 / Women-Owned
3. **Drop Header** (`custom-liquid`) — "This Week's Drop" heading + countdown pill
4. **Product Grid** (`featured-collection`) — Points to "this-weeks-drop" collection
5. **Our Story** (`image-with-text`) — Founder photo + brand narrative
6. **Shop by Category** (`collection-list`) — 4 collection tiles
7. **Artisan Spotlight** (`custom-liquid`) — Navy bg, diamond photo frame
8. **Find Us** (`custom-liquid`) — 3 location cards (WPB, Delray, Fort Lauderdale)

## Product Card Customizations

- **"1 of 1" badge** — Always shown (top-left, navy bg + amber text)
- **"New" badge** — Products created within 7 days (top-right, blue gradient)
- **Scarcity text** — "Only piece in existence" below price
- **Sold-out overlay** — "This piece found its home" with translucent navy overlay
- **Category label** — Product type shown above title

## Competing Theme

Rise theme build at `/Users/vanhoanghai/projects/lena-shopify_theme/` on `website-redesign` branch. User will compare both before deciding which to deploy.

## Collections Required in Shopify Admin

These collections must exist for the homepage to fully work:
- `this-weeks-drop` — Automated, products tagged `drop-current`
- `crochet-figures` — By product type
- `compact-mirrors` — By product type
- `hats-headbands` — By product type
- `signature-purses` — By product type
