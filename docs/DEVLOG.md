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

## 2026-09-16 · Bug · Six sections could be dropped into the header or footer group
**Commit:** 5239cc4 · **Files:** sections/lena-hero.liquid, sections/lena-drop-header.liquid, sections/lena-testimonials.liquid, sections/lena-spotlight.liquid, sections/lena-email-popup.liquid, sections/lena-find-us.liquid

**What it does / did:** Every Lena section with a `presets` block now carries
`"disabled_on": { "groups": ["header", "footer"] }`. Only `lena-featured-piece` had it.

**Why it matters:** CLAUDE.md records the trap — the theme editor shows an "Add section"
button inside the Header group as well as the template area, and a section added there lands in
`sections/header-group.json`, **pinned above the template and undraggable**. Getting it out
means hand-editing a generated JSON file.

`lena-email-popup` is the sharpest case: it is already rendered unconditionally from
`layout/theme.liquid:319`. Adding it a second time from the editor produced two overlays, two
elements sharing `id="lena-popup-overlay"`, and a `querySelector` that binds to whichever came
first — so the close button could control the other copy.

**Correction to the original finding.** R30's list named five sections and said
`lena-find-us` had no `presets`. It has them, at line 209. The check written to confirm the fix
found it — comparing `presets` count against `disabled_on` count per file, rather than trusting
the list. Six sections, not five.

**Verify now:**
```bash
for f in sections/lena-*.liquid; do
  p=$(grep -c '"presets"' "$f"); d=$(grep -c 'disabled_on' "$f")
  [ "$p" != "0" ] && [ "$d" = "0" ] && echo "GAP: $f"
done
#   no output = every section offering itself in the editor is guarded
```
In the theme editor: open the Header group, click Add section, and confirm none of the Lena
sections are listed. They must still be available in the template area.

**Regression risk:** every new section that ships a `presets` block. The loop above is the
check; it is cheap enough to run on any section change.

## 2026-09-16 · Bug · Remove a CSS rule that restated a stock rule
**Commit:** 5ec006e · **Files:** assets/lena-custom.css

**What it does / did:** Deleted `.product__title > a.product__title { display: none; }` from
`lena-custom.css`. Stock `section-main-product.css:257` already declares
`.product__title > a { display: none; }`.

**Why it matters:** the Lena rule was more specific and said exactly the same thing, so it
changed nothing and could only ever drift from the rule it shadowed. It looks like an earlier,
less-informed attempt at the problem the comment block further down the same file documents
properly — stock `.product__title > * { margin: 0 }` zeroing the margins on Lena elements,
solved there by adding a class to the selector.

**Checked before deleting, not assumed.** The rule was only safe to remove if the stock rule
loads everywhere the selector matches:

```
who loads section-main-product.css   → featured-product.liquid, main-product.liquid
who renders <a class="product__title"> inside .product__title  → main-product.liquid:133 only
featured-product.liquid              → <h2 class="product__title">, no nested anchor
```

So the only matching markup is on the product page, which always loads the stock sheet. Had
`featured-product` rendered a nested anchor, deleting this would have hidden the link that
section exists to provide.

**Verify now:**
```bash
grep -n "product__title > a" assets/lena-custom.css assets/section-main-product.css
#   only the stock file
```
In the browser: the product page title must still appear exactly once. If a second, smaller,
underlined copy of the title appears beneath the `<h1>`, this was wrong — revert it.

**Regression risk:** a future section rendering `.product__title > a` without loading
`section-main-product.css`.

## 2026-09-16 · Bug · One definition of the Find Us event window
**Commit:** 07d0fdc · **Files:** snippets/lena-event-window.liquid (new), sections/lena-find-us.liquid

**What it does / did:** The 14-day event window now lives in one snippet. It used to be written
out in full twice in the same file.

**Why it matters:** `lena-find-us.liquid` walked the events twice — once at the top to count
visible cards for `data-cards`, once lower down to render them — with the same timestamp
arithmetic copied into both:

```liquid
assign diff_start = event_start_ts | minus: now_ts
... diff_start <= fourteen_days and diff_end >= -86400
```

Change one copy, for instance to widen the window to 30 days, and `data-cards` disagrees with
the number of cards actually drawn. `.lena-find-grid[data-cards="N"]` then lays out for the
wrong count. The visible result is a wrong column count, which looks like a CSS fault and sends
the next person to the wrong file.

The snippet is consumed with `capture` + `render`, the same shape `breadcrumbs.liquid` already
uses for `lena-category-handles` — a snippet cannot return a value, so this is the theme's
existing idiom for "one fact, two readers".

The file lost 739 bytes and one level of nesting.

**Verify now:**
```bash
grep -c "lena-event-window" sections/lena-find-us.liquid   # 2 - the count pass and the render pass
grep -n "fourteen_days\|diff_start\|now_ts" sections/lena-find-us.liquid || echo "no arithmetic left"
python3 -c "
import re;s=open('sections/lena-find-us.liquid').read()
print(len(re.findall(r'{%-?\s*if\s',s)), len(re.findall(r'{%-?\s*endif\s*-?%}',s)))"   # equal
```
In the browser: the Find Us section must look unchanged — same cards, same column count. To
test the shared definition, change `ev_window` in the snippet to `2592000` (30 days), confirm
both the cards and the column layout change together, then put it back.

**Regression risk:** a third reader of the same question added without the snippet. The point of
the snippet is that the next person has somewhere obvious to look.

## 2026-09-16 · Bug · Featured Piece rotation can now reach every piece in its pool
**Commit:** d3bd5e9 · **Files:** sections/lena-featured-piece.liquid

**What it does / did:** The rotation seed counts days since the epoch. It used to read a
calendar field directly.

**Why it matters:** the old seed was `'now' | date: '%m'` for monthly rotation — the month
number, 1 to 12. `fp_index = fp_seed | modulo: fp_pool_size` therefore only ever took 12
values, so a pool larger than 12 could never show its 13th piece, and the same month picked the
same index every year. Weekly used `'%W'` and capped at 54 the same way. Daily used `'%j'`,
which was fine at 366 but reset each January.

All three are offered as equals in the theme editor, under help text reading "Everyone sees the
same piece for the whole period" — true, and it hides this completely.

Days since the epoch only increases, so modulo covers the whole pool for every setting.

**R15 is documented here, not fixed.** Outside a `{% paginate %}` tag, `collection.products`
returns at most 50 products, so the pool is filtered from the first 50 of the collection in its
sort order. Pointed at the Artisan collection (112 products) the section can only ever feature
50 of them.

Liquid offers no way round this in a section: `paginate` takes its page from the URL, and a
homepage section does not control the URL. So rather than leave it silent, the limit is now
written where the pool is built, and the collection setting's help text in the theme editor
says a smaller curated collection suits this section better than a large one.

**R15 stays open** with that note. The real answer is a store-side decision about which
collection to point at, not a code change.

**Verify now:**
```bash
grep -n "date: '%m'\|date: '%W'\|date: '%j'" sections/lena-featured-piece.liquid || echo "no calendar seeds"
grep -n "fp_days" sections/lena-featured-piece.liquid   # the new seed
```
In the browser, set rotation to **Every month** and confirm a piece appears. The rotation itself
takes a month to observe, so the useful check is arithmetic: with `fp_days` around 20700 today,
`20700 / 30 = 690`, and `690 modulo 112` is 18 — an index the old `%m` seed could never reach,
since it never exceeded 12.

