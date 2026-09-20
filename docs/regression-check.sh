#!/usr/bin/env bash
#
# Regression check for the Lena Craft theme.
#
# Run it after every batch of changes, before committing:
#
#     bash docs/regression-check.sh
#
# It is deliberately made of commands, not of remembered numbers. Every count it
# prints is produced on the spot, so this file cannot go stale the way a table of
# line numbers does.
#
# Exit code 0 = everything asserted below still holds. Non-zero = something broke.
#
# WHY A SCRIPT AND NOT A CHECKLIST: a theme has no build step and no unit tests, so
# the only things that can be checked without a browser are (a) the theme linter,
# (b) files still parsing, and (c) one grep per fixed bug that fails if the bug ever
# comes back. Section 3 below is that last part, and it grows by one block per
# DEVLOG entry. A bug with a line in section 3 cannot silently return.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

FAIL=0
pass() { printf '  \033[32mok\033[0m   %s\n' "$1"; }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; FAIL=1; }

# The Shopify CLI ships a shebang pointing at Homebrew's node, which is not the node
# installed here. Calling the real script through the nvm node is the documented
# workaround; see the shopify-cli-broken-shebang memory.
NODE_BIN="$(ls -d "$HOME"/.nvm/versions/node/*/bin 2>/dev/null | tail -1)"
[ -n "$NODE_BIN" ] && export PATH="$NODE_BIN:$PATH"
SHOPIFY_JS="$(readlink -f "$(command -v shopify 2>/dev/null)" 2>/dev/null)"

echo
echo "1. Theme linter"
echo "---------------"
if [ -n "$SHOPIFY_JS" ] && [ -f "$SHOPIFY_JS" ]; then
  OUT="$(node "$SHOPIFY_JS" theme check --fail-level error 2>&1)"
  if [ $? -eq 0 ]; then
    pass "$(echo "$OUT" | grep -o '[0-9]* files inspected.*' | head -1)"
  else
    fail "theme check reported errors"
    echo "$OUT" | tail -40
  fi
else
  fail "shopify CLI not found - linter skipped"
fi

echo
echo "2. Every JSON template still parses"
echo "-----------------------------------"
# Shopify JSON templates carry a /* */ comment header that json.loads rejects, so it
# is stripped first. A template that stops parsing takes its whole page down.
for f in templates/*.json sections/*-group.json config/settings_data.json; do
  [ -f "$f" ] || continue
  if python3 -c "
import json,re,sys
json.loads(re.sub(r'/\*.*?\*/','',open('$f').read(),flags=re.S))
" 2>/dev/null; then
    pass "$f"
  else
    fail "$f does not parse"
  fi
done

echo
echo "3. Fixed bugs that must not come back"
echo "-------------------------------------"
# One assertion per DEVLOG entry. Each states the condition that was TRUE after the
# fix, so a regression turns it red.

assert_grep() {   # assert_grep <description> <pattern> <file>
  if grep -q "$2" "$3"; then pass "$1"; else fail "$1"; fi
}
assert_no_grep() { # assert_no_grep <description> <pattern> <file>
  if grep -q "$2" "$3"; then fail "$1"; else pass "$1"; fi
}
assert_count() { # assert_count <description> <pattern> <file> <expected count>
  local n; n="$(grep -c "$2" "$3")"
  if [ "$n" = "$4" ]; then pass "$1"; else fail "$1 (found $n, expected $4)"; fi
}
assert_single_source() { # assert_single_source <description> <pattern> <expected file>
  # The pattern must appear in exactly one file under sections/ and snippets/, and that
  # file must be the one named. This is what stops a rule being copied back out again.
  local found
  found="$(grep -rl "$2" sections/ snippets/ 2>/dev/null | sort | tr '\n' ' ' | sed 's/ $//')"
  if [ "$found" = "$3" ]; then pass "$1"; else fail "$1 (found in: ${found:-nothing})"; fi
}

# Batch 1 - collection page empty states (DEVLOG 2026-09-20)
assert_grep "filtered-to-zero shows 'No products found' + remove-all link" \
  "use_fewer_filters_html" sections/main-collection-product-grid.liquid
assert_grep "the filtered empty state is gated on all_products_count, not products.size" \
  "if collection.all_products_count > 0" sections/main-collection-product-grid.liquid
assert_grep "the collection banner still has its <h1>" \
  "collection-hero__title" sections/main-collection-banner.liquid
assert_no_grep "the banner's <h1> is not gated on a product count" \
  "if collection.all_products_count > 0" sections/main-collection-banner.liquid

# Batch 2 - one source for the inventory rule (DEVLOG 2026-09-20)
assert_no_grep "card-product holds no quantity variable to read out of scope" \
  "lena_qty" snippets/card-product.liquid
assert_no_grep "lena-featured-piece holds no quantity variable either" \
  "fp_qty" sections/lena-featured-piece.liquid
for cls in lena-badge-1of1 lena-pdp-badge-1of1 lena-fp-badge \
           lena-scarcity lena-pdp-scarcity lena-fp-scarcity; do
  assert_single_source "$cls is written only in lena-stock" "$cls" snippets/lena-stock.liquid
done
assert_single_source "the Notify Me button is built in only one place" \
  'onclick="window.lenaNotify(' snippets/lena-notify-button.liquid
assert_grep "...and the function it calls is still defined by the modal" \
  "window.lenaNotify = " snippets/lena-notify-modal.liquid

# Batch 3 - facets (DEVLOG 2026-09-20)
assert_no_grep "no facet pill falls back to the raw tag value" \
  "default: value.label" snippets/facets.liquid
