# Tier 0 — Gate Results and Corrections

**Developer response to `TIER0_CLAUDE_CODE_PROMPT-v2.md`**

- **Store:** lenahandicrafts.com — Craft 15.4.1
- **Method:** live published storefront + published CSS bundles + Admin API. No browser needed;
  everything below is reproducible from raw HTTP responses.
- **Status:** Step 0 and A1 both closed. **Still no code written.**

---

## Summary

| Item | Result |
|---|---|
| **Step 0** — which theme is published? | **Published matches `website-redesign`.** No branch mismatch. |
| **A1** — related-card titles | **Does not reproduce. Correction #10.** |
| **T0-14 secondary CTA** | **My error — it works.** Correction #1 against me. |
| **T0-14 primary CTA** | Real, but milder than I stated |
| **A6** — colour filter | **My diagnosis was wrong.** The real bug is different, and live. |
| **77-product gap** | Resolved — 158 is correct, nothing is leaking |
| **New: T0-16** | The filter exposes a *fourth* category taxonomy |

Two of the seven are corrections against my own findings. Details below, because I'd rather
hand you those than have you build on them.

---

## Step 0 · The published theme is this branch

Fetched `https://lenahandicrafts.com/` directly. Every string you verified live on 19 Aug is
byte-identical to `website-redesign`:

| String | Live | Branch |
|---|---|---|
| Drop heading | `New Drop <strong>Every Friday</strong>` | `templates/index.json:84` — identical |
| Marquee | `Each Piece Is 1 of 1` (×2) | `templates/index.json:74` — identical |
| Announcement | `Next drop: Friday 8 PM ET →` | `header-group.json:27` — identical |
| Hero body | `New drops every Friday.` | `templates/index.json:61` — identical |

I also diffed the published CSS against the branch. `lena-custom.css` served from
`cdn/shop/t/22/assets/` is identical to `assets/lena-custom.css` **modulo Shopify's minifier**
(`0.07` → `.07`) — no content differences.

**Conclusion:** there is no third snapshot. What you saw live is what is on this branch. The
"New Pieces Coming Soon" string you couldn't find was my *proposed* replacement in the plan, never
shipped — that was my fault for not labelling it clearly as a proposal.

**Every "already satisfied" conclusion in my v1 response therefore stands**, including A4a: the
countdown is disabled on the published theme, confirmed at source.

---

## A1 · Does not reproduce — correction #10

You asked me to look before dismissing. I did, at source level rather than by screenshot.

**I fetched the live recommendations endpoint on the published theme** — the exact HTML the
desktop browser receives:

```
GET /recommendations/products?section_id=related-products&product_id=10149263900994&limit=4
```

Every `.card__heading` in the response contains a **complete title**:

```
"Midi Velvet Clutch - Royal Blue"
"Midi Velvet Clutch - Black Noir with Mixed Rose Garden"
"Midi Velvet Clutch - Black Noir with Scarlet Bouquet"
"Grande Velvet Clutch - Antique Pink"
```

The published CSS bundles contain **zero** truncation machinery:

| Published asset | `line-clamp` | `box-orient` | `text-overflow` |
|---|---|---|---|
| `lena-custom.css` | 0 | 0 | 0 |
| `component-card.css` | 0 | 0 | 0 |
| `base.css` | 0 | 0 | 1 — on `.share-button__fallback .field__input` |

The only published `.card__heading` rules are margin, font-size and focus-ring.

**On your two caveats:**

- **Colour/option values** — ruled out. The four products carry `color-purple`, `color-black`,
  `color-pink`, `color-red`. Those don't map to *Plum / Pink / Burgundy / Blue*. The `.lena-card-cat`
  eyebrow is `"Velvet Purses"` on all four cards, confirmed in the same response.
- **The blank card** — I think your instinct is right, and it generalises. The desktop strings are
  exactly the trailing token of each title. A full-page screenshot under heavy compression, read by
  a model, plausibly yields the last legible fragment per card and nothing for the fourth.

**One point to you:** my non-determinism rebuttal was too strong. Your two fetches did return the
same set, and Shopify caches recommendations per product, so that's expected rather than a
coincidence. It happens that my fetch returned a *different* set again — so the endpoint does vary
over longer intervals — but that was not a sound basis for dismissing your observation, and it
wasn't the argument that settled this. The source evidence was.

**Close as correction #10.** No fix. If it ever reappears, it is a rendering-engine or extension
artefact, not theme code.

---

## Correction against me · T0-14's secondary CTA is not broken