**Regression risk:** reusing a calendar component as a seed for any pool larger than that
component's range. The test is whether the seed can exceed the pool size.

## 2026-09-16 · Bug · A filter that matches nothing no longer erases the collection page
**Commit:** 0e249fe · **Files:** sections/main-collection-banner.liquid, sections/lena-drop-coming-soon.liquid

**What it does / did:** Two visibility gates moved from the filtered product count to the
collection total.

**Why it matters:** CLAUDE.md states the rule — *"`all_products_count`, not `products_count`:
the latter reflects the current tag-filtered view. Use `all_products_count` for any visibility
decision."* Both gates asked the wrong one.

A visitor who filtered a collection down to no matches got:

- **No heading at all.** `main-collection-banner.liquid` wrapped the eyebrow, the `<h1>`, the
  description and the count pill in `{%- if collection.products_count > 0 -%}`, so the entire
  banner disappeared.
- **The wrong explanation.** On the New Arrivals templates, `lena-drop-coming-soon.liquid`
  keyed on `collection.products.size == 0` and appeared, announcing "We're preparing something
  special" — the collection is empty — when the truth was that their own filter matched
  nothing.

Their filter chips stayed on screen above all of it, contradicting the copy, and the control
that would have cleared the filter was inside the banner that had just been removed.

**The count pill deliberately keeps `products_count`.** It reports what the visitor is looking
at now, so under an active filter it should say how many matched. It hides at zero rather than
reading "0 pieces". That distinction is commented in place, since the whole point here is that
the two counts answer different questions.

**Reproduce (before the fix):** open `/collections/compact-mirrors`, apply a colour filter
showing `(0)`, and look at the page. Expect no title.

**Verify now:**
```bash
grep -n "all_products_count" sections/main-collection-banner.liquid sections/lena-drop-coming-soon.liquid
#   banner: the section gate and the description gate
#   coming-soon: its only gate
grep -n "products_count" sections/main-collection-banner.liquid | grep -v comment
#   only the count pill
```
In the browser: filter a collection to zero matches. The title and the filter controls must
survive, and the page must not claim the collection is empty. Then open the genuinely empty New
Arrivals collection and confirm the "preparing something special" section still appears there.

**Regression risk:** any new gate written as `products_count` or `products.size`. The test is
whether the question is "does this collection hold anything" or "how many is the visitor
seeing" — they need different counts.

## 2026-09-16 · Bug · Both modals now move, trap and return keyboard focus
**Commit:** f224754 · **Files:** snippets/lena-notify-modal.liquid, sections/lena-email-popup.liquid

**What it does / did:** Opening either dialog moves focus into it, Tab is kept inside while it
is open, and closing returns focus to whatever opened it. None of that happened before.

**Why it matters:** both overlays declare `role="dialog" aria-modal="true"`. That tells
assistive technology the rest of the page is inert. Neither did anything to make it so:

- Focus stayed behind the dialog, so a screen-reader user was given no indication the newsletter
  popup had appeared after 10 seconds.
- Tab walked straight out of the dialog and through the page underneath — and everything it
  reached was content the page had just declared did not exist.
- `document.body.style.overflow = 'hidden'` stopped the mouse scrolling the page behind, but
  not the keyboard, so the two disagreed.
- Closing left focus wherever it had wandered to, instead of back at the button that opened it.

**Also fixed:** the Escape handler is bound to `document` for the life of the page. In the
notify modal it was unguarded, so it ran on every Escape keypress whether or not the dialog was
on screen. Both now check the dialog is actually open, and `hide()` returns early if it is not —
so a stray close cannot steal focus from the page.

**Verify now:**
```bash
grep -c "takeFocus\|releaseFocus\|trapTab" snippets/lena-notify-modal.liquid sections/lena-email-popup.liquid
#   7 each
node --check <the extracted <script> body>   # both parse; done before committing
```
In the browser, without a mouse: click a "Notify Me" button, then press Tab repeatedly. Focus
must stay inside the dialog and cycle. Press Escape — focus must return to the Notify Me button
you started from. Repeat for the newsletter popup.

**Regression risk:** any new dialog built by copying these two. The helper block is duplicated
in both files rather than shared, because they are a snippet and a section with separate
`<script>` bodies — a third copy should become a shared asset instead.

## 2026-09-16 · Bug · Notify Me files signups under the real category, not the product type
**Commit:** 5d56833 · **Files:** snippets/lena-notify-target.liquid (new), sections/main-product.liquid, snippets/card-product.liquid

**What it does / did:** Both Notify Me buttons resolve the product's category collection and
tag the contact `notify-<collection handle>`. They used to pass `product.type` for both the tag
and the label.

**Why it matters:** CLAUDE.md warns that `product.type` is not the collection title. Measured
against the live store, five of the seven live categories disagree:

| `product.type` | tag it produced | canonical handle |
|---|---|---|
| Beaded Purses | `notify-beaded-purses` | `glass-bead-woven-handbags` |
| Crochet Figures | `notify-crochet-figures` | `crochet-dolls` |
| Rattan Bags | `notify-rattan-bags` | `rattan-purses` |
| Hats | `notify-hats` | `ribbon-embroidery-hats` |
| Phone Wallet | `notify-phone-wallet` | `phone-travel-wallet` |

Only Compact Mirrors and Velvet Purses lined up. So a segment built to email everyone waiting
on a Glass Bead Woven Handbag would not find those contacts, and the tags could not be joined
back to a collection without a translation table that exists nowhere. The list was being
collected and was not usable for the thing it was collected for.

`lena-category-handles.liquid` was created as the single source of truth for exactly this
question and is already consulted by `breadcrumbs` and `related-products` — but not here. All
three now answer it the same way.

**Existing tags are not migrated.** Contacts already tagged `notify-beaded-purses` keep that
tag. If those signups matter, they need renaming in admin; this only changes what is written
from now on.

**Fallback kept.** A product in none of the canonical collections falls back to `product.type`,
so those behave exactly as before rather than losing the button. That set is real — R13 — and
stays deferred while those product types are unpublished.

**Verify now:**
```bash
grep -rn "lenaNotify" sections/ snippets/ | grep -c "\.type"   # 0
grep -rn "lena-notify-target" sections/ snippets/              # the snippet and its two callers
```
In the browser: open a sold-out beaded purse, click Notify Me, and check the modal says "Glass
Bead Woven Handbags", not "Beaded Purses". Submit, then read the contact's tags in admin —
expect `notify-glass-bead-woven-handbags`.

**Regression risk:** a third caller of `window.lenaNotify` written with `product.type`. The
snippet exists so there is one obvious place to look.

## 2026-09-16 · Bug · One definition of the colour-facet rule, not six
**Commit:** e64d784 · **Files:** snippets/lena-color-facet.liquid (new), snippets/facets.liquid

**What it does / did:** "Is this the Color filter, and is this value a real colour?" is now
asked in one snippet. It was asked in six places in `facets.liquid`, **with two different
conditions**.

**Why it matters:** the two forms are not equivalent.