assert_count "all four active-filter pills use the shared snippet" \
  "render 'lena-facet-pill'" snippets/facets.liquid 4
assert_single_source "the pill's label line is written in exactly one place" \
  "filter.label | escape }}:" snippets/lena-facet-pill.liquid
assert_count "both checkbox lists skip a filter with no visible values" \
  "render 'lena-facet-visible'" snippets/facets.liquid 2
assert_grep "the empty-fieldset guard still spares price_range filters" \
  "filter.type == 'boolean' or filter.type == 'list'" snippets/facets.liquid

# Batch 4 - nav depth, a dangling aria reference, an empty Find Us (DEVLOG 2026-09-20)
for f in snippets/header-dropdown-menu.liquid snippets/header-drawer.liquid \
         snippets/header-mega-menu.liquid; do
  assert_count "$(basename "$f" .liquid) guards all three menu depths" \
    "render 'lena-hide-nav-link'" "$f" 3
done
assert_single_source "the nav-hiding rule is written once" \
  "link.object.handle == 'new-arrivals'" snippets/lena-hide-nav-link.liquid
assert_no_grep "the card link no longer names an emptied badge span" \
  'aria-labelledby="CardLink-{{ section_id }}-{{ card_product.id }} Badge-' snippets/card-product.liquid
assert_grep "Find Us hides itself when nothing is visible" \
  "if visible_count > 0" sections/lena-find-us.liquid

# Batch 5 - Spotlight rotation (DEVLOG 2026-09-20)
assert_grep "Spotlight seeds its rotation off days since the epoch" \
  "assign spot_days = 'now' | date: '%s'" sections/lena-spotlight.liquid
assert_no_grep "Spotlight no longer seeds off the calendar week number" \
  "assign week_num" sections/lena-spotlight.liquid
assert_no_grep "Spotlight draws a dot for every article, not just the first six" \
  "blog.articles limit: 6" sections/lena-spotlight.liquid

# Batch 6 - a mobile rule that never applied, and a dead-code sweep (DEVLOG 2026-09-20)
assert_grep "the mobile Find Us override can out-specify the [data-cards] rules" \
  "lena-find-grid\[data-cards\] { grid-template-columns: 1fr; }" assets/lena-custom.css
assert_count "that override is declared once, not once per breakpoint" \
  "lena-find-grid\[data-cards\] {" assets/lena-custom.css 1
assert_no_grep "the popup no longer guards a value that cannot be empty" \
  "form.action ||" sections/lena-email-popup.liquid

# Batch 7 - shared modal behaviour (DEVLOG 2026-09-20)
assert_grep "the shared modal module exists" "window.LenaModal = " assets/lena-modal.js
assert_grep "the scroll lock is a shared count, not a raw assignment per dialog" \
  "openCount" assets/lena-modal.js
assert_grep "theme.liquid loads the module, deferred" \
  "lena-modal.js" layout/theme.liquid
for f in sections/lena-email-popup.liquid snippets/lena-notify-modal.liquid; do
  n="$(basename "$f" .liquid)"
  assert_no_grep "$n does not keep its own focus trap" "trapTab" "$f"
  assert_no_grep "$n does not keep its own focusable() query" "focusable" "$f"
  assert_no_grep "$n does not write body overflow directly" "body.style.overflow" "$f"
  assert_grep "$n waits for DOMContentLoaded so the module is loaded first" \
    "DOMContentLoaded" "$f"
done

# Batch 8 - documentation that had stopped being true (DEVLOG 2026-09-20)
# These assert the CORRECTIONS hold, not that prose is beautiful. A doc claim that can be
# checked by grep should be.
assert_no_grep "ARCHITECTURE.md no longer claims a fixed stylesheet length" \
  "lena-custom.css\`, 1018 lines" ARCHITECTURE.md
assert_no_grep "ARCHITECTURE.md no longer documents the removed countdown as current" \
  "Countdown:" ARCHITECTURE.md
found_dead="$(grep -rl "lena-pdp-cat\|lena-countdown-pill" assets/ sections/ snippets/ 2>/dev/null | tr '\n' ' ')"
if [ -z "$found_dead" ]; then
  pass "the selectors ARCHITECTURE.md records as removed are really gone from the code"
else
  fail "removed selectors are back in: $found_dead"
fi
assert_grep "ARCHITECTURE.md points at the real colour-facet file" \
  "lena-color-facet.liquid" ARCHITECTURE.md
assert_no_grep "OPEN_ITEMS has no command left that greps facets.liquid for the old name" \
  'lena_color_whitelist" snippets/facets.liquid' docs/OPEN_ITEMS.md
assert_no_grep "CLAUDE.md no longer lists signature-purses as a canonical category" \
  "ribbon-embroidery-hats\`, \`signature-purses" CLAUDE.md
# The canonical list has exactly one home; CLAUDE.md must point at it rather than restate it.
assert_grep "CLAUDE.md points at the canonical handle list instead of copying it" \
  "lena-category-handles.liquid" CLAUDE.md

echo
if [ "$FAIL" -eq 0 ]; then
  printf '\033[32mAll checks passed.\033[0m\n'
else
  printf '\033[31mSomething failed - see above.\033[0m\n'
fi
echo
echo "Still needs a real browser (this script cannot see any of it):"
echo "  - layout at 640px and 900px"
echo "  - text rendering as literal escape characters"
echo "  - a control that is missing rather than wrong"
echo
exit "$FAIL"
