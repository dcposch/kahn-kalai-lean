/-
Copyright (c) 2026 Dan Clemens Posch. All rights reserved.
Released under the Apache License, Version 2.0; see LICENSE.
Authors: Dan Clemens Posch
-/
import Mathlib

/-!
# Kahn–Kalai / Park–Pham (Tran–Vu covering form)

For a family `F` of subsets of a finite ground set `X`, write `generate F`
for the upset of supersets of members of `F` (Tran–Vu’s `⟨F⟩`). The product
measure `μ_p` is the law of a `p`-random subset of `X`. The threshold
`threshold F` is the infimum of those `p ∈ [0,1]` with `μ_p(generate F) ≥ 1/2`.
The cost of a cover `G` is `∑_{S ∈ G} p^|S|`; `coverCost p F` is the infimum
of that cost over families `G` that cover `F`, and `expectationThreshold F`
is the supremum of `p ∈ [0,1]` at which this infimum is still `≤ 1/2`
(Tran–Vu’s `q(F)`).

`covering_theorem` is Tran–Vu, EJC 31(3) #P3.2 (2024), Theorem 2.3, with
their explicit constant `L = 1000` and base-2 logarithm. `park_pham` is
their Theorem 1.1 (Park–Pham / Kahn–Kalai): some absolute `K` satisfies
`p_c(F) ≤ K q(F) log ℓ` for every `ℓ`-bounded family with `ℓ ≥ 2`.

This file is the audited statement surface. Definitions that appear in a
compared theorem type are repeated in `Solution.lean`.
-/

open Finset

namespace KahnKalai

variable {α : Type*} [DecidableEq α] [Fintype α]

/-- Product measure of a single subset: `p^|S| (1-p)^{N-|S|}`. -/
def measure (p : ℝ) (S : Finset α) : ℝ :=
  p ^ S.card * (1 - p) ^ (Fintype.card α - S.card)

/-- Product measure of a family. -/
def measureFamily (p : ℝ) (F : Finset (Finset α)) : ℝ :=
  ∑ S ∈ F, measure p S

/-- Tran–Vu’s `⟨F⟩`: subsets of the ground set that contain some member of `F`. -/
def generate (F : Finset (Finset α)) : Finset (Finset α) :=
  univ.filter fun T => ∃ S ∈ F, S ⊆ T

/-- `G` covers `F` if every member of `F` contains some member of `G`. -/
def Covers (G F : Finset (Finset α)) : Prop := F ⊆ generate G

/-- Expectation `∑_{S ∈ G} p^|S|`. -/
def expectation (p : ℝ) (G : Finset (Finset α)) : ℝ :=
  ∑ S ∈ G, p ^ S.card

/-- Minimum expectation of a cover of `H` (Tran–Vu’s cost `f(H)` at `p`). -/
noncomputable def coverCost (p : ℝ) (H : Finset (Finset α)) : ℝ :=
  sInf ((fun G : Finset (Finset α) => expectation p G) '' {G | Covers G H})

/-- `p_c(F)`: infimum of `p ∈ [0,1]` with `μ_p(⟨F⟩) ≥ 1/2`. -/
noncomputable def threshold (F : Finset (Finset α)) : ℝ :=
  sInf {p : ℝ | p ∈ Set.Icc 0 1 ∧ 1 / 2 ≤ measureFamily p (generate F)}

/-- `q(F)`: supremum of `p ∈ [0,1]` at which some cover still has expectation `≤ 1/2`. -/
noncomputable def expectationThreshold (F : Finset (Finset α)) : ℝ :=
  sSup {p : ℝ | p ∈ Set.Icc 0 1 ∧ coverCost p F ≤ 1 / 2}

/-- Every member of `F` has cardinality at most `ℓ`. -/
def IsBounded (F : Finset (Finset α)) (ℓ : ℕ) : Prop :=
  ∀ S ∈ F, S.card ≤ ℓ

/-- Tran–Vu’s covering constant `L = 1000`. -/
def coveringConstant : ℝ := 1000

/-- Level `m_ℓ = ⌊L p N log₂(ℓ+1)⌋` in the covering theorem. -/
noncomputable def coveringLevel (p : ℝ) (N ℓ : ℕ) : ℕ :=
  ⌊coveringConstant * p * N * Real.logb 2 (ℓ + 1 : ℝ)⌋₊

/-- **Tran–Vu, Theorem 2.3.** If `H` is `ℓ`-bounded and
`f(H) ≥ 1/2 - 2^{-(ℓ+2)}`, then `⟨H⟩` contains at least a
`2/3 + 2^{-(ℓ+2)}` fraction of the `m_ℓ`-level. -/
theorem covering_theorem {α : Type*} [DecidableEq α] [Fintype α]
    (H : Finset (Finset α)) (ℓ : ℕ) (p : ℝ)
    (hℓ : ℓ ≤ Fintype.card α)
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (hb : IsBounded H ℓ)
    (hf : (1 : ℝ) / 2 - 1 / (2 : ℝ) ^ (ℓ + 2) ≤ coverCost p H) :
    ((2 : ℝ) / 3 + 1 / (2 : ℝ) ^ (ℓ + 2)) *
        ((Fintype.card α).choose (coveringLevel p (Fintype.card α) ℓ) : ℝ) ≤
      (((generate H).filter
          (fun S => S.card = coveringLevel p (Fintype.card α) ℓ)).card : ℝ) := by
  sorry

/-- **Park–Pham / Kahn–Kalai** (Tran–Vu, Theorem 1.1). There is an absolute
constant `K` such that every `ℓ`-bounded family with `ℓ ≥ 2` satisfies
`p_c(F) ≤ K q(F) log₂ ℓ`. -/
theorem park_pham :
    ∃ K : ℝ, 0 < K ∧
      ∀ {α : Type} [DecidableEq α] [Fintype α]
        (F : Finset (Finset α)) (ℓ : ℕ),
        2 ≤ ℓ → IsBounded F ℓ →
        threshold F ≤ K * expectationThreshold F * Real.logb 2 (ℓ : ℝ) := by
  sorry

end KahnKalai
