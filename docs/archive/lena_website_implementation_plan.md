> **ARCHIVED 2026-09-15 — superseded. Built on the weekly Friday drop model, which is retired.**
>
> Written 28 May 2026, before the Craft theme was built. Large parts are now false:
>
> - **The whole drop cadence is gone.** `This Week's Drop` on a `drop-current` tag, `drop-current` /
>   `drop-2026-w22` rotated weekly, the 3-message drop email sequence, `/pages/drop-calendar`
>   ("New pieces drop every Friday at 8 PM ET"), "Friday — Rest (or Drop Day)". The business is
>   supply-driven; gaps run from days to a month. **Do not create `/pages/drop-calendar`.**
> - **Wrong fonts.** Specifies Cormorant Garamond + Nunito Sans. The theme shipped **Josefin Sans +
>   Libre Franklin**.
> - **Wrong New Arrivals rule.** Specifies "Created within 14 days". The real rule is
>   `Tag is equal to new`, owned by the app.
> - **`Available Now` rule is incomplete** — it omits the `tag ≠ POS` exclusion that the live smart
>   collection actually carries.
> - **Phase 2 Week 3 is already built** (theme setup, homepage section stack).
>
> Still useful: the tag taxonomy reasoning, the "Don'ts" list, and the market/event research.
> Anything still open has been lifted into `OPEN_ITEMS.md`.

---

# Lena Handicrafts — Website Rebuild Implementation Plan

## Document Purpose
This is the **master implementation spec** for rebuilding lenahandicrafts.com. It combines:
1. Architecture decisions (from research report)
2. Step-by-step task breakdown (daily-level granularity)
3. Daily routine and weekly review framework
4. Claude Code-ready specifications

**Reference prototype:** `lena_prototype.html` (visual spec for all sections)

---

## Current Problems Being Solved

| # | Problem | Impact | Fix |
|---|---------|--------|-----|
| 1 | Homepage showcases wrong products (Velvet Clutches) | Visitors bounce — #1 seller (Crochet Figure, $12K revenue) is invisible | Lead with crochet + mirrors in hero |
| 2 | "Next, add product images" placeholder visible to customers | Looks unfinished/unprofessional | Delete immediately |
| 3 | No hero, no story, no value proposition above the fold | Zero emotional connection online vs strong in-person story | Add hero with artisan narrative |
| 4 | "#MK" suffixes and Online vs Market collections exposed | Confusing internal logic leaked to customers | Unify into single catalog |
| 5 | Newsletter just says "Subscribe to our emails" | No reason to subscribe — zero email list growth | Rewrite: "First access to weekly drops" |
| 6 | Crochet Figures ($12,273 revenue) have zero online presence | Largest untapped revenue opportunity | Publish immediately |
| 7 | Baseball Hats ($4,345), Headbands ($5,271) unpublished | ~$10K of proven products invisible online | Publish immediately |
| 8 | No scarcity messaging (one-of-a-kind is buried in FAQ) | Loses the urgency that drives in-person sales | "1 of 1" badge on every card |
| 9 | No sold-out item capture (no "notify me" on sold items) | Losing potential customers on popular items | Install Back-in-Stock app |
| 10 | Announcement bar links to wrong page | Broken UX, erodes trust | Fix link target |

---

## Architecture Specification

### Design System

```
FONTS
  Display:  Cormorant Garamond (Google Fonts, free)
  Body:     Nunito Sans (Google Fonts, free)

COLORS
  --cream:           #FAF7F2    (page background)
  --linen:           #F3EDE4    (section alternate bg)
  --warm-white:      #FFFCF8    (card backgrounds)
  --sand:            #E8DFD1    (borders, dividers)
  --terracotta:      #C4724E    (primary accent, CTAs)
  --terracotta-deep: #A85A3A    (hover states)
  --sage:            #7A9A7E    (success, scarcity indicators)
  --ink:             #1A1A1A    (dark sections, text)
  --stone:           #6B6560    (secondary text)
  --rose-mist:       #E8D5CE    (soft accent backgrounds)
  --gold-soft:       #D4A853    (premium accents)

SPACING
  Section padding: clamp(48px, 8vw, 96px)
  Content max-width: 1200px
  Card border-radius: 6px
```

