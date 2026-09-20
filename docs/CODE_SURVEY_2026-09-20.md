# Code survey — 2026-09-20

Read-only survey of the custom surface ahead of go-live. **Nothing was changed.**

Covered: the 8 `lena-*` sections, the 5 `lena-*` snippets, `breadcrumbs`, `lena-custom.css`,
every Lena-modified range in stock files, all 7 JSON templates, and `CLAUDE.md` /
`ARCHITECTURE.md` / `OPEN_ITEMS.md` against the code and against the live store.

Findings are grouped by what they cost you, not by file. **Section A is what a shopper sees
today.** Everything below A is real but narrower.

Live-store figures were measured **2026-09-20** through the Admin API; each one names the query
that produced it so it can be re-run.

---

## Legend

*Severity* — `A` visible to a shopper on the live store today · `B` a real fault with a narrower
trigger · `C` duplication that will cause a future fault · `D` dead code · `E` a document that is
no longer true.

*Reachable* — `today` a visitor can hit it now · `latent` correct code path is absent but the data
that triggers it does not currently exist · `n/a` not a runtime fault.

---

## A · Go-live blockers

| # | Finding | Reachable |
|---|---|---|
| A1 | The homepage shows **no products at all** | today |
| A2 | Filtering a collection to zero results renders a **silent blank area** — no message, no explanation | today |

---

### A1 · The homepage has no product on it, and `OPEN_ITEMS.md` says this was fixed

Four homepage sections each hide themselves, for four individually-correct reasons. Nothing
checks the set. Between **Our Story** and **Shop by Category** there is no product.

| Homepage position | Section | Why it renders nothing | Measured 2026-09-20 |
|---|---|---|---|
| 4 | Featured Piece | its collection setting is the handle `artisan` | `collectionByHandle("artisan")` → **null** |
| 5 | New Arrivals bar | `new-arrivals` holds no products | `productsCount` → **0** |
| 6 | New Arrivals grid | same collection, same gate | **0** |
| 7 | Available Now | `"disabled": true` in `index.json` | 219 products, switched off |

The nearest real handle is `artisan-compact-mirrors` (40 products) — `artisan` reads like a
truncation of it.

**This is R1 in `docs/OPEN_ITEMS.md`, and that table records its status as `fixed`.** It is not
fixed: `templates/index.json` still reads `"collection": "artisan"`, no DEVLOG entry ever changed
it, and `grep -n "artisan" docs/DEVLOG.md` returns only two prose mentions inside the R26 entry.

That second half matters more than the first. The bug is one admin setting. The doc saying it is
already fixed is what stops anyone from looking — and the whole point of the state table, per the
convention at the top of `OPEN_ITEMS.md`, is that it stays true.

**Verify now:**
```bash
grep -A3 '"lena_featured_piece' templates/index.json | grep collection
#   "collection": "artisan"
python3 -c "import json,re;d=json.loads(re.sub(r'/\*.*?\*/','',open('templates/index.json').read(),flags=re.S));print(d['sections']['featured-collection'].get('disabled'))"
#   True
grep -n '^| R1 ' docs/OPEN_ITEMS.md
#   ... | admin setting | fixed | not yet |     <- the false row
```
Admin API: `{ collectionByHandle(handle:"artisan"){id} }` → `null`;
`{ collectionByHandle(handle:"new-arrivals"){ productsCount{count} } }` → `0`.

Then load the homepage and scroll from Our Story to Shop by Category.

