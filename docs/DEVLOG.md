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
**Commit:** 26a02aa · **Files:** sections/main-search.liquid, snippets/header-search.liquid, sections/main-404.liquid

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

## 2026-09-16 · Bug · Stop blaming filters the visitor never used
**Commit:** 3dd6093 · **Files:** sections/main-search.liquid

**What it does / did:** An empty search page used to say "No products found — use fewer
filters or remove all", whether or not the visitor had applied a filter. It now tests whether
a filter was actually applied, and shows one of three messages instead of one.

**Why it matters:** `search.filters` is the list of filters the page *offers*, not the ones
the visitor *chose*. Filtering is switched on for search, so that list is never empty and the
condition was always true. Two consequences:

- Every empty page told the visitor to remove filters they had never set. The advice could not
  be followed, and "remove all" was a link that undid nothing they had done.
- The correct plain wording, "No results for X", was unreachable. Its guard required
  `search.filters == empty`, which never happens while filtering is on.

This made R30 read as the visitor's fault. It does not fix R30.

Three states now:

| Situation | Message |
|---|---|
| No results at all, no filter used | No results for "X" |
| No results, a filter was used | Use fewer filters or remove all |
| This page empty, other pages have results | Nothing on this page → back to the first page |

The third case is new. It is what a visitor hits on page 4 of `mirror`: neither stock message
was true there, because the count says results exist.

**Also fixed here:** the "remove all" link is built by hand at line 71 and did not carry
`type=product`. After the previous commit, one click on it would have dropped the product-only
restriction and brought pages and blog posts back into the grid. It now carries it.

**Reproduce (before the fix):**
1. Search `mirror`, apply no filters, go to page 4.
2. → "No products found. Use fewer filters or remove all", with no filters applied.
3. Search for a word matching nothing at all, e.g. `zzzzz` → same filter message, never
   "No results for zzzzz".

**Verify now:**
```bash
grep -n "lena_filter_applied" sections/main-search.liquid   # 5 hits: 1 assign, 1 loop, 3 reads
grep -n "type=product" sections/main-search.liquid          # in the search_url string
python3 -c "
import re;s=open('sections/main-search.liquid').read()
print(len(re.findall(r'{%-?\\s*if\\s',s)), len(re.findall(r'{%-?\\s*endif\\s*-?%}',s)))"   # equal
```
In the browser: search `zzzzz` → expect "No results for zzzzz", not filter wording. Search
`mirror`, go to page 4 → expect the link back to page 1. Apply a colour filter that matches
nothing → expect the filter wording, and check the "remove all" link keeps products only.

**Regression risk:** Any new empty-state condition written as `search.filters != empty` or
`collection.filters != empty`. The same mistake is open as R3 on the collection banner: asking
whether filters exist when the question is whether one was used.

## 2026-09-16 · Bug · Signup forms no longer report success when the submit failed
**Commit:** 2fdec91 · **Files:** snippets/lena-notify-modal.liquid, sections/lena-email-popup.liquid, assets/lena-custom.css

**What it does / did:** Both signup forms now check the response and show an error if the
submit failed. Before, every outcome reached the success branch.

**Why it matters:** `fetch(...).then(...)` runs its callback on *any* completed request,
including a 404, a 500 or a rejected submission, and `.catch` was absent so a network failure
was unhandled. A visitor whose signup failed was told "You'll be the first to know!" and never
heard from the shop again.

The email popup was worse, because it wrote its state before knowing the outcome:

```js
.then(function() {
  localStorage.setItem(SK, '1');   // ran even when the request failed
```

`SK` is checked on load and returns early, so a **failed** signup was reported as success
**and** suppressed the popup permanently on that device. The visitor could not retry even if
they wanted to. The notify modal had no such latch, so retrying there was at least possible.

On failure the form is now left in place with the address still typed, so retrying is one
click. The success and error states reset each time the modal opens.

**Also fixed here:** `localStorage` was read at the top of the popup script with no `try`.
In browsers where storage access throws rather than returning null — private modes, some
embedded webviews — that exception killed the whole script and the popup never appeared at
all. Reads and writes now go through two small guarded helpers.

