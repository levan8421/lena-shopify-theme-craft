# Development log

Append-only. One entry per feature or bug, newest at the bottom. **Entries are never edited** — a
later change gets a later entry. Open work lives in `OPEN_ITEMS.md`, not here.

---

## 2026-09-15 · Feature · Retire the drop cadence; the theme no longer schedules anything
**Commit:** 3615e17 · **Files:** `sections/lena-drop-header.liquid`, `sections/lena-drop-coming-soon.liquid`, `sections/lena-hero.liquid`, `sections/main-product.liquid`, `sections/main-404.liquid`, `sections/collection-list.liquid`, `snippets/breadcrumbs.liquid` (new), `snippets/header-*.liquid`, `snippets/lena-notify-modal.liquid`, `templates/index.json`, both collection templates, `assets/lena-custom.css`

**What it does / did:** Removes every promise of a weekly rhythm from the theme — the Friday
countdown, its UTC maths, the `show_countdown` and `next_drop_date` settings, the dead
`.lena-countdown-pill` / `@keyframes dm-pulse` CSS, and all "New drops every Friday" / "Join the Drop
List" copy. `lena-drop-header` became a New Arrivals bar (174 → 111 lines) that renders only while
`collections['new-arrivals'].all_products_count > 0`. `lena-drop-coming-soon` became a generic
collection empty state. Also in this commit: the PDP quantity stepper is hidden at max-purchasable 1
and capped at real stock otherwise, breadcrumbs were added, and 30-day returns were surfaced on the
PDP.

**Why it matters:** The business is supply-driven; gaps between new pieces run from days to a month.
A countdown to a Friday that may hold nothing trains a customer to stop believing the site. The
countdown was already disabled (`show_countdown: false`) but was deleted rather than left dormant —
one checkbox away from making the claim again.

Separately, the homepage had **no product grid at all**: slot 4's `featured-collection` pointed at
`this-weeks-drop`, which holds zero products, so the section rendered nothing and nobody had noticed.
It now points at `available-now`, as does the hero's primary CTA.

**Reproduce (before the fix):**
1. `git show 0109239:templates/index.json | grep -n "drops every Friday"` → hero subheading promises
   a weekly cadence.
2. `git show 0109239:sections/lena-drop-header.liquid | grep -c "dropStart"` → 13 hits; the Friday
   countdown machinery.
3. `git show 0109239:templates/index.json | grep -A1 '"featured-collection"'` → bound to
   `this-weeks-drop`, a collection with 0 products, so the homepage grid rendered nothing.

**Verify now:**
```bash
# Code-owned files: expect no matches.
grep -rin "every friday\|drop list\|next drop\|countdown" \
  sections snippets templates assets --exclude="*-group.json"

# Admin-owned files: expect exactly 2 matches, both still open. These are theme-editor
# content, deliberately reverted on this branch — see OPEN_ITEMS.md / the admin checklist.
grep -rin "drop list\|next drop" sections/header-group.json sections/footer-group.json
#   header-group.json:27  "Next drop: Friday 8 PM ET →"
#   footer-group.json:20  "Join the Drop List"

grep -n "all_products_count" sections/lena-drop-header.liquid   # → the visibility rule
shopify theme check --fail-level error                          # → 0 errors, 8 pre-existing warnings
```

**Still carrying drop copy:** the announcement bar and the footer newsletter heading live in
`sections/header-group.json` and `sections/footer-group.json`, which are admin-owned — CLAUDE.md
routes header and footer changes to the theme editor, and deleting an announcement block is
structural. **The storefront still says "Next drop: Friday 8 PM ET" until that is done in admin.**
In the app: homepage shows Available Now with products. PDP of a 1-of-1 piece shows no quantity
stepper, shows breadcrumbs, and shows the 30-day returns line.

