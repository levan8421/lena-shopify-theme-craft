# Lena Handicrafts — New Website Preview: QA & UX Checklist

**Reviewed:** `lqz1ziucofj68ru2-75973198146.shopifypreview.com`
**Theme:** `lena-shopify-theme-craft/staging` (marked **Draft** — this is a pre-launch preview, not the live site)
**Reviewed on:** Sep 16, 2026 · Desktop (796px) and Mobile (375px, iPhone-width) viewports
**Method:** Manual click-through of every nav item, every collection, sample products across all 8 categories, cart, search, 404, and all footer/policy pages.

This is a checklist. Check items off as you fix them. Items are grouped by severity so you know what to fix before you point customers at this, versus what can wait.

---

## How to read this

- ❌ **Broken / Wrong** — a customer will hit this and it will cost you a sale or cause a support email.
- ⚠️ **Confusing / Inconsistent** — nothing crashes, but it makes you look less polished or contradicts itself.
- ✅ **Working well** — confirmed working, called out so you know NOT to touch it.

---

## 1. Critical — fix before this goes live

- [ ] ❌ **Return window contradicts itself in three places.** This is the single biggest issue I found.
  - Every product page says: *"Returns accepted within 30 days of delivery."*
  - The homepage FAQ says: *"Returns are accepted within 30 days of delivery on all items."*
  - But your actual **Refund Policy page** (`/policies/refund-policy`) says: *"Purses: within 15 days of delivery. Accessories: within 7 days of delivery."*
  - Nothing on the Refund Policy page covers mirrors, dolls, or hats at all.
  - **Why this matters:** if a customer reads the FAQ (30 days) and you enforce the policy page (15 or 7 days), that's a chargeback or a bad review waiting to happen. Pick one number, apply it everywhere, or clearly explain why purses/accessories differ and make sure product-page and FAQ copy matches.

- [ ] ❌ **"Our Collections" menu link goes nowhere.** It's in your main nav (desktop and mobile) and points to `/#our-collections`, but no section on the homepage has that ID. Clicking it just closes the menu and leaves you at the top of the homepage. This is one of five items in your primary navigation, and it silently does nothing — confirmed on both desktop and mobile.

- [ ] ❌ **Mobile: text is cut off on both edges of the trust-badge strip.** The row that reads "100% HANDMADE · Crafted in Vietnam · EVERY DESIGN TELLS A STORY · Handcrafted in Limited Quantities · WOMEN-OWNED · Supporting Artisan Families" overflows the screen width on mobile. On a phone you see fragments like "...DMADE · Crafted in Vietnam" and "EVERY DESIGN T..." with the rest sliced off — no visible way to read the full line. This is right below your hero, so it's one of the first things a mobile visitor (most of your traffic, almost certainly) sees.

- [ ] ❌ **Mobile: footer is missing 3 of 4 legal links.** On mobile, only "Refund policy" is visible in the footer. Privacy Policy, Terms of Service, and Shipping Policy links exist in the page code but are cut off / not visible or reachable on a phone screen. This looks like the same underlying bug as the trust-badge strip above (a row of text/links that doesn't wrap on narrow screens) — worth asking your theme developer to fix as one issue, since it's likely one shared component.

---

## 2. High priority — content is out of date or over-promises

- [ ] ⚠️ **"Our Story" page promises headbands you don't sell online.** The story text lists "ribbon-embroidery hats, headbands..." as products you make — but headbands are deliberately kept off the website (per your own decision, since they're hard to photograph well). A new visitor reads this, gets excited about headbands, then can't find a single one anywhere on the site. Either pull "headbands" out of that sentence, or get a few headband listings live.

- [ ] ⚠️ **Refund Policy page references products you're phasing out.** It defines "Accessories" as "hair clips, headbands, bookmarks, keychains, etc." — hair clips, bookmarks, and keychains are on your phase-out list (not being reordered), and headbands aren't sold online at all. This paragraph reads like it hasn't been updated since an earlier catalog. Rewrite it around what you actually sell today: mirrors, crochet dolls, hats, purses, phone wallets.

- [ ] ⚠️ **"One-of-a-kind" language on items that aren't.** I checked the Phone Travel Wallet - Seafoam, which shows "2 IN STOCK" — but its description still says "One-of-a-kind embroidery... yours is truly unique" and "designed to last a lifetime" (implying no repeats). This is the exact issue flagged in your own planning notes: the blanket "1 of 1" / "only piece in existence" messaging doesn't hold for restocked items, and it's live on the site as-is. Any product with quantity > 1 needs softened copy — something like "hand-embroidered, small-batch" instead of "the only one that will ever exist."

---

## 3. Medium priority — polish and navigation clarity

