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
| `sections/lena-hero.liquid` | 169 | Hero with mosaic image grid, dual CTAs |
| `sections/lena-drop-header.liquid` | 111 | New Arrivals bar — heading + linked count. Hidden while the collection is empty |
| `sections/lena-drop-coming-soon.liquid` | 77 | Empty-state section for a collection page (soft landing + onward CTA) |
| `sections/lena-spotlight.liquid` | 173 | Blog-powered artisan rotation (1/2/4 week cycle) |
| `sections/lena-featured-piece.liquid` | 228 | Spotlights one available product from a collection, rotating on a date seed (daily/weekly/monthly). Skips sold-out pieces; hides itself when none are available. Has a `presets` block — add it from the theme editor |
| `sections/lena-testimonials.liquid` | 190 | Customer testimonial cards |
| `sections/lena-find-us.liquid` | 239 | Location cards + metaobject scheduled events |
| `sections/lena-email-popup.liquid` | 90 | Newsletter modal (tags `newsletter` only) |
| `snippets/lena-notify-modal.liquid` | 70 | "Notify me" modal for sold-out pieces. Tags the contact `newsletter,notify-<category-handle>` |
| `snippets/breadcrumbs.liquid` | 56 | PDP breadcrumbs — `collection` when arrived through one, category list as fallback. **No trailing crumb**: it would repeat the `<h1>` beneath it |
| `snippets/lena-category-handles.liquid` | 17 | The canonical category handles as one CSV. Single source of truth for `breadcrumbs` and `related-products`; consume with `capture` + `render` |
| `assets/lena-custom.css` | 1203 | All custom styles (17 sections, 80+ classes) |

**Filename note:** `lena-drop-header` and `lena-drop-coming-soon` keep their filenames for historical
reasons — the section `type` string is bound by three JSON templates, so renaming the files breaks
them. Neither has anything to do with drops any more; see their header comments.

### Modified stock files (edit ONLY the marked ranges)

| File | Lena lines | What was added |
|------|-----------|----------------|
| `sections/main-product.liquid` | 101–140, 300–420, 593, 630–645 | PDP: breadcrumbs, inventory badge, artisan line, scarcity/sold msg · quantity stepper hidden at max-purchasable 1 · 30-day returns. **No category eyebrow** — it duplicated the breadcrumb |
| `sections/main-collection-banner.liquid` | 14–33 | Collection: diamond eyebrow, title class, product count pill |
| `sections/featured-collection.liquid` | 67, ~215 | Conditional wrapper: hides section when linked collection is empty (**unmarked** — no `Lena:` comment, so grep misses it) |
| `snippets/card-product.liquid` | 108–122, 164–167, 228–237, 332–337, 436–437 | Cards: inventory badge (dynamic), sold overlay, category label, scarcity/notify · quick add gated on `card_product.available` so a sold-out card keeps Notify Me as its only CTA |
| `snippets/facets.liquid` | 204–220, 592–608 | Color filter whitelist: skips non-color tag values (e.g. "Accessories", "artisan") |
| `snippets/header-dropdown-menu.liquid` | ~11 | Omits the New Arrivals nav link while that collection is empty |
| `snippets/header-drawer.liquid` | ~25 | Same rule, mobile drawer. Link list only — panel behaviour untouched |
| `snippets/header-mega-menu.liquid` | ~11 | Same rule. Dormant unless `menu_type_desktop` is set to `mega` |
| `sections/main-404.liquid` | 1–175 | Full rewrite: branded 404 with search, nav links, diamond motifs |
| `sections/collection-list.liquid` | ~18, schema | `subtitle` setting rendered under the section title |
| `sections/related-products.liquid` | 30–145 | Recommendations filtered to matching `product.type`, topped up from the product's category collection so the row is never short |

### Comment convention

All Lena changes in stock files are marked: `{%- comment -%} Lena: <description> {%- endcomment -%}`. Grep for `Lena:` to find every custom insertion.

### Load point

`layout/theme.liquid` line 259 loads `lena-custom.css` after `base.css`.

## Homepage Section Stack (`templates/index.json`)

| # | Section | Type | Notes |
|---|---------|------|-------|
| 1 | Hero | `lena-hero` | Navy bg, mosaic grid, "One piece at a time" |
| 2 | Trust Strip | `custom-liquid` | Scrolling diamond marquee (inline HTML, not a section file) |
| 3 | Our Story | `image-with-text` | Founder photo + brand narrative |
| 4 | New Arrivals bar | `lena-drop-header` | Collection `new-arrivals`. Heading + linked count. **Hidden while empty** |
| 5 | New Arrivals grid | `featured-collection` | Key `new-arrivals-grid`. Collection `new-arrivals`, no title — the bar above is its heading. Hides itself if empty, so the pair appear and disappear together |
| 6 | Featured Piece | `lena-featured-piece` | One available product from a collection, rotating daily. Replaces the job Available Now was doing |
| 7 | Available Now | `featured-collection` | **Disabled.** 219 products behind a 4-item window; superseded by Featured Piece |
| 8 | Shop by Category | `collection-list` | 12 collection tiles + subtitle |
| 9 | Testimonials | `lena-testimonials` | Customer quotes |
| 10 | Artisan Spotlight | `lena-spotlight` | **Disabled.** Requires an "Artisan Stories" blog |
| 11 | Q&A | `collapsible-content` | 6 accordion items (handmade, artisans, design, in-person, photo, returns) |
| 12 | Find Us | `lena-find-us` | Uses `scheduled_event` metaobjects |

