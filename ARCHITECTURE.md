# ARCHITECTURE.md — Lena Handicrafts Theme Deep Reference

> **This file deliberately contains almost no line numbers.**
>
> It used to be built out of them, and every one had rotted. On 2026-09-20 the CSS map was wrong
> by 80–137 lines on every single row, `main-404.liquid` was documented as 175 lines when it is
> 52, two of the selectors listed no longer existed, and a removed drop countdown was still
> described in three places. A wrong line number is worse than no line number: it sends the reader
> — including a subagent — to the wrong place *after* they have decided to trust it.
>
> So where this file would have printed a number, it prints **the command that produces the number
> now**. Commands cannot go stale. Run them.
>
> Numbers that *are* here carry a date, which makes them history rather than a claim about today.

---

## Where to look first

| Question | Command |
|---|---|
| What are the CSS sections, and where does each start? | `grep -nE '^/\* ?[─-]{2,}' assets/lena-custom.css` |
| How big is the stylesheet? | `wc -l assets/lena-custom.css` |
| Where is every Lena change in a stock file? | `grep -rn "Lena:" sections/ snippets/ layout/` |
| …and the ones with no marker? | `grep -rn "lena-color-facet\|lena_\|lena-" snippets/facets.liquid sections/featured-collection.liquid` |
| Which stock files were touched at all? | `git diff --name-only main -- sections/ snippets/ layout/ assets/ \| grep -v lena` |
| What does a section actually accept? | the `{% schema %}` at the bottom of its own file |
| Is a rule written more than once? | `bash docs/regression-check.sh` — section 3 asserts the single-source rules |

**Start with `grep -rn "Lena:"`.** Every deliberate change to a stock file is marked with
`{%- comment -%} Lena: … {%- endcomment -%}`. Three insertions carry no marker and are listed in
`CLAUDE.md`; they are the only exceptions.

---

## CSS architecture (`assets/lena-custom.css`)

There is no table of line ranges here any more. This prints the current map, correct by construction:

```bash
grep -nE '^/\* ?[─-]{2,}' assets/lena-custom.css
```

Every section of the stylesheet opens with a banner comment in that form, so the output *is* the
table of contents. Measured 2026-09-20 it listed 26 sections across 1500 lines.

**Two rules that matter more than the map:**

1. **No `!important` anywhere.** Verify with `grep -c '!important' assets/lena-custom.css` → `0`.
   That is unusual for an override sheet this size and it is what keeps the cascade predictable.
   Do not be the first to add one.

2. **A media query adds no specificity.** A mobile override written as a bare class loses to a base
   rule written as class-plus-attribute, at every width, silently. This shipped: the mobile
   `.lena-find-grid` rule lost to `.lena-find-grid[data-cards="3"]` and Find Us kept three columns
   on a phone. See the DEVLOG entry of 2026-09-20. **When a mobile rule appears not to work, check
   specificity before changing the value.**

Also note the load-order rule from `CLAUDE.md`: `lena-custom.css` loads in `<head>`, a section's own
stylesheet loads later and therefore *wins* any tie. Inside a stock component, add one more class to
the selector.

---

## Custom files

### Sections

| File | What it does |
|---|---|
| `lena-hero.liquid` | Hero with mosaic image grid and dual CTAs |
| `lena-drop-header.liquid` | New Arrivals bar — heading + linked count. Hidden while the collection is empty. **Nothing to do with drops any more**; the name is kept because three JSON templates bind the section `type` string |
| `lena-drop-coming-soon.liquid` | Empty-state section for a collection page. Same naming note |
| `lena-featured-piece.liquid` | One available product from a collection, rotating on a date seed |
| `lena-spotlight.liquid` | Blog-powered artisan rotation |
| `lena-testimonials.liquid` | Testimonial cards |
| `lena-find-us.liquid` | Location cards + scheduled-event metaobjects |
| `lena-email-popup.liquid` | Newsletter modal |

### Snippets — the single-source-of-truth layer

