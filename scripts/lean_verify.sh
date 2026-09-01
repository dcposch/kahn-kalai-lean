#!/usr/bin/env bash
# Local isolated Lean gate.
# Patterned on jc2-lean/max11-partial-y/scripts/box_lean_verify.sh
# (--file, --receipt-only, fail-closed) but compiled with local lake.
# Do not point this at the Jacobian AWS box.
set -euo pipefail
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

receipt_dir=".receipts"
mkdir -p "$receipt_dir"

usage() {
  echo "usage: $0 [--full | --file FILE.lean [--receipt-only]]" >&2
  exit 2
}

receipt_only=0
full_build=0
lean_file=""

while (($#)); do
  case "$1" in
    --full) full_build=1 ;;
    --receipt-only) receipt_only=1 ;;
    --file)
      shift
      (($#)) || usage
      lean_file="$1"
      ;;
    --help|-h) usage ;;
    *) usage ;;
  esac
  shift
done

if ((full_build)); then
  if [[ -n "$lean_file" || "$receipt_only" -eq 1 ]]; then
    echo "--full cannot be combined with --file or --receipt-only" >&2
    exit 2
  fi
  lake build Challenge Solution KahnKalai
  echo "OK: lake build Challenge Solution KahnKalai"
  exit 0
fi

[[ -n "$lean_file" ]] || usage
[[ "$lean_file" =~ ^[A-Za-z0-9_./-]+\.lean$ ]] || {
  echo "invalid Lean file name: $lean_file" >&2
  exit 2
}
[[ -f "$lean_file" ]] || {
  echo "missing file: $lean_file" >&2
  exit 2
}

sha256_file() {
  local digest
  digest="$(openssl dgst -sha256 -r "$1")"
  printf '%s\n' "${digest%% *}"
}

digest="$(sha256_file "$lean_file")"
receipt="$receipt_dir/${digest}.ok"

if [[ -f "$receipt" ]]; then
  echo "RECEIPT_HIT $digest $lean_file"
  exit 0
fi

if ((receipt_only)); then
  echo "RECEIPT_MISS $digest $lean_file" >&2
  exit 3
fi

lake env lean "$lean_file"
printf 'ok\nfile: %s\nsha256: %s\n' "$lean_file" "$digest" > "$receipt"
echo "RECEIPT_WRITE $digest $lean_file"
