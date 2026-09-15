> **ARCHIVED 2026-09-15 — background reading, not an action list.**
>
> Research from 28 May 2026. The competitive analysis, the artisan/one-of-a-kind UX findings and the
> "Don'ts" still hold and are worth reading. The **Stage 1 / Stage 2 / Stage 3 recommendation lists
> are superseded** — most of Stage 1 and 2 shipped in the Craft theme, and every drop-cadence
> assumption in it has been retired. Anything still open lives in `OPEN_ITEMS.md`.

---

# Lena Handicrafts Website Research & UX Architecture Report

## TL;DR
- **The live lenahandicrafts.com is a default Shopify catalog, not the curated "micro-gallery" the brand wants** — it has no hero, no story above the fold, an unfinished "Next, add product images" placeholder visible to customers, an incentive-free newsletter signup, and zero "weekly drop" signal — yet every raw asset (warm founder story, evocative product names, real Vietnamese artisan provenance, market presence in South Florida) is already on hand and just needs to be surfaced.
- **Ganapati Crafts is a strong reference model** for taxonomy and ethical-craft storytelling (multi-tier mega-menu by theme/animal/festive, "Trusted by" institutional logos including MoMA PS1, Seattle Art Museum, McNally Jackson, The Huntington Library, Carnegie Museums of Pittsburgh, Kinokuniya, and Pittsburgh Zoo; an embedded "from 8604 reviews" widget; women-artisan messaging), but it operates a high-volume restock catalog — for true weekly-drop gallery DNA the closer references are **Vuvu Ceramics, Jiakuma, Pottery by Eleni, Woolster, and Banana Stitches Co.**, which use restock countdowns, "once it's gone it's gone" language, newsletter-as-primary-channel, and drop-specific collections.
- **Recommended path: rebuild on Shopify's free Craft theme** (purpose-built for artisans, includes Lookbook + story sections), add a Klaviyo or Shopify Email signup with a clear "First access to weekly drops" offer, add a "This Week's Drop" pinned collection on the homepage, install a Notify Me / back-in-stock app, and put founder + Vietnam provenance + women-owned credentials inside the hero — this can be shipped in 2–3 weeks without a custom theme purchase.

## Key Findings

### 1. The current Lena Handicrafts site has good bones, poor merchandising
The prototype Shopify preview URL is token-gated (`*.shopifypreview.com` is set to noindex and blocked from archive crawlers), so it could only be reviewed via screenshots the merchant supplies directly. The **live production site at lenahandicrafts.com is fully accessible** and was audited in detail. It is the more important reference because it is what real customers see today.

**What's working on the live site:**
- Clear product taxonomy: Rattan Purses, Velvet Purses (Grande/Lux Bar/Midi/Compact/Coin), Glass Bead Woven Handbags (Grande/Mini), Floral Ribbon-Embroidery Hats, Keepsakes & Accessories (Compact Mirrors, Phone Wallet).
- Consistent price tiers (Compact Mirrors flat $32; Midi $95; Grande $109; Lux Bar $119; Rattan $139–$199).
- Evocative product naming ("Fuji Sakura Dusk", "Crimson Poppy Fields", "Hummingbird in Garden", "Alpine Meadow Bloom") that already supports a gallery positioning.
- Strong, warm About-page copy that tells the trip-back-to-Vietnam origin story.
- Real-world credibility: every Saturday at the West Palm Beach Antique & Flea Market and regular vendor presence at Kollective stores on Atlantis Ave (Delray Beach) and Las Olas Blvd (Fort Lauderdale).
- Full payment stack already enabled (Apple Pay, Google Pay, Shop Pay, PayPal, all major cards).
- Functional Sold-Out badges (Shopify default behavior).

**What's broken or missing (concrete, named issues):**