**Note:** Trust Strip is custom-liquid HTML inside `templates/index.json`, NOT a standalone section file.

### Custom Collection Templates

| Template | Collection | Purpose |
|----------|-----------|---------|
| `templates/collection.new-arrivals.json` | `new-arrivals` | Banner + empty-state section (when empty) + product grid. Requires manual template assignment in Shopify Admin. |
| `templates/collection.this-weeks-drop.json` | `this-weeks-drop` | Legacy. Nothing links here any more; kept in case the URL was printed. |

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

- **Collections:** `available-now` (smart, `inventory > 0 AND tag ≠ POS`), `new-arrivals` (smart, **`Tag is equal to new`** — set once, never edited; the app owns the tag), `crochet-dolls`, `compact-mirrors`, `ribbon-embroidery-hats`, `signature-purses`, `phone-travel-wallet`
- **Blog:** `Artisan Stories` (for spotlight section)
- **Metaobject:** `scheduled_event` (fields: `start_date`, `end_date`, `name`, `time_text`, `description`, `address`, `icon`)
- **Menu:** `main-menu-gallery`

## Branches and themes

**Theme name = branch name.** Shopify prints the connected branch under every theme title, so the
two agreeing makes a rollback unambiguous. This is what the three near-identically-named themes cost
us once already.

| Branch | Shopify theme | Role |
|---|---|---|
| `website-redesign` | `website-redesign` | **LIVE / published.** A push here goes live with no review step |
| `staging` | `staging` | Draft theme, permanently connected. All review happens here |
| `main` | — | Stock Craft 15.4.1, initial commit only. Not connected, not used |

**Never rename `website-redesign`.** Renaming a branch Shopify is connected to breaks the link to
the live theme. Rename the *theme* to match the branch, never the reverse.

**The owner pushes, not Claude.** Claude commits to local `staging` and stops. Pushing is the
owner's call, because a push is what makes work visible on the store.

### The review loop

**Sync first — every time, before any local edit.** Unconditional: do not check whether there is
anything to merge, just run it. It is a no-op when there isn't.

```bash
git fetch origin
git checkout staging && git pull
git merge origin/website-redesign     # usually "Already up to date"
```

Then:

1. Work lands on `staging` in code. Claude commits; **the owner pushes**.
2. The `staging` draft theme picks the push up automatically — the owner verifies in a real browser.
3. The owner makes admin-side changes in the theme editor (move sections, edit text,
   enable/disable). **Shopify commits those back to `staging` as real commits.**
4. `git pull` before touching anything locally again.
5. To publish: run the sync block again, then
   `git checkout website-redesign && git merge staging && git push`.

### Why the sync block matters

Two systems write to these branches, so this is the same hazard as a shared field with no baseline.
**An accidental edit on the *live* theme commits to `website-redesign` only.** If `staging` never
absorbs it, the next publish **silently reverts it** — staging's copy of that JSON file wins the
merge, and nobody gets told.

Merging live → staging first also means `website-redesign` is an ancestor of `staging`, so **the
publish in step 5 is a fast-forward** — no conflict at the single worst moment to have one. That
property only holds if the sync is re-run immediately before publishing, which is why step 5 repeats
it.

An accidental live edit is therefore recoverable, not a disaster: it is a commit, visible in
`git log origin/website-redesign`, and the sync block is how it gets home.

**Step 4 is not optional either.** Any theme-editor save makes local stale, and the conflict lands in
a generated JSON file where it is painful to resolve. Never hold unpushed local commits while the
owner is editing in admin.

## Development Rules

### Where to make the change — admin vs code

Decide this before touching a file. The dividing line is which file stores the change.

| Change | Lives in | Do it in |
|---|---|---|
| Section setting text, images, colors, padding | `templates/*.json` | Shopify admin → `git pull` |
| Hiding / showing / reordering sections and blocks | `templates/*.json` (`"disabled": true`) | Shopify admin → `git pull` |
| Header, footer, menus, global colors and fonts | `sections/*-group.json`, `config/settings_data.json` | Shopify admin → `git pull` |
| Text with no matching field in the theme editor | `sections/*.liquid` | Code → push |
| A *new* setting, markup, conditional logic, styles | `sections/*.liquid`, `assets/lena-custom.css` | Code → push |

