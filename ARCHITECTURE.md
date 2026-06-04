# ARCHITECTURE.md — Lena Handicrafts Theme Deep Reference

> Line numbers verified 2026-06-03. Re-verify after major CSS or facets edits.

## CSS Architecture (`assets/lena-custom.css`, 917 lines)

| Lines | Section | Key selectors |
|-------|---------|---------------|
| 6–26 | CSS Variables | 19 `--lena-*` vars in `:root` |
| 28–31 | Global | `html { scroll-behavior: smooth }` |
| 33–49 | Diamond Motif System | `.dm`, `.dm.filled`, `.dm.gold`, `.dm.sm`, `@keyframes dm-pulse` |
| 51–61 | Announcement Bar | `.announcement-bar` overrides |
| 63–83 | Header / Nav | `.section-header` backdrop blur, `.header__menu-item::after` underline animation |
| 85–215 | Product Cards | `.lena-badge-1of1`, `.lena-badge-new`, `.lena-sold-overlay`, `.lena-scarcity`, `.lena-card-cat`, `.lena-notify-btn`, `.card--sold-out` |
| 216–247 | Section Headers | `.lena-section-eye`, `.lena-section-h`, `.lena-section-p` |
| 249–426 | Hero Section | `.lena-hero`, `.lena-hero-bg`, `.lena-hero-content`, `.lena-hero-mosaic`, `.lena-hero-img`, `.lena-btn`, `.lena-btn-primary`, `.lena-btn-ghost` |
| 428–478 | Trust Strip (Marquee) | `.lena-trust-strip`, `.lena-marquee`, `.lena-marquee-track`, `.lena-marquee-item`, `@keyframes lena-marquee` |
| 480–515 | Drop Section Header | `.lena-drop-bar`, `.lena-countdown-pill`, `.lena-view-all` |
| 517–528 | Category Cards Overlay | `.collection-list .card__media::after`, `.collection-list .card:hover` |
| 530–624 | Artisan Spotlight | `.lena-spot-card`, `.lena-spot-photo`, `.lena-spot-photo-inner`, `.lena-spot-role`, `.lena-spot-link`, `.lena-spot-nav` |
| 626–722 | Find Us Cards | `.lena-find-grid`, `.lena-find-card`, `.lena-find-card.primary`, `.lena-find-card.event`, `.lena-fc-dir`, `[data-cards]` grid |
| 724–732 | Newsletter Overrides | `.newsletter-form__field-wrapper` focus states |
| 734–792 | PDP Branding | `.lena-pdp-cat`, `.lena-pdp-badge-1of1`, `.lena-pdp-artisan`, `.lena-pdp-scarcity`, `.lena-pdp-sold-msg` |
| 794–829 | Collection Banner | `.lena-collection-banner`, `.lena-collection-title`, `.lena-collection-count` |
| 831–879 | Responsive | `@media (max-width: 900px)` tablet, `@media (max-width: 640px)` mobile |
| 881–917 | Popup / Modal | `.lena-popup-overlay`, `.lena-popup`, `.lena-popup-close`, `.lena-popup-field`, `.lena-popup-success`, mobile stack |

## CSS Variables

| Variable | Value | Usage |
|----------|-------|-------|
| `--lena-navy` | `#0E2240` | Dark backgrounds |
| `--lena-navy-mid` | `#132E52` | Newsletter bg |
| `--lena-blue-deep` | `#1B4F8A` | Buttons, headings |
| `--lena-blue-mid` | `#2478BD` | Blue gradient mid |
| `--lena-blue-bright` | `#2E8FD9` | Primary accent, CTAs, diamond motif |
| `--lena-blue-sky` | `#5AAEE6` | Gradient highlights |
| `--lena-blue-ice` | `#E6F0FA` | Light blue bg |
| `--lena-blue-tint` | `rgba(46,143,217,0.07)` | Subtle blue bg |
| `--lena-amber` | `#D4A853` | Secondary accent |
| `--lena-amber-soft` | `#E8B867` | Badge text, eyebrow text |
| `--lena-amber-pale` | `#FDF5E8` | Light amber bg |
| `--lena-snow` | `#FAFBFC` | Default page bg |
| `--lena-ink` | `#141A24` | Darkest text |
| `--lena-graphite` | `#3A4250` | Body text |
| `--lena-slate` | `#6B7585` | Secondary text |
| `--lena-silver` | `#E2E5EA` | Borders, dividers |
| `--lena-success` | `#1A8A5C` | Available/scarcity green |
| `--lena-success-pale` | `#E6F7EF` | Light green bg |

## Section Schema Reference

### `lena-drop-header.liquid`
- **Settings:** `eyebrow`, `collection_handle` (text, default `this-weeks-drop`), `color_scheme`, `padding_top`, `padding_bottom`
- **No blocks.** Uses `collections[collection_handle]` to detect product count.
- **Has products:** heading "This Week's Drop", shows "View all →" link
- **Empty:** heading "New Drop Coming Soon", hides "View all" link
- **Countdown:** JS countdown to next Friday 8 PM (always visible)