**New colour:** `--lena-danger: #B3261E`. Measured 6.54:1 on white and 6.31:1 on snow, against
the 4.5:1 that WCAG AA needs for small text. The check was run with a control that must fail
(`#E8B867`, 1.83) and one that must pass (`#0E2240`, 15.89).

**Reproduce (before the fix):**
1. DevTools → Network → Offline.
2. Open the newsletter popup, enter an address, submit.
3. → "Welcome! You're on the list." No request ever left the browser.
4. Go back online and reload → the popup never appears again.

**Verify now:**
```bash
grep -c "catch(function" snippets/lena-notify-modal.liquid sections/lena-email-popup.liquid
#   1 each
grep -n "localStorage" sections/lena-email-popup.liquid
#   only inside remember() / seen(), both wrapped in try
```
In the browser, offline: submit both forms → expect the red error line, the form still on
screen with the address kept. Then online: submit → expect the success message. Reload → the
popup should stay away only after a **successful** signup.

**Still open:** if Shopify accepts the request but rejects the address with a 200 response,
that still reads as success. Distinguishing it needs a look at what `/contact` actually
returns for a bad address, which needs a browser. Filed as part of R4.

**Regression risk:** any new `fetch` to `/contact` written by copying these two. Both now carry
the check; a third copy would not.

## 2026-09-16 · Bug · PDP stock count no longer depends on block order
**Commit:** 6a740d5 · **Files:** sections/main-product.liquid

**What it does / did:** `lena_qty` is now assigned once, above the block loop. It used to be
assigned inside the `title` block and read from three later blocks.

**Why it matters:** blocks render in `block_order`, which the merchant controls from the theme
editor — CLAUDE.md routes reordering there as the normal way to work. `templates/product.json`
happens to list `title` before `price`, so this worked. Move Price above Title, or delete the
Title block, and `lena_qty` is empty for every later block: the "1 of 1" badge and the "Only
piece in existence" line both disappear. No error, no warning, and the sold-out message keeps
working because it tests `product.available` instead — so the page looks fine.

**Reproduce (before the fix):** theme editor → Product → drag Price above Title → save. The
badge and the scarcity line are gone from every product page.

**Verify now:**
```bash
grep -n "assign lena_qty = product" sections/main-product.liquid   # exactly one, line ~100
grep -n "for block in section.blocks" sections/main-product.liquid # the loop, after it
```
In the theme editor, drag Price above Title and confirm the badge and scarcity line survive.
Put the order back afterwards.

**Regression risk:** any variable assigned inside one block and read from another. The fix is
not to remember the order, it is to assign before the loop.

## 2026-09-16 · Bug · The New badge reads the app's tag instead of inventing its own rule
**Commit:** eb4b34e · **Files:** snippets/card-product.liquid

**What it does / did:** The "New" badge on a product card now shows when the product carries
the `new` tag. It used to show when the product was created less than 7 days ago.

**Why it matters:** CLAUDE.md states the rule this broke — *"the theme does not know what 'new'
means. The app owns a single `new` tag ... Deliberately no date filter, staleness read or item
cap."* Every other surface obeys it: the New Arrivals bar, the grid, and all three nav snippets
gate on `all_products_count` of the tag-driven smart collection. This one card badge did not,
so there were two definitions of "new" and they disagreed in both directions:

- Tagged `new` but created 10 days ago (photographed late, or imported) → in New Arrivals, **no
  badge**.
- Created 3 days ago, never tagged → **badge**, while absent from New Arrivals and the nav.

The second case is live today: `new-arrivals` holds 0 products, so the nav link and both
homepage sections are hidden, yet any recently created product still wore a New badge on every
grid it appeared in.

**Matched case-insensitively.** Shopify's smart-collection rule `Tag is equal to new` ignores
case, so a tag written `New` joins the collection. A plain `tags contains 'new'` would miss it
and reopen the same disagreement from the other side.

**Reproduce (before the fix):** open `/collections/available-now` sorted newest first. Any
product created in the last 7 days shows a New badge, while the New Arrivals collection in
admin is empty and the nav link is hidden.