| # | Issue | Severity |
|---|-------|----------|
| 1 | **No hero section at all** — visitors land directly on a "💖 Signature Purses 💖" product carousel with no headline, value prop, founder image, or CTA | Critical |
| 2 | **Brand story buried** on `/pages/about-us` — no homepage teaser | Critical |
| 3 | **Unfinished placeholder visible to customers**: the text "Next, add product images" is live on the homepage between two lifestyle photos | Critical |
| 4 | **Newsletter has no offer** — just "Subscribe to our emails" with no incentive ("10% off first order" or "First access to weekly drops") | Critical |
| 5 | **No one-of-a-kind/scarcity messaging** above the fold; only surfaces in deep FAQ | Critical |
| 6 | **No "Notify when back in stock" capture** on sold-out cards (and many cards show as Sold out) | Critical |
| 7 | **No "This Week's Drop" / "New This Week" section** despite weekly drops being the business goal | Critical |
| 8 | **Inconsistent navigation across pages** — About page exposes internal "#MK" (market) suffixes and a parallel Online Collections vs. Market Collections menu | Important |
| 9 | **Announcement bar links to wrong target** ("Free standard shipping on orders over $70" links to the refund policy page) | Important |
| 10 | **Phone-quality product photography** — filenames `rn-image_picker_lib_temp_*` indicate React Native phone-picker uploads, not styled studio shoots | Important |
| 11 | **Studio cutouts only** — no lifestyle/in-context/in-use shots on cards | Important |
| 12 | **24-item carousels** without filters create excessive horizontal scrolling | Important |
| 13 | **No retail/market presence on homepage** despite being the brand's strongest credibility signal | Important |
| 14 | **No founder face / "Meet the Artisan" element** | Important |
| 15 | **No reviews/testimonials/UGC** | Important |
| 16 | **"Powered by Shopify" badge** still visible, undermining premium positioning | Minor |
| 17 | **gmail.com support address** (`lenahandicrafts4u@gmail.com`) instead of `hello@lenahandicrafts.com` | Minor |

### 2. Ganapati Crafts (user's favorite reference) — what to emulate, what doesn't translate

Ganapati is an ethical Asian-handicraft Shopify store selling felt finger puppets from Nepal, Bali rattan bags, and Nepal hand-loomed bags. Named institutional customers (per the "Trusted by" strip on their homepage) include MoMA PS1, Seattle Art Museum, McNally Jackson Bookstore, Sugarboo, Pittsburgh Zoo, Odin Parker, The Huntington Library, Kinokuniya Bookstore, and Carnegie Museums of Pittsburgh. (They do not publish a total wholesale-location count; do not extrapolate a number until confirmed with the merchant.)

**Layout (top to bottom of homepage):**
1. Free shipping announcement bar ($80 threshold)
2. **Mega-menu navigation** organized by *theme + category + festive*:
   - Shop by Themes → Animals (Farm/Safari/Birds/Cats/Dogs/Dinosaurs/Mice/Forest/Arctic), Themes (Coastal/Tropical/Food/Rainbow/Sports/Camping/Space), Festive (Easter/Autumn/Love/Pompom/Christmas)
   - Baby & Kids → Nursery Decor, Felt Toys, Accessory
   - Best Rattan Bags For Summer (seasonal hero category)
   - Bags & Accessories
   - Homeware
   - About
