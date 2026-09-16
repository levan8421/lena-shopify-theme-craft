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

---

## 2026-09-15 · Feature · Trim the PDP header to one navigating line
**Commit:** (see `git log --grep "Trim the PDP header"`) · **Files:** `snippets/breadcrumbs.liquid`, `sections/main-product.liquid`, `assets/lena-custom.css`, `CLAUDE.md`

**What it does / did:** Drops the category eyebrow from the PDP entirely, and drops the trailing
crumb from the breadcrumb trail. What remains above the `<h1>` is `Home › Velvet Purses` — one line
that still links back to the category.

**Why it matters:** Three lines above the title carried two facts. The breadcrumb ended with the full
product title, repeating the `<h1>` directly beneath it and wrapping the trail onto a second line on
these long titles; the eyebrow then repeated the middle crumb. The eyebrow was the redundant one —
it was plain text, so removing it costs nothing. The breadcrumb was kept because it is the **only**
path back to the category from a product page; a visitor arriving from search or a shared link would
otherwise have the menu and nothing else.

**Reproduce (before the fix):** open any PDP with a long title → `Home › Velvet Purses › Midi Velvet
Clutch - Black Noir with Mixed Rose Garden` wrapping to two lines, then `VELVET PURSES`, then the
same title again as the heading.

**Verify now:**
```bash
grep -rn "lena-pdp-cat" sections snippets assets    # → no matches, markup and CSS both gone
grep -n "aria-current" snippets/breadcrumbs.liquid  # → no matches, no trailing crumb
```
In the app: one breadcrumb line, no eyebrow, and the category in it is clickable.

**Regression risk:** Re-adding a category line to the PDP "for SEO". The trail already names the
category; a second copy is what was just removed. Note the breadcrumb carries **no** schema.org
markup, so if structured data is ever wanted, that is the change to make — not more visible text.

---

## 2026-09-15 · Bug · "You may also like" recommended unrelated products
**Commit:** (see `git log --grep "same product type"`) · **Files:** `sections/related-products.liquid`, `snippets/lena-category-handles.liquid` (new), `snippets/breadcrumbs.liquid`

**What it does / did:** Filters Shopify's recommendations to products sharing the viewed product's
`type`, then tops the row up from that product's own category collection so it is never short.

**Why it matters:** `related-products.liquid` called the recommendation endpoint with nothing but a
limit. That algorithm leans on order history, and this store has nowhere near the volume to feed it —
so a ribbon-embroidery hat was recommended alongside two crochet dolls and a velvet purse. For a
catalogue sold on craft and category, that undercuts the browsing it exists to support.

**`product.type` is the right key and `collection.title` is the wrong one.** Measured 2026-09-15 via
the Admin API: active products carry types such as `Beaded Purses` and `Compact Mirrors`, while the
collections are *Glass Bead Woven Handbags* and *Artisan / Motif Compact Mirrors*. Matching on title
would have failed silently for most of the catalogue — it is the open T0-16 naming gap.

Side effect worth knowing: the section now renders category products on the **first server pass**,
before the JavaScript fetch returns. Previously it rendered nothing until that fetch completed. The
section therefore works with JavaScript disabled, at the cost of the contents changing once the
filtered set arrives.

**Reproduce (before the fix):** open the Rose Garden Bouquet hat PDP → "You may also like" shows two
crochet dolls and a velvet clutch.

**Verify now:**
```bash
grep -n "rp_rec.type == product.type" sections/related-products.liquid   # → the filter
grep -n "rp_has_fallback" sections/related-products.liquid               # → the top-up guard
grep -rn "lena-category-handles" snippets sections                       # → 3: the snippet + 2 consumers
```
In the app: open a hat, a doll and a mirror. Every card in the row should be the same kind of thing,
and the row should hold a full `products_to_show` wherever the category has that many in stock.

**Regression risk:** Two things. Writing the canonical handle list a second time instead of rendering
`lena-category-handles` — `breadcrumbs` and `related-products` answered the same question separately
once already. And swapping `rp_has_fallback` back to a `!= nil` check: `assign x = nil` and `x != nil`
are not dependable in Liquid, and a silently-false guard drops the top-up with no symptom but a short
row.

---

## 2026-09-15 · Bug · Search result cards did not match collection cards
**Commit:** (see `git log --grep "quick add to search"`) · **Files:** `sections/main-search.liquid`, `CLAUDE.md`