**Verify now:**
```bash
grep -n "604800\|age_seconds\|created_at" snippets/card-product.liquid
#   only inside the explanatory comment - no arithmetic remains
grep -n "lena_is_new" snippets/card-product.liquid   # 4 hits
```
In the browser: no badge should appear anywhere while `new-arrivals` is empty. Tag one product
`new` in admin, and the badge and the New Arrivals section should appear together.

**Regression risk:** any future "recently added" affordance computed from a date in Liquid
rather than read from the tag. The test is whether the theme can disagree with the app.

## 2026-09-16 · Bug · Repair four faults in the hero section
**Commit:** 2f44b95 · **Files:** sections/lena-hero.liquid, templates/index.json

Four separate faults in one file, fixed together because they are all in the hero and each is
small on its own.

**1. The padding sliders did nothing (R6).** The schema declared `padding_top` and
`padding_bottom`, but the section had no `{%- style -%}` block and never emitted
`section-{{ section.id }}-padding`. Every other Lena section does. A merchant could drag both
sliders, save, and see no change. Both are stored at `0`, which is why it went unnoticed.
Wired up in the standard shape.

**2. A paragraph inside the H1 (R7).** `heading` was `"type": "richtext"`, which always wraps
its output in `<p>`. The page's only `<h1>` therefore contained a block-level paragraph, which
is invalid and brings its own margins. Every other Lena section uses `inline_richtext` for
headings. Changed here, **and the stored value in `index.json` was changed too** — changing the
setting type does not rewrite what is already saved, so without that the `<p>` would have
survived the fix.

**3. Four links with no name (R8).** `image_tag` emits `alt=""` when the image has no alt text
in Shopify Files, which is the default. The anchor wrapped only that image, so a screen reader
announced four consecutive links as "link", "link", "link", "link". The `tag_label` that names
them visually sits *outside* the anchor and never counted. The link now carries an
`aria-label`, and the image an `alt`, both falling back `tag_label` → collection title.

The anchor is also skipped entirely when no collection is chosen. It used to be emitted with no
`href` at all, which looks clickable and is not.

**4. Inline styles removed, not moved (R23, in part).** `style="display:block;width:100%;
height:100%"` on the anchor and `width:100%;height:100%;object-fit:cover` on the image were
**exactly duplicated** by `.lena-hero-img a` and `.lena-hero-img img` in `lena-custom.css`
(lines 420-429). Deleting them changes nothing visually.

Also guarded both CTA buttons on their link being set, not just their label. Both are filled in
`index.json` today, so this was latent — but a label with no link renders `href=""`, which
silently links to the current page.

**Verify now:**
```bash
grep -c "section-{{ section.id }}-padding" sections/lena-hero.liquid   # 3
grep -n '"type": "inline_richtext"' sections/lena-hero.liquid          # the heading
grep -n 'style="display:block\|object-fit:cover' sections/lena-hero.liquid || echo "no inline styles"
python3 -c "import json,re;s=open('templates/index.json').read();s=re.sub(r'/\*.*?\*/','',s,flags=re.S);print(json.loads(s)['sections']['lena-hero']['settings']['heading'])"
#   One piece at a time.<br/><strong>Yours alone.</strong>     <- no <p>
```
In the browser: the hero must look unchanged. Check the `<h1>` in view-source contains no
`<p>`. In the theme editor, drag the hero's top padding to 100 and confirm it now moves. Put it
back to 0.

**Regression risk:** a heading setting typed `richtext`; a schema block copied without its
style block; an image-in-link written without an explicit `alt:`.

## 2026-09-16 · Bug · Three text colours were below the readable-contrast minimum
**Commit:** 1ed4eed · **Files:** assets/lena-custom.css

**What it does / did:** Three colours were darkened so small text meets WCAG AA (4.5:1). All
three were measured, not judged by eye.

| What | Was | Measured on snow | Now | Measured |
|---|---|---|---|---|
| Section eyebrow, 11px uppercase | `#2E8FD9` | **3.35:1** | `--lena-blue-deep` `#1B4F8A` | 8.01:1 |
| `--lena-success`, carries "Only piece in existence" | `#1A8A5C` | **4.19:1** | `#157048` | 5.89:1 |
| `--lena-slate`, card category at 9.5px | `#6B7585` | **4.50:1** | `#5C6573` | 5.69:1 |