| Where | Condition |
|---|---|
| The two checkbox lists (desktop, drawer) | `filter.label \| downcase == 'color'` |
| The four active-filter pills | `filter.label == 'Color' or filter.label == 'color'` |

A filter renamed to `COLOUR` or `Colour` in Search & Discovery satisfies the first and not the
second. The checkbox list would then read "Blue" while the pill directly above it read
"color-blue" — the raw tag, leaked to the customer. The ~55-name whitelist itself was pasted
out in full twice, so adding a colour to one copy and not the other silently produced the same
split.

Nothing was broken today: the filter is labelled exactly `Color`, and all 13 live `color-*`
tags pass the whitelist. This is the cost CLAUDE.md names — *"One rule written twice is the
most expensive fault class there is, because every copy passes its own tests."* Six copies
passed six times.

The snippet also accepts the `colour` spelling now, which neither original did.

**Still a whitelist, deliberately.** The Color facet is fed from tags, and the tag namespace
carries non-colours like `Accessories` and `artisan`, so something has to separate them. It now
fails in one place instead of two. The known cost stands: a fourteenth colour added in admin
vanishes from the facet until it is added to the snippet. That is recorded in the snippet's own
comment so the next person meets it there.

`facets.liquid` lost 2,462 bytes.

**Verify now:**
```bash
grep -c "lena-color-facet" snippets/facets.liquid                       # 8: 6 renders + 2 mentions
grep -c "lena_color_whitelist\|lena_is_color\|lena_value_stripped" snippets/facets.liquid   # 0
python3 -c "
import re;s=open('snippets/facets.liquid').read()
print(len(re.findall(r'{%-?\s*if\s',s)), len(re.findall(r'{%-?\s*endif\s*-?%}',s)))"   # equal
```
In the browser: open a collection with filtering on. The Color facet must list the same 13
colours with the same names, and non-colour tag values must still be absent. Tick one and check
the pill above reads "Color: Blue", not "Color: color-blue". Repeat in the mobile drawer — that
is the second copy, and the one most likely to have drifted.

**Regression risk:** a seventh reader of the same question. The snippet exists so there is one
obvious place to add it.

## 2026-09-16 · Bug · All custom styles now live in lena-custom.css
**Commit:** 44b65fe · **Files:** sections/main-404.liquid, sections/lena-spotlight.liquid, sections/lena-testimonials.liquid, sections/lena-find-us.liquid, sections/main-product.liquid, assets/lena-custom.css

**What it does / did:** The 404 page's 132-line inline stylesheet and every remaining Lena
inline `style` attribute moved into `assets/lena-custom.css`. CLAUDE.md rule 4: *"All custom
styles go in `assets/lena-custom.css`. No inline `<style>` tags, no new CSS files."*

**R22 — the 404 stylesheet.** `main-404.liquid` opened with 132 lines of CSS. Beyond the rule,
that meant the rules re-downloaded on every 404 instead of being cached with the rest of the
theme; they were invisible to anyone grepping `lena-custom.css` for a `.lena-404__` class; and
they sat outside the cascade order the rest of the theme is reasoned about in — the thing
CLAUDE.md warns about for `section-main-product.css`. The section went from 4,563 to 2,335
bytes. The CSS is unchanged apart from its location.

**R23 — the inline attributes.** Three of them were the same two declarations:

```
text-align:center; margin-bottom:40px
```

repeated in `lena-testimonials`, `lena-spotlight` and `lena-find-us` — three files to change,
three chances to disagree. Now `.lena-section-head`.

The spotlight's `color:var(--lena-amber-soft)` and `color:white` became
`.lena-spotlight-head` rules, since that section sits on a navy scheme and genuinely needs
inverted header text.

`main-product.liquid` carried
`style="background:var(--lena-success);border-color:var(--lena-success)"` on the scarcity
diamond. `lena-custom.css` already declared exactly that for `.lena-scarcity .dm` — the card
version. The PDP uses `.lena-pdp-scarcity`, which the rule did not cover, which is *why* the
inline copy existed. The selector now covers both and the inline style is gone.

**Deliberately left inline:** `style="display:none"` on the two modal overlays and their
success and error states. Those are JavaScript-controlled state, flipped by
`element.style.display`, not styling — moving them to a class would mean rewriting the show
and hide logic to toggle classes instead, which is a different change.

**Also left alone:** `main-product.liquid` lines 209-240 and 679. Those are stock Craft — the
inventory status icons and the `--rating` custom properties — and the custom-property form is
the legitimate pattern.

**Verify now:**
```bash
grep -rn 'style="' sections/lena-*.liquid snippets/lena-*.liquid | grep -v shopify_attributes | grep -v 'display:none'
#   no output
grep -c "<style type=" sections/main-404.liquid   # 0
grep -c "lena-404" assets/lena-custom.css         # 19 rules
```
In the browser, both pages must look **unchanged**: visit a URL that does not exist and check
the 404 page, then check the Artisan Spotlight section still has amber eyebrow and white
heading on navy. Check the PDP scarcity line still shows a green diamond.

**Regression risk:** a new section written as a self-contained file with its own styles. The
grep above is the check.

## 2026-09-16 · Bug · Close three older open items: A6, the duplicated whitelist, Notify Me failures
**Commit:** 1074965 · **Files:** docs/OPEN_ITEMS.md

`OPEN_ITEMS.md` holds only what is open — closing an item removes its row and records the fact
here instead, so the same thing is never written down twice. Three items from the Tier 0 tail
are now closed.

**A6 — `color-clear` is silently deleted from the Color facet. Closed as stale, not fixed.**
A6 stated the store carried **15** `color-*` tags and the facet rendered 14, with `clear`
missing from the whitelist. Measured against the live store on 2026-09-16 via
`productTags(first: 250)`, there are **13**, and every one passes the whitelist:

```
color-beige  color-black  color-blue   color-brown  color-gray
color-green  color-multi  color-orange color-pink   color-purple
color-red    color-white  color-yellow
```

There is no `color-clear`. The bug it describes is not reachable, because the data moved. The
design point it made — a whitelist that drops unknown values silently — is real and is now
recorded in `snippets/lena-color-facet.liquid`, where someone adding a fourteenth colour will
meet it.

**The colour whitelist is duplicated. Closed as fixed (R21).** It was worse than the item said:
the ~55 names appeared twice, and the surrounding "is this the Color filter" test appeared six
times in two non-equivalent forms.

**Notify Me reports success on failure. Closed as fixed (R4).** Also worse than recorded — the
newsletter popup had the same fault plus a `localStorage` write on the failure path, so a
failed signup was reported as success and then suppressed the popup permanently.

**Still open and unchanged:** the bare `Black` tag alongside `color-black` is still live —
confirmed present in the same tag query.

**Verify now:**
```bash
grep -c "color-clear" docs/OPEN_ITEMS.md    # 0
grep -n "A6" docs/OPEN_ITEMS.md             # only the pointer line to this entry
```

## 2026-09-16 · Bug · New Arrivals bar takes a collection picker, not a typed handle
**Commit:** 8eafb87 · **Files:** sections/lena-drop-header.liquid

**What it does / did:** The section's collection setting is a picker. It was a free-text field
holding a handle, looked up with `collections[section.settings.collection_handle]`.

