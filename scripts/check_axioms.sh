#!/bin/sh
# Verify that the Solution theorems depend only on the three permitted axioms:
#   propext, Classical.choice, Quot.sound
set -eu
cd "$(dirname "$0")/.."

OUT="$(printf 'import Solution\n#print axioms KahnKalai.covering_theorem\n#print axioms KahnKalai.park_pham\n' \
  | lake env lean --stdin 2>&1)" || {
  echo "$OUT"
  echo "FAIL: could not elaborate the probe (build first: lake build)"
  exit 1
}
echo "$OUT"

for thm in KahnKalai.covering_theorem KahnKalai.park_pham; do
  LINE="$(echo "$OUT" | grep "'$thm' depends on axioms" || true)"
  if [ -z "$LINE" ]; then
    echo "FAIL: no axiom report for $thm"
    exit 1
  fi
  BAD="$(echo "$LINE" | sed -e "s/.*axioms: \\[//" -e "s/\\]//" -e "s/,/\\n/g" \
    | tr -d ' ' | grep -v -E '^(propext|Classical\.choice|Quot\.sound)$' || true)"
  if [ -n "$BAD" ]; then
    echo "FAIL: $thm depends on non-permitted axioms: $BAD"
    exit 1
  fi
done
echo "OK: covering_theorem and park_pham depend only on permitted axioms."