### Site Map

```
lenahandicrafts.com/
├── / (Homepage — see section stack below)
├── /collections/this-weeks-drop
├── /collections/all (Available Now — auto: inventory > 0)
├── /collections/crochet-figures
├── /collections/compact-mirrors
├── /collections/hats-headbands
├── /collections/signature-purses
├── /collections/sale
├── /pages/our-story
├── /pages/the-artisans
├── /pages/find-us (markets + retail locations + map)
├── /pages/drop-calendar
├── /pages/care-instructions
├── /pages/shipping-returns
├── /pages/faq
├── /products/[handle] (individual product pages)
└── /cart
```

### Navigation

```
TOP NAV (5 items — flat, no mega-menu)
┌──────────────────────────────────────────────────────────┐
│ Logo: "Lena Handicrafts"                                 │
│                                                          │
│ ● This Week's Drop  |  The Gallery ▾  |  Our Story  |   │
│   Find Us  |  Cart (0)                                   │
│                                                          │
│ "The Gallery" dropdown:                                  │
│   → Crochet Figures                                      │
│   → Compact Mirrors                                      │
│   → Hats & Headbands                                     │
│   → Signature Purses                                     │
│   → Sale / Clearance                                     │
│   → Shop All                                             │
└──────────────────────────────────────────────────────────┘

ANNOUNCEMENT BAR
  Left:  "Free shipping on orders over $70"  → links to /pages/shipping-returns
  Right: "Next drop: Friday at 8 PM ET →"    → links to /collections/this-weeks-drop
```

### Homepage Section Stack

```
 ┌─────────────────────────────────────────────────────┐
 │  1. ANNOUNCEMENT BAR                                │
 │     "Free shipping over $70 | Next drop: Friday"    │
 ├─────────────────────────────────────────────────────┤
 │  2. NAVIGATION                                      │
 │     Logo | Drop | Gallery | Story | Find Us | Cart  │
 ├─────────────────────────────────────────────────────┤
 │  3. HERO (85vh)                                     │
 │     ┌──────────────┬──────────────┐                 │
 │     │ Eyebrow:     │  Image       │                 │
 │     │ "Hand-       │  Mosaic      │                 │
 │     │  Embroidered │  (4 product  │                 │
 │     │  in Vietnam" │   lifestyle  │                 │
 │     │              │   photos)    │                 │
 │     │ H1: "One     │              │                 │
 │     │  piece at a  │              │                 │
 │     │  time.       │              │                 │
 │     │  Yours       │              │                 │
 │     │  alone."     │              │                 │
 │     │              │              │                 │
 │     │ [Shop Drop]  │              │                 │
 │     │ [Join List]  │              │                 │
 │     └──────────────┴──────────────┘                 │
 ├─────────────────────────────────────────────────────┤
 │  4. TRUST STRIP                                     │
 │     ✋ 100% Handmade  |  1 of 1  |  ♀ Women-Owned  │
 ├─────────────────────────────────────────────────────┤
 │  5. THIS WEEK'S DROP                                │
 │     Header + countdown timer + "View all →"         │
 │     ┌────┐ ┌────┐ ┌────┐ ┌────┐                    │
 │     │card│ │card│ │card│ │SOLD│                    │
 │     │    │ │    │ │    │ │OUT │                    │
 │     └────┘ └────┘ └────┘ └────┘                    │
 │     (4–8 product cards, grid layout)                │
 ├─────────────────────────────────────────────────────┤
 │  6. OUR STORY                                       │
 │     ┌──────────────┬──────────────┐                 │
 │     │  Founder     │  "From a     │                 │
 │     │  photo       │   small      │                 │
 │     │  (at market  │   village    │                 │
 │     │   or holding │   in Vietnam │                 │
 │     │   products)  │   to your    │                 │
 │     │              │   hands"     │                 │
 │     │              │              │                 │
 │     │              │  [Read →]    │                 │
 │     └──────────────┴──────────────┘                 │
 ├─────────────────────────────────────────────────────┤
 │  7. SHOP BY CATEGORY                                │
 │     ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐            │
 │     │Croch │ │Mirror│ │ Hats │ │Purse │            │
 │     │ et   │ │  s   │ │  &   │ │  s   │            │
 │     │      │ │      │ │Bands │ │      │            │
 │     └──────┘ └──────┘ └──────┘ └──────┘            │
 │     (4 image tiles with overlay text)               │
 ├─────────────────────────────────────────────────────┤
 │  8. ARTISAN SPOTLIGHT                               │
 │     Circular photo + name + craft story             │
 │     (rotate monthly)                                │
 ├─────────────────────────────────────────────────────┤
 │  9. FIND US IN PERSON                               │
 │     ┌──────────┐ ┌────────┐ ┌────────┐             │
 │     │ WPB Flea │ │Kollect.│ │Kollect.│             │
 │     │ EVERY    │ │ Delray │ │Ft Laud │             │
 │     │ SATURDAY │ │        │ │        │             │
 │     └──────────┘ └────────┘ └────────┘             │
 ├─────────────────────────────────────────────────────┤
 │  10. NEWSLETTER SIGNUP                              │
 │     Dark background                                 │
 │     "Join the Drop List"                            │
 │     [email input] [Join]                            │
 │     "Get the email 24h before each Friday drop"     │
 ├─────────────────────────────────────────────────────┤
 │  11. FOOTER                                         │
 │     Brand | Shop links | About links | Help links   │
 │     © 2026 | Payment icons                          │
 └─────────────────────────────────────────────────────┘
```