**Note on `new-arrivals`:** its collection **title is `New`**, not "New Arrivals". Nothing on the
homepage shows it (the bar's heading is a setting), but the collection page's `<h1>` and any
breadcrumb landing there will read "New".

---

### A2 · Filtering a collection to zero results shows a blank page region with no message

`sections/main-collection-product-grid.liquid:127-129`:

```liquid
{%- if collection.products.size == 0 -%}
  {%- comment -%} Lena: Hide default empty state — lena-drop-coming-soon section handles messaging {%- endcomment -%}
{%- else -%}
```

Stock Craft's empty state — *"No products found. Use fewer filters or clear all"*, with a working
clear-all link — was deleted and replaced with a comment. **The comment's claim is not true in
either direction:**

1. `templates/collection.json` (every ordinary collection) does not contain
   `lena-drop-coming-soon` at all. Its section list is banner + grid, nothing else.
2. Where that section *does* sit (the two New Arrivals templates) it is gated on
   `collection.all_products_count == 0`. Under a filter that count is non-zero, so it
   correctly stays hidden — and nothing takes its place.

So on `/collections/compact-mirrors` (145 products, `enable_filtering: true`), a colour filter
matching nothing gives: banner, filter chips, then **empty space**. No message, no "clear
filters", no explanation. The facet pills are the only way back and nothing points at them.

This is a *residual* of the R3 fix, not a regression of it — R3's own symptom (the `<h1>`
disappearing) is genuinely fixed. The R3 write-up does not mention that the stock empty state had
already been removed underneath it.

**Verify now:**
```bash
sed -n '127,130p' sections/main-collection-product-grid.liquid   # only a comment in the zero branch
grep -n "enable_filtering" templates/collection.json             # true
python3 -c "import json,re;d=json.loads(re.sub(r'/\*.*?\*/','',open('templates/collection.json').read(),flags=re.S));print(d['order'])"
#   ['main-collection-banner', 'main-collection-product-grid']   <- no empty-state section
```
Browser: `/collections/compact-mirrors`, tick a colour facet showing `(0)`.

---

## B · Real bugs, narrower trigger

| # | Finding | File | Reachable |
|---|---|---|---|
| B1 | A genuinely empty collection page has **no `<h1>`** | `main-collection-banner.liquid` | today |
| B2 | `lena_qty` is read outside the branch that assigns it | `card-product.liquid` | latent |
| B3 | The New Arrivals nav-hiding rule misses submenu links | 3 header snippets | latent |
| B4 | Non-colour facet values are hidden in the list but shown raw in the active pill | `facets.liquid` | latent |
| B5 | The Color fieldset can render with zero values inside it | `facets.liquid` | latent |
| B6 | Spotlight still uses the `'%W'` rotation seed that was fixed in Featured Piece | `lena-spotlight.liquid` | latent |
| B7 | Spotlight's dot nav is capped at 6 while the index is not | `lena-spotlight.liquid` | latent |
| B8 | `aria-labelledby` points at a span that was emptied | `card-product.liquid` | today |
| B9 | Find Us renders its heading over an empty grid when nothing is visible | `lena-find-us.liquid` | latent |
| B10 | Two different predicates answer "is this collection empty" | `lena-drop-header` vs `featured-collection` | n/a |
| B11 | A dead condition inside the banner | `main-collection-banner.liquid` | n/a |
| B12 | "In-stock first" sorts only within a page | `main-collection-product-grid.liquid` | today |

---

**B1 · An empty collection page has no `<h1>`.** `main-collection-banner.liquid:25` wraps the
whole banner — eyebrow, `<h1>`, description, count pill — in
`{%- if collection.all_products_count > 0 -%}`. When the collection is genuinely empty the page's
only heading is the `<h2 class="lena-section-h">` inside `lena-drop-coming-soon`. That is a page
with no title and a heading order starting at h2.

This is live-reachable **right now**: `/collections/new-arrivals` and
`/collections/this-weeks-drop` both hold 0 products (measured 2026-09-20).

The irony is that the comment block directly above that gate argues at length *against* losing the
`<h1>` — it just makes the argument for the filtered case and then removes it for the empty case.

```bash
sed -n '12,25p' sections/main-collection-banner.liquid   # the comment block, then the gate
```

**B2 · `card-product.liquid` reads `lena_qty` outside the branch that assigns it.**

- assigned at line **109**, inside `{%- if card_product.featured_media -%}` (lines 61–151)
- read at line **256**, outside it: `{%- if card_product.available and lena_qty == 1 -%}`

For a product with no featured image, `lena_qty` is never set, so the **"Only piece in
existence"** line silently disappears. The `1 of 1` badge, the `New` badge and the sold-out
overlay are all inside the same branch and vanish with it.

