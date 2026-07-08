# Caterham Windscreen Hanger — Tasks

Source PRD: [prd.md](./prd.md) · Rationale: [ADR-0001](../../adr/0001-hang-windscreen-inverted-from-stanchion-cutouts.md)

Each slice is a thin cut through the whole product pipeline — parametric source →
STL → render → catalog — so every slice ends in something you can *look at* (a
fresh Catppuccin Mocha render) or, for the last one, hold. There are no automated
tests: per the PRD, verification is the shared render (a clean CGAL render also
proves the geometry is manifold and printable) plus a physical print-fit.

## Status

- **S1–S6: ✅ Complete** — `Caterham Windscreen Hanger/` built end-to-end
  (`windscreen_hanger.scad` + `.stl` + `render.conf` + `render.png` + `README.md`,
  added to the root index). CGAL render is manifold (`Simple: yes`); bounding box
  58 × 49 × 96 mm fits the bed.
- **S7: ⏳ Pending (HITL)** — physical print-fit against the real stanchion; needs
  a printed part and the car.
- **Design note (S3):** the up-tilt was **dropped** to keep the part genuinely
  non-handed — an up-tilt plus room-facing countersinks can't both survive the
  flip that serves the opposite stanchion. The **collar** is now the sole
  retention feature. Overrule if you'd rather keep the tilt (it makes the part
  handed / needs a mirrored second print).

---

## Slice 1: Tracer — a rough bracket through the whole pipeline

**Type:** AFK
**Blocked by:** None — can start immediately
**User stories covered:** 6, 13, 14 (and stubs 1, 2)
**Test surface:** The shared render pipeline — a successful CGAL render of the new product folder, producing `render.png`; bounding box within a ~256 mm bed.

### What to build

Stand up the new **Caterham Windscreen Hanger** product folder following the
repo's product convention, with a parametric source that produces the *simplest
recognisable* bracket: a flat wall plate, an arm projecting out from the wall,
the 90° turn, and a plain cylindrical **peg** stub — no fixing holes, collar, or
gusset yet. Wire up the whole chain end-to-end: a `render.conf` sidecar (Catppuccin
Mocha, ¾ view, bold edge outline) driving the shared render script, a generated
render, a stub README, and a one-line entry in the root catalog index. The part
is symmetric about its mid-plane from the outset (non-handed).

### Acceptance criteria

- [ ] New product folder exists with a parametric source, an exported STL, a `render.conf`, a `render.png`, a stub README, and a root-index entry
- [ ] The render shows a recognisable L-bracket: wall plate → arm → 90° turn → cylindrical peg
- [ ] The part is symmetric about its vertical mid-plane (one non-handed piece, printed twice)
- [ ] CGAL render succeeds (manifold) and the bounding box fits a ~256 mm bed

---

## Slice 2: The engagement peg

**Type:** AFK
**Blocked by:** Slice 1
**User stories covered:** 2, 4, 11
**Test surface:** Render pipeline — a render (optionally with a ghosted stanchion cutout) showing the peg sized and placed to drop through the cutout; parametric re-render after changing peg/cutout values.

### What to build

Turn the stub peg into the real **peg**: a sideways cylinder, sized to drop
freely through the ~76 × 76 mm triangular cutout and let the cutout's top edge
rest on it, reaching ~38 mm out from the wall and pointing inward. Expose the
governing dimensions as top-level parameters — cutout base and height, peg
diameter, peg-to-cutout clearance, and arm reach — so a re-measure is a one-line
edit.

### Acceptance criteria

- [ ] Peg diameter, cutout base/height, peg clearance, and arm reach are top-level parameters
- [ ] Peg reaches ~38 mm out and passes through where the cutout sits; a render (with a ghost cutout) shows it dropping in with clearance
- [ ] Changing the cutout parameters visibly resizes/repositions the engagement on re-render
- [ ] CGAL render stays manifold

---

## Slice 3: Retention — up-tilt and end collar

**Type:** AFK
**Blocked by:** Slice 2
**User stories covered:** 5
**Test surface:** Render pipeline — a render showing the peg tilted up and the larger-diameter collar on its outer end; parametric re-render after changing tilt/collar values.

### What to build

Add the two retention features to the peg: a slight upward tilt (~5–10°) so the
screen settles inward, and a **collar** — the outer ~5 mm stepped up to a
slightly larger diameter — that the resting cutout edge must climb to slide off.
Expose peg tilt angle, collar diameter, and collar length as parameters. Mind the
CGAL coplanar-subtraction gotcha at the peg/collar step (overshoot any cut faces).