- [ ] ⚠️ **Small formatting bug on every product page's return blurb.** The text renders as: "Returns accepted within" / **"30 days of delivery"** (bold) / then a new line starting with an orphaned period: *". Unused and in original condition; buyer pays return shipping."* That leading period is a template/snippet bug — confirmed on three different products (velvet clutch, crochet doll, phone wallet), so it's systemic, not a one-off.

- [ ] ⚠️ **A full collection index exists but isn't linked anywhere.** Going to `/collections` (which I only found via the 404 page's "All Collections" link) shows sub-collections that never appear in your nav or homepage: "Artisan," "New," "Bookcase Rattan Purses," "Circle Rattan Purses," and separate "Velvet Clutches – Grande / Lux Bar / Midi" collections. A customer has no way to browse these unless they guess the URL or land on a 404 first. In particular, the **"New" collection existing but not being linked anywhere** means there's no "what's new" page for visitors, even though you already tag new arrivals internally.

- [ ] ⚠️ **Inconsistent collection linking between hero and grid.** The hero's quick-category buttons link to `compact-mirrors` and `signature-purses` (the broader, parent collections), while the "Our Collections" grid further down links to the narrower sub-collections (`artisan-compact-mirrors`, `motif-compact-mirrors`, `velvet-purses`, `rattan-purses`, `glass-bead-woven-handbags` as separate tiles). Nothing is broken, but a visitor browsing from two different spots on the same homepage ends up on different collection pages for what feels like the same category. Worth deciding once: is "Compact Mirrors" one collection with a color/style filter, or two separate collections? Right now the site does both.

- [ ] ⚠️ **Sold-out product pages render blank for a moment.** On the Phone Travel Wallet - Pistachio (sold out), the entire right-hand column — title, price, "Sold out" badge, Notify Me button — took roughly 1–2 seconds to appear after the images loaded. It self-corrected, but on a slower connection this could look like a broken page. Worth a quick page-speed check once live (Google PageSpeed Insights is free and takes 30 seconds).

- [ ] ⚠️ **Newsletter section naming is inconsistent.** Hero button says "Join the List," the section it jumps to is titled "Join the Drop List." Also worth noting: "Drop List" still uses drop language, even though your drop-cadence messaging was intentionally softened/retired elsewhere. Minor, but easy to align while you're in there.

- [ ] ⚠️ **Shipping policy page doesn't confirm the free-shipping threshold.** Your announcement bar promises "Free shipping on orders over $70," but the Shipping Policy page itself never restates that number. Not broken, but a customer who clicks through to double-check won't find confirmation.

---

## 4. Confirmed working well (don't touch)

- [x] ✅ **Add to cart / cart page** — tested end-to-end. Adding a 1-of-1 item, then trying to increase quantity past 1, correctly blocks it with "Only 1 item was added to your cart due to availability." This is exactly right for one-of-a-kind inventory.
- [x] ✅ **Search** — predictive search (with thumbnails and pricing) and the full `/search` results page both work correctly.
- [x] ✅ **Custom 404 page** — has a search box and links back to All Collections, All Products, Available Now, and Contact — good recovery path instead of a dead end.
- [x] ✅ **Sold-out handling** — "This piece found its home" + "Notify Me of Similar Items" is warm, on-brand copy and functions correctly (button disables, form present).
- [x] ✅ **Color filters** — tested on Compact Mirrors (132 products); filter options are populated with accurate counts (Blue (35), Pink (20), etc.). If this was a known gap in your product data, it looks resolved in this catalog.
- [x] ✅ **All 8 homepage collection links + all policy pages + Our Story + Contact** — every link I clicked resolved correctly, no 404s.
- [x] ✅ **Mobile product pages** — swipeable image gallery with page counter (e.g. "1/5"), clean layout, nothing cut off.
- [x] ✅ **"Our Story" page** — genuinely good: a real market-booth photo of you, warm founder voice, ends with a clear "Explore our collection" CTA.

---

## 5. UX review — first impression & navigation

**Overall: the visual design is a real step up.** Clean typography, generous spacing, believable trust badges, and — most importantly — actual photos of you at the market (not stock imagery). For a solo, self-funded side business, this reads more polished than most small handmade-goods sites. It does **not** feel "too simple" or unimpressive; if anything the hero and "Piece of the Day" feature do a good job of making individual pieces feel special.

**Where it gets harder for a new visitor:**