**I was wrong, and you elevated my error to the top of Tier 0. Please demote it.**

I reported that `href="#newsletter"` targets a fragment Shopify never emits. I reasoned from how
Shopify wraps sections — `id="shopify-section-sections--…__newsletter"` — and concluded nothing
matches.

I never opened the file. `sections/newsletter.liquid:18` emits its own inner element:

```liquid
<div id="newsletter" class="newsletter center ...">
```

Added in commit `104f17c`, 3 Jun 2026. **The live homepage emits `id="newsletter"` exactly once,
and the anchor resolves and scrolls.**

This is precisely the failure mode I proposed as the sharper method rule — inferring a cause from
platform behaviour without checking the source — and I committed it in the same document where I
proposed the rule. Worth noting for §2b: the rule catches developers too.

**The full-theme anchor sweep you asked for** is clean. Nine fragment `href`s exist; eight target
form fields, `#MainContent`, or tab panels the theme emits. `#newsletter` is the ninth and it
resolves. **No broken fragment anchors anywhere on the site.**

### T0-14's primary CTA — real, but milder than I stated

`Shop This Week's Drop` → `/collections/this-weeks-drop`, which holds **0 products**. That part
holds.

But it does not land on a blank page. It renders the designed `lena-drop-coming-soon` empty state,
with a working `Shop Available Pieces` CTA onward. So it is a **dead end with an exit**, not a dead
button.

**Revised recommendation:** T0-14 is one real defect, not two, and it is a routing problem rather
than breakage. I'd no longer argue it outranks A3 — that argument rested on "two dead buttons," and
one of the two was mine. Your original instinct to weight the mobile hero highly looks better than
my challenge to it. The fix is still worth doing: a primary CTA should not point at a collection
that can be empty.

---

## A6 · Colour filter — my diagnosis was wrong, the bug is real and different

**Correction:** I reported that category tags leak into the colour facet and are suppressed by the
whitelist. **That is not happening.** The live collection page renders four independent facet
groups — Availability, Price, **Product Categories**, Color — and categories have their own group.
Nothing category-shaped is reaching the colour facet.

**The real defect, confirmed live.** The store has **15** `color-*` tags. The live Color facet
renders **14**:

```
color-beige   color-black   color-blue    color-brown   color-clear ← MISSING
color-gray    color-green   color-multi   color-orange  color-pink
color-purple  color-red     color-silver  color-white   color-yellow
```

`clear` is not on the theme's 55-name whitelist (`facets.liquid:215` / `:613`), so **`color-clear`
is silently deleted from the filter.** Products tagged with it are unreachable by colour, and
nothing in the UI indicates a value is missing.

That is the actual shape of the problem — not suppression of bad data, but **silent deletion of
good data**. Any future colour outside the hardcoded list vanishes the same way, with no error.

**Scope for Hai's cleanup:**

| Finding | Severity | Owner |
|---|---|---|
| `color-clear` silently dropped from the filter | Live bug, customer-visible | Theme — one-line whitelist fix, or remove the whitelist |
| Whitelist duplicated at `:215` and `:613` | Code smell — the two can drift | Theme |
| `grey`/`gray` both whitelisted | **Latent only** — the store has `color-gray` and no `color-grey`, so there is no live duplicate. My v1 claim overstated this. | Theme |
| Bare `Black` tag exists alongside `color-black` | Data inconsistency, 1 tag | Part B |

**Recommendation:** the whitelist should invert — display any `color-*` value, and strip the prefix
for the label. A whitelist that fails silently is worse than no whitelist. Still report-only per
your instruction; not Tier 0.

---

## The 77-product gap · resolved, nothing is leaking

`available-now` reports 235 in Admin and renders 158 on the storefront. The gap is entirely
non-storefront product statuses.

```
inventory > 0, not POS, status:active      → 158   ← exactly the storefront count
inventory > 0, not POS, status:archived    →  18
inventory > 0, not POS, status:draft       →   4
                        ...plus UNLISTED products
active AND unpublished                     →   0
```

**158 is correct.** Admin's `productsCount` counts archived, draft and unlisted products that match
the rule; the storefront renders only active-and-published ones. Every active product matching the
rule is published — nothing is hidden or mis-scoped.

This also closes the T0-04 theory: the live Availability facet reports **`Out of stock (0)`**, which
is correct for an `inventory > 0` collection. If a sold-out item was observed in Available Now, the
likeliest cause is Shopify's asynchronous smart-collection recalculation lagging a sale, or a
multi-variant product with one variant still in stock. Neither is theme code, and neither is the
collection rule.