**Why it matters:** the eyebrow is the widest-reaching of the three — it appears on the hero,
the New Arrivals bar, Testimonials, Find Us, Featured Piece, the collection banner and the
empty state. At 11px, uppercase, with 0.2em tracking, it is harder to read than the ratio alone
suggests. The large-text exemption starts at 18.66px bold, so 11px gets no relief from being
semi-bold.

`--lena-success` carries the scarcity line, which is the most commercially important sentence
on a one-of-a-kind card and also the smallest text on it.

The two tokens are shared — 18 rules use `--lena-slate` and 7 use `--lena-success` — so
darkening the token improves every one of them rather than patching one class.

**Not changed:** `.lena-section-eye` is overridden to amber on navy inside `lena-spotlight`,
which measures 8.69:1 and already passed.

**Verify now:**
```bash
python3 - <<'PY2'
def lum(h):
    h=h.lstrip('#'); r,g,b=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    f=lambda c: c/12.92 if c<=0.03928 else ((c+0.055)/1.055)**2.4
    return 0.2126*f(r)+0.7152*f(g)+0.0722*f(b)
def cr(a,b):
    l1,l2=sorted([lum(a),lum(b)],reverse=True); return (l1+0.05)/(l2+0.05)
for c in ['#1B4F8A','#157048','#5C6573']:
    print(c, round(cr(c,'#FAFBFC'),2))          # each must be >= 4.5
print('control, must be under 4.5:', round(cr('#E8B867','#FAFBFC'),2))
PY2
```
In the browser the change is visible but small — the eyebrow reads darker. Check the homepage,
a collection page and a product card.

**Regression risk:** a new colour picked to look right against white without being measured.
The snippet above is the check; run it with one colour that must pass and one that must fail.

## 2026-09-16 · Bug · Section titles are headings, and star ratings say their rating
**Commit:** 66a7c13 · **Files:** assets/lena-custom.css, sections/lena-drop-header.liquid, sections/lena-find-us.liquid, sections/lena-testimonials.liquid, sections/lena-spotlight.liquid, sections/lena-featured-piece.liquid

**What it does / did:** Five section titles were `<div>` elements styled to look like headings.
They are now `<h2>`. Testimonial star ratings now state the rating.

**Why it matters (headings):** the homepage outline ran `<h1>` (hero) straight to `<h3>`
(testimonial cards, Find Us cards, the featured piece title) with nothing at level 2 between.
Navigating a long page by heading is the normal way a screen-reader user skims it, and doing so
here skipped "New Arrivals", "Loved by Collectors", "Today's Feature" and "Find Us" entirely —
the four largest pieces of text on the page. Only `lena-drop-coming-soon` had it right.

With a real `<h2>` above them, the existing `<h3>` card titles become correct rather than
orphaned.

**Spacing had to move with it.** `.lena-section-h` declared no margin, so a `<div>` sat at
margin 0 while an `<h2>` would inherit the browser's default heading margin and push every
section title down. `margin: 0` added to `.lena-section-h`, and `.lena-fp-heading`'s
`margin-bottom: 20px` changed to the `margin: 0 0 20px` shorthand so it kills the top margin
too. **The layout should look unchanged** — that is the test.

One small deliberate change: `lena-drop-coming-soon` was already an `<h2>` and therefore
already carried a default top margin. It now sits at 0 like the rest, so that section tightens
slightly.

**Why it matters (stars):** filled and empty stars were the same character `&#9733;`, differing
only by CSS class. A screen reader read "black star" five times regardless of the rating, so a
3-star review was indistinguishable from a 5-star one. The wrapper now carries
`role="img"` and an `aria-label` stating the rating, and the individual stars are
`aria-hidden`. This is the pattern stock Craft already uses for product ratings in
`card-product.liquid`.

