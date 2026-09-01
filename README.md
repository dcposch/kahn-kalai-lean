# Kahn–Kalai / Park–Pham (Tran–Vu)

Lean 4 formalization of the expectation-threshold theorem: for an
`ℓ`-bounded family `F`,

\[
p_c(\mathcal{F})=O\bigl(q(\mathcal{F})\log\ell\bigr).
\]

The proof follows Tran–Vu, *A Short Proof of Kahn-Kalai Conjecture*,
[EJC 31(3) #P3.2 (2024)](https://doi.org/10.37236/12266)
([arXiv:2303.02144](https://arxiv.org/abs/2303.02144)). Park–Pham’s original
argument is [arXiv:2203.17207](https://arxiv.org/abs/2203.17207).

This is a Palomar project. Submissions go to
<https://submit.palomar-registry.org/>.

## Repository map

- `Challenge.lean` — audited statements: `covering_theorem` (Tran–Vu 2.3)
  and `park_pham` (Tran–Vu 1.1).
- `Solution.lean` — the same declarations, proved.
- `KahnKalai/` — lemmas. `*Scratch.lean` files are isolated gates, not
  default Lake targets.
- `sources/` — Tran–Vu and Park–Pham PDFs.
- `scripts/lean_verify.sh` — local `--file` / `--receipt-only` gate,
  patterned on `jc2-lean/max11-partial-y/scripts/box_lean_verify.sh`
  (no AWS box).
- `comparator.json`, `formalization.yaml` — Palomar metadata.

## Verify

```sh
lake build Challenge Solution KahnKalai
./scripts/lean_verify.sh --full
./scripts/lean_verify.sh --file SomeScratch.lean --receipt-only
./scripts/check_axioms.sh
```

Lean 4.32.0, Mathlib v4.32.0. Forbidden: `native_decide`, `Lean.ofReduceBool`.
Permitted axioms: `propext`, `Classical.choice`, `Quot.sound`.