**What it does / did:** Adds `quick_add` to the search section — schema setting, conditional
`quick-add.css` / `quick-add.js` loading, and the parameter passed through to `card-product`.

**Why it matters:** Both grids render the *same* `card-product.liquid` with the same global
`card_style`, so the markup is identical. The cards still looked different, and three settings
explain it — measured 2026-09-15 by diffing `templates/collection.json` against
`templates/search.json`:

| Setting | Collection | Search |
|---|---|---|
| `image_ratio` | `portrait` | `square` |
| `show_rating` | true | false |
| `quick_add` | `standard` | **not supported at all** |

The first two are template settings and belong in the theme editor. The third was a **code gap**:
stock Craft's search section has no `quick_add` in its schema and never passed one to the snippet, so
no template value could have turned the button on.

**Unresolved:** search cards also render a *shortened* title — "Marigold Rose Medley" where the
product is **"Ribbon-Embroidery Hat - Marigold Rose Medley"** (confirmed via the Admin API). Every
observed case is the tail of the real title, which points at vertical clipping inside the card's
ratio box rather than any text filter. **This is audit finding A1/T0-09, previously closed as "does
not reproduce."** That investigation was right that there is no `truncate`, `truncatewords` or
`line-clamp` anywhere in the card path — and wrong to conclude from that that the symptom was not
real. Re-open it. The first thing to try is aligning `image_ratio`, since `--ratio-percent` is the
one value that differs between a page that shows full titles and one that does not.

**Reproduce:** search "ribbon embroidery hat" → cards are square-cropped, have no Add to cart, and
show only the tail of each product title. Open `/collections/velvet-purses` → portrait crops, Add to
cart present, full titles.

**Verify now:**
```bash
grep -n "quick_add" sections/main-search.liquid          # → asset loading, render param, schema
shopify theme check --fail-level error                   # → 0 errors, 8 warnings
```

**Regression risk:** Putting a `{%- comment -%}` inside a `{% render %}` argument list. Doing exactly
that here broke the tag silently — the page still rendered, and the only signal was theme check
reporting `skip_card_product_styles` as an unused variable, because the malformed tag no longer
counted as a use. Nine warnings instead of eight was the whole tell.

---

## 2026-09-15 · Bug · A1/T0-09 solved — card images overflowed their box and hid the title's first line
**Commit:** (see `git log --grep "overriding every section"`) · **Files:** `assets/lena-custom.css`, `templates/search.json`, `templates/product.json`

**What it does / did:** Removes `.card__media { aspect-ratio: 4/5; }` from `lena-custom.css`, and
sets `image_ratio` to `portrait` on the two sections that were `square`.

**Why it matters:** This is the audit's A1 / T0-09 "truncated related-product titles", raised twice
and closed as **"does not reproduce"**. It reproduces. The titles were never truncated — they were
**occluded**. The card image was rendering taller than the box meant to contain it and spilling down
over the text, so the first line of every two-line title sat behind the photo.

`.card__inner` takes its height from `::before { padding-bottom: var(--ratio-percent) }`, and
`--ratio-percent` comes from the section's `image_ratio` setting. The Lena rule pinned `.card__media`
to 4/5 = 125% regardless:

| Section | `image_ratio` | ratio box | forced media | result |
|---|---|---|---|---|
| `main-collection-product-grid` | portrait | 125% | 125% | matches — looked fine |
| `featured-collection`, `collection-list`, `main-list-collections` | portrait | 125% | 125% | matches |
| `main-search` | **square** | **100%** | 125% | **25% overflow → title occluded** |
| `related-products` | **square** | **100%** | 125% | **25% overflow → title occluded** |

That table is the whole bug. It also explains why two investigations missed it: both searched for
`truncate`, `truncatewords`, `line-clamp` and `text-overflow`, correctly found none, and concluded
the symptom was not real. **No text was ever being cut. A box was the wrong height.**

The rule was redundant on all seven sections where it agreed with the setting, and wrong on the two
where it did not — the worst shape a CSS override can have, because it looks harmless everywhere you
check first.

**Reproduce (before the fix):** open any product whose title wraps to two lines, e.g.
*"Crochet Doll - Beige Dress Crimson Bow Amigurumi"*. In "You may also like" or in search results,
line one is hidden behind the image and only *"Crimson Bow Amigurumi"* is legible. The same product
on `/collections/crochet-dolls` shows the full title.

