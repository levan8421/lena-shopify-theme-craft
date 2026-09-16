# Open items

**Only what is open.** Closing an item removes its row and writes a `DEVLOG.md` entry instead, so the
same fact is never recorded twice. Everything here was lifted out of the Tier 0 responses and the
May 2026 plan so those can be archived without losing the tail.

Last swept: 2026-09-15.

---

## Theme code

### A6 · `color-clear` is silently deleted from the Color facet

The store carries **15** `color-*` tags; the live Color facet renders **14**. `clear` is absent from
the ~55-name whitelist in `snippets/facets.liquid` (desktop ~line 204, drawer ~line 592), so products
tagged `color-clear` are **unreachable by colour**, and nothing in the UI indicates a value is
missing. Any future colour outside the hardcoded list vanishes the same way.

Recommended fix: **invert the whitelist** — render any `color-*` value and strip the prefix for the
label, rather than matching against a fixed list. A whitelist that fails silently is worse than no
whitelist.

Held report-only under the Part C protection. Worth re-raising with the auditor: the protection was
written on the belief that the filters "all work", which this contradicts.

**Verify:** compare the tag list against the rendered facet.
```
# every color-* tag on the store, vs what the facet renders
shopify app ... / Admin API: productTags  →  expect 15
open /collections/available-now and count the Color facet entries  →  renders 14
```

### The colour whitelist is duplicated

The same ~55 names appear twice in `snippets/facets.liquid` — desktop and mobile drawer. The two can
drift. Folding them into one `{% assign %}` or a snippet removes the class of bug entirely. Fix this
in the same pass as the item above.

### Notify Me reports success on failure

`snippets/lena-notify-modal.liquid` submits with `fetch('/contact', …).then(…)` and has **no
`.catch` and no response-status check**. A network failure or a rejected submission still swaps the
form for "You'll be the first to know!", so the visitor believes they signed up when they did not.

Fix: check `response.ok`, and show an error state on the failure path.

---

## Admin · data, not theme

### T0-16 · Filter facet names match the canonical eight 1 time in 7

The live **Product Categories** facet and the nav taxonomy give two names for the same family, on the
same page:

| Filter facet | Canonical name | Match |
|---|---|---|
| Crochet Figures | Crochet Dolls | ✗ |
| Compact Mirrors | Artisan / Motif Compact Mirrors | ✗ — unsplit |
| Hats | Ribbon-Embroidery Hats | ✗ |
| Velvet Purses | Velvet Purses | ✓ |
| Rattan Bags | Rattan Purses | ✗ |
| Beaded Purses | Glass Bead Woven Handbags | ✗ |
| Phone Wallet | Phone Travel Wallet | ✗ |

Counts total correctly, so coverage is complete — this is purely naming. Lives in **Search &
Discovery** configuration, not theme code. **Settle before the `Shop ▾` menu ships**, or the nav
restructure introduces the inconsistency it exists to remove.

### Smaller data items

- A bare `Black` tag coexists with `color-black` — one tag, cleanup.
- `Phone Travel Wallet` → **`Phone Travel Wallets`** (pluralisation, for consistency with the other
  seven category names).
- Currency format → `${{amount}}`. Admin UI only; no API surface.
- **Shop Pay marketing consent** — read *Settings → Checkout → marketing sign-up*. Not exposed in the
  Admin API, so a human has to look.

---

## Admin · store setup

### Theme rollback record — rename before publishing

Three themes carry near-identical names and two were updated in the same minute. At 10pm under
pressure, "roll back to website-redesign" is a coin flip.

```
192252215618  lena-shopify-theme-craft/website-redesign          MAIN (published)
189601186114  legacy lena-shopify-theme-craft/website-redesign   unpublished
189535355202  lena-handicrafts/website-redesign                  unpublished
```

**Rename the two unpublished ones before anything is published.**

### Drop copy still live on the storefront

Two strings still promise the retired weekly cadence. Both live in admin-owned files, so code cannot
reach them — CLAUDE.md routes header and footer to the theme editor, and deleting an announcement
block is structural.

```bash
grep -rin "drop list\|next drop" sections/header-group.json sections/footer-group.json
#   header-group.json:27  "Next drop: Friday 8 PM ET →"
#   footer-group.json:20  "Join the Drop List"
```

- [ ] Header → Announcement bar → **delete** the `Next drop: Friday 8 PM ET →` block. Keep free shipping.
- [ ] Footer → Newsletter heading → **`Join the List`**
- [ ] Footer → Newsletter paragraph → **`Be first when new pieces go live.`**

Then `git pull` on `website-redesign`. Until this is done the storefront still advertises a Friday
drop, whatever the code says.

### Refund policy vs the new PDP wording

- [ ] Read `/policies/refund-policy` against the 30-day returns line now on the PDP. If they
      conflict, **raise it** — a legal page should not be rewritten to match marketing copy.

### The `Shop ▾` menu

Not a theme change — the stock dropdown and drawer already render three levels. The exact build spec
with verified handles is in `TIER0_DEVELOPER_RESPONSE_V2.md`. Blocked on the T0-16 naming decision
above.

### Unverified, carried from the May 2026 plan

- `Sale` collection and clearance pricing — never confirmed as done.
- Whether `/pages/care-instructions`, `/pages/faq`, `/pages/find-us`, `/pages/our-story` exist.
- **`/pages/drop-calendar` should not be created.** Its entire content was the Friday cadence.

---

# Full theme review — 2026-09-16

Whole-theme survey: homepage stack, PDP, cards, collection and search templates, facets,
modals, CSS, and accessibility. Read-only — **nothing was changed**.

**Legend.**

*Origin* — `Lena file` a file Lena created; `Lena in stock` a Lena-added range inside a stock
Craft file; `admin setting` a value in a theme-editor-owned JSON, not code; `store data`
neither; `Shopify search` a fault on Shopify's side, outside this repository. No finding is an
inherited stock Craft defect — though this review covered the custom surface and the stock
code next to it, not the whole of unmodified Craft 15.4.1.

*Status* — `open` means not changed yet. `fixed` means the change is committed.

*Review* — `not yet` means nobody has checked it in a browser. `passed` means someone followed
the **Verify** steps for that item and it worked. `failed` means someone followed them and it
did not work. A fix stays `not yet` until a person looks at it; `failed` is a real verdict and
is never used to mean "unchecked".