**Why it matters:** a typo, a collection renamed in admin, or a pasted URL instead of a handle
all produced a blank collection. `na_count` stayed 0 and the section hid itself — which is
**exactly** what it does when the collection is legitimately empty. Two very different
situations, one indistinguishable outcome, and no feedback to the merchant either way.

R1 was this same failure in Featured Piece, reached differently: a handle stored as `artisan`
that no collection matched, so the section rendered nothing while looking deliberate. A picker
does not make that impossible — R1 happened *with* a picker — but it removes the typo route and
makes the stored value a reference that survives a title change.

**The setting id is unchanged on purpose.** A `collection` setting stores its handle as a plain
string, which is exactly what was already saved in `index.json` (`"collection_handle":
"new-arrivals"`). Keeping the id means the existing value survives the type change; renaming it
to something tidier would have discarded it and left the section blank until someone noticed.

`"default"` was removed because a `collection` setting cannot carry one. The help text says so,
rather than leaving the merchant to wonder why the field is empty on a fresh install.

**Unchanged and load-bearing:** visibility is still `all_products_count` and nothing else — no
date window, no staleness read, no cap. The app owns what "new" means.

**Verify now:**
```bash
grep -n "collections\[" sections/lena-drop-header.liquid    # only inside the comment
python3 -c "
import json,re;s=open('templates/index.json').read();s=re.sub(r'/\*.*?\*/','',s,flags=re.S)
print(json.loads(s)['sections']['lena-drop-header']['settings']['collection_handle'])"
#   new-arrivals   <- the stored value must survive
```
In the theme editor: open the New Arrivals section. The field must now be a dropdown showing
"New", not a text box. **The section is currently hidden because `new-arrivals` is empty** — to
test it, point it at `available-now` temporarily, confirm the bar appears with the right count,
then set it back.

**Regression risk:** any collection addressed by a typed string. `lena-drop-coming-soon` takes a
`url` rather than a collection, which is a different shape and was left alone.

---

## 2026-09-19 · Bug · The return window on the PDP contradicted the refund policy page
**Commit:** 5f6cb6a · **Files:** sections/main-product.liquid

**What it does / did:** Every product page told the customer "Returns accepted within **30 days of
delivery**". The store's own Refund Policy page said 15 days for purses and 7 days for
accessories. Three places, two different systems, three different answers.

**Why it matters:** A customer reads 30 days on the product page, buys, and asks for a return on
day 20. The policy page says the window closed on day 15. That is a chargeback, and the card
issuer normally sides with the customer, because the merchant's own product page promised 30.
It is also the one contradiction a customer is most likely to act on, since it is the number they
check before buying.

**Reproduce (before the fix):**
1. Open any available product → the returns line reads "30 days of delivery".
2. Click "Full return policy" in that same line → the page it opens says 15 days / 7 days.
3. Open the homepage Q&A, "How do I start a return?" → says 30 days.

**The decision:** the owner set one window — **15 days, all products** — and rewrote the Refund
Policy page on 2026-09-19 to say so, removing the purses/accessories split and the stale
"hair clips, headbands, bookmarks, keychains" list. This commit makes the PDP agree.

**Still to match (theme editor, not code):** the homepage Q&A block `qa-return` in
`templates/index.json` still says 30 days. It is a `collapsible-content` setting, so it is edited
in admin and Shopify commits it back — see CLAUDE.md, "Where to make the change".

**Verify now:**
```bash
grep -rn "30 days" sections/ snippets/ templates/     # must return NOTHING once the Q&A is fixed
grep -n "15 days" sections/main-product.liquid        # one hit, line ~654
```
In a browser: open any available product. The returns line must read "15 days of delivery", and
the "Full return policy" link next to it must open a page that also says 15 days.

**The new policy adds a clause the theme does not mention:** items bought in person, and items
marked Sale or Clearance, are final sale. Measured 2026-09-19 with
`productsCount(query: "tag:Sale OR tag:sale OR tag:Clearance OR tag:clearance")` → **0 products**,
so nothing on the site is affected today. If a Sale tag is ever used, this PDP line becomes wrong
again, because it promises returns unconditionally.

**Regression risk:** any number that is written down in more than one place. This one lived in
code, in a theme-editor field, and in a Shopify admin policy page — three owners, no single
source. The policy page is the binding one; the other two must follow it, never the reverse.

---

## 2026-09-19 · Bug · Three faults in the hero and trust strip
**Commit:** 9a8b656 · **Files:** sections/lena-hero.liquid, assets/lena-custom.css, templates/index.json

### 1. The theme editor kept putting a `<p>` back inside the H1

**What it did:** the `heading` setting is `inline_richtext`, but saving the section in the theme
editor stores the value wrapped in `<p>...</p>`. The markup was `<h1>{{ heading }}</h1>`, so the
page rendered `<h1><p>One piece at a time...</p></h1>` - a block element inside a heading, which
is invalid, and which adds the paragraph's bottom margin on top of `h1 { margin-bottom: 22px }`.

**Why it matters:** it was fixed once already, in `2f44b95`, by correcting the stored value in
`templates/index.json`. Commit `2ca5914` - a theme-editor save by the owner on 2026-09-16 - put
it straight back. Correcting stored data does not hold when a second system writes the same
field. The fix has to live where the value is *consumed*.

**The fix:** strip `<p>` and `</p>` on output. The stored value no longer matters.

### 2. The hero reserved roughly 240px of empty navy

**What it did:** `.lena-hero { min-height: 88vh }` plus `.lena-hero-content { padding: 80px }`.
The tallest thing inside is the mosaic at 510px (175 + 140 + 175 + two 10px gaps). On a 1000px
window 88vh is 880px, so the content centred and left wide empty bands above and below.

**The fix:** `min-height: 640px` (content is 622px at the new padding, so ~18px slack) and
padding 80px → 56px. Mobile was already `min-height: auto` / `padding: 56px 20px` and is
untouched.

### 3. The trust marquee jumped once per loop

**What it did:** `@keyframes lena-marquee` slides the track to `translateX(-50%)` and restarts.
That is only seamless if the second half of the track is an exact copy of the first. The track
held five items in the order 1, 2, 3, 1, 3 - so -50% did not even land on an item boundary, and
the strip visibly snapped every 28 seconds.

**The fix:** six items, 1, 2, 3, 1, 2, 3.

**Reproduce (before the fix):**
1. Homepage, desktop, tall window → wide empty navy above the eyebrow and below the buttons.
2. Watch the white badge strip for 30 seconds → it snaps back.
3. View source on the hero → `<h1><p>`.

**Verify now:**
```bash
grep -n "lena_heading" sections/lena-hero.liquid          # the replace filter
grep -n "min-height: 640px" assets/lena-custom.css        # not 88vh
python3 -c "
import re;s=open('templates/index.json').read();i=s.find('lena-marquee-track')
print(re.findall(r'<strong>([^<]+)</strong>', s[i:i+1600]))"
#   must print the same three names twice, in the same order
```
In a browser: the hero sits tighter top and bottom; the gap between the heading and the grey
paragraph is smaller; the badge strip scrolls without a snap. Check 640px and 900px - the mobile
rules were not touched, so both should look exactly as before.