This is the most important part of the theme to understand, because most of the bugs found in 2026
were one rule written twice and then edited once. Each of these exists so that a rule has exactly
one home.

| Snippet | The one question it answers |
|---|---|
| `lena-stock.liquid` | How many are left, and what do we say about it? (`part: badge` / `part: scarcity`) |
| `lena-notify-button.liquid` | The Notify Me button, including the target plumbing |
| `lena-notify-target.liquid` | Which category is a Notify signup filed under? Outputs `<handle>\|<label>` |
| `lena-category-handles.liquid` | The canonical category handles, as one CSV |
| `lena-color-facet.liquid` | Is this facet value a real colour, and what is its label? (`fallback: hide` / `clean`) |
| `lena-facet-pill.liquid` | One active-filter pill, whole |
| `lena-facet-visible.liquid` | Will this filter render anything at all? |
| `lena-hide-nav-link.liquid` | Should this nav link be omitted? |
| `lena-event-window.liquid` | Is this scheduled event inside the display window? |
| `breadcrumbs.liquid` | PDP breadcrumbs. No trailing crumb — it would repeat the `<h1>` |
| `lena-notify-modal.liquid` | The Notify Me dialog markup and its `window.lenaNotify` entry point |

**Consume a snippet that returns a value with `capture`**, since Liquid snippets cannot return:

```liquid
{%- capture csv -%}{%- render 'lena-category-handles' -%}{%- endcapture -%}
{%- assign handles = csv | strip | split: ',' -%}
```

### Assets

| File | What it does |
|---|---|
| `lena-custom.css` | Every custom style. No inline `<style>`, no second CSS file |
| `lena-modal.js` | Shared dialog behaviour — focus trap, scroll lock, close wiring. `LenaModal.create(overlay, { onClose })`. Loaded `defer` from `<head>`, so both dialogs do their setup on `DOMContentLoaded` |

**The scroll lock is a shared count**, not a per-dialog assignment. A third dialog that writes
`document.body.style.overflow` itself will work alone and break the other two. Go through
`LenaModal`.

---

## Section schema reference

Settings verified against each file's `{% schema %}` on **2026-09-20**. Regenerate at any time:

```bash
for f in sections/lena-*.liquid; do echo "### $f"; sed -n '/{% schema %}/,/{% endschema %}/p' "$f"; done
```

| Section | Settings | Blocks |
|---|---|---|
| `lena-hero` | `eyebrow`, `heading`, `subheading`, `button_label_1/2`, `button_link_1/2`, `padding_top/bottom` | `mosaic_image`: `image`, `collection`, `tag_label`, `placeholder_text` |
| `lena-drop-header` | `eyebrow`, `heading`, `collection_handle`, `color_scheme`, `padding_top/bottom` | — |
| `lena-drop-coming-soon` | `eyebrow`, `heading`, `description`, `cta_label`, `cta_link`, `color_scheme` | — |
| `lena-featured-piece` | `collection`, `rotation`, `eyebrow`, `heading`, `description`, `cta_label`, `color_scheme`, `padding_top/bottom` | — |
| `lena-spotlight` | `eyebrow`, `heading`, `blog`, `rotation_weeks`, `color_scheme`, `padding_top/bottom` | — |
| `lena-find-us` | `eyebrow`, `heading`, `subheading`, `color_scheme`, `padding_top/bottom` | `location`: `name`, `schedule`, `description`, `address`, `directions_url`, `icon`, `primary` |
| `lena-testimonials` | `eyebrow`, `heading`, `subheading`, `color_scheme`, `padding_top/bottom` | `testimonial`: `quote`, `author_name`, `author_info`, `rating` |
| `lena-email-popup` | `heading`, `text`, `button_label`, `placeholder`, `success_message`, `delay_seconds` | — |

**There is no countdown in any of these.** `lena-drop-header` and `lena-drop-coming-soon` used to
carry a JS countdown to Friday. It was removed — the business is supply-driven and gaps run from
days to a month, so no cadence claim belongs anywhere in the theme. Earlier versions of this file
documented the countdown in three places; if you find another mention, it is stale.