| # | Bug | Origin | Status | Review |
|---|---|---|---|---|
| R1 | Featured Piece points at collection handle `artisan`, which does not exist — section renders nothing, and the homepage has no products at all | admin setting | fixed | not yet |
| R2 | Quick add on search is inert: schema default is `none` and `search.json` never sets it | admin setting | fixed | not yet |
| R3 | Filtering a collection to zero results removes the `<h1>` and shows "we're preparing something special" | Lena in stock | fixed | not yet |
| R4 | Email popup and Notify modal report success on a failed submit; the popup also suppresses itself permanently | Lena file | fixed | not yet |
| R5 | Card "New" badge uses a 7-day `created_at` window — a second definition of "new" competing with the app-owned tag | Lena in stock | fixed | not yet |
| R6 | Hero's padding sliders are bound to nothing | Lena file | fixed | not yet |
| R7 | Hero heading is `richtext`, emitting `<p>` inside `<h1>` | Lena file | fixed | not yet |
| R8 | Hero mosaic links have no accessible name when image alt is empty | Lena file | fixed | not yet |
| R9 | Section eyebrow `#2E8FD9` on snow measures 3.35:1 — fails WCAG AA at 11px | Lena file | fixed | not yet |
| R10 | Scarcity green on white measures 4.34:1; card category grey 4.50:1 — both under AA | Lena file | fixed | not yet |
| R11 | Every section title is a `<div>`, not a heading — homepage outline jumps h1 → h3 | Lena file | fixed | not yet |
| R12 | Related products filters sold-out pieces out of the top-up pass but not the recommendations pass | Lena in stock | fixed | not yet |
| R13 | Breadcrumbs and related-products top-up both fail for products outside the 7 canonical collections | Lena file | open | not yet |
| R14 | Notify Me tags by `product.type`, not the canonical collection handle | Lena in stock | open | not yet |
| R15 | Featured Piece pool is capped at 50 by `collection.products` — no Liquid fix exists; now documented in the section and its help text | Lena file | open | not yet |
| R16 | Featured Piece monthly rotation can only ever surface 12 items | Lena file | fixed | not yet |
| R17 | Both modals declare `aria-modal` but never move, trap, or restore focus | Lena file | fixed | not yet |
| R18 | Testimonial star ratings have no text alternative | Lena file | fixed | not yet |
| R19 | PDP `lena_qty` depends on block order — moving the title block kills the badge and scarcity line | Lena in stock | fixed | not yet |
| R20 | Six sections with `presets` lack the `disabled_on` header/footer guard | Lena file | fixed | not yet |
| R21 | Colour-filter logic is written six times, with two different conditions | Lena in stock | open | not yet |
| R22 | `main-404.liquid` carries a 175-line inline `<style>` block | Lena file | open | not yet |
| R23 | Inline styles across five Lena files | Lena file | open | not yet |
| R24 | Empty-state paragraph hardcodes navy text, ignoring `color_scheme` | Lena file | fixed | not yet |
| R25 | Find Us computes its 14-day event window twice | Lena file | fixed | not yet |
| R26 | `lena-drop-header` takes a typed collection handle instead of a picker | Lena file | open | not yet |
| R27 | `.product__title > a` display rule is duplicated between stock and custom CSS | Lena file | fixed | not yet |
| R28 | A6 (`color-clear`) is stale — the tag no longer exists | store data | open | not yet |
| R29 | Search results mix in pages and blog posts — "Our Story" appears among the products | Lena in stock | fixed | not yet |
| R30 | Search says "167 results" but most result pages are nearly or completely empty | Shopify search | open | not yet |
| R31 | An empty search page says "Use fewer filters" even when no filter is applied | Lena in stock | fixed | not yet |

---

## R1 · Featured Piece points at a collection that does not exist

`templates/index.json` sets the Featured Piece collection to the handle **`artisan`**. There is
no such collection on the store. `fp_collection` resolves blank, the `{%- if -%}` guard at
`sections/lena-featured-piece.liquid:31` fails, and the section renders **nothing** — correctly,
by its own design, but for the wrong reason.

The consequence is larger than one section. All three product surfaces on the homepage are
simultaneously absent:

| # | Section | Why it renders nothing |
|---|---|---|
| 4 | New Arrivals bar | `new-arrivals` holds 0 products |
| 5 | New Arrivals grid | same collection, same gate |
| 6 | Featured Piece | collection handle `artisan` does not exist |
| 7 | Available Now | `"disabled": true` in `index.json` |

**Between "Our Story" and "Shop by Category" the homepage currently shows no product at all.**
Each guard is individually correct; nothing checks the set. The nearest real handle is
`artisan-compact-mirrors` (40 products) — the setting reads like a truncation of it.

**Verify:**
```bash
# the handle resolves to nothing
#   Admin API: collectionByHandle(handle: "artisan")  ->  null   (measured 2026-09-16)
grep -A2 '"lena_featured_piece' templates/index.json | grep collection
#   "collection": "artisan"
```
Then load the homepage and scroll from Our Story to Shop by Category — no product appears.

**Regression risk:** any `type: "collection"` setting whose handle is retyped or renamed in
admin. The section hides itself rather than erroring, so this class is always silent.

---

## R2 · Quick add on search is built but switched off

`sections/main-search.liquid` gained the `quick_add` setting, the conditional asset loading and
the pass-through to `card-product` (commit 262289b). The schema default is `"none"`
(`main-search.liquid:459`), and `templates/search.json` does not set `quick_add` at all.

So the setting resolves to `none`, `quick-add.css` and `quick-add.js` never load, and search
cards still cannot show Add to cart — the exact gap the commit set out to close. The collection
templates both set `"quick_add": "standard"` explicitly; search was missed.

**Verify:**
```bash
grep -n '"quick_add"' templates/*.json
#   collection.json:            "quick_add": "standard"
#   collection.new-arrivals.json: "quick_add": "standard"
#   search.json:                (absent)
sed -n '457,460p' sections/main-search.liquid   # "default": "none"
```
Search for a term returning in-stock pieces; compare a card there with the same card on
`/collections/available-now`.

**Regression risk:** any new template that renders a section whose feature is opt-in by default.

---

## R3 · Filtering a collection to zero results dismantles the page

Two independent gates key off the *filtered* product count rather than the collection total:

- `sections/main-collection-banner.liquid:13` — `{%- if collection.products_count > 0 -%}` wraps
  the **entire banner**: the eyebrow, the `<h1>`, the description and the count pill.
- `sections/lena-drop-coming-soon.liquid:11` — `{%- if collection.products.size == 0 -%}` renders
  the empty-state.

CLAUDE.md states the rule these violate: *"`all_products_count`, not `products_count`: the latter
reflects the current tag-filtered view. Use `all_products_count` for any visibility decision."*

