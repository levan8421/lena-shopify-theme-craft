# Tier 0 Part A — build report

**Brief:** `TIER0_CLAUDE_CODE_PROMPT-v7.md` (supersedes v1–v6)
**Branch:** `tier0-part-a`, off `website-redesign`
**State:** nothing committed, nothing published, no preview run yet

---

## Summary table

| Ref | Status | Files touched |
|---|---|---|
| A1 · Related-card titles | **Not reproduced — closed** | none |
| A2 · Quantity stepper at inventory 1 | **Fixed** | `sections/main-product.liquid` |
| A3a · Primary CTA → `available-now` | **Fixed** | `templates/index.json` |
| A3b · Mobile hero 2×2 tiles | **Fixed** | `assets/lena-custom.css` |
| A4b · Cadence claims | **Fixed (code) / 3 items to admin** | `lena-drop-header.liquid`, `lena-drop-coming-soon.liquid`, `index.json`, `lena-hero.liquid`, both collection templates |
| A4c · 1-of-1 marquee | **Fixed** | `templates/index.json` |
| A4d · 30-day returns | **Fixed (FAQ + PDP)** · policy page is owner-side | `templates/index.json`, `sections/main-product.liquid` |
| A5 · Nav restructure, code half | **Fixed** | `snippets/breadcrumbs.liquid` (new), `main-product.liquid`, `collection-list.liquid`, `index.json`, `main-404.liquid`, `lena-notify-modal.liquid` |
| A6 · Colour filter | **Report only — not implemented**, per brief | none |
| §4 · New Arrivals | **Built** | `lena-drop-header.liquid`, 3 header snippets, `index.json` |

**Validation:** `shopify theme check --fail-level error` → **0 errors, 8 warnings**, all pre-existing
in stock files across 7 files (`layout/password`, `layout/theme`, `featured-product`, `main-article`,
`main-list-collections`, `main-product` `seo_media`, `main-search`). All JSON parses; no blank schema
defaults; Liquid tag balance verified per tag type on every edited file.

---

## What was built

### A2 · Quantity stepper

The stepper is hidden when only one unit can be bought, and capped at real stock otherwise. Two
things were not obvious and are worth recording:

- **The wrapper div must always render.** `product-info.js` dereferences `#Quantity-Form-<section>`
  on variant change and throws if it is absent. Only the control inside it is conditional; a hidden
  `<input name="quantity">` carries the value.
- **Show/hide is decided across every variant, not the selected one.** The theme swaps
  price/sku/inventory on variant change but never re-renders this block, so a stepper hidden at load
  would stay hidden after switching to a higher-stock variant — capping that variant at one unit.
  Affects the ~8 multi-variant products.
- **The cap is the lower of the merchant rule and inventory.** `quantity_rule.max` is merchant-set
  and normally `nil`, so the stock markup emitted no `max` at all. The brief's "capped at 3" was not
  actually being met before this.

### §4 · New Arrivals

Built to the v7 rewrite: **visibility only.** No settings, no `published_at`, no `created_at`, no
staleness read, no item cap. `sections/lena-drop-header.liquid` went from 174 lines to 111.

- Renders only while `collections['new-arrivals'].all_products_count > 0`
- Copy is a heading plus a linked count — "14 new pieces", singular-aware
- **No empty-state copy.** See the open question below

The **menu link** is omitted by the same condition, via one `{% continue %}` in
`header-dropdown-menu.liquid`, `header-drawer.liquid` and `header-mega-menu.liquid`. Scoped to the
`new-arrivals` handle by name — a general "hide empty collections" rule would erase a newly created
category from the nav before its products load. The drawer edit is a link-list skip only; panel
behaviour, back button and tap count are untouched.

**At launch this section and link are both hidden**, because the collection does not exist yet and
nothing has been published since 27 May. That is the design working.

### A4b · Cadence

The Friday countdown is gone entirely from both sections — the UTC Friday maths, the pills, the
`show_countdown` and `next_drop_date` settings, and the now-dead `.lena-countdown-pill` /
`@keyframes dm-pulse` CSS. It was dormant (`show_countdown: false`) but one checkbox from making a
claim the whole brief exists to remove.

Section names in the theme editor: "Drop Header" → **New Arrivals**, "Drop Coming Soon" →
**Collection Empty State**. **Filenames unchanged** — the section `type` string is bound by three
JSON templates.

### Homepage bindings

| Slot | Was | Now |
|---|---|---|
| 3 `lena-drop-header` | `this-weeks-drop` | `new-arrivals` — hidden today |
| 4 `featured-collection` | `this-weeks-drop`, 0 products → **grid rendered nothing** | `available-now`, title "Available Now" |

Slot 4's `title` was `""` because it relied on the header above it, which now hides. The homepage
had no product grid at all before this change.

---

## Owner-side

### Admin — do these in the theme editor, then `git pull` on `website-redesign`

`sections/header-group.json` and `sections/footer-group.json` were reverted on this branch: CLAUDE.md
routes header/footer to admin, and deleting a block is structural.

1. Header → Announcement bar → **delete** the "Next drop: Friday 8 PM ET →" block (keep free shipping)
2. Footer → Newsletter heading: `Join the Drop List` → **`Join the List`**
3. Footer → Newsletter paragraph → **`Be first when new pieces go live.`**

