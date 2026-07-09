// Caterham Windscreen Hanger
// A wall bracket that stores a removed Caterham Seven windscreen. The screen
// hangs INVERTED and flat to the wall; each steel stanchion sticks straight out
// from the wall and its triangular cutout faces sideways. So the bracket reaches
// out and makes a 90 deg turn into a sideways PEG that the cutout drops over and
// hangs on. A larger-diameter COLLAR on the peg's outer end is the retention lip.
//
// One symmetric, non-handed part: print two and flip one for the opposite
// stanchion. See ../CONTEXT.md and ../docs/adr/0001-...md.
//
// Axes (authoring = mounted orientation):
//   +Y = out from the wall      (wall face at Y=0, plate front at Y=plate_t)
//   +Z = up                     (part is symmetric about z=0 -> non-handed)
//   +X = sideways, toward the stanchion (peg points +X)

/* ============================ STANCHION (measured) ========================= */
cutout      = 76;    // triangular cutout, base & height (~3") — reference only
plate_max_t = 12.7;  // stanchion plate thickness the peg passes through (<1/2")

/* ================================ PEG ===================================== */
peg_d      = 16;     // peg diameter — drops freely through the 76 mm cutout
peg_over   = 10;     // clear peg PAST the plate edge, before the collar — the
                     // stanchion seats here, beyond the plate, resting on the
                     // wall rather than the proud baseplate. peg_len derived below.
collar_d   = 24;     // collar diameter — the lip the cutout edge climbs over
collar_len = 5;      // collar length at the peg's outer end

/* =========================== ARM / WEB ==================================== */
arm_reach  = 42;     // web length, plate face -> peg axis; sized so the collar's
                     // near rim stands 30 mm clear of the plate face
                     // (arm_reach = 30 clearance + collar_d/2)
web_t      = 10;     // web thickness (sideways, X)
web_h      = 52;     // web height at the plate, tapering to the peg

/* ============================ WALL PLATE ================================== */
plate_w  = 58;       // plate width  (X)
plate_h  = 96;       // plate height (Z) — symmetric about z=0
plate_t  = 7;        // plate thickness (Y)
corner_r = 8;        // rounded plate corners

/* ============================ FIXING HOLES =============================== */
// Four countersunk holes in a spread rectangle, symmetric about z=0 (which is
// what keeps the part non-handed). Land one or two on a stud where it falls;
// toggle/butterfly-anchor the rest in bare plasterboard.
screw_d = 4.5;       // clearance for the screw shank
head_d  = 9;         // countersunk head diameter
hole_dx = 17;        // hole offset from plate centre, X (clears the web)
hole_dz = 36;        // hole offset from plate centre, Z

$fn = 72;

/* =============================== DERIVED ================================== */
peg_y   = plate_t + arm_reach;      // peg axis distance out from the wall face
peg_len = plate_w/2 + peg_over + collar_len;  // plate edge + clear seat + collar
eps     = 0.6;                       // overshoot for clean CGAL cuts

/* =============================== MODULES ================================== */

// Rounded flat plate against the wall: thickness plate_t along +Y, centred in
// X and Z, back face on the wall at Y=0.
module wall_plate() {
    hull() for (sx = [-1, 1], sz = [-1, 1])
        translate([sx * (plate_w/2 - corner_r), 0, sz * (plate_h/2 - corner_r)])
            rotate([-90, 0, 0]) cylinder(h = plate_t, r = corner_r);
}

// Vertical web (the arm): tall at the plate, tapering to a boss around the peg.
// Symmetric about z=0, so it doubles as the corner gusset.
module web() {
    hull() {
        translate([-web_t/2, plate_t - 1, -web_h/2]) cube([web_t, 2, web_h]);
        translate([0, peg_y, 0]) rotate([0, 90, 0])
            translate([0, 0, -web_t/2]) cylinder(h = web_t, r = peg_d/2 + 3);
    }
}

// The sideways peg with its end collar.
module peg() {
    translate([0, peg_y, 0]) rotate([0, 90, 0]) {
        cylinder(h = peg_len, r = peg_d/2);
        translate([0, 0, peg_len - collar_len])
            cylinder(h = collar_len, r = collar_d/2);
    }
}

// One countersunk fixing hole along +Y; shank overshoots both plate faces
// (avoids the coplanar-subtraction skin CGAL leaves on a flush cut).
module csk_hole() {
    translate([0, -eps, 0]) rotate([-90, 0, 0])
        cylinder(h = plate_t + 2*eps, r = screw_d/2);
    translate([0, plate_t - head_d/2, 0]) rotate([-90, 0, 0])
        cylinder(h = head_d/2 + eps, r1 = 0, r2 = head_d/2);
}

module fixing_holes() {
    for (sx = [-1, 1], sz = [-1, 1])
        translate([sx * hole_dx, 0, sz * hole_dz]) csk_hole();
}

module bracket() {
    difference() {
        union() {
            wall_plate();
            web();
            peg();
        }
        fixing_holes();
    }
}

bracket();
