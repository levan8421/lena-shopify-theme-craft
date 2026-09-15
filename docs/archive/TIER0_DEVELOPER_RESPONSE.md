> **ARCHIVED 2026-09-15 — superseded by `TIER0_DEVELOPER_RESPONSE_V2.md`.**
>
> Three findings in this document were retracted by their own author in V2. Do not act on them:
>
> - **The `#newsletter` secondary CTA is NOT broken.** `sections/newsletter.liquid:18` emits its own
>   `<div id="newsletter">`, added in commit `104f17c`. The anchor resolves and scrolls.
> - **The A6 colour-filter diagnosis was wrong.** Category tags are not leaking into the colour
>   facet; categories have their own facet group. The real bug is the opposite — `color-clear` is
>   *silently deleted* from the facet by the whitelist. See `OPEN_ITEMS.md`.
> - **The `grey`/`gray` duplicate is latent, not live.** The store has `color-gray` and no
>   `color-grey`, so no duplicate renders today.
>
> Kept as history because the method argument and the withdrawn "canonical eight" concern are still
> worth reading. Everything drop-cadence related in it is also retired — see `DEVLOG.md`.

---

# Tier 0 Findings, Retested

**Developer response to the Tier 0 brief and `WEBSITE_AUDIT.md` rev 6**

- **Store:** Lena Handicrafts — Shopify Craft theme 15.4.1
- **Branch inspected:** `website-redesign`
- **Scope:** Part A only. Part B not attempted. Part C not touched.
- **Status:** Nothing published. No code committed. No branch created.

Every Part A finding was retested against theme source and the live Shopify Admin API
before any code was written.

---

## Position

The brief's central instruction — reproduce before fixing — was the right call, and it paid
for itself. Retesting changed the disposition of **four of the five Part A items**.

One thing to flag up front, because it shapes everything below. The audit's stated failure
mode was "inspecting HTML without rendering it in a browser." I think that diagnosis is half
right. The costlier pattern is the reverse: **reading a rendered page and inferring a cause
without checking the source.** A2 and A3 both failed that way, and rendering them again would
have confirmed the symptom while still producing the wrong fix.

None of this is a complaint about rigour. The audit found real problems and its business
reasoning on cadence is sound. I'd rather we disagree explicitly now than have me quietly
"fix" things that aren't broken.

---

## Disposition at a glance

| Ref | Finding | Position |
|---|---|---|
| A1 · T0-08 | Quantity stepper on qty-1 items | **Upheld** — reproduces, correctly diagnosed |
| A2 · T0-09 | Truncated related-product titles | **Disputed** — not producible from source |
| A3 · T0-11 | Hero mosaic on mobile | **Part disputed** — symptom real, cause wrong, scrim claim false |
| A4a · T0-12 | Remove the countdown | **Already done** — disabled everywhere before this brief |
| A4b/c · T0-01 | Cadence & 1-of-1 claims | **Upheld** — but two quoted strings don't match the site |
| A5 · T0-13 | Navigation restructure | **Part blocked** — menu is admin; one collection missing |
| A5 (drawer) | Mobile `Shop` must not link out | **Already satisfied** — stock drawer already does this |
| — | Both hero CTAs are broken | **Not in audit** — highest-impact defect found |
| — | Colour filter suppresses bad data | **Not in audit** — contradicts a Part C protection |
| — | Canonical eight orphan products | **Withdrawn** — I raised it; it checked out clean |

---

## Where I push back

### A2 · The title truncation cannot exist in this codebase

**Audit ref T0-09**

> The same module renders full titles on mobile … So this is purely a rendering rule at the
> desktop breakpoint.

That inference doesn't hold. `/recommendations/products` is **non-deterministic** — it returns
a different product set per request. The desktop and mobile observations were two different
fetches showing two different sets of products. There was never a controlled comparison, so
"same module, different output" isn't evidence of a breakpoint rule.

**What the source actually contains:**

- `card-product.liquid:188` renders `{{ card_product.title | escape }}` — **no `truncate`,
  `truncatewords` or `split`** anywhere in the card path
- **Zero** `line-clamp` or `-webkit-box-orient` in all of `assets/`
- The only `text-overflow: ellipsis` is `base.css:1534`, on a share-button input
- No JS touches `.card__heading` or `.full-unstyled-link`
- The only desktop `min-width` queries reaching the title set **font-size and padding**.
  Neither can hide text.

I also tested a data-side explanation and **disproved my own hypothesis**, which I'd rather
report than bury. I suspected the strings were the category eyebrow (`card_product.type`),
which would neatly explain both the duplicate string and the blank card. It fails: every
velvet clutch in the catalogue carries the identical `productType` of `"Velvet Purses"`, so
that field would print one repeated string, not `Plum` / `Pink` / `Burgundy`. **A2 is not
product-data work either.**