### Product Card Anatomy

```
┌─────────────────────────┐
│ ┌─────────────────────┐ │
│ │  [1 of 1]    [NEW]  │ │  ← Badges (always show "1 of 1")
│ │                     │ │
│ │   Product Photo     │ │  ← 4:5 aspect ratio
│ │   (lifestyle or     │ │
│ │    flat-lay)        │ │
│ │                     │ │
│ └─────────────────────┘ │
│  COMPACT MIRROR          │  ← Category eyebrow (10.5px, uppercase)
│  Rose Garden on Ivory    │  ← Product name (Cormorant, 17px)
│  $32                     │  ← Price (terracotta, bold)
│  ✦ Only piece in exist.  │  ← Scarcity line (sage green)
└─────────────────────────┘

SOLD-OUT VARIANT:
┌─────────────────────────┐
│ ┌─────────────────────┐ │
│ │ ░░░░░░░░░░░░░░░░░░░ │ │  ← Semi-transparent dark overlay
│ │ ░ "This piece found ░ │ │
│ │ ░  its home"        ░ │ │  ← White pill badge centered
│ │ ░░░░░░░░░░░░░░░░░░░ │ │
│ └─────────────────────┘ │
│  COMPACT MIRROR          │
│  Fuji Sakura Dusk        │  ← Name in muted color
│  $38 (strikethrough)     │
│  [🔔 Notify me of       │  ← Notify button (terracotta outline)
│   similar drops]         │
└─────────────────────────┘
```

### Product Detail Page Template

```
┌───────────────────────────────────────────────────────┐
│  ┌────────────────────┐  ┌─────────────────────────┐  │
│  │                    │  │ [1 of 1]                │  │
│  │   Main Product     │  │ COMPACT MIRROR · EVERY  │  │
│  │   Photo            │  │                         │  │
│  │   (front view /    │  │ Rose Garden on Ivory    │  │
│  │    lifestyle)      │  │                         │  │
│  │                    │  │ $32                     │  │
│  │                    │  │                         │  │
│  └────────────────────┘  │ Embroidered by artisans │  │
│  ┌─────────┐ ┌─────────┐│ in Huế, Vietnam         │  │
│  │ Detail  │ │ Scale / ││                         │  │
│  │ close-  │ │ in-hand ││ ● Only piece in exist.  │  │
│  │ up      │ │ photo   ││                         │  │
│  └─────────┘ └─────────┘│ [Description text]      │  │
│                          │                         │  │
│                          │ [═══ ADD TO CART ═══]   │  │
│                          │                         │  │
│                          │ Disclaimer (italic)     │  │
│                          │                         │  │
│                          │ ▸ Care Instructions     │  │
│                          │ ▸ Shipping & Returns    │  │
│                          └─────────────────────────┘  │
│                                                       │
│  ── Other pieces in this week's drop ──               │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                         │
│  │    │ │    │ │    │ │    │                         │
│  └────┘ └────┘ └────┘ └────┘                         │
└───────────────────────────────────────────────────────┘
```

