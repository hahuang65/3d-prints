# Caterham Windscreen Hanger — PRD

## Problem Statement

When the owner removes the **windscreen** from their **Caterham Seven** 420R S3
— for a track day, or just to store it — they are left holding a ~5 kg assembly
of curved laminated glass in an aluminium frame, with two steel **stanchions**
still bolted on. There is nowhere good to put it. On the garage floor it is
underfoot and easily knocked or scratched; leaning it against a wall risks the
glass and the frame. Commercial racks are scarce, and a DIY timber rack is bulky
and still tends to bear on the frame or glass.

## Solution

A pair of identical 3D-printed wall brackets that carry the **windscreen** by its
two **stanchions** — the strong steel parts designed to take its full weight —
so no load ever touches the glass or frame. The screen hangs **inverted**
(stanchions up) and flat against the wall. Because the triangular cutouts face
*perpendicular* to the wall, each **stanchion** projects straight out from the
wall and the bracket **turns 90°** — an **arm** out from the wall, then a
sideways **cylindrical peg** through the cutout that the screen hangs on, with a
larger-diameter collar at the peg's outer end to keep it from sliding off. Each
braced arm carries ~2.5 kg as a short **cantilever** in bending; the screen leans
flat on the wall, which reacts the horizontal tipping. The
part is one symmetric, non-handed bracket the owner prints twice and mounts at
whatever spacing their stanchions land at. See **ADR-0001** for why this hanging
scheme was chosen over cradling the frame, gripping the glass, or using the
stanchion bolt-holes.

## User Stories

1. As a Caterham owner, I want to store my removed windscreen off the garage
   floor, so that it is not underfoot or at risk of being kicked.
2. As a Caterham owner, I want the mount to carry the screen by its steel
   stanchions, so that no load rests on the fragile glass or the aluminium frame.
3. As a Caterham owner, I want the screen to hang flat against the wall and off
   the floor, so that it is safely stored and the wall reacts the tipping load.
4. As a Caterham owner, I want each stanchion's triangular cutout to drop over a
   cylindrical peg, so that the screen hangs securely on steel.
5. As a Caterham owner, I want the peg's end collar to retain the screen, so that
   a bump cannot walk it off the peg.
6. As a Caterham owner, I want a single non-handed bracket I print twice, so that
   there is no left/right part to track or print in mirror.
7. As a Caterham owner, I want to mount the two brackets at any spacing, so that
   I can match wherever my stanchions and my wall studs actually fall.
8. As a Caterham owner, I want the bracket to fix safely to plasterboard with
   toggle anchors, or to bite a stud when one is present, so that a ~5 kg glass
   screen is held with a large safety margin.
9. As a Caterham owner, I want to drop the screen on and lift it off quickly, so
   that swapping to the aeroscreen for a track day is not a chore.
10. As a Caterham owner, I want the part printed in PETG, so that it resists
    creep under sustained load in a warm garage.
11. As a Caterham owner, I want the model to be parametric, so that I can dial in
    the exact cutout size and plate thickness I measure off my own stanchion.
12. As a Caterham owner, I want the bracket to print without supports in a
    sensible orientation, so that it is easy to make and the arm is not weak
    along a layer line.
13. As a maker browsing the catalog, I want a render and README consistent with
    the other products, so that the hanger is documented the same way.
14. As a Caterham owner, I want the two brackets to fit a normal desktop printer
    bed, so that I do not need a large-format printer for a big screen.

## Implementation Decisions

- **Load path and orientation — per ADR-0001.** Hang the **windscreen** inverted
  and flat to the wall from the two **stanchion** triangular cutouts. All load
  goes through the steel stanchions; nothing bears on glass or frame.
- **One symmetric, non-handed bracket, printed twice.** No mirrored variant. The
  two brackets are independent, so the owner sets any spacing to match their
  stanchions and studs. Symmetry about the bracket's vertical mid-plane is what
  makes it non-handed.
- **Engagement — 90° turn to a cylindrical peg.** The cutout faces *perpendicular*
  to the wall, so the bracket turns 90°: an arm out from the wall, then a
  **sideways** cylindrical peg through the cutout. The inverted screen's cutout
  (~76 × 76 mm) drops over the peg and hangs on it. Simpler than a matched wedge,
  at the cost of the wedge's self-centring — a little sideways play remains,
  capped by the collar.