**Regression risk:** fault 1 is the one to watch. Any Lena setting that is `inline_richtext` and
rendered into a heading has the same exposure, because the theme editor decides what it stores,
not us. Sanitise on output, never by correcting the stored JSON - that fix gets overwritten by
the next admin save and nobody is told.

---

## 2026-09-20 · Bug · The Shop by Category description stopped half way across the page
**Commit:** e885b34 · **Files:** assets/lena-custom.css

**What it does / did:** `.lena-section-sub` - the one-line description under the "Our Collections"
heading on the homepage - carried `max-width: 60ch`. The collection tiles directly below it run the
full 1200px page width, so the text broke onto a second line and ended well short of the right edge
while the image row continued past it. Removed the cap. The sentence now runs the full width of the
section on desktop, lining its right edge up with the tiles, and still wraps normally on narrow
screens because the container itself is the limit.

**Why it matters:** purely visual, but it is the first block of prose on the homepage and it read as
a layout mistake - a ragged column of text sitting on top of an edge-to-edge grid.

**Reproduce (before the fix):** open the homepage on a desktop browser at 1200px or wider, scroll to
"Our Collections". The description wrapped after "New pieces go up as" and the second line ended
around the middle of the page, while the four collection images below spanned the full width.

**Verify now:**
```
grep -n "max-width" assets/lena-custom.css | grep -n "60ch"   # expect no output
```
In a browser at 1280px: the description is one line whose right edge finishes near the right edge of
the last collection tile. At 640px it wraps to several lines with no horizontal scrolling.

**Regression risk:** `.lena-section-sub` is rendered only by `sections/collection-list.liquid`, and
"Our Collections" is the only section on the site using it, so nothing else moves. If a much longer
subtitle is ever typed into that field it will now run the full 1200px, which is a long line to
read - if that happens, cap it again at a width closer to the grid rather than at 60ch.

---

## 2026-09-20 · Feature · Match the Shop by Category description to the collection-name size
**Commit:** 7c90020 · **Files:** assets/lena-custom.css

**What it does / did:** `.lena-section-sub` was a fixed `font-size: 15px`. The collection names
under each tile are plain `<h3>` elements in `snippets/card-collection.liquid:86`, with no size
override anywhere, so base.css governs them: `calc(var(--font-heading-scale) * 1.7rem)` below 750px
and `1.8rem` above it. The subtitle now uses that same expression at both breakpoints.

**Why it matters:** two pieces of text stacked directly on top of each other at visibly different
sizes read as an accident. More importantly, the size is now *derived* rather than copied - the
heading scale is a theme setting the owner can change in admin, and a hardcoded 15px would have
silently stopped matching the first time it moved.

**Numbers, for reference only:** with `heading_scale: 110` and `body_scale: 105` in
`config/settings_data.json` (measured 2026-09-20), `--font-heading-scale` is 110/105 = 1.0476 and
`html` is `calc(var(--font-body-scale) * 62.5%)` = 10.5px per rem, so desktop lands near 19.8px and
mobile near 18.7px. Do not treat those as targets - the expression is the contract.

**Knock-on effect:** the previous entry said this sentence fits on one desktop line. At the larger
size it no longer does; it wraps to two full-width lines at 1200px. That is the size request
winning over the line-count, and it still aligns to the same left and right edges as the tile row.

**Verify now:**
```
grep -n "font-heading-scale" assets/lena-custom.css   # expect the two .lena-section-sub rules
```
In a browser: the description text and the words "Velvet Purses" should measure the same height.
Easiest check is to zoom in - the two should stay the same as each other at any zoom level.

**Regression risk:** if anyone ever adds a size to `.card__heading` for collection cards - in
`section-collection-list.css` or `lena-custom.css` - the two stop matching and this rule has to
follow. There is no size there today, which is the only reason reading base.css directly is safe.

---

## 2026-09-20 · Bug · Four blocks of prose on the homepage were four different sizes
**Commit:** 999a5f4 · **Files:** assets/lena-custom.css

**What it does / did:** the owner asked for the top menu, the hero subheading, the Our Story
paragraphs and the Shop by Category description to be the same size, with Our Story as the
reference. Measured first, 2026-09-20:

| Text | Set by | Desktop size |
|---|---|---|
| Top menu links | nothing - inherits `body` | 1.6rem |
| Our Story paragraphs | nothing - inherits `body` | 1.6rem |
| Hero subheading | `.lena-hero-sub` hardcoded | 16px |
| Shop by Category description | `.lena-section-sub` hardcoded | `--font-heading-scale * 1.8rem` |

Two of the four already agreed because neither declares a size - `component-list-menu.css` and
`component-image-with-text.css` contain no `font-size` at all, so both fall through to the `body`
rule in `layout/theme.liquid:236` (1.5rem, 1.6rem from 750px up). The fix was therefore to delete
the two hardcoded sizes rather than add a third number. All four now read one rule.

**Why it matters:** it is the difference between four sizes that happen to be close today and four
sizes that cannot drift apart. The body scale is a theme setting the owner can change in admin;
`16px` would have stopped matching the first time it moved.

**Reproduce (before the fix):** homepage at 1280px. The Shop by Category description was visibly
larger than the Our Story paragraphs directly above it, and the hero subheading was fractionally
smaller than the menu above it.

**Verify now:**
```
grep -n "lena-hero-sub" -A8 assets/lena-custom.css     # expect no font-size line
grep -n "lena-section-sub" -A6 assets/lena-custom.css  # expect no font-size line
```
In a browser, zoom to 200% - the top menu, hero subheading, Our Story text and Shop by Category
description should stay identical to each other at every zoom step. `line-height`, colour and
weight were left alone deliberately, so the blocks still look different in other ways.

**Regression risk:** this works only because nothing between `body` and these elements sets a size.
Adding a `font-size` to `.lena-hero`, `.lena-hero-content`, `.lena-hero-text`, `.collection-list-
wrapper` or `.page-width` would break the match silently, with no error anywhere. The reverse of
the earlier entry today: matching `h3` here was the wrong reference and lasted one screenshot.

---

## 2026-09-20 · Bug · The Shop by Category description touched both screen edges on mobile
**Commit:** 436c2c5 · **Files:** sections/collection-list.liquid

**What it does / did:** on screens under 750px, `assets/section-collection-list.css:16` sets
`.section-collection-list .page-width { padding-left: 0; padding-right: 0 }` - it removes the
section's side padding outright, and each child is expected to supply its own. The heading does,
through `title-wrapper--self-padded-mobile` (1.5rem, `base.css:800`); the tile grid does, through
`.section-collection-list .collection-list:not(.slider)` (1.5rem, same file). The Lena subtitle
`<div>` had neither, so it rendered at 0 while everything around it was inset by 1.5rem. Fixed by
giving it the same class the heading uses, under the same `show_mobile_slider` condition - no new
CSS, and nothing to keep in step by hand.

**Why it matters:** text touching the edge of a phone screen reads as broken layout, and it was the
only element in the section doing it, which made the heading look wrongly indented rather than the
paragraph wrongly flush.

**Reproduce (before the fix):** homepage at 390px wide, scroll to "Our Collections". The heading
and the collection tiles started ~1.5rem in; the description started at x=0 and its last line broke
mid-word ("in-person") against the right edge.

