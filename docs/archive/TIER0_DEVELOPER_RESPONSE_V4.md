> **ARCHIVED 2026-09-15 — wholly obsolete.**
>
> This entire document analyses a New Arrivals mechanism that was never built. Its subject —
> a 30-day `published_at` window, the `created_at`-vs-`published_at` sort mismatch, and the
> "configurable window, default 30" owner decision — was replaced by **tag-driven visibility with no
> date logic at all**: the app owns a single `new` tag, a smart collection matches it, and the theme
> renders the section only while `all_products_count > 0`.
>
> **Do not implement anything in this file.** There is no `new_arrivals_window_days` setting, no
> `published_at` read, and no staleness rule in the theme.
>
> Two things in it are still true and have been lifted into `OPEN_ITEMS.md`: the **theme rollback
> record** (`192252215618` is MAIN, two unpublished themes carry near-identical names) and the
> **Shop Pay marketing-consent** item.

---

# Tier 0 v4 — New Arrivals mechanism: verification results

**Developer response to `TIER0_CLAUDE_CODE_PROMPT-v4.md`**

v4 answered all three of my open questions — tile targets, the empty-state data source, and the CTA
contradiction all dissolve under the new mechanism. Thank you.

You asked me to verify two assumptions before building and to stop and report if the first failed.
**Assumption 1 passes. Assumption 2 is fine. But a third condition nobody checked fails hard, and it
would have shipped the feature invisible.**

**Owner decisions have since arrived** — recorded at the foot of this document. Build is underway
on everything except the New Arrivals template, which is held pending one open question.

---

## Headline · the 30-day window renders zero products today

| Window (active products) | Count |
|---|---|
| Published in last **30 days** | **0** |
| Published in last **60 days** | **0** |
| Published in last 90 days | 30 |
| Published in last 180 days | 261 |
| All active | 296 |

**The newest published product on the store is 2026-05-27 — 86 days ago.**

Under the v4 spec, New Arrivals would therefore:

1. Render an empty product list, and
2. Hit the rule *"empty and newest published product >30 days old → hide the section entirely"*

**The feature ships, works exactly as designed, and is invisible on day one.** It stays invisible
until the next publish. That is arguably correct behaviour — but it means the homepage loses a
section, the nav gains an item pointing at an empty page, and nobody sees the work.

This isn't an argument against the mechanism. It's that **30 days is calibrated to a publishing
rhythm that isn't currently happening.**

**Resolved:** the owner has made the window a **configurable setting defaulting to 30**, which is a
better answer than the fixed 90 I proposed — the default stays honest, and anyone seeing the section
empty can widen it in the theme editor without a code change. The measurement is why the setting
earns its place.

---

## Assumption 1 · `published_at` semantics — **PASSES**

> Does `published_at` reflect the publish date for a backlog product, or its creation date?

It reflects the **publish** moment. Proof — the one product in the recent set where the two diverge:

```
Motif Compact Mirror - Totoro Peony Lily
  createdAt    2026-05-21T04:01:45Z
  publishedAt  2026-05-27T20:05:46Z   ← six days later
```

Every other product in the twelve most-recently-published carries `createdAt == publishedAt`, i.e.
created and published in one action. So the field behaves as your design requires.

**One behaviour worth knowing:** `published_at` resets if a product is unpublished and republished.
An old piece pulled and relisted would re-enter New Arrivals. I'd argue that's desirable — relisting
*is* the product going live again — but it should be a deliberate choice, not a surprise.

---

## Assumption 2 · Liquid performance — **fine**

No concern. Even the 90-day window is 30 products, and Shopify's per-page ceiling is 50. A single
page covers any realistic drop.

---

## The condition that fails · sort field ≠ filter field

This is the one that breaks the backlog workflow the design is built around.

Smart collections **cannot filter by date** — Shopify's rule set has no `created_at` or
`published_at` condition. So the 30-day cut must happen in the template, iterating a collection of
~235 products. That only works if the newest products sort to the front.

Shopify's collection sort offers `created-ascending` / `created-descending` — **there is no
published-date sort.** I tested whether "Date, new to old" secretly sorts by publish date. It does
not:

```
GET /collections/available-now?sort_by=created-descending
  1. Crochet Doll - Blush Tutu Ballerina      created 2026-05-27T15:07:17
  2. Crochet Doll - Rose Bun Ballerina        created 2026-05-27T15:07:09
  3. Crochet Doll - Frosted Snowflake Princess
  ...
```

The Totoro mirror — **the most recently published product on the store** — does not appear in the
first page positions, because it was *created* on 21 May. Sorting is by `created_at`, confirmed
empirically rather than inferred.

**Why this matters:** v4's rationale is *"products sit unpublished in a backlog, and `published_at`
is set the moment they go live."* That is precisely the case where the two fields diverge — and
where a `created_at` sort buries a just-published item below items created more recently. A backlog
piece published today would either appear at the bottom of New Arrivals, or be missed entirely by a
loop that stops at the cutoff.

**The mechanism is sound; the ordering underneath it isn't.**

### Options

| # | Approach | Trade-off |
|---|---|---|
| **1** | **Sort and filter both on `created_at`** | Ordering is always correct and no early-break bug. Loses the backlog semantics — a piece created in March and published today never reads as new. **Currently near-equivalent**, since all but one recent product has `created == published`. |
| **2** | Sort by `created_at`, filter by `published_at`, **never break early** — scan the full first page | Catches backlog items *if* they're within the 50 most-recently-created. Silently wrong beyond that. I don't recommend shipping a rule that's right most of the time with no error surface — that's the A6 lesson. |
| **3** | Set the collection sort to **manual** and have Hai order it | Fully correct, fully manual. This is the recurring chore the `new` tag was scrapped to avoid. |

