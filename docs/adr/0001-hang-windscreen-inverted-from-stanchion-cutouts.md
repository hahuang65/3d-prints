# ADR 0001 — Hang the windscreen inverted, from its stanchion triangular cutouts

**Status:** Accepted · 2026-07-06

## Context

We need a garage wall mount for a removed Caterham Seven (420R S3) windscreen:
~5 kg of curved laminated glass in an aluminium frame, carried on two flat steel
stanchions that stay bolted to the frame in storage. The candidate load paths:

1. **Cradle the aluminium frame** — a shelf/hook under the frame's edge.
2. **Grip/pad the glass** directly.
3. **Use the stanchion foot bolt-holes** — hang on pegs through the existing
   bolt holes.
4. **Use the stanchion triangular cutouts** — the triangular lightening-hole in
   each stanchion foot.

Constraints that shaped the choice: keep all load off the glass and frame; a
single non-handed printed part the user can mount at arbitrary spacing; and a
plasterboard wall (studs only where they happen to fall).

## Decision

Hang the screen **inverted** (stanchions up), **flat against the wall**, from the
two **triangular cutouts**. The cutouts face *perpendicular* to the wall, so each
stanchion projects straight out from the wall; the bracket therefore **turns
90°** — an arm out from the wall, then a **sideways cylindrical peg** through the
cutout. The inverted screen's cutout drops over the peg and hangs on it. The peg
is tilted up slightly and carries a **slightly larger-diameter collar at its
outer end** (a lip) that the resting cutout edge must climb to slide off, so the
screen stays put — with no load on the glass. **One symmetric bracket, printed twice**, mounted at
whatever spacing the stanchions land at.

## Consequences

**Positive**
- Zero load on the glass or frame — the steel stanchions carry everything, as on
  the car.
- The screen leans flat on the wall, which reacts the horizontal tipping load;
  each arm carries ~2.5 kg vertically.
- Simple cylindrical peg with a larger-diameter end collar; single non-handed
  part; arbitrary bracket spacing; plasterboard-friendly load.

**Trade-offs / negatives**
- The cutout faces perpendicular to the wall, so the peg sits out from the wall
  by the stanchion's projection: each arm is a **cantilever in bending**, not
  pure shear, and needs a gusseted L-profile with a bending-resistant print
  orientation.
- A round peg does not self-centre the way a matched wedge would; the screen has
  a little sideways play on the peg, capped by the end collar — accepted for
  simpler modelling and printing.
- Uses the stanchion's lightening cutout as a structural bearing. Fine for steel
  on a padded printed wedge, but it is not what the hole was designed for.
- The screen must be **inverted** to mount — a deliberate two-hand job with a
  5 kg glass part, not a one-handed grab-and-go.
- Glass faces the wall: protected, but not on display.
- The wedge is sized to this stanchion's ~3″×3″ cutout; other Sevens' stanchions
  may differ (mitigated by keeping the SCAD parametric).

**Rejected alternatives**
- *Frame cradle* — contacts the frame/glass and is bulkier.
- *Glass grip* — puts clamping load on the fragile part.
- *Bolt-hole pegs* — the screen would hang at whatever angle the bolt-hole axis
  dictates, likely awkward, and needs tighter tolerance than a peg in the cutout.
- *Matched nesting wedge* — self-centring, but simplified to a plain cylindrical
  peg plus an end collar to make the model and the print trivial.