### Shopify Collections Setup

| Collection | Type | Rule | Purpose |
|-----------|------|------|---------|
| This Week's Drop | Automated | Tag = `drop-current` OR created ≤ 7 days + in stock | Hero homepage section |
| Available Now | Automated | Inventory > 0 | "Shop All" page |
| Crochet Figures | Tag-based | Tag: `crochet-figure` | Category page |
| Compact Mirrors | Tag-based | Tag: `compact-mirror` | Category page |
| Hats & Headbands | Tag-based | Tag: `hat` OR `headband` | Category page |
| Signature Purses | Tag-based | Tag: `purse` | Category page |
| Sale | Manual | Owner adds clearance items | Clearance section |
| New Arrivals | Automated | Created within 14 days | Optional secondary feed |

### Required Shopify Apps

| App | Cost | Purpose | Install When |
|-----|------|---------|-------------|
| Shopify Email | Free (≤10K emails/mo) | Weekly drop emails, signup | Week 1 |
| Notify Me / Back in Stock | Free tier | Email capture on sold-out items | Week 1 |
| Pasilobus Social Proof | Free | "X people viewing" during drops | Week 4 (optional) |

### Email Flow (3-message drop sequence)

```
SIGNUP → "Welcome to the drop list"
  - Thank you for joining
  - What to expect: one email per week, new drops every Friday
  - Browse the gallery: [link]

24H BEFORE DROP → "Tomorrow's drop preview"
  - "Here's what's coming this Friday at 8 PM"
  - 3–5 preview images (teaser, not full listing)
  - "Set a reminder"

DROP MOMENT → "It's live — shop now"
  - "This week's drop is live. [X] pieces available."
  - Direct links to each product
  - "Each piece is 1 of 1 — once it's gone, it's gone"

WEEKLY (post-drop) → "What sold out this week" (optional, FOMO builder)
  - Show sold-out items with "found its home" messaging
  - "Join the list to shop first next Friday"
```

---

## Step-by-Step Task Breakdown

### Phase 0: Emergency Fixes (Day 1 — 1 hour)

These take minutes and fix embarrassing issues visible to every visitor right now.

| # | Task | Time | How |
|---|------|------|-----|
| 0.1 | Delete "Next, add product images" placeholder from homepage | 5 min | Shopify Admin → Online Store → Themes → Customize → find the section → delete |
| 0.2 | Fix announcement bar link ("Free shipping" → shipping page, not refund policy) | 5 min | Theme Customize → Header → Announcement bar → change URL |
| 0.3 | Remove "Powered by Shopify" from footer | 5 min | Theme Customize → Footer → uncheck "Show Powered by Shopify" |
| 0.4 | Rewrite newsletter copy from "Subscribe to our emails" to "Be first to shop each Friday's drop — join our list" | 10 min | Theme Customize → Footer/Newsletter section → edit text |

### Phase 1: Foundation Fix (Week 1–2)

**Goal:** Clean up the mess. Unified catalog, hidden bestsellers published, scarcity messaging added.

#### Week 1: Catalog Cleanup (5–6 hours across 4 evenings)

**Monday (1.5 hrs):**
- [ ] Audit all products: list every product with "#MK" suffix
- [ ] Remove "#MK" from all product titles (Shopify Admin → Products → edit each)
- [ ] Identify duplicate listings (same product listed twice — one "online" one "market")

**Tuesday (1.5 hrs):**
- [ ] Archive/delete duplicate product listings
- [ ] Merge "Online Collections" and "Market Collections" — delete the market-only collections
- [ ] Tag all products with correct category tags: `crochet-figure`, `compact-mirror`, `hat`, `headband`, `purse`

**Wednesday (1.5 hrs):**
- [ ] Restructure navigation menu in Shopify:
  - Delete old menu items (Online Collections, Market Collections, etc.)
  - Create new structure: This Week's Drop | The Gallery (dropdown) | Our Story | Find Us
  - The Gallery dropdown: Crochet Figures, Compact Mirrors, Hats & Headbands, Signature Purses, Sale
- [ ] Create automated collection "Available Now" (rule: inventory > 0)