**Regression risk:** Re-adding any date arithmetic to a section that describes new pieces. The theme
must never compute what "new" means — the app owns that via a single `new` tag and the smart
collection matches it. A future "hide if stale" or "last drop was N days ago" setting would put the
claim straight back.

---

## 2026-09-15 · Feature · Let shoppers add to cart from the grid, except when sold out
**Commit:** 6588a73 · **Files:** `snippets/card-product.liquid`, `templates/collection.json`, `templates/index.json`, `templates/collection.new-arrivals.json`, `templates/collection.this-weeks-drop.json`

**What it does / did:** Sets `quick_add` to `standard` on every product grid, and gates the quick-add
region in `card-product.liquid` on `card_product.available`.

**Why it matters:** Product cards had never carried an add-to-cart control — `quick_add` was `"none"`
from the initial commit, which is the stock Craft default rather than a decision anyone made. For a
catalogue of mostly one-of-a-kind pieces at $42–$109, forcing a click through to the product page to
buy costs a step for no benefit.

The availability gate is the part worth knowing. Stock Craft renders the quick-add button in a
*disabled* state for an unavailable product. Without the gate, a sold-out card would have shown a
dead "Sold out" button immediately beneath the Notify Me button already there — two CTAs on a card
that cannot be bought, one of which does nothing when clicked.

**Reproduce (before the fix):**
1. `git show 3615e17:templates/collection.json | grep quick_add` → `"none"`; no button on any card.
2. Set it to `standard` without the gate and load a collection page containing a sold-out piece →
   the card shows both a disabled "Sold out" button and the Notify Me button.

**Verify now:**
```bash
grep -n "quick_add" templates/*.json                              # → "standard" in all four
grep -n "card_product.available" snippets/card-product.liquid     # → both quick-add branches gated
```
In the app, on any collection page: an in-stock card shows "Add to cart" under the price; a sold-out
card shows the sold overlay and **only** Notify Me.

**Regression risk:** A theme update overwriting `card-product.liquid` drops the gate while leaving
`quick_add: standard` in the templates — the two dead-CTA cards return silently. The `Lena:` comment
markers at lines 332–337 and 436–437 are what a merge conflict should catch.

---

## 2026-09-15 · Feature · Show the New Arrivals pieces on the homepage, not just a count
**Commit:** d24c104 · **Files:** `templates/index.json`, `CLAUDE.md`

**What it does / did:** Adds a `featured-collection` block keyed `new-arrivals-grid`, bound to the
`new-arrivals` collection, between the New Arrivals bar and Available Now. No title, no view-all
link, `padding_top: 0` — the bar above supplies the heading and the count link.

**Why it matters:** The bar announced "14 new pieces →" and then required a click to see any of them.
These are the pieces a returning customer came back for; showing them is the whole job.

No new section file. `featured-collection` is already wrapped in a `products.size > 0` guard, so the
grid hides itself on the same condition as the bar. Both read the same collection, so they cannot
fall out of sync — either both render or neither does. This is the drop feature as it now stands:
Shopify decides what is in the collection, the theme only reflects whether anything is.

**Reproduce (feature — the steps that exercise it):**
1. With `new-arrivals` empty or non-existent: load the homepage → neither the bar nor the grid
   appears; Available Now sits directly under the trust strip.
2. Tag a product `new` so the smart collection picks it up → the bar appears reading "1 new piece →"
   with a 1-up grid directly beneath it.

**Verify now:**
```bash
grep -n "new-arrivals-grid" templates/index.json          # → block definition and order entry
sed -n '/"order"/,/]/p' templates/index.json              # → bar then grid then featured-collection
shopify theme check --fail-level error                    # → 0 errors
```

**Regression risk:** Changing either the bar's `collection_handle` or the grid's `collection` without
changing the other. They are two settings holding one value; if they ever disagree, a heading will
render over a grid of different products, or one will appear without the other.

---

## 2026-09-15 · Docs · Archive the drop-model documents
**Commit:** (this commit) · **Files:** `docs/`

