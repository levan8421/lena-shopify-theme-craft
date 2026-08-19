Edit the Shopify Craft theme. The user will describe what to change.

## Rules — read before every edit

### Step 0 — route the change (do this before classifying files)

`git pull` first — the admin theme editor commits back to `website-redesign`, so local can be stale.

Then decide where the change belongs:

| Change | Lives in | Do it in |
|---|---|---|
| Section setting text, images, colors, padding | `templates/*.json` | Shopify admin |
| Hiding / showing / reordering sections and blocks | `templates/*.json` (`"disabled": true`) | Shopify admin |
| Header, footer, menus, global colors and fonts | `sections/*-group.json`, `config/settings_data.json` | Shopify admin |
| Text with no matching field in the theme editor | `sections/*.liquid` | Code |
| A *new* setting, markup, conditional logic, styles | `sections/*.liquid`, `assets/lena-custom.css` | Code |

Quick test: does the section's `{% schema %}` already declare a setting for it? Yes means admin. No means code.

If the change is admin-owned, say so and tell the user to make it in the theme editor (Online Store → Themes → Customize) and then `git pull` — do not edit the JSON locally. Shopify strips setting IDs that the section's `{% schema %}` doesn't declare, so a hand-added setting in a JSON template is silently dropped.

### File classification (CRITICAL — determines how you edit)

**Lena-created files (edit freely):**
- `sections/lena-*.liquid` — Custom sections (hero, drop-header, drop-coming-soon, spotlight, find-us, email-popup, testimonials)
- `snippets/lena-*.liquid` — Custom snippets (notify-modal)
- `assets/lena-custom.css` — All custom styles (1000+ lines, organized by section)
- `templates/collection.this-weeks-drop.json` — Custom collection template

**Stock files with Lena edits (edit ONLY within marked ranges):**
- `sections/main-product.liquid` — lines 101–139 (PDP: eyebrow, badge, artisan, scarcity)
- `sections/main-collection-banner.liquid` — lines 14–33
- `sections/featured-collection.liquid` — line 67, ~215
- `snippets/card-product.liquid` — lines 108–122, 164–167, 228–237
- `snippets/facets.liquid` — lines 204–220, 592–608
- `sections/main-404.liquid` — full rewrite (lines 1–175)
- `sections/main-collection-product-grid.liquid` — in-stock-first sorting

**Stock files (DO NOT edit outside marked ranges):**
All other files in `sections/`, `snippets/`, `assets/`, `layout/`, `templates/` are stock Craft theme files. Theme updates will overwrite unmarked changes.

### Comment convention (MANDATORY for stock files)

Every insertion in a stock file MUST be wrapped:
```liquid
{%- comment -%} Lena: <description> {%- endcomment -%}
```
This makes all custom code greppable with `Lena:`.

### CSS rules

1. All custom CSS goes in `assets/lena-custom.css` — never add inline `<style>` tags
2. Use `--lena-*` CSS variables for colors (19 defined at top of file)
3. Prefix all custom classes with `lena-` to avoid conflicts with stock theme
4. Follow the section organization in the CSS file (each section has a header comment)
5. Mobile breakpoints: 900px (tablet), 640px (mobile)

### Liquid patterns

1. **Empty-state handling**: Always check `collection.products.size > 0` before rendering collection-dependent sections
2. **Inventory badges**: Use `product.variants.first.inventory_quantity` for dynamic stock display
3. **Color filter**: If adding new tag types, check `snippets/facets.liquid` whitelist to prevent filter pollution
4. **Drop countdown**: Uses UTC internally — `Friday 11:00 UTC = Friday 6 AM EST`
5. **Section schemas**: Include `color_scheme` picker when section needs theme-aware colors

### Design system

- Fonts: Josefin Sans (headings) + Libre Franklin (body)
- Diamond motif: `.dm` (7px), `.dm.filled` (solid blue), `.dm.gold` (amber), `.dm.sm` (5px)
- Buttons: `.lena-btn-primary` (blue gradient), `.lena-btn-ghost` (white border)
- Color schemes: scheme-1 (Snow), scheme-2 (White), scheme-3 (Amber), scheme-4 (Navy), scheme-5 (Navy-mid)

## Edit workflow

1. Read CLAUDE.md and ARCHITECTURE.md for current state
2. Identify if the target file is Lena-created or stock (determines edit approach)
3. Read the target file(s) before making changes
4. Make changes following the rules above
5. Verify with `shopify theme dev` if a dev store is available
6. If editing `lena-custom.css`, check mobile responsiveness at 640px and 900px
7. If editing stock files, verify `Lena:` comment markers are in place
8. Summarize what changed and which files were modified