### Acceptance criteria

- [ ] Peg tilt, collar diameter, and collar length are top-level parameters
- [ ] The render clearly shows the up-tilt and the stepped collar at the peg's outer end
- [ ] The collar diameter is larger than the peg but still drops through the cutout
- [ ] CGAL render stays manifold (no zero-thickness skin at the collar step)

---

## Slice 4: Wall-plate fixing pattern

**Type:** AFK
**Blocked by:** Slice 1
**User stories covered:** 7, 8
**Test surface:** Render pipeline — a render of the wall plate showing the countersunk spread hole pattern; manifold render with the holes subtracted.

### What to build

Flesh out the flat wall plate with a spread, countersunk screw/anchor hole
pattern: a hole positioned to catch a stud where one falls, plus outer holes
sized for toggle/butterfly anchors in bare plasterboard. Expose plate dimensions
and the hole pattern as parameters. Watch the coplanar-subtraction / CGAL
manifold gotcha — overshoot the countersink and through-hole cuts past both
faces so no zero-thickness skin remains.

### Acceptance criteria

- [ ] Plate dimensions and the screw/anchor hole pattern are top-level parameters
- [ ] The render shows countersunk holes: one placed for a stud, plus toggle-anchor holes
- [ ] Holes are cleanly subtracted — CGAL render is manifold with no coplanar skin
- [ ] The plate stays flat (single face against the wall)

---

## Slice 5: Gusset and print-readiness

**Type:** AFK
**Blocked by:** Slices 3, 4
**User stories covered:** 10, 12, 14
**Test surface:** Render pipeline — final CGAL render (manifold) of the complete part; bounding box within a ~256 mm bed; exported STL opens cleanly in a slicer with no supports needed.

### What to build

Bring the full geometry together: add a modest **gusset** at the 90° corner so the
short cantilever resists bending, and settle the print orientation so the corner
is strong (layers not peeling under load) and no supports are required. Confirm
the complete part is a clean manifold, fits a ~256 mm bed, and export the
final STL. Note PETG and the chosen orientation for the README to pick up.

### Acceptance criteria

- [ ] A gusset braces the 90° corner; the complete part renders as one manifold solid
- [ ] Chosen print orientation needs no supports and keeps the corner strong in bending
- [ ] Bounding box fits a ~256 mm bed; final STL exported
- [ ] Final Mocha render regenerated and looks right

---

## Slice 6: README and catalog index

**Type:** AFK
**Blocked by:** Slice 5
**User stories covered:** 2, 3, 9, 10, 13
**Test surface:** Documentation review — README follows the repo's product-README shape; the root index entry renders with the final image.

### What to build

Write the full product README in the repo's house style: what it is and how it
hangs (inverted, by the stanchions), a BOM/mount table (screws + toggle anchors,
PETG, print notes — orientation and no supports), a dimensions table keyed off
the final geometry, and the CC BY-NC 4.0 license line. Finalise the root catalog
index entry with the final render and blurb, placed in the existing alphabetical
order.

### Acceptance criteria

- [ ] README covers description, BOM/mount (screws + anchors), material (PETG), print notes, dimensions, and license — matching the other products' shape
- [ ] Mounting guidance names the stud-vs-toggle fixing choice
- [ ] Root index shows the hanger with its final render, in alphabetical position
- [ ] All internal links (source, STL, README, license) resolve

---

## Slice 7: Print-fit validation

**Type:** HITL — requires a physical print and the actual stanchion
**Blocked by:** Slice 5
**User stories covered:** 1, 2, 4, 5, 9
**Test surface:** Physical print-fit — a printed bracket offered up to the real stanchion cutout.

### What to build

Print one bracket in PETG and offer it up to the actual **stanchion**: confirm the
triangular cutout drops over the peg, the screen hangs cleanly with load on steel
only, the collar retains it against a nudge, and the bracket clears the glass and
frame. If anything is off, adjust the relevant parameters (peg diameter, clearance,
tilt, collar) and re-export before printing the second and mounting.

### Acceptance criteria

- [ ] The printed cutout drops over the peg and hangs without fouling the glass or frame
- [ ] The collar noticeably resists the stanchion walking off the peg
- [ ] Any fit correction is captured as a parameter change and re-exported
- [ ] Confirmed good before printing the second bracket