**My recommendation: option 1.** Filter and sort on the same field so the two can never disagree.
It is correct by construction rather than correct-if-nobody-uses-the-backlog. If the backlog
workflow becomes real and you want publish-date semantics, that's a Storefront API or metafield job,
and it's a bigger change than a Tier 0 template.

---

## Rollback record — captured, and a naming hazard

You asked for the published theme recorded before first publish.

```
PUBLISHED (role: MAIN)
  lena-shopify-theme-craft/website-redesign
  gid://shopify/OnlineStoreTheme/192252215618
  created 2026-08-19T16:00:17Z · updated 2026-08-19T18:12:15Z
```

This also closes Step 0 a second way, from the Admin side: the published theme *is* the
`website-redesign` branch.

**Hazard for rollback:** three themes carry near-identical names, two updated the same day.

```
192252215618  lena-shopify-theme-craft/website-redesign          MAIN
189601186114  legacy lena-shopify-theme-craft/website-redesign   unpublished, updated 2026-08-19T18:12:15Z
189535355202  lena-handicrafts/website-redesign                  unpublished, updated 2026-08-19T15:52:51Z
```

At 10pm under pressure, "roll back to website-redesign" is ambiguous between three themes. **Suggest
renaming the two unpublished ones before we publish anything** — this is exactly the guessing game
your note was written to prevent.

---

## Smaller items

**Mirrors — resolved, and I was over-thinking it.** I had flagged a contradiction between v4's
*merge* and the *keep the split* answer I was given directly. The owner's clarification dissolves it:
these are just collections, several exist in parallel, and **menu and hero assignment will be made
directly later** rather than derived by me. Tile 2 already points at `/collections/compact-mirrors`,
so there is no code dependency here at all. Concern withdrawn — see decision (3) below.

**Shop Pay marketing consent.** Checkout settings aren't exposed in the Admin API — there's no query
for the marketing sign-up preference. This needs a human to read *Settings → Checkout → marketing
sign-up*. Reporting rather than guessing.

**A4d return policy.** Understood and in scope: FAQ answer, PDP surface, and the refund policy page.
I'll check the policy page against the 30-day wording and flag any conflict rather than silently
overwriting a legal page.

**Breadcrumbs and parent collections.** Noted — tile 4 keeps `signature-purses`, which isn't in the
menu. Handled: breadcrumbs use `collection` whenever the visitor arrived through one, so a parent
collection renders correctly. The menu list is only the fallback for direct PDP hits.

---

## Owner decisions received

| # | Question | Decision |
|---|---|---|
| 1 | New Arrivals window — 30 or 90 days? | **Configurable setting, default 30.** Not a hardcoded constant either way. |
| 2 | Sort field — both `created_at`? | **Open — owner is taking this back to the auditor.** |
| 3 | Mirrors — merge confirmed? | **Use `/collections/compact-mirrors` for now.** |

### On (1) — better answer than either of mine

Making the window a setting is the right call and I've adopted it. It also defuses the
zero-products finding: whoever sees the section empty can widen it in the theme editor without a
code change, and the default stays honest at 30. The measurement still stands as the reason the
setting matters — **at 30 days the section renders nothing today.**

### On (2) — this is the one blocker

**I am not building the New Arrivals template until this is settled.** The sort/filter mismatch is
not cosmetic: with `created_at` ordering and `published_at` filtering, a backlog item published
today sorts below items created more recently and can fall outside the rendered page entirely. Any
implementation I ship before the decision would have to be rewritten.

Everything else proceeds.

### On (3) — scope correction, accepted

The owner's position: these are just collections. There are separate collections for all mirrors,
artisan mirrors and motif mirrors, and the **menu and hero assignments will be made directly later**
rather than being derived by me from a taxonomy.

That is the right reading and it shrinks the work. The hero tile already points at
`/collections/compact-mirrors`, so **tile 2 needs no change at all**, and the merge-vs-split
question stops being a code dependency. I withdraw the concern I raised about the contradicted
decision — it was a decision about *menu content*, which was never mine to resolve.

---

## Build status

**Building now:** A2 quantity stepper · A3 hero 2×2 stack + primary CTA repoint to
`available-now` · A4b cadence claims · A4c marquee · A4d return policy · A5 code half
(breadcrumbs, *Shop by Category* rename, `/collections/all` retirement, remaining "drop" labels).
A6 report already delivered in the v2 response.

**Held:** the New Arrivals 30-day template, pending (2). The window will land as a section setting
defaulting to 30 when it does.

**Not mine:** `new-arrivals` collection creation, facet alignment, `Phone Travel Wallets`
pluralisation, currency format — all reassigned to the owner in v4. Menu and hero assignment now
also owner-side per (3).

**Before first publish:** the three near-identically-named themes should be renamed — see the
rollback record above. `lena-shopify-theme-craft/website-redesign` is `MAIN`
(`192252215618`), and two unpublished themes carry confusingly similar names.

**Tally: auditor corrections 12, developer corrections 2.** I'd log the zero-products measurement
and the sort mismatch as design findings against the v4 spec rather than corrections — neither was
a claim about the site, both are things nobody had measured yet.