### Still outstanding

- Create **`new-arrivals`** — smart collection, `Tag is equal to new`. Set once, never edited
- Assign `templates/collection.new-arrivals.json` to it
- **Rename the two near-identical unpublished themes before any publish** — `192252215618` is MAIN
- Check `/policies/refund-policy` against the new 30-day wording; flag conflicts rather than
  overwriting a legal page
- T0-16 facet names (app-side) · `Phone Travel Wallets` plural · currency `${{amount}}` (admin UI
  only, no API surface) · build the `Shop ▾` menu · Shop Pay marketing-consent setting

---

## Open question for the auditor

**A4b's vocabulary spec contradicts §4.** A4b still specifies an empty state — "New pieces added
throughout the season", plain text, no link — and a `new_arrivals_window_days` hide rule. §4 cancels
that setting and says "otherwise **both hide**". Built to §4; that empty string does **not** exist in
the theme. A4b bullets 3–4 look like they were missed when §4 was rewritten.

---

## Developer error, caught in preview — `theme check` does not detect it

Retiring `/collections/all` (A5) included changing the `cta_link` default in
`lena-drop-coming-soon.liquid` to `/collections/available-now`. **A `url` setting's `default` may
only be `/collections` or `/collections/all`** — those two literals, nothing else. Shopify rejected
the section file on upload, and both JSON templates referencing that section type failed with it.
The same cascade CLAUDE.md already documents for blank defaults.

`shopify theme check --fail-level error` passed clean throughout. It does not validate `url` defaults,
so **theme check alone is not a sufficient gate before pushing** — a `theme dev` upload is.

Fixed by omitting `default` entirely and skipping the button when the link is blank; both templates
already supply the real URL. Swept every `url` setting in the theme — this was the only one.

**Add to the post-change checklist:** for any `url` setting, either omit `default` or use exactly
`/collections` or `/collections/all`.

---

## Found, not fixed

- **A6 · the two extra colour tags.** 15 live `color-*` tags vs the app's 13 families. The 13
  spectrum/neutral names fit exactly, and the extras are **`color-clear`** and **`color-silver`** —
  2 products each, **all four Glass Bead Woven Handbags**. Finishes, not colours, from that one
  category template. `color-clear` is also the only value the theme's 55-name whitelist silently
  drops. Neither bag vanishes from the facet (both carry a second colour tag), but "Clear" is
  unfilterable, so a customer wanting it finds it under Black or White by accident.
- **`drop-list` customer tag** — `sections/footer.liquid:174` and `sections/newsletter.liquid:49`
  post `contact[tags] = "newsletter,drop-list"`. Not customer-visible, but it lands on the customer
  record and in any email-platform segment. Renaming it would split the subscriber list across two
  tags. Left alone; it is an email-platform decision, not a theme one.
- **`featured-collection.liquid:67`** carries the empty-collection guard but no `Lena:` marker, so
  the grep convention misses it. Noted in CLAUDE.md rather than adding a marker to a line that
  already works.
- **`this-weeks-drop`** collection and template are now unreferenced. Left in place in case the URL
  was printed somewhere.
- **`featured-collection.products_to_show` is 4.** That was sized for a small weekly batch; it is now
  the homepage's only product grid over 158 available pieces. A pure setting value — change it in the
  theme editor if one row looks thin.

---

## Verification still needed — requires a browser

```bash
node /opt/homebrew/Cellar/shopify-cli/3.92.1/libexec/bin/shopify theme dev
```

The stock `shopify` shim is broken: its shebang points at a Homebrew node that no longer exists.
Invoke via `node` as above. Not repaired — that is a change to your PATH, not to this project.

**Check at 375px and 1440px:**

| What | Expect |
|---|---|
| A2 · `grande-velvet-clutch-antique-pink` | qty 1 → **no stepper**, still adds to cart |
| A2 · `lux-bar-velvet-clutch-rose-blush` | qty 2 → stepper capped at 2 |
| A2 · `midi-velvet-clutch-black-noir-with-mixed-rose-garden` | qty 3 → stepper capped at 3 |
| A2 · `midi-velvet-clutch-magenta` | sold out → §6 treatment unregressed |
| A3b · hero | all four tiles visible, legible, unclipped at 375px; desktop unregressed |
| New Arrivals | section absent, nav link absent from **both** dropdown and drawer, no Liquid error |
| Homepage spacing | no double gap where the New Arrivals section is hidden |
| Breadcrumbs | arrive via a collection → that collection; direct hit → menu-list fallback |

To exercise the populated New Arrivals path before the collection exists: point `collection_handle`
at `available-now` and add a temporary menu link to it — expect the bar reading "235 new pieces" —
then revert both.

**§6 regression sweep:** sold-out treatment · `1 OF 1` / `3 IN STOCK` badges · mobile PDP gallery ·
**mobile drawer open/close, submenu slide and back button** (the carve-out file) · mobile collection
grids and "Filter and sort" · Lux Bar Velvet Clutch PDP.

**Nothing published without explicit approval. Preview URL first.**