This is the identical fault class to **R19**, which was found and fixed on the PDP — the fix there
was to hoist the assign above the block loop, with a comment explaining why. `card-product` never
got the same treatment.

**Latent today, not reachable.** Of the first 250 of 296 active products, 6 have no featured
media, and all 6 are POS-tagged — and every POS product has `publishedAt: null`, so none is
reachable from the storefront at all. It becomes reachable the first time a published product is
created before its photo is uploaded, which is the normal order of work.

```bash
grep -n "lena_qty" snippets/card-product.liquid
#   109 (assign, inside the featured_media branch) ... 256 (read, outside it)
awk 'NR==61||NR==151' snippets/card-product.liquid   # the branch boundaries
```

> **A measurement I threw away, recorded so nobody repeats it.** I first counted photoless
> products with `productsCount(query: "-has:media status:active")` and got **279 of 296**. The
> negative control disproved it: `has:media` and `-has:media` both return 296, so that filter is
> unsupported and silently ignored. The real figure (6, all POS) came from fetching 250 products
> and testing `featuredMedia == null` in Python.

**B3 · The nav-hiding rule misses submenu links.** All three header snippets `continue` on
`link.type == 'collection_link' and link.object.handle == 'new-arrivals'` — but only in the
**top-level** `for link in section.settings.menu.links` loop. The `childlink` and `grandchildlink`
loops (`header-dropdown-menu.liquid:43,69` and `header-drawer.liquid:63`) have no such test. Move
New Arrivals under a dropdown in the menu editor and the empty-collection link comes back.

**B4 · Non-colour values are hidden in the list but rendered raw in the active pill.** The
checkbox lists skip a value when `lena-color-facet` returns blank. The four active-pill sites do
`| default: value.label` instead, so a non-whitelisted value that is *active* — arriving from a
bookmarked or shared URL — prints as `Color: color-accessories`. Narrow, but it is the exact
"checkbox says Blue, pill says color-blue" inconsistency the snippet was written to eliminate,
surviving on the other side of the fallback.

**B5 · An empty Color fieldset.** If every value of a filter is skipped, the `<fieldset>`,
`<summary>` and `<ul>` still render with no `<li>` inside — a Color accordion that opens onto
nothing. `filter.active_values.size` (used for the "(N)" count at `facets.liquid:146,167`) also
still counts hidden values.

**B6 · Spotlight kept the rotation bug that Featured Piece documents as fixed.**
`lena-spotlight.liquid:33` seeds off `'now' | date: '%W'` — the calendar week number.
`lena-featured-piece.liquid:40-50` carries a comment explaining precisely why that is wrong
(`'%W'` caps at ~54 and resets every year, so a pool larger than that can never be fully reached
and the rotation jumps at the year boundary) and uses days-since-epoch instead. Spotlight is
disabled today, so this only bites if it is ever switched on.

**B7 · Spotlight's dot nav is capped at 6.** `{%- for article in blog.articles limit: 6 -%}`
draws at most 6 dots, but `article_index` is `modulo: blog.articles_count`. With 7+ articles the
featured one is regularly outside the first 6 and **no dot is active**.

**B8 · A dangling `aria-labelledby`.** Line 205 keeps stock's
`aria-labelledby="CardLink-… Badge-…"`, but the Lena change at lines 621–624 emptied the `Badge-`
span (stock put the "Sold out" / "Sale" text in it). The reference now resolves to an empty
element. Worth noting the inconsistency it leaves: the **no-media** badge block at lines 170–185
was *not* emptied, so a photoless card still shows a stock "Sold out" badge while a card with a
photo does not.

**B9 · Find Us renders a heading over an empty grid.** Unlike `lena-testimonials` — which wraps
everything in `{%- if testimonial_count > 0 -%}` — `lena-find-us` computes `visible_count` and
then renders the heading and `<div class="lena-find-grid" data-cards="0">` regardless. Remove the
location blocks with no event in the 14-day window and you get "Find Us This Weekend" over
nothing.