- [ ] The site never says, in one sentence near the top, *what kind of store this is.* A first-time visitor scrolling the hero sees "One piece at a time. Yours alone." and category icons (dolls, mirrors, hats, purses) before any text explains "each of these is a single handmade item, not a product line you can reorder in your size." The "Our Collections" section subtitle ("Browse the full range — mirrors, dolls, hats, purses and more") is the closest thing to an overview, and it's four screens down. Consider a one-line explainer higher up: something like *"Every piece below is one-of-a-kind and handmade in Vietnam — when it's gone, it's gone."* This also does double duty explaining why some items show "Only 1 in stock" while others don't.
- [ ] Navigation depth is inconsistent (see the collection-linking note in section 3). A returning customer who remembers "there was a rattan purse collection" has to guess whether it's under Signature Purses, Rattan Purses, Bookcase Rattan Purses, or Circle Rattan Purses.
- [ ] There's no visible way to see "what's new" even though a New collection exists in the backend. For a business built on frequent small drops of unique pieces, a "New This Week" or "Just Added" entry point is a natural conversion driver you're currently not using anywhere in the nav.
- [ ] The Q&A section on the homepage is genuinely well-chosen (handmade sourcing, sizing/fit accuracy, returns) — but it duplicates content that should live on Contact/Refund Policy pages, and right now the FAQ's own return answer (30 days) disagrees with the Refund Policy page (15/7 days), so it's actively doing harm on that one question. Otherwise, keep it.

**Trust and credibility — strong:**
- [ ] ✅ Real customer names + specific market locations in testimonials (not generic "Amazing! 5 stars")
- [ ] ✅ Payment icons in the footer (Amex, Apple Pay, Discover, Mastercard, PayPal, Shop Pay, Visa) signal legitimacy
- [ ] ✅ "Find Us" section with real addresses and Get Directions links makes the in-person side of the business feel tangible, which matters since ~84% of your revenue is in-person today

---

## 6. UX review — mobile specifically

Mobile is where most new visitors will land, so this deserves its own pass rather than assuming "desktop worked, mobile probably did too."

- [ ] ❌ Trust-badge row cut off (see Critical section)
- [ ] ❌ Footer legal links cut off (see Critical section)
- [ ] ✅ Hero fits the screen without excessive scrolling before the first CTA is visible
- [ ] ✅ Category tiles reflow cleanly into a 2-column grid
- [ ] ✅ Product image gallery is swipeable with a page counter
- [ ] ✅ Hamburger menu is clean and includes a "Log in" link at the bottom
- [ ] ✅ Q&A accordion expands/collapses correctly and is readable at phone width

---

## 7. Direct answers: what to add / remove / combine / change

You asked specifically about this, so here it is as a standalone list:

**Add:**
- [ ] An "All Collections" or "Shop All" link somewhere in the main nav or footer, so the hidden sub-collections (New, Bookcase/Circle Rattan, Velvet Clutch sub-types) are actually reachable.
- [ ] A "New Arrivals" nav entry pointing at the existing (currently unlinked) New collection.
- [ ] One short sentence near the hero explaining the one-of-a-kind model in plain terms, before the first collection grid.
- [ ] A single, consistent return-policy statement, referenced identically on product pages, the FAQ, and the Refund Policy page.

**Remove:**
- [ ] "Headbands" from the Our Story copy, unless you're putting headband listings back online.
- [ ] The hair clips / bookmarks / keychains example list from the Refund Policy page — replace with your current product categories.
- [ ] "Drop List" wording on the newsletter section, to match the fact that fixed-cadence drop messaging was intentionally retired elsewhere on the site.

**Combine:**
- [ ] Decide once whether Compact Mirrors, Rattan Purses, and Velvet Purses are each a single collection with filters, or families of separate sub-collections — then link consistently from both the hero and the "Our Collections" grid instead of mixing parent and child links.
- [ ] The homepage Q&A and the formal policy pages are answering overlapping questions (returns, in-person viewing) with different answers in different places — merge them into one source of truth per topic.

**Change:**
- [ ] Soften "one-of-a-kind" / "only piece in existence" language on any product where quantity is greater than 1 (this is already on your own to-do list — it's just not implemented on the live preview yet).
- [ ] Fix the orphaned-period formatting bug in the returns snippet on every product page.

---

## 8. Suggested fix order

1. Return-policy contradiction (Critical §1) — highest customer-trust and financial risk
2. Broken "Our Collections" nav link (Critical §1) — quick fix, high visibility
3. Mobile overflow bug affecting trust badges + footer links (Critical §1) — likely one CSS fix covers both
4. Our Story / Refund Policy stale product references (High §2)
5. Soften absolute "one-of-a-kind" claims on multi-quantity items (High §2)
6. Everything in Medium priority (§3) as time allows before or shortly after launch

---

*Note: I did not submit the newsletter signup form or attempt checkout, to avoid creating a test subscriber or entering the real payment flow on your live Shopify backend. Both should be spot-checked manually before launch.*