Quick test: open the section in the theme editor. A field for it means admin. No field means code.

Do not hand-edit `templates/*.json`, `sections/*-group.json`, or `config/settings_data.json` locally unless the matching setting already exists in that section's `{% schema %}` — Shopify strips setting IDs it doesn't recognise when it ingests the file.

### Editing workflow
1. **Pull first** — `git pull` before any local edit. The admin theme editor commits back to whichever branch the theme is connected to (`staging` during review, `website-redesign` once live), so local can be behind at any time.
2. **Read before editing** — Always read the target file and ARCHITECTURE.md before making changes
3. **Stock vs custom** — Know which type of file you're editing. Stock files get `Lena:` comment markers; custom files are edited freely.
4. **CSS in one place** — All custom styles go in `assets/lena-custom.css`. No inline `<style>` tags, no new CSS files.
5. **Mobile-first verification** — Check 640px and 900px breakpoints after any layout change
6. **Empty-state handling** — Any section that depends on a collection must handle `products.size == 0` gracefully

### Shopify Liquid patterns
- **Inventory**: `product.variants.first.inventory_quantity` for stock counts
- **Tags**: Check for tag before rendering conditional UI (`product.tags contains 'tag-name'`)
- **Metaobjects**: Use `section.settings.{metaobject}` for dynamic data
- **No cadence claims**: The business is supply-driven — gaps run from days to a month. No frequency
  or day-of-week wording anywhere, and no countdown. The Friday countdown was removed for this reason.
- **New Arrivals**: the theme does not know what "new" means. The app owns a single `new` tag; the
  smart collection matches it; the section and nav link render only while
  `collections['new-arrivals'].all_products_count > 0`. Deliberately **no** date filter, staleness
  read or item cap — those would make the theme second-guess the app.
- **`all_products_count`, not `products_count`**: the latter reflects the current tag-filtered view.
  Use `all_products_count` for any visibility decision.
- **Color filter**: Whitelist in `snippets/facets.liquid` — update both desktop and mobile instances
- **Section CSS beats `lena-custom.css` at equal specificity.** `lena-custom.css` loads in the
  `<head>` (`theme.liquid:259`); a section's own stylesheet loads from inside the section body, so
  it comes *later* in the cascade and wins any tie. This is why `.product__title > * { margin: 0 }`
  in `section-main-product.css` silently zeroed the margins on every Lena element inside the PDP
  title block. **When styling inside a stock component, add one more class to the selector** —
  `.product__title > .lena-breadcrumbs`, not `.lena-breadcrumbs`.
- **`product.type` is NOT the collection title.** Measured 2026-09-15: types include `Beaded
  Purses` and `Compact Mirrors` while the collections are *Glass Bead Woven Handbags* and
  *Artisan / Motif Compact Mirrors*. Group products by `type`; never match `type` against
  `collection.title` — it fails silently for most categories. See T0-16 in `docs/OPEN_ITEMS.md`.
- **Sections with `presets` can be added to the header/footer groups by mistake.** The theme editor
  shows an "Add section" button inside the Header group as well as the Template area, and a section
  added there lands in `sections/header-group.json` — pinned above the template and undraggable.
  Guard any body-only section with `"disabled_on": { "groups": ["header", "footer"] }` in its schema.
- **No random filter in Liquid.** To pick one item pseudo-randomly, seed an integer off `'now'`
  and modulo the collection size. `lena-spotlight` and `lena-featured-piece` both do this; reuse
  the pattern rather than adding JavaScript.
- **`url` setting defaults**: Shopify accepts only `/collections` and `/collections/all` as the
  `default` for a `type: "url"` setting. Any other path — even a valid one like
  `/collections/available-now` — is rejected with `default must be a string or datasource access
  path`, and the whole section file fails to upload, taking every JSON template that references it
  down too. **Omit `default` and handle blank in the markup.** `shopify theme check` does not catch
  this; only an upload does.
- **Schema defaults**: Never write `"default": ""` in a `{% schema %}` setting. Shopify rejects the whole file with `Invalid schema: setting with id="x" default can't be blank`, and the GitHub sync then silently skips it — plus any JSON template referencing that section type. Omit `default` entirely for an optional field.

### Post-change checklist
1. Visual check in `shopify theme dev` (if available)
2. Check mobile layout at 640px
3. Verify no Liquid syntax errors (broken pages)
4. Update CLAUDE.md tables if files were added/modified
5. Update ARCHITECTURE.md for complex logic changes

## Slash Commands

- `/edit-theme` — Safely edit theme files (handles stock vs custom distinction)
- `/add-section` — Add a new custom section with proper naming, schema, and CSS

## Competing Theme

Rise theme at `/Users/vanhoanghai/projects/lena-shopify_theme/` on `website-redesign` branch. Comparing both before deploy.