**Thursday (1 hr):**
- [ ] Set phased-out products to clearance pricing:
  - Velvet Clutch Compact: 15% off
  - Resin Wooden Hairpin: 25% off
  - Passport Cover, Scrunchie: deep discount or mark as free-with-purchase
- [ ] Create "Sale" collection and add clearance items
- [ ] Install "Notify Me" or "Back in Stock" app (free tier)

#### Week 2: Homepage & Hidden Products (6 hours across 4 evenings)

**Monday (1.5 hrs):**
- [ ] Publish Crochet Figures to website (set status = Active, Published = true)
  - Use existing POS photos if available
  - Add scarcity line to each description: "One-of-a-kind. When it's gone, it's gone."
- [ ] Publish Baseball Hats to website

**Tuesday (1.5 hrs):**
- [ ] Publish Headbands to website
- [ ] Publish Hair Ties to website
- [ ] Add "1 of 1" text to all product descriptions (batch edit via CSV if faster)

**Wednesday (1.5 hrs):**
- [ ] Swap homepage hero images:
  - Remove Velvet Clutch hero
  - Add Crochet Figures and Compact Mirrors as hero images
  - Add headline text: "Hand-embroidered in Vietnam. One piece at a time."
  - Add sub-text: "Each item is 1 of 1 — once it's gone, it's gone."
- [ ] Add "New Arrivals" or "This Week's Drop" collection section to homepage

**Thursday (1.5 hrs):**
- [ ] Add artisan story section to homepage (copy from About Us page, condense to 2 paragraphs)
- [ ] Add "Find Us" section to homepage: West Palm Beach Antique & Flea Market + Kollective locations
- [ ] Move Velvet Clutches/Purses below the fold into "Signature Collection" section

### Phase 2: Theme Migration & Brand Polish (Week 3–5)

**Goal:** Migrate to Craft theme. Implement the full homepage section stack from the prototype.

#### Week 3: Theme Setup (6 hours)

**Monday (1.5 hrs):**
- [ ] Install Craft theme (free) as an unpublished theme
- [ ] Configure color scheme using design tokens from spec above
- [ ] Configure fonts: Cormorant Garamond (display) + Nunito Sans (body)

**Tuesday (1.5 hrs):**
- [ ] Set up Craft theme header:
  - Logo text: "Lena Handicrafts"
  - Navigation: match spec (5 items)
  - Announcement bar: "Free shipping over $70 | Next drop: Friday at 8 PM ET"
- [ ] Set up footer:
  - 4-column layout: Brand | Shop | About | Help
  - Remove "Powered by Shopify"
  - Add `hello@lenahandicrafts.com` (set up domain email first if possible)

**Wednesday (2 hrs):**
- [ ] Build homepage section stack in Craft theme customizer:
  1. Hero section (Image with Text overlay) — add lifestyle photo + headline + CTAs
  2. Trust strip (Rich text or custom Liquid section) — 3 icons
  3. Featured Collection: "This Week's Drop"
  4. Image with Text: Our Story block
  5. Collection list: 4 category tiles
  6. Rich text: Artisan Spotlight
  7. Multicolumn: Find Us In Person (3 columns)
  8. Newsletter section (dark background)

**Thursday (1 hr):**
- [ ] Preview theme on mobile — test all sections
- [ ] Fix any spacing/layout issues
- [ ] Publish theme (make it live)

#### Week 4: Product Photography Sprint (5 hours)

**Monday (2 hrs):**
- [ ] Set up photo station (white cloth, double lights, phone)
- [ ] Photograph top 15 products:
  - Each item: 1 front shot + 1 detail/close-up shot
  - Priority: Crochet Figures (5), Compact Mirrors (5), Hats (3), Headbands (2)

**Tuesday (1.5 hrs):**
- [ ] Edit photos (Shopify free editor or Canva):
  - Consistent white/linen background
  - Crop to consistent aspect ratio (4:5)
  - Light adjustment only — no heavy filters
- [ ] Upload photos to corresponding product listings

**Wednesday (1 hr):**
- [ ] Photograph next 10 products
- [ ] Upload and assign photos

**Thursday (30 min):**
- [ ] Review all live product photos for consistency
- [ ] Ensure every product has at least 1 photo

#### Week 5: Content Pages (5 hours)