**What it does / did:** Splits `docs/` into current documents, `OPEN_ITEMS.md`, and `archive/`. Six
files moved to `archive/`, each with a header naming what superseded it and what inside it is now
false.

**Why it matters:** Five of the seven documents were written against assumptions that no longer hold,
and two of them were actively dangerous to follow. `TIER0_DEVELOPER_RESPONSE_V4.md` analyses in
detail a 30-day `published_at` window that was never built — someone implementing from it would add
date logic the theme deliberately does not have. `lena_website_implementation_plan.md` specifies the
weekly Friday drop throughout, plus the wrong fonts (Cormorant Garamond + Nunito Sans, against the
shipped Josefin Sans + Libre Franklin) and a New Arrivals rule ("created within 14 days") that
contradicts the tag-driven design.

`TIER0_DEVELOPER_RESPONSE.md` (v1) keeps three findings its own author retracted in V2 — most
importantly that the `#newsletter` anchor is broken, which it is not: `sections/newsletter.liquid:18`
emits `<div id="newsletter">`.

**Verify now:**
```bash
ls docs docs/archive
head -3 docs/archive/TIER0_DEVELOPER_RESPONSE_V4.md   # → the ARCHIVED header
grep -c "^" docs/OPEN_ITEMS.md                        # → the open-items sweep exists
```

**Regression risk:** Acting on an archived document without reading its header. The headers are the
only thing standing between `archive/` and a reintroduced `new_arrivals_window_days` setting.

---

## 2026-09-15 · Bug · Stock section CSS was flattening the PDP title block
**Commit:** 58adb7a · **Files:** `assets/lena-custom.css`, `CLAUDE.md`

**What it does / did:** Restores margins on every Lena element inside `.product__title`, and gives
the `<h1>` a size that belongs to this design system.

**Why it matters:** `section-main-product.css:253` sets `.product__title > * { margin: 0 }`. It
loads from inside the section body (`main-product.liquid:12`), which puts it **after**
`lena-custom.css` in the head (`theme.liquid:259`) — so at equal specificity the stock rule wins.
Breadcrumbs, the category eyebrow, the 1-of-1 badge and the artisan line all rendered as one cramped
stack. Separately the `<h1>` had no Lena rule at all and inherited stock
`calc(var(--font-heading-scale) * 4rem)` ≈ **70px** at `heading_scale: 110`, dwarfing the 11px
eyebrow beside it.

Nothing catches this: `theme check` passes, the Liquid is correct, the classes are applied. It is
visible only in a browser.

**Reproduce (before the fix):**
1. `grep -n "product__title > \*" assets/section-main-product.css` → the `margin: 0` rule.
2. `grep -n "base.css\|lena-custom.css" layout/theme.liquid` → both in `<head>`.
3. `grep -n "section-main-product.css" sections/main-product.liquid` → line 12, inside the body,
   therefore later in the cascade.
4. Open any PDP → breadcrumb, eyebrow and title touch with no spacing; title is ~70px.

**Verify now:**
```bash
grep -n "product__title >" assets/lena-custom.css
# → 7 matches: the 5 new rules (h1 + 4 children, each one class more specific than the stock
#   `.product__title > *`), plus the pre-existing line 727 and one mention inside the comment.
```
In the app, on a PDP: clear space between breadcrumb, eyebrow, title, badge and artisan line; the
title sits at a size comparable to other section headings.

**Regression risk:** Adding a new element inside `.product__title` and styling it with a bare class
selector. It will silently lose its margin. Always qualify with the parent:
`.product__title > .lena-thing`.

---

## 2026-09-15 · Feature · Featured Piece section, rotating one product on a date seed
**Commit:** d79bc4a · **Files:** `sections/lena-featured-piece.liquid` (new), `assets/lena-custom.css`, `CLAUDE.md`