**Verify now:**
```
grep -n "title-wrapper--self-padded" sections/collection-list.liquid   # expect 2 hits: heading, subtitle
```
In a browser at 390px: the first letter of the description lines up under the first letter of "Our
Collections" and under the left edge of the first tile. At 750px and above the class zeroes itself
out by design, so desktop is unchanged - check that too.

**Regression risk:** these classes zero their padding at different breakpoints (750px for
`--self-padded-mobile`, 990px for `--self-padded-tablet-down`), which is exactly why the condition
was copied from the heading rather than one class being picked. If the heading's condition ever
changes, this one has to change with it. `swipe_on_mobile` is `false` for this section today, so
only the `--self-padded-mobile` branch is live.

---

## 2026-09-20 · Bug · The hero was off-centre and had five different spacing values
**Commit:** b55b816 · **Files:** assets/lena-custom.css

**What it does / did:** the owner marked six gaps in the hero that should have matched and did not.
Measured in the CSS, 2026-09-20, the hero was using: 56px above and below the content, 24px to its
left and right, 56px between the two columns, 22px below the eyebrow, 22px below the h1 and 36px
below the description. Four separate faults:

1. **Off-centre.** `.lena-hero` is `display: flex`. A flex item with no width is sized by its own
   content, so `.lena-hero-content`'s `max-width: 1200px` was frequently never reached and
   `margin: 0 auto` had no leftover space to centre with. Adding `width: 100%` makes the box fill
   the row first and then cap, so the auto margins are equal by construction.
2. **Not aligned with the rest of the page.** That `1200px` was a second hardcoded copy of the
   theme's page width. Now `var(--page-width)`, the same variable `base.css:80` gives `.page-width`,
   so the hero's edges line up with Our Collections below it and both follow the admin setting.
3. **Uneven padding.** `56px 24px` became `56px`. The gap to the left of the text was previously
   less than half the gap above it.
4. **Columns floating.** `align-items: center` made the shorter of the two columns float in the
   middle of the taller one - the mosaic sat below the eyebrow and above the buttons rather than
   squaring off with them. Removed, so the grid default `stretch` applies. To make stretch actually
   do something, `.lena-hero-mosaic` rows went from `175px 140px 175px` to `175fr 140fr 175fr` with
   `min-height: 510px` as the floor (the old fixed total: 175+140+175 plus two 10px gaps). The
   mosaic now fills the row height at the same proportions, so its top, left and bottom gaps are all
   56px.

Separately, `.lena-hero-sub`'s `margin-bottom` went 36px to 22px, matching the eyebrow and the h1,
so every gap inside the left column is now the same number.

**Why it matters:** the hero is the first thing on the site. Off-centre by itself reads as broken,
and edges that do not line up with the section below it make the whole page look untidy.

**Reproduce (before the fix):** homepage at 1280px. The left text started closer to the screen edge
than the mosaic finished from the right one; the mosaic's top edge sat below the eyebrow and its
bottom edge above the buttons; the gap under the description was visibly larger than the gap above
it.

**Verify now:**
```
grep -n "lena-hero-content" -A10 assets/lena-custom.css   # width:100%, var(--page-width), padding:56px, no align-items
grep -n "lena-hero-mosaic" -A7 assets/lena-custom.css     # 175fr 140fr 175fr, min-height 510px
```
In a browser at 1280px: the left edge of "ARTISAN-CRAFTED IN VIETNAM" should sit directly above the
left edge of the "Our Collections" heading further down the page. The mosaic's top edge should be
level with the top of the eyebrow and its bottom edge level with the bottom of the buttons.

**Regression risk:** `min-height: 510px` has to be cleared at every breakpoint that switches the
mosaic to fixed pixel rows, or it forces a 510px box onto a 370px stack. The `max-width: 900px`
block now sets `min-height: 0` for exactly this reason, and it carries down to the 640px block
because that one never sets `min-height` again. Any new mosaic breakpoint must do the same. The fr
rows also mean very long hero text stretches the images taller - that is the intended trade for
matching gaps, but a much longer subheading is the thing that would show it.

---

## 2026-09-20 · Bug · CLAUDE.md told the next reader the return window was 30 days
**Commit:** 13ed4be · **Files:** CLAUDE.md

**What it does / did:** the "Modified stock files" table described `sections/main-product.liquid` as
carrying "30-day returns". The PDP has said **15 days** since the return-window fix. The same row's
line ranges (`101–140, 300–420, 593, 630–645`) were also stale: line 593 holds no `Lena:` marker at
all, and the return blurb it was meant to point at is at 648–658, outside every listed range.

Both are corrected, and a new bullet under *Shopify Liquid patterns* records that the return window
is written by hand in three unlinked places, with the command that finds them.

**Why it matters:** CLAUDE.md is the first file read before any edit, including by a subagent. A
number in it is trusted without checking. Someone asked to "make the FAQ agree with the product
page" would have set the FAQ to 30 days from this table and reopened the exact contradiction that
the outside review called the single biggest issue it found. The stale line ranges are the same
hazard in the other direction — the table exists to stop people editing outside the marked ranges,
and pointing at line 593 sends them to stock Craft code.

**Reproduce (before the fix):** `grep -n "30-day" CLAUDE.md` returned the `main-product.liquid` row,
while `grep -n "days of delivery" sections/main-product.liquid` returned `15 days of delivery`. The
two disagreed.

**Verify now:**
```
grep -rn "days of delivery" sections/ templates/   # two hits, both "15 days of delivery"
grep -c "30-day" CLAUDE.md                         # 0
grep -n "Lena:" sections/main-product.liquid       # markers fall inside the ranges now in the table
```
The Refund Policy page is the third copy and is not in git — check it in Shopify admin → Settings →
Policies. Measured 2026-09-20: "Returns are accepted within 15 days of delivery, on all products."

**Regression risk:** the return window still lives in three places with nothing linking them, so any
future change reopens this. The new bullet under *Shopify Liquid patterns* names all three and gives
the grep; a change that edits one of them without the other two is the failure mode. The line-number
columns in that table decay on every edit to a stock file — treat any range there as a hint, and
confirm with `grep -n "Lena:"` before editing.

---

## 2026-09-20 · Bug · The hero heading broke into four lines and split a word on desktop
**Commit:** fcbe8d1 · **Files:** assets/lena-custom.css

**What it does / did:** `.lena-hero h1` was `clamp(36px, 5vw, 58px)`. Both the cap and the middle
value size the text against the **viewport**, but the heading is not in the viewport - it is in the
left half of a two-column grid. At the 1200px page width that column is about 516px
(`1200 - 112px padding - 56px gap`, halved). 58px no longer fitted, so the two sentences broke into
four lines and the hyphen in "mass-produced" became a line break:

```
One piece at a          One piece at a time.
time.             vs    Never mass-produced.
Never mass-             (mobile, one column)
produced.
```

Now `clamp(36px, 4vw, 50px)`.

**Why it matters:** this is the H1, the first line of the site. A word split at its hyphen reads as
broken rather than styled, and four ragged lines push the buttons down the page. Mobile was already
correct, which is what made it look like a desktop fault rather than a copy-length problem.