**B10 · Two predicates for one question.** `CLAUDE.md` states the rule: *"`all_products_count`,
not `products_count` … for any visibility decision."*

- `lena-drop-header.liquid:36` — `na_collection.all_products_count`
- `featured-collection.liquid:67` — `section.settings.collection.products.size > 0`

`CLAUDE.md` claims these two "appear and disappear together". They agree today by luck, not by
construction. `products.size` is also capped at 50 outside a `paginate`. This is the "one rule
written twice" class the global rules call the most expensive fault there is.

**B11 · A dead condition.** `main-collection-banner.liquid:38` reads
`{%- if section.settings.show_collection_description and collection.all_products_count > 0 -%}`
— but the entire block already sits inside the `{%- if collection.all_products_count > 0 -%}`
gate at line 25. The second test can never be false.

**B12 · "In-stock first" only sorts within a page.** The two-pass loop at
`main-collection-product-grid.liquid:146-200` runs inside `{%- paginate collection.products by … -%}`,
so `collection.products` is the current page slice. With `products_per_page: 48` against
`compact-mirrors`' 145 products, page 1 sorts its own 48 and page 3 sorts its own. Page 2 can open
on sold-out pieces while page 1 still had sold-out ones at the bottom. Not fixable in Liquid —
worth a comment saying so, the way R15 is handled in `lena-featured-piece`.

Also: `products_per_page` is **16** in `collection.new-arrivals.json` but **48** in
`collection.json` and `collection.this-weeks-drop.json`. 48 cards in one request is a lot of
images for a mobile visitor.

---

## C · Duplication — where the next bug will come from

The single-source-of-truth work already done (`lena-category-handles`, `lena-color-facet`,
`lena-event-window`, `lena-notify-target`) is genuinely good and has clearly prevented drift. These
are the places it did not reach.

| # | Rule written more than once | Copies | Where |
|---|---|---|---|
| C1 | The `1 of 1` / `N in stock` inventory badge | **3** | `card-product:108-119`, `main-product:118-128`, `lena-featured-piece:131-140` |
| C2 | "Only piece in existence" scarcity line | **3** | `card-product:256-260`, `main-product:148-154`, `lena-featured-piece:146-150` |
| C3 | "This piece found its home" | **2** | `card-product:148`, `main-product:157` |
| C4 | The Notify Me button (capture → split → onclick) | **2** | `card-product:262-270`, `main-product:159-167` |
| C5 | The modal focus-trap JS, **verbatim** | **2** | `lena-email-popup:48-100`, `lena-notify-modal:44-99` |
| C6 | The `section-{{ section.id }}-padding` `{% style %}` block | **6** | every Lena section with padding sliders |
| C7 | The facet active-pill capture boilerplate | **4** | `facets.liquid:77,358,818,929` |
| C8 | `collection.this-weeks-drop.json` vs `collection.new-arrivals.json` | **2** | differ only in `products_per_page` (48 vs 16) |

**C1–C4 are the ones that matter**, because all four read the same underlying fact — inventory
quantity — and B2 is already one of the three copies behaving differently from the other two. Two
snippets would collapse all of it:

```
snippets/lena-stock-badge.liquid     accepts: product, variant: 'card' | 'pdp' | 'featured'
snippets/lena-notify-button.liquid   accepts: product, label_style
```

That also gives `lena_qty` exactly one definition site, which is what makes B2 structurally
impossible rather than something to remember.

**C5** is ~55 lines duplicated character-for-character, including the comment explaining why it
exists. Two copies with one shared side effect: both write `document.body.style.overflow`, so if
both dialogs are ever open, whichever closes first unlocks scrolling for the other. An
`assets/lena-modal.js` with a `LenaModal(overlayEl)` factory removes both the duplication and that
interaction.

**C6** is the standard Shopify idiom and copying it is normal — but it is 6 copies of an
identical 12-line block, and `snippets/lena-section-padding.liquid` taking `section` would end it.
Low value, zero risk.

**C7** cannot be hoisted as-is because `{% render %}` isolates scope, but a
`lena-facet-pill` snippet rendering the whole `<facet-remove>` element would take all four sites
down to one line each *and* fix B4 in the same move.