**Monday (1.5 hrs):**
- [ ] Write and publish `/pages/our-story`:
  - Founder photo at top
  - Trip-back-to-Vietnam origin narrative (expand from About Us)
  - 2–3 artisan photos if available
  - "Women-owned. Handmade with love in Vietnam."

**Tuesday (1.5 hrs):**
- [ ] Write and publish `/pages/find-us`:
  - West Palm Beach Antique & Flea Market (every Saturday, 8:30 AM–1:30 PM)
  - Kollective Delray Beach (Atlantis Ave)
  - Kollective Fort Lauderdale (Las Olas Blvd)
  - Google Maps embed or link to directions
- [ ] Write and publish `/pages/care-instructions`

**Wednesday (1 hr):**
- [ ] Write and publish `/pages/drop-calendar`:
  - Explain the weekly drop model
  - "New pieces drop every Friday at 8 PM ET"
  - Newsletter signup CTA
- [ ] Update `/pages/shipping-returns`

**Thursday (1 hr):**
- [ ] Write and publish `/pages/faq`:
  - "Why is everything 1 of 1?"
  - "What happens if my item sells before I check out?"
  - "How do drops work?"
  - "Where do you sell in person?"
- [ ] Review all pages on mobile

### Phase 3: Email Marketing & Drop System (Week 6–8)

#### Week 6: Email Setup (5 hours)

**Monday (1.5 hrs):**
- [ ] Set up Shopify Email (or Klaviyo free tier)
- [ ] Create email signup popup (delayed 10 seconds):
  - Headline: "Be First to Shop Each Friday's Drop"
  - Sub: "Join the list and we'll email you 24 hours before the next drop goes live"
  - No discount offer — the value is access
- [ ] Add email signup to footer (should already be there from theme setup)

**Tuesday (1.5 hrs):**
- [ ] Design email template: "New This Week at Lena Handicrafts"
  - One-line greeting
  - 4–6 product images with names and prices
  - "Each piece is 1 of 1 — once it's gone, it's gone"
  - Footer: market schedule + social links

**Wednesday (1 hr):**
- [ ] Write first welcome email (auto-sent on signup)
- [ ] Write first drop preview email (template for weekly reuse)
- [ ] Send test email to yourself

**Thursday (1 hr):**
- [ ] Send first real email to any existing contacts/customers
- [ ] Set up tag system: tag new products with `drop-current` each week
  - Remove `drop-current` tag from previous week's products
  - This drives the "This Week's Drop" automated collection

#### Week 7: First Managed Drop (5 hours)

**Monday (1.5 hrs):**
- [ ] Photograph 15–20 new products for this week's drop
- [ ] Upload via batch CSV or Shopify duplicate method

**Tuesday (1 hr):**
- [ ] Tag all new products with `drop-current`
- [ ] Remove tag from last week's products
- [ ] Verify "This Week's Drop" collection shows correct items

**Wednesday (1.5 hrs):**
- [ ] Design QR code market event card (Canva):
  - Front: "Scan for more pieces → lenahandicrafts.com"
  - Back: "Join our Friday drop list — new pieces every week"
  - QR code links to: lenahandicrafts.com (or /pages/drop-calendar)
- [ ] Order printed cards (Vistaprint or local, ~$20 for 500)

**Thursday (1 hr):**
- [ ] Send drop preview email: "Tomorrow's drop preview"
- [ ] Friday: send "It's live" email at 8 PM
- [ ] Track: how many emails opened? How many products sold within 48 hrs?

#### Week 8: Refine & Optimize (5 hours)

**Monday (1 hr):**
- [ ] Review Week 7 drop performance:
  - Email open rate (target: 30%+)
  - Click-through rate (target: 5%+)
  - Products sold within 48 hrs of drop (target: 50%+)
- [ ] Adjust email timing, subject lines, or product selection based on results

**Tuesday (1.5 hrs):**
- [ ] Second batch upload (15–20 products)
- [ ] Continue weekly drop rhythm

**Wednesday (1 hr):**
- [ ] Set up Google Business Profile (free):
  - Business name: Lena Handicrafts
  - Category: Handmade goods store
  - Address: use market location or home city
  - Add photos, hours, website link