- **Retention — tilt and collar (both).** The peg is tilted up slightly (~5–10°)
  so the screen settles inward, **and** the peg's outer ~5 mm steps up to a
  larger-diameter **collar** (a lip) that the resting cutout edge must climb to
  slide off, so the screen stays put.
- **Wall plate — spread fixing.** A flat plate against the wall with a spread,
  countersunk screw/anchor hole pattern: a hole placed to catch a stud where one
  falls, plus outer holes sized for toggle/butterfly anchors in bare
  plasterboard. Each bracket carries ~2.5 kg, comfortably inside anchor ratings.
- **Structure — short braced cantilever, PETG.** The peg sits out from the wall
  by the stanchion's projection, measured at about **38 mm (1.5″)**, so each arm
  carries ~2.5 kg as a *short* cantilever in bending — well under 1 N·m, a small
  moment with a large PETG margin. The L-profile still gets a modest gusset at
  the 90° corner, and the print is oriented so bending cannot peel layers apart
  there. PETG for sustained-load and garage-temperature durability; no supports.
- **Parametric interface.** Top-level parameters expose the cutout base and
  height, plate thickness, peg diameter and its clearance in the cutout, collar
  diameter and length, peg tilt angle, arm reach, wall-plate dimensions, and the
  screw/anchor hole pattern, so the design re-measures with a quick edit.
- **Deliverables follow the repo's product-folder convention.** A product folder
  containing the parametric source, an STL export, a `render.conf` sidecar
  (Catppuccin Mocha, ¾ view, bold edge outline) driving the shared `render.sh`,
  a `render.png`, and a README with BOM/mount/print notes and dimensions under
  the repo's CC BY-NC 4.0 license. Added to the root product index.
- **Deferred to design time:** exact peg diameter and collar size against the
  measured cutout, exact plate thickness, and the exact screw/anchor hole spacing.

## Testing Decisions

Consistent with every other product in this repo, there are **no automated
tests** — the model is verified the same way the door hanger and tunnel tray
are:

- **Visual verification** through the shared render pipeline: a successful CGAL
  render (which also confirms the geometry is manifold and printable) plus the
  Catppuccin Mocha ¾ render for a human eyeball check.
- **Physical print-fit** against the owner's actual **stanchion**: print one
  bracket, confirm the cutout drops over the peg, hangs cleanly, and the collar
  retains it before printing the second and mounting.
- The **parametric interface** is the durable seam — if the fit is off, the fix
  is editing a top-level parameter and re-rendering, not reworking geometry.

The single deep module (the parametric bracket) is therefore covered by visual +
print-fit verification; `render.conf` and the README carry no product tests.

## Out of Scope

- Displaying the screen glass-out or "the right way up" — it hangs inverted,
  glass toward the wall (ADR-0001).
- Storing the **aeroscreen** or a windscreen with the stanchions removed.
- A single full-width rack spanning both stanchions — the design is deliberately
  two independent brackets.
- Supplying the screws, wall anchors, or any protective felt/padding — these are
  off-the-shelf items the owner adds.
- Any change to the shared `render.sh` itself.

## Further Notes

- **Glass faces the wall:** protected from the room but not on display. Adhesive
  felt or heat-shrink on the peg is a cheap optional add the owner can apply to
  cushion the steel; not a printed feature.
- **Protrusion:** the stanchions point straight out from the wall, so the screen
  stands off the wall by the stanchion's projection — leave that much clearance
  in front of the wall.
- **Mirror clearance:** if a mirror is left on the frame, inverting the screen
  may bring it near the wall — worth checking clearance when positioning the
  brackets. Removing mirrors before storage sidesteps it.
- **Two-hand job:** inverting and hanging a ~5 kg glass assembly is deliberately
  a careful two-handed operation, not a one-handed grab.
- **Weight is estimated** at ~5 kg total (~2.5 kg per arm); fixings are sized
  with margin so the estimate being a little high is harmless.