**What it does / did:** Spotlights a single available product from a chosen collection, with a large
image beside category, title, inventory badge, price, scarcity line and a CTA. The piece changes on
a daily, weekly or monthly period set in the theme editor.

**Why it matters:** Available Now holds **219 products** and is sorted **MANUAL** (measured
2026-09-15 via the Shopify Admin API: `productsCount` 219, `sortOrder` MANUAL). A 4-item homepage
window into that is neither a shop nor a taste — the four shown were whatever floated to the top of
an arrangement nobody maintains. One deliberately presented piece does more work.

**Liquid has no random filter.** Rather than add JavaScript, this reuses the rotation already proven
in `lena-spotlight.liquid:32-35`: seed an integer off `'now'`, modulo the pool size, pick by index.
Everyone sees the same piece for the period, which reads as curation rather than chance and loads
exactly one image.

Two self-enforced rules: **sold-out pieces are excluded** from the pool (`where: 'available'`), since
nearly everything here is one of a kind and featuring something already sold is worse than showing
nothing; and the section **hides entirely** when the collection is blank or has nothing available.

**Reproduce (feature — the steps that exercise it):**
1. Theme editor → Add section → **Featured Piece**. Assign a collection.
2. With every product in it sold out, or no collection assigned → the section does not render.
3. With available products → one piece shows; it changes when the seeded period rolls over.

**Verify now:**
```bash
grep -n "where: 'available'" sections/lena-featured-piece.liquid    # → the sold-out exclusion
grep -n "date: '%j'\|date: '%W'\|date: '%m'" sections/lena-featured-piece.liquid   # → the three seeds
shopify theme check --fail-level error                              # → 0 errors
```

**Regression risk:** Switching `where: 'available'` to the two-argument form
(`where: 'available', true`). That form compares against a string and does not reliably match a
boolean, so the pool would silently include sold-out pieces. Also: a future "pick truly at random"
request means JavaScript and a rendered candidate pool — it is not a small change to this file.

---

## 2026-09-15 · Bug · Featured Piece could be added to the header group, where it cannot be moved
**Commit:** (this commit) · **Files:** `sections/lena-featured-piece.liquid`, `sections/header-group.json`, `templates/index.json`, `CLAUDE.md`

**What it does / did:** Moves the Featured Piece instance out of the header section group and into
the homepage template, and adds `"disabled_on": { "groups": ["header", "footer"] }` to the section
schema so it can never be added there again.

**Why it matters:** The theme editor shows an **Add section** button inside the Header group as well
as in the Template area. A section with a `presets` block is offered in both. Added under Header, it
is written to `sections/header-group.json`, renders pinned between the header and the template, and
**cannot be dragged into the template area** — the owner hit exactly this. Nothing in the editor
explains why the section will not move.

The same edit fixed a second thing: the instance carried `"color_scheme": ""`, which renders the
class `color-` and matches no scheme at all, so the section had no background treatment. Set to
`scheme-1`, the schema's own default.

**Reproduce (before the fix):**
1. Theme editor → Home page → under the **Header** group, Add section → Featured Piece.
2. `git pull` → the instance appears in `sections/header-group.json`, not `templates/index.json`.
3. Try to drag it below "Lena Hero" in the editor → it will not cross into the Template area.

**Verify now:**
```bash
grep -c "lena-featured-piece" sections/header-group.json   # → 0
grep -c "lena-featured-piece" templates/index.json         # → 1
grep -A3 '"disabled_on"' sections/lena-featured-piece.liquid
shopify theme check --fail-level error                     # → 0 errors
```
In the editor: Featured Piece now sits in the Template list and drags freely; it no longer appears
in the Add-section list offered inside the Header or Footer groups.

**Regression risk:** Any future Lena section that ships a `presets` block and belongs in the page
body. Without `disabled_on` it is addable to the header and footer groups, and the resulting "why
won't this move" is not obviously a theme problem.