---

## D · Dead code

| # | What | Where |
|---|---|---|
| D1 | `{%- when 'article' -%}` and `{%- when 'page' -%}` result branches | `main-search.liquid:361,371` |
| D2 | `form.action \|\| '/contact'` — `HTMLFormElement.action` always returns a resolved URL, never empty | `lena-email-popup.liquid:117` |
| D3 | `.lena-popup-content` and `.lena-fp-body` — used in markup, **zero** CSS rules | both modals, `lena-featured-piece:112` |
| D4 | `.lena-find-grid { grid-template-columns: 1fr }` declared in both the 900px and 640px media queries | `lena-custom.css:1058,1106` |
| D5 | `templates/collection.this-weeks-drop.json` + the live empty `this-weeks-drop` collection | template + admin |
| D6 | `lena-spotlight` — disabled, and its required "Artisan Stories" blog does not exist | `index.json` |

**D1** is a direct consequence of a Lena change: `<input type="hidden" name="type" value="product">`
now forces product-only results in all three search entry points (`header-search`, `main-search`,
`main-404`), and `search_url` carries `&type=product` so even "clear all filters" keeps it. Those
two branches can no longer be reached.

**D3** — `.lena-popup-content` sits on both dialogs' inner wrapper and has no styling at all; the
layout comes from `.lena-popup`. Either a leftover or a missing rule; worth one look in a browser.

**D5** — `/collections/this-weeks-drop` is live, holds 0 products, and will serve its
"we're preparing something special" empty state indefinitely. `CLAUDE.md` says it is kept in case
the URL was printed. That is a fair reason to keep the *collection*, but the template is a
copy of the New Arrivals one and a 301 to `/collections/available-now` would serve a visitor
holding an old card better than a permanent empty state.

---

## E · Documents that are no longer true

These are ranked by how much damage the false statement does.

| # | Document | What it says | What is true |
|---|---|---|---|
| **E1** | `OPEN_ITEMS.md` R1 | status `fixed` | **Not fixed.** See A1. The highest-cost line in the docs |
| E2 | `ARCHITECTURE.md` | `lena-custom.css`, 1018 lines + a line-number table | **1483 lines.** Every row's range is wrong |
| E3 | `ARCHITECTURE.md` | lists `.lena-countdown-pill` and `.lena-pdp-cat` | Neither exists — 0 hits in CSS *and* 0 in markup. Both were deliberately removed (countdown, PDP category eyebrow) |
| E4 | `CLAUDE.md` | homepage stack: Featured Piece is #6, after the New Arrivals pair | It is **#4**, before them. `index.json` order: hero, trust, our-story, **featured-piece**, drop-header, new-arrivals-grid, … |
| E5 | `CLAUDE.md` | required collections include `signature-purses` | `signature-purses` exists (50 products) but is **deliberately excluded** from `lena-category-handles`. The list omits the three that *are* canonical: `velvet-purses`, `rattan-purses`, `glass-bead-woven-handbags` |
| E6 | `CLAUDE.md` | modified stock files table | Missing 4: `main-collection-product-grid.liquid`, `header-search.liquid`, `newsletter.liquid`, `footer.liquid` |
| E7 | `CLAUDE.md` | `lena-custom.css` — 1414 lines, "80+ classes" | 1483 lines, 89 `.lena-*` classes |
| E8 | `OPEN_ITEMS.md` R28 | verify with `grep "lena_color_whitelist" snippets/facets.liquid` | Returns **0**. The whitelist moved to `lena-color-facet.liquid` and is named `cf_whitelist` |
| E9 | `OPEN_ITEMS.md` | line references throughout (R3, R15, R2 …) | Stale across the board — the files moved under them. Spot-checked 4, all 4 wrong |

**On E1 specifically.** Every other item here is ordinary drift. E1 is different in kind: it is a
state table asserting that a live, shopper-visible fault has been dealt with. The global rule
*"reply with a state table, not prose — a table of states stays true"* only holds if the table is
maintained; an unmaintained one is worse than prose, because it is trusted.

