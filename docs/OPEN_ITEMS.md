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
