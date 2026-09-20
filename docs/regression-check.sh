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

# Batch 1 - collection page empty states (DEVLOG 2026-09-20)
assert_grep "filtered-to-zero shows 'No products found' + remove-all link" \
  "use_fewer_filters_html" sections/main-collection-product-grid.liquid
assert_grep "the filtered empty state is gated on all_products_count, not products.size" \
  "if collection.all_products_count > 0" sections/main-collection-product-grid.liquid
assert_grep "the collection banner still has its <h1>" \
  "collection-hero__title" sections/main-collection-banner.liquid
assert_no_grep "the banner's <h1> is not gated on a product count" \
  "if collection.all_products_count > 0" sections/main-collection-banner.liquid

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