**Every section with `presets` carries `"disabled_on": { "groups": ["header", "footer"] }`** except
`lena-drop-coming-soon`, which has no presets. Without that guard, a section added from the "Add
section" button inside the Header group lands in `sections/header-group.json`, pinned above the
template and undraggable.

---

## Rotation: how "pick one" works without a random filter

Liquid has no `random`. Both rotating sections seed an integer off the date and take it modulo the
pool size, so every visitor sees the same piece for the whole period.

**The seed counts days since the epoch** — `'now' | date: '%s' | divided_by: 86400` — divided down
for weekly or monthly. It must not read a calendar field directly: `'%m'` only takes 12 values,
`'%W'` caps near 54, and both reset every year, so a pool larger than that can never be fully reached
and the sequence jumps at the year boundary. `lena-featured-piece` hit this and `lena-spotlight`
carried the same fault until 2026-09-20.

**Known limit (R15):** outside a `paginate` tag, `collection.products` returns at most 50 products,
so `lena-featured-piece` can only ever feature the first 50 of its collection. Liquid offers no way
round it in a section. The practical answer is a collection sized to the job.

---

## Stock files: what was changed and why

`CLAUDE.md` holds the authoritative table. This is the part that needs explaining rather than
listing.

### Colour filter (`snippets/facets.liquid`)

The whitelist lives in **`snippets/lena-color-facet.liquid`**, once, in a variable named
`cf_whitelist`. It used to be pasted out in full twice inside `facets.liquid`, surrounded by six
copies of the "is this the Color filter" test written in two non-equivalent forms. Add a colour
there and every call site follows.

```bash
grep -n "cf_whitelist" snippets/lena-color-facet.liquid     # the list
grep -c "lena-color-facet" snippets/facets.liquid           # the call sites
```

Two answers, chosen by the caller:

- `fallback: 'hide'` (default) — the checkbox lists drop a non-colour value.
- `fallback: 'clean'` — the active pills tidy it instead (`color-accessories` → `Accessories`). A
  pill can never be hidden: it **is** the control that removes the filter.

A filter whose every value is hidden is skipped entirely by `lena-facet-visible`, so no empty
fieldset renders. That guard is restricted to `boolean` and `list` filters — `price_range` has no
`values` at all and an unguarded version would remove price filtering from the store.

> The Color filter appears empty on a collection until its products carry `color-{family}` tags from
> the batch uploader app.

### Product cards (`snippets/card-product.liquid`)

The badge, the scarcity line and the Notify button are **rendered from snippets**, not written here.
That is deliberate: the quantity used to be assigned inside the `featured_media` branch and read
outside it, so a product with no photo silently lost its scarcity line. There is no quantity variable
at any call site now.

The **New badge reads the app-owned `new` tag**, case-insensitively. It does *not* compute a window
from `created_at`. The app owns what "new" means and the `new-arrivals` smart collection matches the
same tag; a date filter in the theme would be a second opinion.

### PDP (`sections/main-product.liquid`)

Breadcrumbs, inventory badge, artisan line, scarcity/sold message, notify button, a quantity stepper
hidden at max-purchasable 1, and the return-window blurb. **There is no category eyebrow** —
`.lena-pdp-cat` was removed because it duplicated the breadcrumb directly above it.

**The return window is written by hand in three places** — here, the homepage Q&A in
`templates/index.json`, and the Refund Policy page in admin. Nothing links them.
`grep -rn "days of delivery" sections/ templates/` plus the admin page.

### Collection pages

- **Banner** — diamond eyebrow, title class, count pill. The banner **always renders**, including
  when the collection is empty; a collection page's `<h1>` is its title and there is no count at
  which it should disappear. The count pill keeps its own zero test.
- **Grid** — in-stock-first sorting via a two-pass loop, and two different empty states: a genuinely
  empty collection is handled by `lena-drop-coming-soon`, a collection *filtered* to nothing gets
  stock Craft's "No products found / remove all". Those are different sentences for different
  situations and must not be collapsed.