**On E2/E9.** Line-number tables in a document that is not regenerated will always go stale — this
is the second time `ARCHITECTURE.md`'s table has drifted. The global rule already names the fix:
*"give it a date, or write the command that produces it instead of the number."* For the CSS map
that is a one-line command:

```bash
grep -n '^/\* ---\|^/\* ──' assets/lena-custom.css
```

That prints the current section map, correct by construction, and would replace the whole table.

**What checks out.** Measured against the live store 2026-09-20, all **7** handles in
`lena-category-handles.liquid` resolve to real collections, and the "`compact-mirrors` is the
parent on purpose" note is right (`motif-compact-mirrors` 102 + `artisan-compact-mirrors` 40 sit
under `compact-mirrors` 145). The return window reads **15 days** in both places in code
(`main-product.liquid:654`, `index.json:432`) — the admin Refund Policy page is the third and was
not checked here. R2, R3, R9, R10, R11, R19, R21, R25, R26, R29 and R31 are all genuinely fixed in
the code.

---

## Smaller notes

- **Inline `style="display:none"` survives in both modals** (6 occurrences) and on
  `card-product.liquid:622`'s `card__badge`. R23 is recorded as closing this out. Removing them is
  not cosmetic: `isOpen()` in both dialogs is literally `overlay.style.display !== 'none'`, so the
  JS has to change with the markup. The `card__badge` one has no such excuse.
- **`lena-find-us`'s default heading is "Find Us This **Weekend**"** and its preset schedule reads
  "Every Saturday". `CLAUDE.md` says *"no frequency or day-of-week wording anywhere"*. That rule
  was written about **drop cadence**, and a recurring market stall is a different thing — but the
  rule as written does not carve that out, so the next person to read it will either "fix" this or
  quietly stop trusting the rule. Worth one sentence in `CLAUDE.md` either way.
- **`main-404.liquid`** builds a link as `{{ routes.collections_url }}/available-now` and hardcodes
  `/pages/contact` without `routes.root_url`. Both break under a locale or subfolder prefix.
- **`{% section 'lena-email-popup' %}`** is rendered statically in `theme.liquid:319`, but the
  section also declares `presets`. It can therefore also be added to a template from the theme
  editor, producing two popups on one page. `"limit": 1` does not prevent this — the static render
  is not counted.
- **`lena-featured-piece` hides its own image from assistive tech** (`tabindex="-1"
  aria-hidden="true"` on the media link). Deliberate — the title link beside it carries the name —
  but worth confirming in a screen reader, since the `alt` text is computed and then discarded.
- **`lena-custom.css` uses no `!important` anywhere.** Worth saying out loud; that is unusual for a
  1483-line override sheet and is why the cascade note in `CLAUDE.md` works.

---

## Suggested order of work

Nothing below has been done. Stated as a recommendation, not a plan.

**Before go-live**
1. **A1** — set the Featured Piece collection in admin (`artisan-compact-mirrors`, or re-enable
   Available Now), then correct R1's row in `OPEN_ITEMS.md`. One setting; the homepage currently
   has no product on it.
2. **A2** — restore an empty state in the filtered branch of `main-collection-product-grid`, with
   a working clear-filters link.
3. **B1** — let the collection banner keep its `<h1>` when the collection is empty.

**Soon after**
4. **B2 + C1–C4** as one change — extract `lena-stock-badge` and `lena-notify-button`. The bug and
   its three duplicates die together, which is the only version of this fix that stays fixed.
5. **B3, B4, B8, B11** — small, independent, each a few lines.
6. **E2, E4, E5, E6, E7** — one documentation pass. Replace `ARCHITECTURE.md`'s line table with the
   `grep` command above rather than re-deriving numbers that will drift again.

**When convenient**
7. **C5** — `assets/lena-modal.js`, removing ~55 duplicated lines and the shared-`overflow` interaction.
8. **B6, B7** — before Artisan Spotlight is ever enabled, not now.
9. **D1, D2, D3, D4, D5** — dead-code sweep.