**Verify now:**
```bash
grep -n "aspect-ratio" assets/lena-custom.css          # → none on .card__media
grep -h '"image_ratio"' templates/*.json | sort | uniq -c
#   → 9 portrait, 1 adapt, 0 square
```
In the app: a two-line title is fully readable on the collection grid, in search, and in
"You may also like" — all three identical.

**Regression risk:** Any CSS that sets a height or aspect on `.card__media`, `.card__inner` or
`.media` in `lena-custom.css`. The theme already has one mechanism for card proportions — the `ratio`
box, driven by a setting a merchant can see — and a second one in CSS will not track it. If the cards
should be a different shape, change `image_ratio` on the sections, not the stylesheet.

## 2026-09-16 · Bug · Turn on the Add to cart button in search results
**Commit:** a29d5a2 · **Files:** templates/search.json

**What it does / did:** The search results page now shows an "Add to cart" button on each
product card, the same as a collection page. Before, it showed no button.

**Why it matters:** The code for this button was already written and shipped in 262289b —
the setting, the CSS and JS loading, and the hand-off to the card snippet. But the setting
was never switched on, so none of it ran. A customer who found a piece by searching had to
open the product page before they could buy it. A customer who found the same piece by
browsing a collection could buy it straight from the grid. Same card, two behaviours.

The cause was narrow: `sections/main-search.liquid` declares the `quick_add` setting with
`"default": "none"`, copied faithfully from stock Craft's `main-collection-product-grid`.
Both collection templates override it to `"standard"`. `templates/search.json` never did,
so it kept the default and the feature stayed dark.

**Reproduce (before the fix):**
1. Open the storefront and search for `crochet`.
2. Look at any in-stock card in the results grid → no Add to cart button.
3. Open `/collections/crochet-dolls` and look at the same piece → Add to cart is there.

**Verify now:**
```bash
grep -n '"quick_add"' templates/*.json
#   collection.json:              "quick_add": "standard"
#   collection.new-arrivals.json: "quick_add": "standard"
#   search.json:                  "quick_add": "standard"   <- new
python3 -c "import json;json.load(open('templates/search.json'));print('valid')"
```
In the browser: search `crochet`, confirm in-stock cards now have Add to cart, and confirm
a **sold-out** card still shows only "Notify Me" and no disabled Add to cart button.

**Regression risk:** A new template that renders a section whose feature is opt-in by
default. The class is "the code shipped but the setting was never turned on", which no build
or lint step can see — only a rendered page shows it. Predictive search (the dropdown while
typing) is deliberately left without the button; it is a preview list, not a shop grid.

## 2026-09-16 · Bug · Search only products, so pages stop appearing in the product grid
**Commit:** PENDING · **Files:** sections/main-search.liquid, snippets/header-search.liquid, sections/main-404.liquid

**What it does / did:** All three search forms now send `type=product`, so Shopify searches
products only. Before, none of them said what to search, and Shopify's default is to search
products, pages and blog posts together.

**Why it matters:** A customer searching `mirror` got the "Our Story" page as a card in the
middle of the product grid — no photo, no price, no button. It reads as a product that failed
to load, not as a page. It also inflated the result count, which made R30 harder to reason
about: some of the 167 were not products at all.

Three forms, not one. Fixing only the search page would have left the header box — the one a
customer actually uses — still returning pages. The 404 page carries a third copy.

**Reproduce (before the fix):**
1. Search `mirror` from the header box.
2. Page 1 of the results → a card labelled "Page" reading "Our Story", among the mirrors.

**Verify now:**
```bash
grep -rn 'name="type" value="product"' sections/ snippets/
#   sections/main-404.liquid
#   sections/main-search.liquid
#   snippets/header-search.liquid      <- all three
```
In the browser: search `mirror` from the header, from the search page, and from a 404 page.
No "Page" or "Article" card should appear in any of them. The result count will drop below
167; that is correct, not a regression.

**Regression risk:** A fourth search form added later without the hidden field. There is no
shared snippet for these forms — Craft repeats the markup — so the next one will have to be
remembered. This does **not** change the predictive dropdown while typing: that uses a
separate Shopify endpoint and keeps its own product/suggestion split.

**Does NOT fix:** R30. The empty result pages and the unstable ordering are a Shopify-side
search fault and are unaffected by this change.