**Two possibilities remain, and only a rendered preview separates them.** Either the audit
mis-transcribed a screenshot — its stated failure mode for four other findings — or **the
published theme is not this branch**. The second would be far more serious than the
truncation, and would invalidate every "already satisfied" conclusion in this document.

I've made A2 a **verify-first gate**: check it at 1440px before implementing anything else,
and stop if it reproduces.

---

### A3 · The symptom is real; both stated causes are wrong

**Audit ref T0-11**

The audit describes tiles that "compress into a cramped horizontal strip" with "the fourth
tile cut off." That describes a broken grid. What's actually at `≤640px` is a **deliberate
snap-scroll carousel** — `display: flex`, tiles at `flex: 0 0 72%`, scrollbar hidden,
`scroll-snap-type: x mandatory`.

The observation is fair: only about 1.4 tiles are visible and there's no affordance signalling
that it scrolls. But the difference matters, because "fix the broken grid" and "this carousel
doesn't announce itself" lead to different work.

**The second claim is simply false.**

> Audit: "tile labels are white text directly on photography with no scrim"

Source — `lena-custom.css:415-428`, `.img-tag`:

```
background:        rgba(navy, 0.75)
backdrop-filter:   blur(8px)
color:             amber
```

There is already a solid label bar with a blur scrim. **Two of A3's three sub-claims don't
survive contact with the source**, yet it carried a 45-minute estimate and a confident fix
order.

I'm still implementing the 2×2 stack, because the underlying discoverability problem is real
and the preferred option is the right one — but not the scrim work.

---

### A4 · Quoted strings that aren't on the site, and work already finished

**Audit refs T0-01, T0-12**

- **"New drops every other Friday"** — the actual string is "New drops every *Friday*."
  `every other` has **zero hits** anywhere in the theme.
- **A4a is already complete.** `show_countdown` is `false` in schema and in all three
  templates, and both the markup and the script are gated behind it. The countdown has not
  rendered for some time.

A4 was budgeted at 1.5 hours partly for work that was already done. The *business* reasoning
is sound and I'm implementing all of A4b and A4c — I'd just flag that quoting strings verbatim
from the live site, rather than approximately, would have caught both.

---

## What the audit missed

Found while verifying the above. The first I'd rank above A2 and A3 on impact.

### Both hero CTAs are broken

A5 states that "one hero CTA currently points there [`/collections/all`]." Neither does.
What's actually true is worse, and the audit found neither half:

- **Primary CTA** → `this-weeks-drop`, which the Admin API reports holds **0 products**. The
  main button on the first screen lands on an empty page.
- **Secondary CTA** → `href="#newsletter"`. Shopify renders that section as
  `id="shopify-section-sections--…__newsletter"`, so the fragment matches nothing and **the
  button does nothing at all**.

For a brief that opens by insisting the primary visitor is on a phone and that first-screen
discovery is what matters, two dead buttons in the hero should outrank a related-products
cosmetic issue. The theme already solves the anchor problem elsewhere —
`collection-list.liquid:27` hardcodes `id="the-gallery"` for exactly this reason.

### The colour filter works by hiding bad data — and it's in Part C

Part C protects "Collection page filters — availability, price, category, colour. All
working." They appear to work because `facets.liquid` holds a hardcoded whitelist of ~55
colour names and **silently discards any Colour value not on it**. Category tags are being
merged into the colour facet and suppressed rather than corrected.

- Whitelist duplicated verbatim at `facets.liquid:215` (desktop) and `:613` (drawer) — the two
  can drift
- Both `grey` and `gray` pass, producing **two separate entries for one colour**

I have not touched this — Part C is explicit and I'm respecting it. But I'd ask that the
protection be reconsidered: a filter that looks correct because a whitelist is hiding the mess
is a data problem wearing a working UI, and it's likely a **Part B tagging issue** rather than
theme code.

### The site contradicted itself on the drop time

The announcement bar advertised **"Next drop: Friday 8 PM ET"** while the countdown script
targeted **Friday 6 AM EST**. A4c flags the marquee for being self-contradictory; this is a
sharper instance of the same problem and went unnoticed. Root cause is that the countdown is
copy-pasted into two section files with no shared asset, so the two drifted.

### The 404 page links to a collection that doesn't exist

`main-404.liquid:167` hardcodes `/collections/new-arrivals`. There is no such collection — so
the branded 404 page contains a link that 404s. The theme also ships a live
`collection.new-arrivals.json` template for it.