A shopper on New Arrivals who filters to a combination with no matches therefore gets a page with
**no heading at all**, headed instead by "Fresh From Vietnam / New Arrivals / We're preparing
something special" — which reads as *the collection is empty*, not *your filter matched nothing*.
The filter chips stay on screen above it, contradicting the copy. There is no "clear filters"
affordance in that state because the banner that would have carried it is gone.

Note `collection.new-arrivals.json` sets `enable_filtering: false`, so New Arrivals itself cannot
reach this state today; `collection.json` sets `enable_filtering: true`, so every other collection
can — for the banner half. The empty-state section only sits on the two New Arrivals templates.

**Verify:** open `/collections/compact-mirrors`, apply a colour filter with no matches (the facet
shows a `(0)` count), and read the page. Expect the collection title to survive and the copy to
name the filter, not the collection.

This one needs a browser to confirm the filter-awareness of `products_count`; the rule above is
taken from CLAUDE.md rather than re-measured here.

**Regression risk:** every new gate written as `products_count` or `products.size`.

---

## R4 · Both signup forms report success when the submit fails

`snippets/lena-notify-modal.liquid` and `sections/lena-email-popup.liquid` both post with
`fetch(...).then(...)` — **no `.catch`, no `response.ok` check**. A network failure, a 422, or a
rejected submission all land in the success branch, swap the form out, and show
"You'll be the first to know!" / the success message.

The popup is the worse of the two, because it writes state before it knows the outcome:

```js
.then(function() {
  localStorage.setItem(SK, '1');      // lena-popup-subscribed
  ...
```

`SK` is checked on load and returns early. So a visitor whose signup *failed* is told it worked
**and is never shown the popup again on that device** — the failure is both invisible and
permanent. The notify modal has no equivalent latch, so a retry there is at least possible.

The notify-modal half of this was already filed above under "Notify Me reports success on
failure"; the popup instance is new, and the `localStorage` latch was not part of it.

**Verify:** DevTools → Network → offline, then submit either form. Expect an error state; observe
the success message. Reload with the popup: it no longer appears.

**Regression risk:** any further `fetch` written against `/contact` by copying these two.

---

## R5 · The card "New" badge is a second, competing definition of "new"

`snippets/card-product.liquid:120-126` computes newness from the product's own timestamp:

```liquid
{%- assign age_seconds = now_timestamp | minus: created_timestamp -%}
{%- if age_seconds < 604800 -%}
  <div class="lena-badge-new">New</div>
{%- endif -%}
```

CLAUDE.md is explicit that the theme must not do this: *"the theme does not know what 'new' means.
The app owns a single `new` tag ... Deliberately **no** date filter, staleness read or item cap —
those would make the theme second-guess the app."* Every other surface obeys it — the New Arrivals
bar, the grid, and all three nav snippets gate on `all_products_count` of the tag-driven smart
collection. This one card badge does not.

The two answers disagree in both directions:

- A piece the app tags `new` but created 10 days ago (photographed late, backdated import) appears
  in New Arrivals **without** a New badge.
- A piece created 3 days ago and never tagged shows a New badge **while being absent** from New
  Arrivals and from the nav.

Since `new-arrivals` currently holds 0 products, the nav link and both homepage sections are
hidden — yet any product created in the last 7 days still wears a New badge on every grid it
appears in. That is the contradiction live right now.

**Verify:**
```bash
grep -n "604800" snippets/card-product.liquid
# Admin: new-arrivals all_products_count -> 0   (measured 2026-09-16)
```
Then compare products sorted by newest on `/collections/available-now` against the New Arrivals
collection in admin.

**Regression risk:** any future "recently added" affordance computed in Liquid instead of read
from the tag.

---

## R6 · The hero's padding sliders do nothing

`sections/lena-hero.liquid` declares `padding_top` and `padding_bottom` range settings in its
schema, but the section has **no `{%- style -%}` block and never emits
`section-{{ section.id }}-padding`**. Every other Lena section does. The markup opens straight at
`<section class="lena-hero">`.

The merchant gets two sliders in the theme editor that move, save, and change nothing. This is the
"a control that is *missing* rather than wrong" class CLAUDE.md flags as only visible in a browser.
`index.json` currently stores `0` for both, so the fact that they are inert has never surfaced.

**Verify:**
```bash
grep -c "section-{{ section.id }}-padding" sections/lena-hero.liquid   # 0
grep -c "section-{{ section.id }}-padding" sections/lena-featured-piece.liquid  # 3
```
Theme editor → Lena Hero → drag Top padding to 100 → save → no change.

**Regression risk:** copying a schema block without its matching style block.

---

## R7 · The hero heading is `richtext`, so a `<p>` lands inside the `<h1>`

`sections/lena-hero.liquid` renders `<h1>{{ section.settings.heading }}</h1>` where `heading` is
`"type": "richtext"`. Richtext always wraps its output in `<p>`, so the live markup is:

```html
<h1><p>One piece at a time.<br/><strong>Yours alone.</strong></p></h1>
```

`<p>` is flow content and not permitted inside `<h1>`. Browsers nest it anyway rather than
discarding it, so the page is not visibly broken — but the paragraph brings its own block
formatting and default margins inside the heading, and the document fails validation.

Every other Lena section uses `inline_richtext` for exactly this reason — `lena-drop-header`,
`lena-drop-coming-soon`, `lena-testimonials`, `lena-spotlight` and `lena-featured-piece` all do.
The hero is the only one that does not, and it carries the page's only `<h1>`.

**Verify:**
```bash
grep -n '"type": "richtext"' sections/lena-*.liquid
#   only sections/lena-hero.liquid
```
View source on the homepage and look at the `<h1>`.

**Regression risk:** any heading setting typed as `richtext`.

---

## R8 · Hero mosaic links have no accessible name

`sections/lena-hero.liquid:21-23`:

```liquid
<a {% if block.settings.collection != blank %}href="{{ block.settings.collection.url }}"{% endif %} ...>
  {{ block.settings.image | image_url: width: 800 | image_tag: loading: 'lazy', ... }}
</a>
```

`image_tag` emits `alt` from the image's own alt text in Shopify Files. When that is unset — the
default for uploaded images — it emits `alt=""`, and the anchor wraps nothing else. A screen
reader announces four consecutive links as "link", with no indication of destination.

The `tag_label` span that would name them sits **outside** the anchor, so it does not contribute.

Two related notes on the same block:

- When `collection` is blank the `<a>` is emitted **with no `href`** rather than skipped, producing
  a non-interactive anchor that still occupies the tab order in some browsers.