**Reproduce (before the fix):** homepage at 1280px wide, heading set to
`One piece at a time.<br><strong>Never mass-produced.</strong>`. The heading rendered on four lines
with "Never mass-" and "produced." on separate lines. The same page at phone width rendered two
clean lines.

**How the numbers were chosen - read this before changing them.** The width one line needs was
derived from the mobile rendering, which does fit: 20 characters occupied the full text column at
the clamp minimum, giving roughly **0.465em of width per character**, so a 20-character sentence
needs about **9.3em**. Applied to the narrowest column at each width where the grid has two columns:

| Viewport | Text column | Font | Line needs | Fits |
|---|---|---|---|---|
| 900px (two columns begin) | 366px | 36px (min) | 335px | yes |
| 1000px | 416px | 40px | 372px | yes |
| 1200px | 516px | 48px | 446px | yes |
| 1440px+ | 516px | 50px (cap) | 465px | yes |

**That 0.465em is an estimate read off a screenshot, not a measured font metric.** It has not been
run against a positive and a negative case, so by the project's own measurement rule the table above
is a draft. It is recorded because it shows *why* these numbers and not others - the browser check
below is what actually confirms the fix.

**Verify now:**
```
grep -n "lena-hero h1" -A2 assets/lena-custom.css   # clamp(36px, 4vw, 50px)
```
In a browser, each sentence must sit on exactly one line, and "mass-produced" must never split, at
**1440px, 1280px, 1200px, 1000px and 900px**. 900px is the tightest case - it is the first width
where the grid has two columns and the font is already at its 36px floor, so it cannot shrink
further to compensate. Below 900px the hero is one column and this rule does not apply.

**Regression risk:** these values are a fitting constraint tied to the current heading text. A longer
heading set in the theme editor - the field is admin-owned, so it can change without touching code -
will overflow the column again, and nothing warns anyone. The failure is always the same shape: the
longest sentence wraps, usually at a hyphen. If the heading grows, the cap comes down, or the text
column gets more of the grid than `1fr 1fr` gives it.

---

## 2026-09-20 · Bug · All the hero's leftover vertical space piled up under the buttons
**Commit:** a90de8d · **Files:** assets/lena-custom.css

**What it does / did:** the hero is a two-column grid. The text column holds less than the mosaic
beside it, so the row is as tall as the mosaic and the text column stretched to match - but its
*content* stayed at the top, putting every pixel of leftover space in one block below the buttons.
`.lena-hero-text { align-self: center }` takes that one column out of the default `stretch`, so the
leftover space is split evenly above and below the text instead.

**Why it matters:** the gap under the buttons read as an unfinished section rather than as spacing.
It is also the kind of fault that gets worse on its own - every word removed from the heading or
subheading makes the text column shorter and the gap below it bigger.

**Reproduce (before the fix):** homepage at 1280px. The eyebrow sat level with the top of the
mosaic, the buttons ended roughly two thirds of the way down, and the remaining third of the left
column was empty.

**Supersedes part of the earlier entry today.** The 2026-09-20 centring fix
("The hero was off-centre and had five different spacing values", commit `b55b816`) told you to
verify that *"the mosaic's top edge should be level with the top of the eyebrow and its bottom edge
level with the bottom of the buttons."* **That check is no longer correct and must not be used.**
Top-edge alignment was the side effect of both columns stretching; centring the text column
deliberately trades it away. Everything else in that entry still holds - in particular the mosaic
still stretches, so its own top, left and bottom gaps are all still 56px.

**Verify now:**
```
grep -n "lena-hero-text" -A3 assets/lena-custom.css   # align-self: center
```
In a browser at 1280px: the empty space above the eyebrow and the empty space below the buttons
should look the same size. The mosaic's top, left and bottom gaps should each still be 56px. At
640px and 900px the hero is one column, every item is its own row sized by its content, and nothing
should move at all - that is the check that this did not leak into mobile.

**Regression risk:** returning `align-items: center` to `.lena-hero-content` would apply this to the
mosaic as well, which is what caused the original off-centre and uneven-gap faults - the mosaic must
keep stretching. Any future breakpoint that keeps two columns needs to decide this again; the rule
only makes sense while the two columns have different content heights.

---

## 2026-09-20 · Bug · Filtering a collection to no matches showed a blank area with no message
**Commit:** `40ccdea` · **Files:** sections/main-collection-product-grid.liquid, docs/regression-check.sh

**Batch 1 of the CODE_SURVEY_2026-09-20 work** (survey finding A2). Batched with the banner `<h1>`
entry below because both are the same visitor on the same page.

**What it did:** stock Craft renders *"No products found — Use fewer filters or remove all"* with a
working clear-all link when `collection.products.size == 0`. A Lena change deleted that block and
left a comment in its place reading *"lena-drop-coming-soon section handles messaging."* That claim
was wrong in both directions:

1. `templates/collection.json` — the template every ordinary collection uses — does not contain
   `lena-drop-coming-soon` at all. Its section list is banner + grid, nothing else.
2. Where that section *does* exist (the two New Arrivals templates) it is gated on
   `collection.all_products_count == 0`. A filter never makes that true, so it correctly stays
   hidden — and nothing took its place.

**What it does now:** the zero branch splits the two cases that reach it. A genuinely empty
collection still renders nothing here, because `lena-drop-coming-soon` really does own that message.
A collection filtered down to no matches gets the stock block back, including the *remove all* link
pointing at `collection.url`.

**Why it matters:** `/collections/compact-mirrors` holds 145 products and has filtering switched on.
A colour facet matching nothing gave the visitor a banner, a row of filter chips, and then empty
space — no message, no explanation, and no route back except the chips themselves. Nothing on the
page said the filter was the reason. This is the most common dead end in a filtered catalogue and
the theme had no answer for it.

**How it got here:** this is a *residual* of the R3 fix, not a regression of it. R3's own symptom —
the `<h1>` disappearing under a filter — is genuinely fixed. The R3 write-up never recorded that the
stock empty state had already been removed underneath it, so nobody knew there was a hole left.

**Reproduce (before the fix):**
1. Open `/collections/compact-mirrors`.
2. Tick a colour facet that shows `(0)`, or any combination matching nothing.
3. Saw: banner, filter chips, blank space. Expected: a message and a way to clear the filters.

**Verify now:**
```
bash docs/regression-check.sh          # assertions 1 and 2 under "Fixed bugs"
sed -n '/products.size == 0/,/else/p' sections/main-collection-product-grid.liquid
```
In a browser: `/collections/compact-mirrors`, apply a filter matching nothing. You should see
**"No products found / Use fewer filters or remove all"**, and *remove all* must clear every facet
and bring the grid back. Then check `/collections/new-arrivals` (0 products, measured 2026-09-20)
still shows the "preparing something special" section and **not** this message — that is the
negative control, and it is the half that the original change got right.

**Regression risk:** collapsing the two branches back into one. They look redundant — both are
"there is nothing to show" — but `products.size` is the filtered view and `all_products_count` is
the collection total, and the visitor needs a different sentence for each. Any future edit that
reaches for one count to answer both questions brings this back.

---

## 2026-09-20 · Bug · A genuinely empty collection page had no `<h1>` at all
**Commit:** `40ccdea` · **Files:** sections/main-collection-banner.liquid, docs/regression-check.sh