- [ ] Start handing out QR cards at every market event

**Thursday (1.5 hrs):**
- [ ] Write "What Sold Out This Week" email template (monthly, not weekly)
- [ ] Send second drop sequence (preview → live)

### Phase 4: Clearance & Season Prep (Week 9–12)

#### Week 9–10: Summer Clearance

- [ ] Launch sale: Velvet Clutch Compact 15% off
- [ ] Launch sale: Resin Wooden Hairpin 25% off
- [ ] Create bundle: Crochet Figure + Crochet Flower at 30% off
- [ ] Deep discount/giveaway: Passport Cover, Scrunchie, Snap Barrette
- [ ] Send clearance email to subscriber list
- [ ] Continue weekly drops

#### Week 11: Fall Ordering

- [ ] Place fall batch order with artisans:
  - Crochet Figures: 60+ units (heavy on $35–$42 range)
  - Compact Mirrors: 40+ units (Everyday + Letter)
  - Hats: 30+ units
  - Headbands: 40+ units (25 Alice Band)
- [ ] Do NOT reorder phased-out products
- [ ] Reduce Velvet Clutch orders by 50%+

#### Week 12: Review & Etsy Launch

- [ ] Set up Etsy shop with top 10 products
- [ ] Review all 12-week metrics against targets
- [ ] Set Q4 revenue goals
- [ ] Update plan for next quarter

---

## Daily Routine (Weekday Evenings, 30–45 min)

This adjusts your existing weekly routine to incorporate the website rebuild tasks.

### Monday — Inventory + Plan Task (45 min)
```
[15 min] Post-event cleanup:
  → Mark sold items in Shopify (set inventory to 0, keep listing visible)
  → Review weekend sales numbers

[30 min] Plan task from current phase:
  → Weeks 1–2: Catalog cleanup tasks
  → Weeks 3–5: Theme/content tasks
  → Weeks 6–8: Email/drop setup tasks
  → Weeks 9–12: Clearance/ordering tasks
```

### Tuesday — Listings + Photos (45 min)
```
[20 min] Photograph new products (batch of 5–10)
  → Quick setup: table, white cloth, both lights on
  → 1 front shot + 1 detail per item
  → Done when you've covered the week's new inventory

[25 min] Upload products:
  → Use Batch Uploader tool OR Shopify duplicate method
  → Add photos to listings
  → Tag with category + "drop-current" if this week's drop
```

### Wednesday — Marketing (30–45 min)
```
[30 min] Weekly email OR plan task:
  → If drop week: draft and schedule drop preview email
  → If non-drop week: work on current phase tasks
  → Alternate weeks: 1 social media post (photo + short caption)
```

### Thursday — Admin + Review (30 min)
```
[15 min] Business admin:
  → Check online orders → package and ship
  → Respond to customer messages
  → Plan which products to bring to weekend event

[15 min] Quick metrics check:
  → Shopify Analytics: weekly revenue, traffic, orders
  → Email stats: subscribers, open rate, clicks
  → Note any products running low
```

### Friday — Rest (or Drop Day)
```
  → If running a drop: send "It's live" email at 8 PM
  → Otherwise: save energy for Saturday market
```

### Saturday/Sunday — Market Event
```
  → Hand out QR cards to every customer
  → Sunday evening (30 min):
    → Mark sold items in Shopify
    → Quick-upload any new pieces for next week
```

---

## Weekly Review (15 min, Sunday night)

### Metrics Dashboard

| Metric | Where to Find | Week Target |
|--------|---------------|-------------|
| Online orders | Shopify Admin → Orders | 3+ |
| Online revenue | Shopify Analytics | $200+ (growing) |
| Event revenue | POS records | Track |
| Products listed | Count new uploads | 15–20 |
| Email subscribers | Shopify Email → Subscribers | Growing by 5+/week |
| Website traffic | Shopify Analytics → Online Store | 100+ sessions |
| Drop email open rate | Email platform stats | 30%+ |
| Drop sell-through | % of drop items sold within 48h | 50%+ |

### Weekly Questions

1. **What sold fastest this week?** (in-person and online)
2. **How many products did I list?** (target: 15–20)
3. **Did I send a drop email this week?** (target: yes, every week)
4. **Any online order conflicts?** (document and learn)
5. **Am I on track with the current phase?** (check tasks above)
6. **What's my #1 priority next week?**