- Both hero CTAs render `href="{{ ... }}"` with no blank guard. `index.json` currently fills both,
  so this is latent rather than live — but `lena-drop-coming-soon` guards its CTA for precisely
  this reason and the hero does not.

**Verify:** VoiceOver / NVDA link list on the homepage, or:
```bash
grep -n "image_tag: loading" sections/lena-hero.liquid   # no alt: argument
```

**Regression risk:** any image-in-link written without an explicit `alt:`.

---

## R9 · The section eyebrow fails contrast everywhere it is used

`.lena-section-eye` (`assets/lena-custom.css:222-228`) is `--lena-blue-bright` `#2E8FD9` at
**11px, weight 600, uppercase, 0.2em tracking**.

| Foreground | Background | Measured | AA needs | |
|---|---|---|---|---|
| `#2E8FD9` | snow `#FAFBFC` | **3.35:1** | 4.5:1 | fail |
| `#2E8FD9` | white `#FFFFFF` | **3.47:1** | 4.5:1 | fail |

11px is small text under WCAG regardless of weight — the large-text exemption starts at 18.66px
bold. Small size, uppercase and wide tracking all make it harder to read than the ratio alone
suggests.

This is the most widespread of the contrast findings: the eyebrow appears on the hero, the New
Arrivals bar, Testimonials, Find Us, Featured Piece, the collection banner and the empty state.
`lena-spotlight` overrides it to `--lena-amber-soft` on navy, which measures 8.69:1 and passes —
so the pattern is sound, only the light-background value is wrong.

**Verify:**
```bash
python3 - <<'PY'
def lum(h):
    h=h.lstrip('#'); r,g,b=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    f=lambda c: c/12.92 if c<=0.03928 else ((c+0.055)/1.055)**2.4
    return 0.2126*f(r)+0.7152*f(g)+0.0722*f(b)
def cr(a,b):
    l1,l2=sorted([lum(a),lum(b)],reverse=True); return (l1+0.05)/(l2+0.05)
print(round(cr('#2E8FD9','#FAFBFC'),2))   # 3.35
print(round(cr('#E8B867','#0E2240'),2))   # 8.69  <- the passing control
PY
```
Positive and negative control both in the snippet: the navy/amber pairing must come back above
4.5, the snow pairing below it.

**Regression risk:** new palette entries chosen by eye against white.

---

## R10 · Two more colour pairs sit under AA

Measured 2026-09-16 with the script in R9:

| Class | Pair | Measured | Needs | |
|---|---|---|---|---|
| `.lena-scarcity` (11px, 500) | `#1A8A5C` on `#FFFFFF` | **4.34:1** | 4.5:1 | fail |
| `.lena-pdp-scarcity` (13px, 500) | `#1A8A5C` on `#FFFFFF` | **4.34:1** | 4.5:1 | fail |
| `.lena-card-cat` (9.5px, 600) | `#6B7585` on `#FAFBFC` | **4.4959:1** | 4.5:1 | fail by 0.004 |

`--lena-success` `#1A8A5C` carries "Only piece in existence" — the scarcity line, which is the
single most commercially important sentence on a one-of-a-kind card. It is also the smallest text
on it.

The card category label is a rounding error away from passing and only on the snow background; on
pure white the same grey measures 4.66:1 and passes. Worth darkening with the others rather than
filing separately.

Checked and **passing**, for the record: the 1-of-1 badge (8.69:1), the New badge (4.67:1), the
sold-out overlay (15.89:1), the PDP artisan line (4.66:1), scheme-3 amber with its navy text
(7.21:1), and the navy-mid newsletter (13.63:1).

**Regression risk:** as R9.

---

## R11 · Section titles are not headings

Five sections render their title in a `<div>`:

| File | Element |
|---|---|
| `sections/lena-drop-header.liquid` | `<div class="lena-section-h">` |
| `sections/lena-testimonials.liquid` | `<div class="lena-section-h">` |
| `sections/lena-spotlight.liquid` | `<div class="lena-section-h">` |
| `sections/lena-find-us.liquid` | `<div class="lena-section-h">` |
| `sections/lena-featured-piece.liquid` | `<div class="lena-fp-heading">` |

Only `lena-drop-coming-soon` uses a real `<h2>`.

The homepage heading outline is therefore `<h1>` (hero) → `<h3>` (testimonial cards, find-us
cards, the featured piece title), with nothing at level 2 in between. A screen-reader user
navigating by heading — the normal way to skim a long page — passes straight from the hero to
individual cards and never hears "New Arrivals", "Loved by Collectors", "Today's Feature" or
"Find Us". Those titles are visually the most prominent text on the page.

**Verify:**
```bash
grep -rn 'class="lena-section-h"' sections/ | grep -c "<div"   # 4
grep -rn 'lena-fp-heading' sections/lena-featured-piece.liquid  # <div
```
Browser: run the accessibility tree / heading outline on the homepage and confirm no h2.

**Regression risk:** new sections copying `lena-section-h` from an existing one.

---

## R12 · Related products filters availability on one pass but not the other

`sections/related-products.liquid` fills the row in two passes.