**Batch 1 of the CODE_SURVEY_2026-09-20 work** (survey findings B1 and B11).

**What it did:** the whole banner — eyebrow, `<h1>`, description and count pill — was wrapped in
`{%- if collection.all_products_count > 0 -%}`. When a collection genuinely held nothing, the page's
first and only heading was the `<h2 class="lena-section-h">` inside `lena-drop-coming-soon`. That is
a page with no title, and a heading order that starts at h2.

**What it does now:** the banner always renders. The count pill keeps its own `products_count > 0`
test, so it still hides itself rather than saying "0 pieces".

**Why it matters:** a collection page's `<h1>` is its title. Search engines and screen readers both
read it as the page's name, and there is no product count at which a page should stop having one.
This was live-reachable, not hypothetical: `/collections/new-arrivals` and
`/collections/this-weeks-drop` both hold 0 products (measured 2026-09-20 via
`collectionByIdentifier(identifier: {handle: "..."}) { productsCount { count } }`).

**The irony worth recording:** the comment block directly above that gate argues at length *against*
losing the `<h1>`. It makes the argument for the filtered case, fixes that, and then removes the
`<h1>` for the empty case two lines later. Getting half of a rule right is what made this invisible.

**Also in this change (survey B11):** the description's test read
`show_collection_description and collection.all_products_count > 0`, but the whole block already sat
inside the count gate, so the second half could never be false. With the outer gate gone it would
have quietly become live and started hiding the description on empty collections, so it was removed
rather than left to change meaning on its own.

**Reproduce (before the fix):**
1. Open `/collections/new-arrivals` (0 products).
2. View source, search for `<h1`.
3. Saw: no `<h1>` anywhere on the page. Expected: the collection title.

**Verify now:**
```
bash docs/regression-check.sh          # assertions 3 and 4 under "Fixed bugs"
grep -n "all_products_count" sections/main-collection-banner.liquid   # comment prose only
```
In a browser: `/collections/new-arrivals` must show the Collection eyebrow and the title **New** as
its `<h1>`, with the "preparing something special" block beneath it and **no** count pill. Then
`/collections/compact-mirrors` (145 products) must be unchanged, pill included — that is the
positive control.

**Note for whoever writes the collection copy:** the `new-arrivals` collection's title in admin is
**"New"**, not "New Arrivals". Nothing showed it before, because the homepage bar's heading is a
theme setting. This change puts it on screen, so it is now worth renaming in admin if "New" reads
oddly as a page title.

**Regression risk:** re-adding a count gate around the banner. It will look like the right fix the
next time a filtered page misbehaves, because that is exactly how it was introduced the first time.
The regression check asserts the gate is absent for this reason.

---

## 2026-09-20 · Bug · A card with no photo silently lost its scarcity line, and two other copies of the same rule could not tell
**Commit:** `00ee335` · **Files:** snippets/lena-stock.liquid (new), snippets/lena-notify-button.liquid (new), snippets/card-product.liquid, sections/main-product.liquid, sections/lena-featured-piece.liquid, docs/regression-check.sh

**Batch 2 of the CODE_SURVEY_2026-09-20 work** (survey findings B2 and C1–C4). The bug and its
duplicates are fixed together on purpose; fixing only the bug would have left two copies free to
drift again, which is how it got here.

**What it did:** `snippets/card-product.liquid` assigned the stock quantity at line 109, *inside*
`{%- if card_product.featured_media -%}` (the branch spanning lines 61–151), and read it again at
line 256, *outside* that branch. For a product with no featured image the variable was never set, so
`{%- if card_product.available and lena_qty == 1 -%}` was false and the **"Only piece in existence"**
line vanished. No error, nothing in the linter, nothing on screen to notice. The `1 of 1` badge, the
`New` badge and the sold-out overlay all sat in the same branch and disappeared with it.

**Why it matters:** "Only piece in existence" is the sentence that makes a one-of-a-kind catalogue
feel one-of-a-kind. Losing it costs nothing visible and everything persuasive.

**This is the same fault as R19, in a second place.** R19 was the PDP version: the quantity was
assigned inside the `title` block and read from `price`, and reordering blocks in the theme editor
emptied it. That was fixed by hoisting the assign and writing a comment explaining why.
`card-product` never got the same treatment, because nothing connected the two.

**Latent today, not reachable — and why it will not stay that way.** Of the first 250 of 296 active
products, 6 have no featured media, and all 6 are POS-tagged; every POS product has
`publishedAt: null`, so none is reachable from the storefront. It becomes reachable the first time a
published product is created before its photo is uploaded, which is the normal order of work.

**What it does now:** two new snippets own these rules outright.

- `snippets/lena-stock.liquid` — takes `product`, `style` (`card` / `pdp` / `featured`) and `part`
  (`badge` / `scarcity`). It computes the quantity itself, at the call site, every time. **There is
  no quantity variable left anywhere to read out of scope**, which is what makes this fix
  structural rather than something to remember.
- `snippets/lena-notify-button.liquid` — takes `product` and `style`. It captures
  `lena-notify-target`, splits on the pipe and calls `window.lenaNotify(label, handle)`. Getting
  that argument order wrong files a signup under the wrong category silently, so it should never
  have been written twice.

Three copies of the badge, three of the scarcity line and two of the Notify button collapse to one
each. `style` picks the CSS class only — it never changes the wording.

**One deliberate behaviour change.** The scarcity line is now gated on `product.available` as well
as a quantity of 1. `card-product` and `main-product` already did this; `lena-featured-piece` tested
the quantity alone, which was safe only because its pool is pre-filtered with `where: 'available'`.
The extra test changes nothing today and stops the section depending on a filter applied elsewhere.

**What was deliberately NOT extracted.** "This piece found its home" is written twice, but the card
paints it across the image as an overlay and the PDP prints it as a line under the price. They share
a sentence, not an element, and a snippet that renders two unrelated shapes is worse than two lines
of duplication. Both call sites now carry a comment saying so.

**Reproduce (before the fix):**
1. In admin, create a published product with inventory 1 and **no image**.
2. Put it in any collection and open that collection page.
3. Saw: a text-only card with no "Only piece in existence" line. Expected: the line, as on every
   other one-of-a-kind card.

**Verify now:**
```
bash docs/regression-check.sh
grep -rn "lena_qty" snippets/card-product.liquid      # must return nothing
grep -rl "lena-badge-1of1" sections/ snippets/        # only snippets/lena-stock.liquid
```
The script asserts each of the six badge/scarcity class names appears in exactly one file. In a
browser, check all three surfaces still look identical to before:
- **a collection page** — `1 of 1` badge over the image, "Only piece in existence" under the price
- **a PDP** — the same two, plus "Notify me of similar items" on a sold-out product
- **the homepage Featured Piece** — the same two
Then the actual fix: a published product with inventory 1 and no photo must now show the scarcity
line.

**Regression risk:** someone needing the quantity for a fourth thing and assigning it at the call
site again "just this once". The next copy will agree on the day it is written and drift later, the
same way these three did. If a new surface needs the badge, give `lena-stock` a new `style`; if it
needs the number for something else, that is a new `part`, not a new `assign`.