### `lena-drop-coming-soon.liquid`
- **Settings:** `eyebrow`, `heading` (inline_richtext), `description` (textarea), `cta_label`, `cta_link` (url, default `/collections/all`), `color_scheme`
- **No blocks.** Entire section wrapped in `{%- if collection.products.size == 0 -%}` — only renders on empty collections.
- **Used in:** `templates/collection.this-weeks-drop.json`

### `lena-hero.liquid`
- **Settings:** `eyebrow`, `heading` (richtext), `subheading`, `button_label_1`, `button_link_1`, `button_label_2`, `button_link_2`, `padding_top`, `padding_bottom`
- **Blocks:** `mosaic_image` — `image`, `collection`, `tag_label`, `placeholder_text` (max 4)

### `lena-spotlight.liquid`
- **Settings:** `eyebrow`, `heading` (richtext), `blog` (blog picker), `rotation_weeks` (select: 1/2/4), `color_scheme`, `padding_top`, `padding_bottom`
- **No blocks.** Rotation: `week_number / rotation_weeks % article_count`

### `lena-find-us.liquid`
- **Settings:** `eyebrow`, `heading`, `subheading`, `color_scheme`, `padding_top`, `padding_bottom`
- **Blocks:** `location` — `name`, `schedule`, `description`, `address`, `directions_url`, `icon`, `primary` (bool)
- **Also reads:** `shop.metaobjects.scheduled_event` — auto-shows events within 14-day window

### `lena-email-popup.liquid`
- **Settings:** `heading` (inline_richtext), `text` (textarea), `button_label`, `placeholder`, `success_message`, `delay_seconds` (range 3–30, default 10)
- **No blocks.** Limit 1 per theme.
- **Behavior:** Auto-shows after `delay_seconds` or on exit-intent (mouse toward browser top). localStorage prevents re-showing after dismiss or subscribe.
- **Tags contact with:** `newsletter` (general interest only)
- **Rendered in:** `layout/theme.liquid` (after footer-group)

### `lena-notify-modal.liquid` (snippet)
- **No schema** (rendered via `{% render %}`, not `{% section %}`).
- **JS API:** `window.lenaNotify(label, handle)` — opens modal, sets category label and tags dynamically.
- **Tags contact with:** `newsletter,notify-{handle}` (e.g. `newsletter,notify-crochet-dolls`)
- **Called from:** `snippets/card-product.liquid` notify button on sold-out products.
- **Rendered in:** `layout/theme.liquid` (after email popup section)

## 404 Page (`sections/main-404.liquid`, 175 lines)

Fully branded 404 page replacing the stock Dawn 404. Self-contained styles (no external CSS dependency).

| Feature | Details |
|---------|---------|
| Diamond motif header | `.lena-404__diamond` — 3 diamonds (blue, gold, blue) |
| Error code | `.lena-404__code` — Large "404" in `--lena-blue-bright` |
| Search bar | `.lena-404__search` — Form submitting to `{{ routes.search_url }}` with focus ring |
| Quick nav links | `.lena-404__links` — All Collections, All Products, New Arrivals, Contact Us |
| Home CTA | `.lena-404__home` — Blue button back to root |
| Responsive | `@media (max-width: 640px)` reduces padding and font sizes |

## Color Filter Whitelist (`snippets/facets.liquid`)

Shopify's Storefront Filtering API exposes all product tags under the "Color" filter, including non-color values like "Accessories", "artisan", "Compact Mirrors". A Liquid whitelist (55+ recognized color names) skips non-color values before rendering.

| Location | Lines | Loop |
|----------|-------|------|
| Desktop filters | 204–220 | `for value in filter.values` (first occurrence) |
| Mobile/drawer filters | 592–608 | `for value in filter.values` (second occurrence) |

**How it works:** Before each `<li>`, checks `value.label` against `lena_color_whitelist`. Non-matches set `lena_skip_value = true`, and the `<li>` is wrapped in `{%- unless lena_skip_value -%}`. The whitelist includes standard colors plus extended names (navy, teal, coral, champagne, etc.).

**Note:** The Color filter will appear empty on collections until products have `color-{family}` tags applied via the batch uploader app.

## Product Card Customizations (`snippets/card-product.liquid`)

| Lines | Feature | Condition |
|-------|---------|-----------|
| 108–111 | 1-of-1 badge (`.lena-badge-1of1`) | Always shown |
| 112–118 | "New" badge (`.lena-badge-new`) | `created_at` < 7 days ago (604800s) |
| 119–122 | Sold-out overlay (`.lena-sold-overlay`) | `!card_product.available` |
| 164–167 | Category label (`.lena-card-cat`) | `card_product.type` present |
| 228–232 | Scarcity text (`.lena-scarcity`) | `card_product.available` |
| 233–238 | Notify button (`.lena-notify-btn`) | `!card_product.available` — opens category-specific modal via `window.lenaNotify()` |