**Verify now:**
```bash
grep -rn 'class="lena-section-h"\|class="lena-fp-heading"' sections/ | grep -c "<div"   # 0
grep -n "margin: 0;" assets/lena-custom.css | head -3
grep -n 'role="img"' sections/lena-testimonials.liquid
```
In the browser: the homepage must look the same. Compare section-title spacing against a
screenshot before the change. Then run the page's heading outline — it should read h1, then h2
for each section, then h3 for cards. Set a testimonial to 3 stars and confirm a screen reader
says "3 out of 5 stars".

**Regression risk:** a new section copying `lena-section-h` onto a `<div>`; any icon-only state
indicator without a text alternative.

## 2026-09-16 · Bug · "You may also like" no longer recommends sold-out pieces from one source only
**Commit:** 0275556 · **Files:** sections/related-products.liquid

**What it does / did:** The recommendations pass now skips sold-out pieces, which the category
top-up pass already did.

**Why it matters:** the row is filled in two passes — Shopify's suggestions first, then a
top-up from the product's own category. Pass 2 tested `rp_p.available`; pass 1 tested only id
and type. So whether a sold-out piece appeared depended entirely on which pass filled the slot,
which is invisible from the outside and varies per product.

On this catalogue most pieces are one of a kind and sell permanently, so pass 1 surfaced gone
pieces often — every one a click into a dead end, on the row whose whole purpose is to keep a
visit alive after the piece someone came for is unavailable.

Nothing in the section's comment block treated availability as a difference between the passes,
and pass 2 treated it as obviously required, so the asymmetry reads as an oversight rather than
a decision.

**Verify now:**
```bash
grep -c "available" sections/related-products.liquid   # 2 - one per pass
```
In the browser: open a product whose type has recent sales and confirm every card in "You may
also like" can actually be bought. A sold-out piece should not appear at all.

**Regression risk:** a third source added to the row without the same test. The row is built by
two independent loops rather than one filtered list, so each one has to carry the rule.

## 2026-09-16 · Bug · The collection empty state follows its own colour scheme
**Commit:** 712ba48 · **Files:** sections/lena-drop-coming-soon.liquid, assets/lena-custom.css

**What it does / did:** The empty-state paragraph took its colour from the section's colour
scheme. It used to hardcode `rgba(14,34,64,0.7)` — navy at 70% — regardless of the scheme.

**Why it matters:** the section exposes a `color_scheme` setting and the wrapper honours it
(`class="color-{{ section.settings.color_scheme }} gradient"`). The paragraph reached past it.
On the current `scheme-1` (snow) it measures 5.89:1 and reads fine. Pick `scheme-4` in the
theme editor and the background becomes navy `#0E2240` while the text stays navy — the body
copy vanishes. `scheme-5` (navy-mid) fails the same way.

Both are offered in the same dropdown, with no warning. The eyebrow and heading above use
classes and recolour correctly, so the section would render with a visible heading over an
invisible paragraph — which reads as a loading fault, not a colour mistake.

It now uses `rgba(var(--color-foreground), 0.75)`, the theme's own pattern for scheme-aware
text (`assets/base.css` uses it in several places).

**Also here (R23, in part):** all five inline `style` attributes moved into
`assets/lena-custom.css`, which is where CLAUDE.md requires custom styles to live. Three of
them — `text-align:center; margin-bottom:40px` — are the same wrapper repeated in
`lena-testimonials` and `lena-find-us`; those two still carry it and are still open under R23.

**Reproduce (before the fix):** theme editor → New Arrivals template → Collection Empty State →
Colour scheme → `scheme-4`. The heading stays readable; the paragraph disappears.

**Verify now:**
```bash
grep -c 'style="' sections/lena-drop-coming-soon.liquid   # 0
grep -n "14,34,64" sections/lena-drop-coming-soon.liquid  # nothing
grep -n "lena-coming-soon-text" assets/lena-custom.css    # the new rule
```
In the browser the section must look unchanged on scheme-1. Then switch it to scheme-4 and
confirm the paragraph is now readable on navy. Set it back to scheme-1.

**Regression risk:** any hardcoded colour inside a section that offers a colour scheme. The
test is whether the section still reads correctly on `scheme-4`.