Pass 1 (Shopify's recommendations, lines 70-80) keeps a suggestion on two conditions:
```liquid
{%- if rp_rec.id != product.id and rp_rec.type == product.type -%}
```
Pass 2 (category top-up, lines 96-108) adds a third:
```liquid
unless rp_p.available
  assign rp_ok = false
endunless
```

So whether a sold-out piece can appear under "You may also like" depends entirely on which pass
happened to fill the slot. On a catalogue where most items are one of a kind and sell permanently,
pass 1 will frequently surface pieces that are gone — every one a click into a dead end, on the
row whose whole job is to recover the visit.

The asymmetry looks unintended rather than deliberate: nothing in the section's comment block
mentions availability as a difference between the passes, and the top-up pass treats it as
obviously required.

**Verify:** open a PDP in a type with recent sales and compare the row against each card's stock
state. Or:
```bash
grep -n "available" sections/related-products.liquid   # one hit, in pass 2 only
```

**Regression risk:** any third source added to the row.

---

## R13 · A quarter of the catalogue has no canonical category

`snippets/lena-category-handles.liquid` lists seven handles. Two features depend on a product
being in one of them:

- `snippets/breadcrumbs.liquid` — otherwise the trail is "Home" alone.
- `sections/related-products.liquid` — `rp_has_fallback` stays false, so the top-up never runs.

Measured 2026-09-16 via the Admin API:

```
total products                                415
compact-mirrors 145 · ribbon-embroidery-hats 58 · crochet-dolls 30 · rattan-purses 26
velvet-purses 23 · glass-bead-woven-handbags 13 · phone-travel-wallet 11   =  306
```

Leaving roughly **109 products (~26%)** outside all seven, assuming the seven do not overlap.
Sampling confirms the shape of it — these product types have no canonical collection at all:

| Product type | Collections the sampled product is actually in |
|---|---|
| Keychains | `available-now` only |
| Bookmarks | none |
| Tote Bags | `available-now`, or none |

Also outside the seven: Coin Purses, Hair Clips, Hair Pins, Hair Ties, Headbands, Jewelry Boxes,
Passport Covers, Lepironia Bag, Water Hyacinth Bag — and `signature-purses` (50 products), which
`breadcrumbs.liquid`'s own comment names as a deliberate parent but which is **not in the list**.

For those PDPs the breadcrumb is a single "Home" link, and "You may also like" is whatever pass 1
returns — short, or absent entirely, which is the outcome the section's comment claims cannot
happen ("the row is always topped up rather than left short").

**Verify:**
```bash
cat snippets/lena-category-handles.liquid | tail -1   # the seven
# Admin API: productsCount -> 415; per-collection counts as above
```
Open a PDP for a keychain or a bookmark and read the breadcrumb and the recommendation row.

**Regression risk:** new product types introduced without a matching collection; the list is
maintained by hand and nothing checks coverage.

---

## R14 · Notify Me segments by product type, not by category

Both notify entry points pass `product.type`:

```liquid
onclick="window.lenaNotify('{{ product.type | escape }}','{{ product.type | handleize }}')"
```
`sections/main-product.liquid:145`, `snippets/card-product.liquid:245`

`snippets/lena-notify-modal.liquid` then tags the contact `newsletter,notify-<handle>`.

CLAUDE.md warns the two are different strings, and live data confirms it:

| `product.type` | Tag produced | Canonical handle |
|---|---|---|
| Beaded Purses | `notify-beaded-purses` | `glass-bead-woven-handbags` |
| Crochet Figures | `notify-crochet-figures` | `crochet-dolls` |
| Rattan Bags | `notify-rattan-bags` | `rattan-purses` |
| Hats | `notify-hats` | `ribbon-embroidery-hats` |
| Phone Wallet | `notify-phone-wallet` | `phone-travel-wallet` |

Only Compact Mirrors and Velvet Purses line up. So a segment built to email "everyone waiting on a
Glass Bead Woven Handbag" will not find those contacts, and the tags cannot be joined to a
collection without a translation table that exists nowhere.

`lena-category-handles.liquid` was created as the single source of truth for exactly this question
and is consulted by `breadcrumbs` and `related-products` — but not here. This is the "grep for who
else computes it" rule in CLAUDE.md.

Secondary: the modal reads "We'll email you when new **{type}** arrive." Singular types —
`Lepironia Bag`, `Water Hyacinth Bag`, `Phone Wallet` — produce "when new Phone Wallet arrive".

**Verify:** click Notify Me on a sold-out beaded purse, submit, and read the contact's tags in
admin. Expect a handle that matches a collection.

**Regression risk:** any third caller of `window.lenaNotify`.

---

## R15 · Featured Piece can only ever see the first 50 products

`sections/lena-featured-piece.liquid:26`:
```liquid
assign fp_pool = fp_collection.products | where: 'available'
```

Outside a `{% paginate %}` tag, `collection.products` returns **at most 50 products**. `fp_pool` is
filtered from that 50, not from the collection.

The section's purpose is to rotate one piece out of a large collection — CLAUDE.md records it as
replacing Available Now precisely because "219 products behind a 4-item window" was the problem.
Pointed at `available-now` (219 products) it would rotate through the first 50 in the collection's
sort order and never show the other 169. The seed arithmetic is sound; the pool it indexes into is
silently truncated.

Not observable today because the collection setting is broken (R1) — fixing R1 makes this live.

**Verify:** point the section at `available-now`, then `{{ fp_pool_size }}` in the template, or
watch the featured piece across days and confirm it never leaves the first page of the collection.

**Regression risk:** any `collection.products` used for counting or indexing rather than display.

---

## R16 · Monthly rotation can only surface twelve pieces

`sections/lena-featured-piece.liquid:33-40`:
```liquid
when 'monthly'  -> assign fp_seed = 'now' | date: '%m' | plus: 0   # 1..12
when 'weekly'   -> assign fp_seed = 'now' | date: '%W' | plus: 0   # 0..53
else (daily)    -> assign fp_seed = 'now' | date: '%j' | plus: 0   # 1..366
assign fp_index = fp_seed | modulo: fp_pool_size
```

With monthly rotation the seed only ever takes twelve values, so `fp_index` only ever takes twelve
values. On any pool larger than 12, the remaining pieces are unreachable — and the same month
always selects the same index, every year. Weekly caps the same way at 54.

Daily is the current setting and is unaffected (366 values), but all three are offered in the
theme editor as equals, with the info text "Everyone sees the same piece for the whole period" —
which is true and hides this.

A monotonic seed (days since epoch, divided by the period length) removes the ceiling for all
three. `lena-spotlight` already does something closer to this with `week_num | divided_by:
rotation_weeks`.

**Verify:** set rotation to monthly against a pool of 30 and list the twelve reachable indices.

**Regression risk:** reusing a calendar-component seed for any pool larger than that component's
range.

---

## R17 · Neither modal manages focus

`snippets/lena-notify-modal.liquid` and `sections/lena-email-popup.liquid` both declare
`role="dialog" aria-modal="true"`, and neither:

- moves focus into the dialog when it opens,
- constrains Tab to the dialog while it is open,
- returns focus to the element that opened it on close.

The practical result for a keyboard or screen-reader user: the popup appears after 10 seconds
with focus still behind it, announced only if the user happens to be at that point in the
document. Tab walks out of the dialog and through the page underneath, which is still scrollable
by keyboard even though `document.body.style.overflow = 'hidden'` blocks the mouse. `aria-modal`
tells assistive technology that the rest of the page is inert, so the content it reaches is
content it has been told does not exist.

The Escape handler works in both. Notify's is bound to `document` unconditionally and runs on
every keyup for the life of the page, closed or not.

Smaller item in the same file: the popup calls `localStorage.getItem` at the top of the IIFE with
no `try`/`catch`. Where storage access throws rather than returning null — Safari in Lockdown
Mode, some embedded webviews — the whole script aborts and the popup never runs at all.

**Verify:** Tab from the moment the popup appears and confirm focus never enters it; keep
tabbing and confirm it reaches the page behind.

**Regression risk:** any further dialog built by copying these two.

---

## R18 · Testimonial ratings are invisible to assistive technology

`sections/lena-testimonials.liquid:43-51` renders the rating as five bare spans:

```liquid
{%- for i in (1..5) -%}
  {%- if i <= block.settings.rating -%}
    <span class="lena-star filled">&#9733;</span>
  {%- else -%}
    <span class="lena-star">&#9733;</span>
```

Filled and empty differ only by CSS class — the character is `★` in both. There is no
`aria-label`, no `role="img"`, no visually-hidden text. A screen reader either announces
"black star" five times regardless of the actual rating, or skips them as punctuation. Either
way a 3-star review is indistinguishable from a 5-star one.

Stock Craft's own product rating does this correctly a few files away, in
`snippets/card-product.liquid:195-199`: `role="img"` with an `aria-label` built from
`accessibility.star_reviews_info`. The pattern to copy is already in the theme.

**Verify:** set a testimonial block to 3 stars and read the card with a screen reader.

**Regression risk:** any icon-only state indicator.

---

## R19 · The PDP inventory badge depends on block order

`sections/main-product.liquid:105` assigns `lena_qty` inside the `{%- when 'title' -%}` branch.
Line 136, inside `{%- when 'price' -%}`, consumes it:

```liquid
{%- if product.available and lena_qty == 1 -%}
  <div class="lena-pdp-scarcity"> ... Only piece in existence
```

Blocks are rendered in `block_order`, which the merchant controls from the theme editor.
`templates/product.json` currently lists `title` before `price`, so this works. It stops working
silently if the title block is moved below price, or removed — `lena_qty` is then nil, `lena_qty
== 1` is false, and **both** the "1 of 1" badge and "Only piece in existence" vanish with no other
symptom. The sold-out message survives, because it tests `product.available` instead.

CLAUDE.md routes section reordering to admin as the normal way to work, which is what makes this
reachable rather than theoretical.

**Verify:**
```bash
grep -n "lena_qty" sections/main-product.liquid
#   105 assign (inside when 'title')
#   136, 417, 593 read (inside when 'price' / quantity / buy_buttons)
```
Theme editor → Product → drag Price above Title → the badge and scarcity line disappear.

**Regression risk:** any variable assigned in one block and read in another.

---

## R20 · Five sections can be dropped into the header or footer group

CLAUDE.md: *"Guard any body-only section with `"disabled_on": { "groups": ["header", "footer"] }`
in its schema"* — a section added from the Header group's own "Add section" button lands in
`sections/header-group.json`, pinned above the template and undraggable.

Every Lena section with a `presets` block is addable that way. Only one is guarded:

| Section | `presets` | `disabled_on` |
|---|---|---|
| `lena-featured-piece` | yes | **yes** |
| `lena-hero` | yes | no |
| `lena-drop-header` | yes | no |
| `lena-testimonials` | yes | no |
| `lena-spotlight` | yes | no |
| `lena-email-popup` | yes | no |

`lena-email-popup` is the sharpest of these: it is already rendered unconditionally from
`layout/theme.liquid:319`, so adding it a second time from the editor yields two overlays, two
`id="lena-popup-overlay"` elements, and a `querySelector` that binds to whichever came first.

`lena-drop-coming-soon` and `lena-find-us` have no `presets` and so cannot be added this way.

**Verify:**
```bash
grep -L "disabled_on" sections/lena-*.liquid
```

**Regression risk:** every new section with a preset.

---

## R21 · The colour-filter rule is written six times, two ways

`snippets/facets.liquid` decides "is this the Color filter?" in six places, with **two different
conditions**:

| Lines | Purpose | Condition |
|---|---|---|
| 210-228 | desktop checkbox list — whitelist + label | `filter.label \| downcase == 'color'` |
| 608-626 | drawer checkbox list — whitelist + label | `filter.label \| downcase == 'color'` |
| 78-81 | active-filter pill (drawer form) | `filter.label == 'Color' or filter.label == 'color'` |
| 374-377 | active-filter pill (desktop) | same |
| 849-852 | active-filter pill (mobile) | same |
| 964-967 | active-filter pill (pill form) | same |

The two are not equivalent. A filter labelled `COLOR` or `Colour` in Search & Discovery satisfies
the `downcase` form and not the literal form — so the checkbox list would strip the prefix and
show "Blue" while the active-filter pill above it showed "color-blue". The whitelist itself, ~55
names, is pasted in full twice.

Nothing here is broken today: the filter is labelled exactly `Color`, and all 13 live tags are in
the whitelist (see R28). This is the "one rule written twice" cost — six copies, none of which
fails a test when one is edited.

**Verify:**
```bash
grep -c "lena_color_whitelist" snippets/facets.liquid   # 4  (2 assigns, 2 loops)
grep -c "lena_pill_label" snippets/facets.liquid        # 8  (4 sites x 2 lines)
```

**Regression risk:** renaming the filter in Search & Discovery, or adding a colour to one
whitelist copy and not the other.

---

## R22 · `main-404.liquid` carries its stylesheet inline

`sections/main-404.liquid` opens with `<style type="text/css">` and roughly 175 lines of rules —
`.lena-404`, `.lena-404__code`, `.lena-404__search`, `.lena-404__links` and the rest.

CLAUDE.md rule 4: *"All custom styles go in `assets/lena-custom.css`. No inline `<style>` tags, no
new CSS files."*

Beyond the rule, the practical costs are that these rules re-download on every 404 instead of
being cached with the rest of the CSS, and that they are invisible to anyone grepping
`lena-custom.css` for a class name — including a future subagent asked to restyle the 404.

Every declaration already uses the `var(--lena-*, #fallback)` pattern, so the move is mechanical.

**Verify:**
```bash
grep -n "<style" sections/main-404.liquid   # line 1
```

**Regression risk:** new full-page sections written as self-contained files.

---

## R23 · Inline styles across five Lena files

Same rule as R22. Excluding the stock Craft pattern of `style="--custom-property: value"`, which
is legitimate:

| File | Lines |
|---|---|
| `sections/lena-drop-coming-soon.liquid` | 12, 13, 16, 19, 31 |
| `sections/lena-spotlight.liquid` | heading wrapper, eyebrow colour, photo `object-fit` |
| `sections/lena-hero.liquid` | 21 (`display:block;width:100%;height:100%`), 22 (`image_tag: style:`) |
| `sections/lena-testimonials.liquid` | 29 |
| `sections/lena-find-us.liquid` | 51 |
| `sections/main-product.liquid` | 138 |

`main-product.liquid:138` is the one worth calling out as redundant rather than merely misplaced:

```liquid
<span class="dm filled sm" style="background:var(--lena-success);border-color:var(--lena-success)">
```

`assets/lena-custom.css:156-158` already declares exactly that for `.lena-scarcity .dm`. The
inline copy exists because the PDP class is `.lena-pdp-scarcity`, which the CSS rule does not
cover — so a one-line selector addition removes the inline style entirely.

`sections/lena-drop-coming-soon.liquid:12` and `lena-testimonials.liquid:29` and
`lena-find-us.liquid:51` are the same `text-align:center;margin-bottom:40px` wrapper written three
times, which would be one class.

**Regression risk:** each new section styled where it is written.

---

## R24 · The empty-state paragraph ignores its own colour scheme

`sections/lena-drop-coming-soon.liquid:19`:
```liquid
<p style="font-size:16px;line-height:1.7;color:rgba(14,34,64,0.7);margin-bottom:28px">
```

`rgba(14,34,64,0.7)` is navy at 70%. The section exposes a `color_scheme` setting, and the
wrapper honours it — `class="color-{{ section.settings.color_scheme }} gradient"` — but this
paragraph hardcodes its text colour past it.

On the current `scheme-1` (snow) it measures 5.89:1 and reads fine. Select `scheme-4` in the theme
editor and the background becomes `#0E2240` — navy — while the paragraph stays navy at 70% opacity
over it. The body copy becomes essentially invisible. `scheme-5` (navy-mid `#132E52`) fails the
same way.

The setting is offered with all five schemes and nothing warns against the two that break it. The
eyebrow and heading above it use classes and would recolour correctly, so the section would render
with a visible heading over an invisible paragraph.

**Verify:** theme editor → New Arrivals template → Collection Empty State → colour scheme →
scheme-4.

**Regression risk:** any hardcoded colour inside a scheme-aware section.

---

## R25 · Find Us computes its event window twice

`sections/lena-find-us.liquid` walks `shop.metaobjects.scheduled_event.values` twice — once at
lines 28-40 to count visible cards for `data-cards`, once at lines 60-70 to render them. The date
arithmetic is identical and duplicated verbatim:

```liquid
assign event_start_ts = event.start_date.value | date: '%s' | plus: 0
... diff_start <= fourteen_days and diff_end >= -86400
```

If one copy is edited — widening the window to 30 days, say — `data-cards` and the number of
cards actually rendered disagree, and `.lena-find-grid[data-cards="N"]` lays out for the wrong
count. The failure is a wrong column count, which looks like a CSS bug and is not one.

The location-block count is duplicated the same way at lines 44-48 and 89-93.

Capturing the rendered cards into a variable and counting from that would make the two
structurally incapable of drifting — the same shape `related-products.liquid` already uses with
`rp_items`.

**Verify:**
```bash
grep -c "fourteen_days" sections/lena-find-us.liquid   # 3: one assign, two comparisons
```

**Regression risk:** editing the window in one place.

---

## R26 · The New Arrivals bar takes a typed handle, not a picker

`sections/lena-drop-header.liquid` schema:
```json
{ "type": "text", "id": "collection_handle", "label": "Collection handle",
  "default": "new-arrivals", "info": "From the collection URL. ..." }
```

and the section resolves it with `collections[section.settings.collection_handle]`.

A typo, a rename in admin, or a pasted URL rather than a handle all produce a blank collection,
`na_count` stays 0, and the section hides itself — the same visible outcome as "the collection is
legitimately empty". The merchant gets no feedback distinguishing the two.

This is R1 in a different section, reached a different way. R1 happened with a proper
`type: "collection"` picker, so a picker does not eliminate the class — but it does remove the
typo route and makes the stored value a reference that survives a title change.

The section's own comment is worth preserving through any change: visibility must stay keyed to
`all_products_count` and nothing else.

**Verify:** theme editor → New Arrivals → set the handle to `new-arrival` → the section
disappears with no error.

**Regression risk:** any collection addressed by a typed string.

---

## R27 · A stock CSS rule is restated in the custom stylesheet

`assets/lena-custom.css:735`:
```css
.product__title > a.product__title { display: none; }
```
`assets/section-main-product.css:257`:
```css
.product__title > a { display: none; }
```

The stock rule already hides the linked `<h2>` duplicate of the product title that Craft emits for
featured-product contexts. The custom rule is more specific and says the same thing, so it changes
nothing today.

It is worth a look rather than a silent deletion: the surrounding comment block at
`lena-custom.css:1191-1211` documents the real version of this problem — stock
`.product__title > * { margin: 0 }` zeroing the margins on every Lena element in the title block,
fixed correctly by adding a class to the selector. Line 735 looks like an earlier, less-informed
attempt at the same file that was never removed. Confirm which before deleting.

**Verify:**
```bash
grep -n "product__title > a" assets/lena-custom.css assets/section-main-product.css
```

---

## R28 · A6 is stale — `color-clear` no longer exists

The A6 item above states the store carries 15 `color-*` tags and that `color-clear` is absent from
the whitelist, making those products unreachable by colour.

Measured 2026-09-16 against the live store, the tag list is **13**, and every one is in the
whitelist:

```
color-beige  color-black  color-blue   color-brown  color-gray
color-green  color-multi  color-orange color-pink   color-purple
color-red    color-white  color-yellow
```

No `color-clear`, and no fourteenth or fifteenth value. The facet renders all 13.

So the bug A6 describes is not currently reachable. The underlying design point it makes still
stands and is worth keeping on its own terms — a whitelist that drops unknown values silently
will do this again the first time a new colour is introduced, which is R21's territory. But A6 as
written is no longer true and should be closed with a DEVLOG entry rather than left as an open
item, per the OPEN_ITEMS convention at the top of this file.

The companion item, "A bare `Black` tag coexists with `color-black`", **is** still true — `Black`
is present in the live tag list.

**Verify:**
```
# Admin API: productTags(first: 250), filter to color-*  ->  13 (measured 2026-09-16)
grep -o "lena_color_whitelist = '[^']*'" snippets/facets.liquid | head -1
# confirm each of the 13 appears after the color- prefix is stripped
```


---

# Search problems found in the browser — 2026-09-16

Found by Hai while checking the quick-add fix, then measured against the **live** site
(`lenahandicrafts.com`), so none of these were introduced by our recent commits.

These three are written in the four-part format: what effect, where and how, how to fix,
what else it affects.

---

## R29 · Pages and blog posts appear among the product results

**1. What effect it can cause**

A customer searches for `mirror`. In the grid of products, one card is not a product. It is
the "Our Story" page. The card has no photo, no price, and no Add to cart button — just a
small grey label saying "Page".

It looks like a product that failed to load. A customer may think the site is broken.

**2. Where and how it happens**

The search box sends no instruction about what kind of thing to search for. In
`sections/main-search.liquid` around line 126 the form contains only:

```liquid
<input name="options[prefix]" type="hidden" value="last">
```

When Shopify is not told what to search, it searches everything: products, pages and blog
posts. The section then draws whatever comes back into the same grid
(`main-search.liquid:294`, `case item.object_type`).

To see it: search `mirror` on the live site. "Our Story" is on page 1.

**3. How to fix**

Code change, one line. Add a hidden field to the search form so only products are searched:

```liquid
<input type="hidden" name="type" value="product">
```

This is stock Craft behaviour, not something Lena added — but the form lives in a file Lena
already edits, so the change belongs with our code.

**4. Does it affect other features**

Yes, two:

- **The dropdown while typing** (predictive search) is a different feature in a different
  file. It has its own settings and is not changed by this.
- **The result count drops.** Today the page says 167 results, which includes pages and blog
  posts. Searching products only will make that number smaller and more honest. It does not
  fix R30.

---

## R30 · Search says 167 results but the pages are nearly empty

**1. What effect it can cause**

This is the serious one. A customer searching `mirror` is told there are **167 results**
across **7 pages**. Most of those pages are almost empty, and two of them show nothing at
all.

A customer who clicks to page 4 sees "No products found". They will reasonably conclude the
shop has nothing, and leave — while the shop actually has 132 mirrors in stock.

Measured on the live site, 2026-09-16, with **no filters applied**:

| Page | Product cards shown |
|---|---|
| 1 | 24 (23 products + the "Our Story" page) |
| 2 | 10 |
| 3 | 5 |
| 4 | **0 — "No products found"** |
| 5 | 1 |
| 7 | **0 — "No products found"** |

Header on every one of those pages: "167 results".

**Confidence.** Pages 4 and 7 being empty is certain — the words "No products found" are
written into the page by the server, and Hai saw the same thing independently in the browser.
The counts for pages 2, 3 and 5 come from an automated reader and may be undercounts; they
have not been counted by hand in a browser.

**Control test.** The same check on a collection page works correctly:
`/collections/compact-mirrors?page=3` shows 36 cards, says "132 pieces", links exactly 3
pages, and shows no empty message. So **normal page-by-page browsing is fine. Only search is
broken.**

**2. Where and how it happens**

`sections/main-search.liquid:88` splits the results into pages:

```liquid
{% paginate search.results by 24 %}
```

Shopify decides how many pages to draw from its own total (167). But the actual products it
hands back for each page are far fewer than 24. The total and the contents disagree.

The cause is inside Shopify's search, not in our theme. The pagination code here is stock
Craft and has not been modified.

**Two further measurements, both pointing away from the theme:**

*The same URL returns different products on different requests.* Hai saw "Grande Glass Bead
Woven Handbag - Ruby Red" on page 3. Minutes later the same page 3 returned five Motif
Compact Mirrors and no handbag. Neither of us changed anything. A page that is stable cannot
do this; the theme code is identical on both requests.

*Search returns a product that does not match the word.* That handbag contains no occurrence
of "mirror" anywhere Shopify indexes:

```
title        Grande Glass Bead Woven Handbag - Ruby Red
productType  Beaded Purses
tags         artisan, chain, color-red, glass bead, size_1
description  ...no occurrence of "mirror"...
```

So the search is returning wrong products, an unstable set, and a total that does not match
what it returns — three symptoms of one cause on Shopify's side, most likely a stale or
damaged search index for this shop.

**Earlier idea, now weaker:** that filtering on the search page
(`"enable_filtering": true` in `templates/search.json`) makes the count and the results
disagree. It is still worth testing because it is free, but it
cannot explain a wrong product or a result set that changes between two identical requests.

**3. How to fix**

Not yet known. Test in this order, cheapest first:

1. **Open the Search & Discovery app** and look for synonyms, product boosts or rules that
   could pull unrelated products into a search. A rule naming "mirror" would explain the
   handbag. This is free to check and is the only cause we could fix ourselves.
2. **Turn filtering off on the search page** (admin setting) and re-check pages 1 to 7. Cheap,
   and rules the idea out either way.
3. **Apply R29** (products only), which at least removes one source of noise from the count.
4. **Contact Shopify support.** This is the likely ending. Send them three things: the page
   table above, the fact that one URL returns different products on different requests, and
   the handbag that matches no occurrence of the search word. Ask them to rebuild the search
   index for the shop. Those three facts together are far stronger than "search looks wrong".

Do **not** change the `by 24` number. That is not the cause and changing it will hide the
symptom without fixing anything.

**4. Does it affect other features**

- **Collection pages are not affected.** Proven by the control test above.
- **The dropdown while typing is not affected.** It shows a short list and does not paginate.
- **R29 and R31 sit on top of this.** Fixing them makes the page less confusing but does not
  make the missing products appear.
- **The Add to cart button we just switched on (R2) is not affected** — but a customer cannot
  use it on a product that never appears.

---

## R31 · An empty search page blames filters that were never used

**1. What effect it can cause**

When a search page has nothing on it, the page says:

> **No products found**
> Use fewer filters or **remove all**

The customer used no filters. There is nothing to remove. The advice cannot be followed, and
"remove all" is a link that changes nothing they did.

This makes R30 worse: the customer is told the empty page is their own fault.

**2. Where and how it happens**

`sections/main-search.liquid:252`:

```liquid
{%- if search.results.size == 0 and search.filters != empty -%}
```

`search.filters` is the list of filters that are *available* on the page — not the filters the
customer *chose*. Because filtering is switched on for search, that list is never empty. So
this message is shown for every empty search page, whether or not a filter was used.

Line 165 has the correct plain message, but it can only appear when no filters exist at all.

**3. How to fix**

Code change. Test whether a filter was actually applied, not whether filters exist. Shopify
exposes the applied values, so the check becomes "does any filter have an active value" rather
than "does the filter list exist". Show the plain "no results" wording otherwise.

**4. Does it affect other features**

- **Collection pages use the same wording** from a different file
  (`main-collection-product-grid.liquid`). There the message is usually correct, because a
  customer normally reaches an empty collection page by filtering. Worth checking, not urgent.
- **This overlaps R3** in the earlier list, which is the same class of mistake: asking "do
  filters exist" when the question is "did the customer use one". Fix them together.