### T0-04's stated cause looks wrong

The audit assumes "Available Now" is "likely a manual or tag-based collection that should be
automated." It is **already a smart collection** with the rule
`VARIANT_INVENTORY > 0 AND tag ≠ POS`. If a sold-out item still appears there, the cause is
something else — inventory sync or a stale index — and the proposed fix wouldn't have
addressed it. Flagging so nobody spends time re-automating a rule that already exists.

---

## A concern I raised, then withdrew

Recorded so it isn't re-opened later, and because I'd want the same in return.

### The canonical eight do not orphan any live product

My concern was that A5 frames the taxonomy problem as *naming* when it might really be
*coverage* — that adopting the eight as the only nav path could strand products sitting in the
broader parent collections. The arithmetic looked bad: `compact-mirrors` holds 145 products
while `artisan-` (40) and `motif-` (102) sum to 142.

Checked against the Admin API:

- `tag:"Compact Mirrors"` minus `artisan`/`motif`/`POS` → **3 products, every one ARCHIVED or
  DRAFT**
- `tag:Purse` minus `Velvet`/`Rattan Bag`/`glass bead`/`POS`, active only → **zero**

The gap is entirely non-storefront items. **Every live product is reachable through the
canonical eight.** Concern withdrawn — the eight are safe to ship as the complete nav taxonomy.

---

## Blocked — needs auditor or admin

### There is no `new-arrivals` collection

A5 requires `This Week's Drop → New Arrivals`, "pointing at the new-arrivals collection." That
collection does not exist on the store. Creating it is admin work, so per the brief I'm
stopping and reporting rather than working around it.

The other eight destinations all check out: **every canonical category exists with exactly the
supplied title**, and `available-now` (235 products) is a real home for *All Available Pieces*,
which lets me retire `/collections/all` as asked.

| Canonical title | Handle | Products |
|---|---|---|
| Crochet Dolls | `crochet-dolls` | 30 |
| Artisan Compact Mirrors | `artisan-compact-mirrors` | 40 |
| Motif Compact Mirrors | `motif-compact-mirrors` | 102 |
| Ribbon-Embroidery Hats | `ribbon-embroidery-hats` | 58 |
| Velvet Purses | `velvet-purses` | 23 |
| Rattan Purses | `rattan-purses` | 26 |
| Glass Bead Woven Handbags | `glass-bead-woven-handbags` | 13 |
| Phone Travel Wallet | `phone-travel-wallet` | 11 |

### The `Shop ▾` menu cannot be built in code

The theme stores only the menu *handle* (`main-menu-gallery`). Every nav label and URL lives in
the Shopify Admin navigation object and appears nowhere in the repository. No theme change is
needed or possible — the desktop dropdown and mobile drawer **already support three levels of
nested links today**. I'm delivering an exact menu build spec instead.

### The mobile drawer requirement is already met

A5 asks that `Shop` "expand in place … must not link out to a separate page." The stock drawer
already keeps the visitor inside the drawer: tapping a parent slides a submenu panel over it
with a back button. It never navigates away, and it's the same three taps as an accordion.

I'm **not** rebuilding it. Converting the slide-panel to a literal accordion would mean
restructuring a stock snippet plus its CSS and JS, risking every mobile menu, for no measurable
gain. Say so if you disagree and want the literal reading.

---

## What I'd like back

1. **A2 — how was it observed?** Screenshot, live browser, or rendered HTML dump? And was it
   the published theme or the `website-redesign` branch? If those differ, that's the real
   finding and I need to know before building on this branch.
2. **Part C, the colour filter.** I'd like the protection lifted enough to report on it
   properly, or confirmation that the underlying tag data is already tracked as Part B work.
3. **Priority.** I'd put the two dead hero CTAs above A2 and A3. Confirm, or tell me why the
   related-products module outranks them.
4. **The `new-arrivals` collection.** Who creates it, and on what rule? Until it exists, "New
   Arrivals" cannot enter the nav and the 404 page keeps its broken link.
5. **Interim vocabulary.** A4 defers the drop-section heading to "A5 vocabulary," but A5 only
   supplies *category* names. I've used "New Pieces Coming Soon" as a cadence-free placeholder
   — tell me if you want something else.

---

## Ready to implement, pending agreement

Everything not disputed above is planned and ready: A1, A3's 2×2 stack, all of A4b and A4c, and
the code-side half of A5 — breadcrumbs, the *Shop by Category* rename, `/collections/all`
retirement, and every remaining "drop" label.

Nothing is committed and nothing is published. I'd rather settle the five questions above than
have us discover the disagreement in review.