## PDP Customizations (`sections/main-product.liquid`)

| Lines | Feature | Condition |
|-------|---------|-----------|
| 101–104 | Category eyebrow (`.lena-pdp-cat`) | `product.type` present |
| 106–109 | 1-of-1 badge (`.lena-pdp-badge-1of1`) | Always |
| 110–113 | Artisan attribution (`.lena-pdp-artisan`) | Always |
| 130–134 | Scarcity text (`.lena-pdp-scarcity`) | `product.available` |
| 135–139 | Sold-out message (`.lena-pdp-sold-msg`) | `!product.available` |

## Collection Banner (`sections/main-collection-banner.liquid`)

| Lines | Feature |
|-------|---------|
| 14–18 | Diamond eyebrow: `<span class="dm filled sm"></span> Collection <span class="dm filled sm"></span>` |
| 19–22 | Title with `.lena-collection-title` class |
| 28–33 | Product count pill (`.lena-collection-count`) with piece/pieces pluralization |

## Inline Sections (NOT standalone files)

These live as `custom_liquid` HTML inside `templates/index.json`, not as section `.liquid` files:

| Section | JSON key | What it contains |
|---------|----------|-----------------|
| Trust Strip | `lena-trust` | Scrolling marquee with 3 messages duplicated for seamless `translateX(-50%)` loop. Hover pauses. `prefers-reduced-motion` fallback. |

> **Note:** Drop Header was previously inline `custom-liquid` but has been converted to a proper section (`sections/lena-drop-header.liquid`) to access collection data for empty-state handling.

## Custom Collection Templates

| Template | Sections | Purpose |
|----------|----------|---------|
| `collection.this-weeks-drop.json` | `main-collection-banner` → `lena-drop-coming-soon` → `main-collection-product-grid` | Branded empty-state when no products in drop collection. Coming-soon section self-hides when products exist. |

**Shopify Admin step:** Assign `this-weeks-drop` template to the `this-weeks-drop` collection (Admin → Collections → This Week's Drop → Theme template).

## Common Tasks Cheat Sheet

| Task | File(s) to edit |
|------|----------------|
| Change brand colors | `assets/lena-custom.css` lines 7–25 (`:root` vars) |
| Change hero content/images | Shopify admin or `templates/index.json` → `lena-hero` |
| Change drop header messaging | `sections/lena-drop-header.liquid` (heading text in Liquid conditionals) |
| Change drop coming-soon page | `sections/lena-drop-coming-soon.liquid` or Shopify admin section settings |
| Change trust strip messages | `templates/index.json` → `lena-trust` → `custom_liquid` |
| Change product card badges | `snippets/card-product.liquid` lines 108–122 |
| Change "New" badge threshold | `snippets/card-product.liquid` line 116 (`604800` = 7 days) |
| Change scarcity/sold text | `snippets/card-product.liquid` lines 228–237 + `sections/main-product.liquid` lines 129–139 |
| Change PDP branding | `sections/main-product.liquid` lines 101–139 |
| Change collection banner | `sections/main-collection-banner.liquid` lines 14–33 |
| Edit Q&A content | `templates/index.json` → `lena-qa` blocks, or Shopify admin (section settings) |
| Add/edit Find Us locations | Shopify admin (section blocks) or `templates/index.json` |
| Change event display window | `sections/lena-find-us.liquid` line 21 (`1209600` = 14 days) |
| Change spotlight rotation | Shopify admin → section settings → `rotation_weeks` |
| Add new CSS section | Append before responsive block (before line 831) |
| Change responsive breakpoints | `assets/lena-custom.css` lines 831–879 |
| Change 404 page content/style | `sections/main-404.liquid` (self-contained styles + markup) |
| Edit color filter whitelist | `snippets/facets.liquid` lines 204–220 (desktop) and 592–608 (mobile) — keep both in sync |
| Change fonts / page width | `config/settings_data.json` |
| Change color schemes | `config/settings_data.json` → `color_schemes` |
| Change email popup text/delay | Shopify admin → Email Popup section settings, or `sections/lena-email-popup.liquid` |
| Change notify modal text | `snippets/lena-notify-modal.liquid` |
| Change newsletter tags | `sections/newsletter.liquid` line 49, `sections/footer.liquid` line 174 (drop-list), `sections/lena-email-popup.liquid` (general), `snippets/lena-notify-modal.liquid` (category) |

## Newsletter Tagging Strategy

| Segment | Tag(s) | Capture point |
|---------|--------|---------------|
| General interest | `newsletter` | Email popup (auto 10s / exit-intent) |
| Drop list | `newsletter,drop-list` | Hero "Join the Drop List" button → footer newsletter, footer newsletter form |
| Category notify | `newsletter,notify-{handle}` | "Notify Me" button on sold-out product cards |
| POS subscribers | `newsletter,drop-list` | Shopify Flow auto-tags on customer creation with marketing consent |