3. **Hero rotating banner** with "Best Seller" eyebrow + product callouts (Bali Rattan Handbag, Felted Wool Finger Puppets, "Where Love Begins to Bloom" Mother's Day banner)
4. **"Trusted by" institutional logo strip** (the named museums and bookstores above)
5. **"Best Seller — The Bag Everyone's Talking About"** single hero product with detailed lifestyle photo
6. **"Discover Bali's Best"** product grid (4–6 items)
7. **"Let customers speak for us"** — embedded reviews widget with photos of products, customer names, dates, star ratings; the site displays "from 8604 reviews"
8. **"Choose your favorite" Felt Finger Puppets** — featured collection grid with "Shop the look" tagging
9. **"Best for Babies & Kids" Collections** — five circular collection tiles
10. **"Felt Garlands & Party Banners" Featured Products** — 8-item grid
11. **"Spring 2026 Market Schedule" — Find us at West Palm Clematis Market** with "Every Saturday 8:30 AM – 1:30 PM" + Google Maps directions
12. **Footer**: Quick Links, Customer Care, Newsletter signup with 10% discount offer, country/currency selector

**Why it works for handcrafted goods:**
- Multi-axis taxonomy (animal × theme × festive × age) gives a deep catalog enough wayfinding to feel like a gallery, not a grid.
- Trust signals are institutional (museums, bookstores) rather than user-generated, which fits a fair-trade-craft narrative.
- Storytelling is layered: brand mission ("celebrate craftsmanship, sustainability, and the empowerment of women artisans") in footer; product origin ("hand-loomed bags from Nepal", "rattan bags from Bali") in nav; market schedule with directions to physical booth.
- The 8,604-review widget directly on the homepage is the dominant social proof block.
- "Free shipping on order $80+" threshold is consistent in announcement bar AND footer.

**Why Ganapati does NOT translate 1:1 to Lena:**
- Ganapati sells *repeatable*, multi-quantity products (felt puppets are made in editions; the same Bali Rattan Tote – Medium can restock indefinitely). Lena sells *one-of-one* pieces where each Hummingbird Hat or Fuji Sakura mirror exists in qty 1. That fundamentally changes the homepage emphasis from "best-seller-driven catalog" to "drop calendar / curated wall."
- Ganapati's mega-menu is heavy and would feel cluttered for Lena's smaller product range.
- Ganapati's review widget assumes thousands of reviews — Lena will start near zero.

### 3. Comparable artisan/drop-model websites (10 detailed references)

| # | Site | What they sell | Key takeaway for Lena |
|---|------|----------------|------------------------|
| **1** | **vuvuceramics.com** (Vuvu Ceramics, Deana Coveney, Encinitas CA) | Botanical pottery, jewelry dishes, leaf/flower-imprinted clay, sculpted ladybugs/bees/foxes/dragons | **The closest model to Lena.** Homepage headline literally reads "Welcome to Vuvu Ceramics! My May restock has sold out! Please subscribe to my newsletter and I'll send you an email when I restock. My pieces are sold ONLY here on this website." Homepage adds: "Pieces generally sell out within 10-15 minutes of the restock." Vuvu's FAQ goes further: "My shop restocks do sell out quickly, sometimes within 5 minutes." Newsletter is the centerpiece. The FAQ explains drops happen 1–2× per month with about 100 pieces per drop. Three image-tile collections beneath. Built on Shopify. |
| **2** | **jiakumadesign.com** (Jiakuma, Milan) | Hand-cut, hand-stitched one-of-a-kind fabric bags (bento/Kiki/dumpling/Mariko bags), espadrilles, scrap-fabric necklaces, "waste-zero" | "Every Jiakuma bag is cut, stitched and assembled by hand by Giacomo in our Milan studio. No factories, no mass production." FAQ: *"Each piece is truly one of a kind. Once its gone, it will never be made again."* / "How can I stay updated on new drops? Follow us on instagram @jiakumadesign and join our newsletter. All our pieces are one of a kind and once they are gone, they are gone." Direct quote-template Lena should adopt. |
| **3** | **potterybyeleni.com** (Pottery by Eleni) | Hand-sculpted feminine ceramics | "We've transitioned from made-to-order to small batch releases—meaning no more waiting! Sign up for our mailing list to be the first to know when each collection drops." Demonstrates the made-to-order → drop transition messaging. Each "collection" gets a name ("Whispers of Spring," inspired by Italian dogwoods). |
| **4** | **woolster.com** (Esther, Dutch-Kiwi crocheter) | Crochet washcloths, bath mitts, baskets, fruit/veg bags, festive crochet, baubles | "Everyone will adore these handcrafted crochet treasures... All unique & custom-made creations." Travel-inspired collections with seasonal rotation (Easter, Christmas, Easter-Egg Tree). Demonstrates how a single-maker crochet brand handles multiple categories without losing personal voice. |
| **5** | **silversageceramics.com** (Maine) | Handmade pottery + artisan jewelry | "One-of-a-kind pottery and jewelry inspired by nature, detailed illustration, and storytelling... celebrates craftsmanship, texture, and the beauty of imperfection." Combines two product categories cleanly. |
| **6** | **fdpstudioshop.com** (fdp studio+shop, eastern Pennsylvania) | Husband makes pottery on-site; founder curates complementary artisan goods (candles, tableware, charcuterie boards) | "Welcome to fdp studio+shop! fdpottery is made on site in our newly restored, historic building forty minutes east of Pittsburgh, PA. My husband, Francis DeFabo, creates small-batch ceramics while basking in the pottery studio's view of rolling hills and neighborly goats." Shows how a family/place-based story humanizes a multi-category small Shopify store. |
| **7** | **theartisannest.com** (The Artisan Nest) | Macramé + crochet | "Born from a journey with fibromyalgia, each handmade piece reflects softness, care, and natural beauty... we celebrate slowness, imperfection, and the quiet joy of creating with heart." Strong founder story; offers digital gift cards (good idea for Lena since drops sell out fast). |
| **8** | **mountaintopyarn.com** (indie hand-dyed yarn + handmade community pieces) | Hand-dyed yarn, original patterns, community-made one-of-a-kind pieces | Dedicated "one-of-a-kind community pieces" collection: "When you shop this section, you are supporting small artists, slow crafting, and the work of people who create because they love it." Demonstrates a "Featured Makers / Spotlight" pattern. |
| **9** | **inspiremakers.com** (Inspire Makers, Cornwall UK) | Multi-maker gallery shop | "Inspire Makers showcases the work of over 60 Cornish contemporary design-led artists and craftspeople... The story of each maker is told alongside their work, giving you an insight into what inspires them." Demonstrates "story-per-product / story-per-maker" pattern. |
| **10** | **capsulerecords.co.uk** (vinyl shop, but instructive) | Vinyl records, "The Weekly Drop" | Has a dedicated `/pages/the-weekly-drop` URL: "Every week behind the scenes, we're busy ordering and listening to lots of new music to bring you a carefully curated selection of new additions to the shop. The Weekly Drop is our way of bringing our new additions to the shop, to you." Best-in-class naming convention Lena should outright steal. |

### 4. UX best practices specifically for artisan / one-of-a-kind / drop-model e-commerce

**Homepage hero patterns that work:**
- **Single hero image** with a value-statement headline ("Hand-embroidered in Vietnam. One piece at a time."), a sub-line about provenance, and ONE CTA ("Shop this week's drop" or "Join the drop list").
- Avoid auto-rotating carousels for the hero — they hurt mobile conversion and bury the message.
- Include a *secondary* hero strip immediately below the fold with the brand promise in 3 icons (e.g., "100% handmade in Vietnam" / "Each piece is one-of-one" / "Women-owned").
- If video is available, a 4–6 second silent loop of hands embroidering or stitching is the highest-converting hero asset for handmade goods (used by Akoiaswim, Saachi, Aluma).

**Navigation for multi-category artisan shops (5–25 SKUs per category):**
- A flat, short nav (4–6 items) outperforms a mega-menu when the catalog is small. Recommended for Lena: `Shop All` / `This Week's Drop` / `Purses` / `Mirrors & Keepsakes` / `Hats & Headbands` / `About`.
- Use a *visual collection grid* below the hero (image-tile per category) instead of forcing customers into nav drilldowns.
- Hide "market"-only SKUs from the public nav (Lena currently exposes "#MK" suffixes — fix by tagging products as `online-only` vs. `market-only` and filtering with collection rules).

**Product gallery vs. traditional grid:**
- For one-of-a-kind merchandise, a *masonry / Pinterest-style* or *asymmetric mosaic* layout reads as "gallery"; a uniform 4-column grid reads as "catalog." Themes that ship this natively: Highlight ($300), Editions, Studio (free).
- Avoid horizontal carousels for the primary product surface — they hide inventory; instead, use a "Shop All" infinite-scroll collection page as the primary discovery surface and use carousels only for "Featured" curation.
- Lifestyle photography on the *first* image with hover-to-studio is the highest-converting pattern for handmade fashion.

**Communicating "one-of-a-kind" / scarcity effectively:**
- Persistent line under EVERY product title: "1 of 1 — once it's gone, it's gone." (Jiakuma's exact pattern.)
- Inventory indicator: "Only 1 left" (Shopify's Dawn theme ships a free low-stock block — no app needed).
- Drop-date badge on new arrivals: "Just listed [date]" or "New this week."
- Sold-out items should remain on the homepage with a "Sold out" badge to *amplify* the scarcity signal (counterintuitive but effective — Vuvu and Jiakuma both do this).

**Email capture strategy for artisan businesses:**
- For drop-driven brands, the newsletter IS the storefront. Promise: "Get the email 24 hours before each drop." (Vuvu does exactly this — "the day before each shop update.")
- Klaviyo is the Shopify-default standard; for SMS, Postscript is the standard. SMS open rates average around 98% versus email's typical ~20–27% (per Infobip's 2026 SMS marketing statistics roundup, citing Forbes 2025 and Validity), which matters more than email for drops because timing matters down to the minute.
- Three-message drop flow: signup confirmation → reminder 24h before → "It's live" the moment the drop goes live.
- Offer a small first-order discount (5–10%) only IF margins allow — many artisans don't, because the value proposition is access, not discount.

**"Sold out" handling best practices:**
- Keep sold-out items visible (do not hide them) — they prove items move.
- Add a "Notify me of similar pieces" button (apps: Notify-me, Back in Stock, Klaviyo Back-in-Stock).
- Tag sold-out items with a soft visual treatment (grayscale on hover, "SOLD" overlay) rather than removing them.
- For true one-of-ones, the messaging should say "This piece has found its home" or "Sold — but new mirrors drop every Friday" rather than the generic Shopify "Sold out."

**Mobile-first design patterns for visual product businesses:**
- Globally about 70.92% of e-commerce traffic comes from mobile devices as of 2025, per Capital One Shopping Research's *Mobile eCommerce Statistics 2026* (citing Statcounter Jan 2026). For an Instagram-driven artisan brand the share is typically higher.
- Single-column hero, large thumb-friendly tap targets (min 44×44 px), sticky add-to-cart on product pages.
- Image zoom on tap (not hover, which doesn't work on mobile).
- Product card must show: image, title, "1 of 1" badge, price — nothing else. No hover effects.
- Tap to enlarge full-screen product gallery (especially important for embroidery detail).

### 5. Shopify theme recommendations

**Best free Shopify themes for Lena's gallery + drop model:**

| Theme | Cost | Why it fits | Watch-outs |
|-------|------|-------------|------------|
| **Craft** (Shopify, free) | $0 | Purpose-built for handmade/artisan. Includes Lookbook section, Story block, Press section, large editorial product cards. Clean and uncluttered. Used by The Mint Museum Store and Sheair Butters. | Limited variants; needs custom CSS to feel premium. |
| **Studio** (Shopify, free) | $0 | Free theme built for creative/artist stores with sticky nav, artist profiles, asymmetric product grids — exactly the gallery feel Lena wants. Strong testimonials from jewelry artisans. | Slightly less polished than Craft; smaller community. |
| **Dawn** (Shopify, free, default) | $0 | Lena's site likely already runs Dawn or a Dawn variant. Strong free option, fast, ships with built-in low-stock messaging block. | Generic; needs heavy customization to feel like a gallery. |
| **Publisher** (Shopify, free) | $0 | Narrative-first, moody, minimalist; uses contextual links rather than traditional nav. Best for editorial brand storytelling. | Less commerce-focused; not ideal if conversion is the priority. |

**Best paid themes:**

| Theme | Cost | Why |
|-------|------|-----|
| **Handmade** (Shopify) | $320 | Predictive search + video banners; refined design specifically for handmade. |
| **Highlight** (Shopify) | $300 | Parallax vertical slider + asymmetric product grid — best for "dynamic art" presentation. |
| **DROP** (third-party) | One-time fee | Built specifically for product drops with built-in countdown timer and "drop hub." Worth it only if drops become the central business model. |
| **Editions** (Shopify) | Paid | Content-first, gallery-style, strong storytelling. Strong for fine art / fine craft. |

**Key Shopify features and apps Lena needs regardless of theme:**
- **Built-in scheduled publishing** (no app needed) — set products to "Draft," set a publish date, Shopify auto-publishes at the drop moment.
- **Built-in inventory tracking** with quantity = 1 for one-of-ones; sold-out auto-toggles.
- **Klaviyo** or **Shopify Email** for newsletter (free up to 250 contacts on Shopify Email).
- **Notify Me / Back in Stock** app (free tier available) — captures emails on sold-out cards.
- **Pasilobus Social Proof** (free, made by a Shopify-community developer) — live counter "X people viewing" during drops.
- **Pasilobus Confetti** (free) — confetti on order-confirmation page; small but emotionally on-brand for a craft purchase.
- **Built-in "Trusted by" / Press logo strip** (most themes ship this section) — populate with Kollective Delray, Las Olas Blvd, West Palm Beach Antique & Flea Market.
- **Shopify Forms** for capturing "Notify me when drops" interest before launch.

## Details

### Recommended site architecture (information architecture) for Lena Handicrafts

**Top nav (5 items):**
1. Shop All
2. **This Week's Drop** (pinned collection; tag-driven)
3. **The Gallery** (browse all by category — Purses / Mirrors / Hats & Headbands / Crochet Figures)
4. Our Story
5. Find Us (markets, retail locations, contact)

**Footer:**
- About (founder story teaser, women-owned + Vietnamese artisans badge)
- Drop Calendar / Next Drop date
- Markets We Vend
- Care Instructions (especially for embroidery and rattan)
- Shipping & Returns
- Newsletter signup ("Be first to shop each Friday's drop")
- Contact (`hello@lenahandicrafts.com` — get a domain email)
- Social

**Homepage section stack (top to bottom):**
1. Announcement bar: "Free shipping over $70 / Next drop: Friday at 8pm ET" (links to drop calendar page)
2. **Hero**: Lifestyle photo of an artisan's hands embroidering a hat OR a flat-lay of a curated drop set. Headline: "Hand-embroidered in Vietnam. One piece at a time." Sub: "Every mirror, hat, and bag in our shop is a one-of-one. New drops every Friday." CTA: "Shop this week's drop"
3. **3-icon trust strip**: "100% handmade in Vietnam" • "Each piece is 1 of 1" • "Women-owned, since [year]"
4. **This Week's Drop** carousel (4–8 items) with countdown to next drop
5. **The Story** — 2-column block: founder photo + 80-word excerpt from About page + "Read our story" CTA
6. **Shop by category** — 4 image tiles: Purses, Mirrors, Hats, Crochet Figures
7. **Featured maker / artisan spotlight** (rotate monthly): photo + 60 words about one of the family/friends artisans in Vietnam
8. **Find us in person** — list of markets + Kollective Delray + Las Olas Blvd Fort Lauderdale + Google Maps embed (this is gold and is currently invisible)
9. **Reviews / testimonials** strip (once you collect them; until then, use written notes from customers met at markets)
10. **Newsletter signup**: "Be first to shop each Friday's drop" — Email + optional SMS (drops get the SMS list; weekly newsletter goes by email)
11. **Footer**

### Product page improvements
- "1 of 1" badge above title.
- Inline artisan attribution if known ("Embroidered by [Name] in [Village/Province], Vietnam").
- "Slight variations make your piece unique" trust line (already in FAQ — promote to PDP).
- Detail-zoom images (front, back, embroidery close-up, in-hand for scale).
- Care instructions accordion.
- "Found a home? Get notified when similar pieces drop" if sold-out.
- Cross-sell: "Other pieces in this week's drop."

## Recommendations

### Stage 1 — Quick wins (this week, no theme change)
1. Delete the placeholder text "Next, add product images" — it is live on the homepage right now.
2. Fix the announcement-bar link so "Free shipping over $70" goes to a shipping page, not the refund policy.
3. Rewrite the newsletter prompt from "Subscribe to our emails" to: *"Be first to shop each Friday's drop — join our list and we'll email you 24 hours before the next drop goes live."*
4. Add three lines of copy near the top of the homepage (above the first product carousel): *"Hand-embroidered in Vietnam. One piece at a time. Each item is 1 of 1 — once it's gone, it's gone."*
5. Move the "Find us at the West Palm Beach Antique & Flea Market every Saturday" call-out from a deep page onto the homepage.
6. Tag products as `online-only` vs `market-only` and remove the "#MK" suffixes from public-facing collection names.
7. Replace the gmail support address with a domain email (`hello@lenahandicrafts.com`).
8. Install **Notify Me** or **Back in Stock** app (free tier) and enable on every sold-out item.

**Benchmark to advance to Stage 2:** at least 100 newsletter subscribers AND first drop sells through ≥ 50% within 48 hours.

### Stage 2 — Theme migration and brand polish (next 2–4 weeks)
1. Migrate to **Craft theme** (free) — keep all products and collections.
2. Reshoot top 30 products with a consistent flat-lay-on-linen style + 1 lifestyle shot per product (held by hand, worn, or on a styled vanity). Phone photos are fine if lighting is controlled — use one north-facing window, white foamcore reflector, $0 budget.
3. Add a Hero section (Craft theme has a built-in lookbook/hero block) using one strong founder/artisan photo.
4. Build the "This Week's Drop" Shopify collection rule: tag drop products with `drop-2026-w22` etc., or simply use "Available for sale + Created in last 7 days."
5. Set up Klaviyo (free up to 250 contacts) with the 3-message drop flow: confirmation, 24h reminder, "It's live."
6. Build a `/pages/our-story` page with founder photo, trip-back-to-Vietnam narrative, and 2–3 artisan portraits if family members consent.
7. Add a `/pages/drops` page with archive of past drops and "next drop" date. This gives social media a single deep link to share.

**Benchmark to advance to Stage 3:** 500+ newsletter subscribers AND 3 consecutive drops sell ≥ 70%.

### Stage 3 — Scale (Q3–Q4 2026)
1. Add SMS (Postscript or Klaviyo SMS) for drop alerts — top-tier subscribers only.
2. Run lottery or VIP early access for highest-LTV customers (Shopify Tags + Klaviyo segments).
3. Introduce **wholesale on Faire** (Ganapati's model — buy on faire.com link). Lena already vendors at retail; wholesale is the natural extension.
4. Add a **drop calendar Google/Apple integration** ("Set a reminder").
5. Hire a part-time photographer or invest in a $400 lightbox + macro lens for embroidery detail shots.
6. Consider DROP theme (paid) if drops become 80%+ of revenue.

### Don'ts
- **Don't** auto-rotate the hero carousel.
- **Don't** hide sold-out items — they prove demand.
- **Don't** lower prices to clear inventory; raise prices on remaining one-of-ones if anything (scarcity signal).
- **Don't** add unnecessary apps — Notify Me + Klaviyo is enough to start.
- **Don't** copy Ganapati's mega-menu — too heavy for Lena's catalog size.

## Caveats

- The prototype Shopify preview URL (`po40vnz074l4eo4v-75973198146.shopifypreview.com`) is token-gated, set to noindex, and blocked from the Wayback Machine. It could not be reviewed from public sources. All "current site" findings above are based on the **live production site at lenahandicrafts.com**, which is what real customers see today. If the prototype differs substantially, the merchant should share screenshots or grant preview access.
- The U.S. fiber-arts market is large but smaller than sometimes reported: Dataintelo's 2025 *Global Knitting Yarn Market* report estimates "approximately 34 million active knitters and crocheters in the United States alone as of 2025," and a separate EconMarketResearch analysis cites "approximately 31 million Americans" in 2024 — so the market is large (~31–34M) but the often-quoted "40+ million" figure is unsupported.
- Marketing-vendor blogs (DROP theme, AdsX, Shopify, Frontlevels) are reasonable directional sources for drop-mechanics best practices, but should not be cited as independent research.
- Theme pricing is current as of May 2026 (Handmade $320, Highlight $300, Craft and Studio free) — Shopify can change these without notice.
- Ganapati Crafts publicly names institutional partners on its homepage (MoMA PS1, Seattle Art Museum, McNally Jackson, Sugarboo, Pittsburgh Zoo, Odin Parker, The Huntington Library, Kinokuniya, Carnegie Museums of Pittsburgh) but does not publish a total wholesale-account count; do not extrapolate "200+" or any other number until confirmed directly with the merchant. Lena should not attempt to mimic the "Trusted by" strip until comparable relationships exist, lest it appear inflated.
- Recommendations assume the merchant will keep the single-maker / family-network production model. If Lena's production scales to multiple manufacturing partners, the "1 of 1" promise must remain honest or the brand positioning collapses.