---

## New · T0-16 · The filter is a fourth category taxonomy

Your T0-15 asks me to flag internal links pointing outside the canonical eight. This is the same
problem one layer down, and it is customer-visible today.

The live **Product Categories** facet renders these seven names:

| Filter facet | Canonical eight | Match? |
|---|---|---|
| Crochet Figures (29) | Crochet Dolls | ✗ |
| Compact Mirrors (56) | Artisan / Motif Compact Mirrors | ✗ — unsplit |
| Hats (22) | Ribbon-Embroidery Hats | ✗ |
| Velvet Purses (11) | Velvet Purses | ✓ |
| Rattan Bags (18) | Rattan Purses | ✗ |
| Beaded Purses (13) | Glass Bead Woven Handbags | ✗ |
| Phone Wallet (9) | Phone Travel Wallet | ✗ |

**One of seven matches.** A customer who filters by *Crochet Figures* and then uses a nav labelled
*Crochet Dolls* is being shown two names for one family, on the same page. The counts do total 158,
so coverage is complete — this is purely naming.

The facet names come from Search & Discovery configuration, so it is **Part B**, not theme code. But
it should be settled before the `Shop ▾` menu ships, or the restructure introduces the very
inconsistency it exists to remove.

### T0-15 — the hero tiles

Confirmed as you describe. Tile 2 → `/collections/compact-mirrors` (145-product parent), tile 4 →
`/collections/signature-purses` (49). Both resolve today. The rest of the theme's internal links
are clean — the only other hardcoded collection URLs are `/collections/all` (three places, already
scheduled for retirement) and `/collections/new-arrivals` in `main-404.liquid:167`, which your
`new-arrivals` collection fixes.

---

## `Shop ▾` menu build spec

Content → Menus → `main-menu-gallery`. Handles verified live.

```
Shop                        →  /collections/available-now
  All Available Pieces      →  /collections/available-now
  Crochet Dolls             →  /collections/crochet-dolls
  Artisan Compact Mirrors   →  /collections/artisan-compact-mirrors
  Motif Compact Mirrors     →  /collections/motif-compact-mirrors
  Ribbon-Embroidery Hats    →  /collections/ribbon-embroidery-hats
  Velvet Purses             →  /collections/velvet-purses
  Rattan Purses             →  /collections/rattan-purses
  Glass Bead Woven Handbags →  /collections/glass-bead-woven-handbags
  Phone Travel Wallet       →  /collections/phone-travel-wallet
New Arrivals                →  /collections/new-arrivals    (pending Hai)
Our Story                   →  existing
Find Us                     →  existing
Contact                     →  existing
```

`Phone Travel Wallet` left singular as supplied. No theme change required — the stock dropdown and
drawer already render three levels.

---

## Open question on the A4 vocabulary spec

Your empty-state rule needs a data source I can't derive:

> Empty *and* last drop >30 days old — **hide the section entirely.**

When the collection is empty there are no products to date, so "last drop" has no value to read in
Liquid. `new-arrivals` will be tag-driven (`Tag is equal to new`), so an empty collection carries no
timestamp at all.

Two workable options:

1. **A section setting** — `last_drop_date`, updated by Hai at each tag swap. Simple, but it is one
   more thing to remember, and a stale value silently hides the section.
2. **Derive from the newest published product store-wide** — no manual step, and it degrades safely
   (if nothing has been published in 30 days, that *is* the condition you want to detect).

I'd recommend option 2 unless you specifically want it merchant-controlled. Confirm which, and I'll
build it.

The populated variant — **"14 new pieces this week"** — I'd also flag: with a supply-driven model,
"this week" is a cadence claim of the kind A4 exists to remove. Suggest **"14 new pieces"**, linked.

---

## Running tally

- **Auditor findings corrected:** 10 (A1 closes as #10)
- **Developer findings corrected:** 2 — T0-14's secondary CTA, and the A6 diagnosis

---

## What I need to start

1. **Hai** — create `new-arrivals` (`Tag is equal to new`)
2. **Hai** — T0-15 decision: repoint hero tiles, or keep both collections as redirect targets
3. **Auditor** — confirm the A4 empty-state data source (option 1 or 2), and the "this week" wording
4. **Auditor** — accept or contest the T0-14 demotion

Everything else is unblocked: A2 stepper, A3 2×2 stack, all of A4b/A4c, and the code half of A5.
Nothing committed, nothing published, still no branch created.