### Phase Milestones (Am I On Track?)

| Week | Milestone | How to Verify |
|------|-----------|---------------|
| 2 | Homepage leads with crochet + mirrors, hidden products published | Visit site — Crochet Figures visible above fold |
| 3 | Craft theme live, navigation fixed | Visit site — clean nav, no "#MK" anywhere |
| 5 | All content pages published, 50+ products with photos | Shopify admin: 50+ active published products |
| 6 | Email signup live with popup + footer | Visit site — popup appears, footer has signup |
| 8 | 3 drop emails sent, subscribers > 50 | Email platform: 50+ subscribers, 3+ campaigns |
| 10 | Clearance sale running, slow movers discounted | Sale collection populated, email sent |
| 12 | Etsy live with 10+ listings, fall order placed | Etsy shop URL exists, order confirmation |

### Monthly Revenue Targets

| Month | Online Revenue Target | Why |
|-------|----------------------|-----|
| Month 1 (Jun) | $400 | Foundation fix + publishing hidden products |
| Month 2 (Jul) | $800 | Theme live, drop system running, email growing |
| Month 3 (Aug) | $1,500+ | Full system running, 200+ subscribers, weekly drops |

---

## Claude Code Implementation Notes

When using Claude Code to build Shopify theme customizations or generate Liquid templates, reference these specs:

### Key Files to Generate

1. **Custom CSS** — Port the design tokens and styles from `lena_prototype.html` into Shopify theme's `assets/custom.css`
2. **Product card snippet** — Override `snippets/product-card.liquid` to include:
   - "1 of 1" badge (always)
   - "New" badge (if product created ≤ 7 days ago)
   - Sold-out overlay with custom messaging
   - Category eyebrow from product type
   - Scarcity line
3. **Newsletter section** — Custom section with dark background, "Join the Drop List" copy
4. **Trust strip section** — Custom section with 3 icon columns
5. **Find Us section** — Custom section with 3 location cards
6. **Product page template** — Override to include:
   - "1 of 1" badge
   - Artisan attribution line
   - Scarcity messaging
   - Conflict disclaimer
   - Care instructions accordion
   - Cross-sell: "Other pieces in this week's drop"

### Liquid Template Variables

```liquid
{%- comment -%} Product card badges {%- endcomment -%}
{% assign is_new = product.created_at | date: '%s' | plus: 604800 %}
{% assign now = 'now' | date: '%s' %}

{% if product.available %}
  <span class="badge-1of1">1 of 1</span>
  {% if is_new > now %}
    <span class="badge-new">New</span>
  {% endif %}
{% else %}
  <div class="badge-sold">
    <span>This piece found its home</span>
  </div>
{% endif %}
```

### SEO Template

```
Title:    [Product Type] — [Design Name] | Handmade by Lena Handicrafts
URL:      /products/[auto-handle]
Meta:     Hand-embroidered [product type] featuring [design]. One-of-a-kind,
          handmade by Vietnamese artisans. Free shipping over $70.
Alt text: [Product title] — handmade [product type] by Lena Handicrafts
```

### Tag Taxonomy

```
CATEGORY TAGS (one per product):
  crochet-figure
  compact-mirror
  hat
  headband
  purse
  hair-tie
  hair-clip

DROP TAGS (rotated weekly):
  drop-current     ← add to this week's new products
  drop-2026-w22    ← permanent archive tag (optional)

STATUS TAGS:
  sale             ← clearance items
  featured         ← for manual homepage curation
  online-only      ← products not at markets
```

---

## Don'ts (from Research)

- **Don't** auto-rotate hero carousels — they hurt mobile conversion
- **Don't** hide sold-out items — they prove demand and build FOMO
- **Don't** copy Ganapati's mega-menu — too heavy for this catalog size
- **Don't** use a discount as newsletter incentive — the value proposition is access, not price
- **Don't** lower prices to clear inventory unless strategic (clearance items only)
- **Don't** add unnecessary Shopify apps — Notify Me + Shopify Email is enough to start
- **Don't** spend money on paid ads before email list hits 500+ subscribers
- **Don't** try to make social media + email + blog all at once — email only for now
