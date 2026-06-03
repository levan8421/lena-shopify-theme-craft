# CLAUDE.md — Lena Handicrafts Craft Theme

Shopify Craft theme (v15.4.1) for Lena Handicrafts — one-of-a-kind handmade goods. Navy/blue/amber palette with diamond motifs derived from logo DNA. For full architecture details, see `ARCHITECTURE.md`.

## Dev Commands

```bash
shopify theme dev                  # Local preview
shopify theme push --unpublished   # Push for review
```

## Custom vs Stock Files

### Lena-created (safe to edit freely)

| File | Lines | Purpose |
|------|-------|---------|
| `sections/lena-hero.liquid` | 170 | Hero with mosaic image grid, dual CTAs |
| `sections/lena-drop-header.liquid` | 117 | Drop header — adapts heading/CTA based on collection product count |
| `sections/lena-drop-coming-soon.liquid` | 98 | Empty-state "coming soon" for drop collection page |
| `sections/lena-spotlight.liquid` | 174 | Blog-powered artisan rotation (1/2/4 week cycle) |
| `sections/lena-find-us.liquid` | 240 | Location cards + metaobject scheduled events |
| `assets/lena-custom.css` | 846 | All custom styles (16 sections, 70+ classes) |

### Modified stock files (edit ONLY the marked ranges)

| File | Lena lines | What was added |
|------|-----------|----------------|
| `sections/main-product.liquid` | 101–139 | PDP: category eyebrow, 1-of-1 badge, artisan line, scarcity/sold msg |
| `sections/main-collection-banner.liquid` | 14–33 | Collection: diamond eyebrow, title class, product count pill |
| `sections/featured-collection.liquid` | 67, ~215 | Conditional wrapper: hides section when linked collection is empty |
| `snippets/card-product.liquid` | 108–122, 164–167, 228–237 | Cards: badges, sold overlay, category label, scarcity/notify |

### Comment convention

All Lena changes in stock files are marked: `{%- comment -%} Lena: <description> {%- endcomment -%}`. Grep for `Lena:` to find every custom insertion.

### Load point

`layout/theme.liquid` line 259 loads `lena-custom.css` after `base.css`.

## Homepage Section Stack (`templates/index.json`)

| # | Section | Type | Notes |
|---|---------|------|-------|
| 1 | Hero | `lena-hero` | Navy bg, mosaic grid, "One piece at a time" |
| 2 | Trust Strip | `custom-liquid` | Scrolling diamond marquee (inline HTML, not a section file) |
| 3 | Drop Header | `lena-drop-header` | Adaptive: "This Week's Drop" or "Coming Soon" + countdown |
| 4 | Product Grid | `featured-collection` | Collection: `new-arrivals`, 4 columns. Hidden when empty. |
| 5 | Our Story | `image-with-text` | Founder photo + brand narrative |
| 6 | The Gallery | `collection-list` | 5 collection tiles |
| 7 | Artisan Spotlight | `lena-spotlight` | Requires "Artisan Stories" blog |
| 8 | Q&A | `collapsible-content` | 6 accordion items (handmade, artisans, design, in-person, photo, returns) |
| 9 | Find Us | `lena-find-us` | Uses `scheduled_event` metaobjects |

**Note:** Trust Strip is custom-liquid HTML inside `templates/index.json`, NOT a standalone section file.

### Custom Collection Templates

| Template | Collection | Purpose |
|----------|-----------|---------|
| `templates/collection.this-weeks-drop.json` | `this-weeks-drop` | Banner + coming-soon section (when empty) + product grid. Requires manual template assignment in Shopify Admin. |

## Color Schemes

| ID | Background | Usage |
|----|-----------|-------|
| scheme-1 | Snow `#FAFBFC` | Default sections |
| scheme-2 | White `#FFFFFF` | Alternate light |
| scheme-3 | Amber `#D4A853` | Accent badges |
| scheme-4 | Navy `#0E2240` | Hero, announcement, spotlight |
| scheme-5 | Navy-mid `#132E52` | Newsletter |

## Design System

- **Fonts:** Josefin Sans (headings) + Libre Franklin (body)
- **Page width:** 1200px
- **Diamond motif:** `.dm` (7px), `.dm.filled` (solid blue), `.dm.gold` (amber), `.dm.sm` (5px)
- **Buttons:** `.lena-btn-primary` (blue gradient), `.lena-btn-ghost` (white border)

## Required Shopify Admin Objects

- **Collections:** `new-arrivals`, `this-weeks-drop` (needs `this-weeks-drop` template assigned), `crochet-dolls`, `compact-mirrors`, `ribbon-embroidery-hats`, `signature-purses`, `phone-travel-wallet`
- **Blog:** `Artisan Stories` (for spotlight section)
- **Metaobject:** `scheduled_event` (fields: `start_date`, `end_date`, `name`, `time_text`, `description`, `address`, `icon`)
- **Menu:** `main-menu-gallery`

## Competing Theme

Rise theme at `/Users/vanhoanghai/projects/lena-shopify_theme/` on `website-redesign` branch. Comparing both before deploy.