- **In-stock-first sorts within a page only.** The loop runs inside `paginate`, so
  `collection.products` is the current page slice. Not fixable in Liquid.

### 404 (`sections/main-404.liquid`)

Full rewrite: branded page with search, nav links and diamond motifs. **Its styles live in
`lena-custom.css`**, not in an inline block — an earlier version of this file said otherwise.

---

## Inline sections (NOT standalone files)

| Section | JSON key | What it is |
|---|---|---|
| Trust Strip | `lena-trust` | `custom_liquid` HTML inside `templates/index.json`. Scrolling marquee, messages duplicated for a seamless `translateX(-50%)` loop. Hover pauses; `prefers-reduced-motion` fallback |

Grepping the `sections/` directory will never find it. For the current homepage order:

```bash
python3 -c "import json,re;print(json.loads(re.sub(r'/\*.*?\*/','',open('templates/index.json').read(),flags=re.S))['order'])"
```

---

## Custom collection templates

| Template | Purpose |
|---|---|
| `collection.new-arrivals.json` | Banner + empty-state section + grid. Needs manual template assignment in admin |
| `collection.this-weeks-drop.json` | **Legacy.** Nothing links here. The collection is live and holds 0 products, so it serves a permanent empty state — see `docs/OPEN_ITEMS.md` for the redirect that should replace it |

---

## Common tasks

Files, not line numbers. Find the spot inside the file with the grep in the right-hand column.

| Task | File | Find it with |
|---|---|---|
| Brand colours | `assets/lena-custom.css` | `grep -n '^  --lena-' assets/lena-custom.css` |
| A CSS section | `assets/lena-custom.css` | `grep -nE '^/\* ?[─-]{2,}' assets/lena-custom.css` |
| Responsive breakpoints | `assets/lena-custom.css` | `grep -n '@media' assets/lena-custom.css` |
| Inventory badge / scarcity wording | `snippets/lena-stock.liquid` | whole file |
| Notify button wording | `snippets/lena-notify-button.liquid` | whole file |
| "New" badge rule | `snippets/card-product.liquid` | `grep -n 'lena_is_new' snippets/card-product.liquid` |
| Colour whitelist | `snippets/lena-color-facet.liquid` | `grep -n 'cf_whitelist'` |
| Event display window | `snippets/lena-event-window.liquid` | `grep -n 'ev_window'` |
| Which nav links are hidden | `snippets/lena-hide-nav-link.liquid` | whole file |
| Dialog behaviour | `assets/lena-modal.js` | whole file |
| Return window | three places | `grep -rn "days of delivery" sections/ templates/` + admin |
| Products per page | `templates/collection*.json` | `grep -rn products_per_page templates/` |
| Hero, Q&A, testimonials, Find Us content | **Shopify admin** | `templates/index.json` stores it; edit in admin, then `git pull` |
| Fonts, page width, colour schemes | **Shopify admin** | `config/settings_data.json` |

**Before editing any of these, re-read the admin-vs-code table in `CLAUDE.md`.** Section setting
text, images, colours, padding, and section show/hide/reorder live in `templates/*.json` and must be
changed in admin — Shopify strips setting IDs it does not recognise when it ingests a hand-edited
JSON template.

---

## Newsletter tagging

| Segment | Tags | Capture point |
|---|---|---|
| General interest | `newsletter` | Email popup (delay or exit intent) |
| Footer list | `newsletter,drop-list` | Footer newsletter form |
| Category notify | `newsletter,notify-{handle}` | Notify Me on a sold-out card or PDP |
| POS subscribers | `newsletter,drop-list` | Shopify Flow, on customer creation with marketing consent |

The `{handle}` comes from `lena-notify-target`, **never from `product.type`** — the two disagree for
five of the seven live categories.

```bash
grep -rn "contact\[tags\]\|notify-" snippets/lena-notify-modal.liquid sections/lena-email-popup.liquid
```
