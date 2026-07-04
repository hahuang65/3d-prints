// ============================================================================
//  CATERHAM DOOR HANGER — Wall Mount
//  Holds a Caterham door by its bottom frame member in two curved J-hooks.
//
//  One hanger per door — print two for a pair.
//
//  PRINT ORIENTATION: backplate flat on the bed (XY plane), hooks pointing
//  upward (+Z).  After printing, rotate 90° about X to mount on the wall.
//
//  PRINTING:
//    PETG (never PLA).  ≥4 walls, 30 % infill, 0.2 mm layer height.
//    No supports required.
// ============================================================================

/* ============================ DIMENSIONS ================================ */
// Cradle (the hole that holds the door's frame member)
cradle_d  = 5.25;       // cradle diameter  (mm)
cradle_r  = cradle_d/2;

// Backplate
bp_w      = 174;        // width (X) — arm edge aligns with chamfer inner edge (mm)
bp_h      = 42;         // backplate height (Y) — centred for equal top/bottom margins (mm)
bp_t      = 5;          // thickness (Z)                (mm)

// Arms — curved J-hook shape
hook_w    = 28;         // width of each arm (X)        (mm)
hook_gap  = 142.8;      // centre–centre arm spacing (X) (mm)
arm_l     = 30;         // cradle centre from backplate face (Z, mm)
drop      = 35.4;       // cradle centre below arm attachment (Y, mm) — 10 mm lower
arm_t     = cradle_d + 4;  // arm thickness — 2 mm per side of cradle  (mm)
floor_t   = 0.5;        // material below cradle centre (Y, mm) — 2 mm past hole bottom

// Countersunk mounting screws (#8 flat-head wood screw)
screw_d   = 4.5;        // clearance hole diameter — shaft + slop  (mm)
head_d    = 8.3;        // countersunk head outer diameter  (mm)
csink_ang = 82;         // countersink included angle (degrees)

// General
round_r   = 1.5;        // 2D edge rounding radius       (mm)
$fn       = 48;

/* ============================ DERIVED =================================== */
csink_depth = (head_d - screw_d) / 2 / tan(csink_ang/2);

// Bottom of arm (vertical hook + floor below cradle)
hy = -(drop + floor_t + cradle_r);       // Y at bottom of arm

// Screws — one above and one below each arm.
// Top screw at screw_dist above the arm's TOP edge (Y=0).
// Bottom screw at screw_dist below the arm's BOTTOM edge (Y=-arm_t).
screw_x    = hook_gap / 2;   // X = aligned with arm centre
screw_dist = 6.86;           // distance from arm-attachment edge to screw centre (mm)
top_screw_y = screw_dist;
bot_screw_y = -(arm_t + screw_dist);

// Backplate vertically offset so top and bottom margins are equal.
// The midpoint of the two countersink edges is independent of margin.
bp_center_y = (top_screw_y + bot_screw_y) / 2;

// ---- Pre-compensation for the offset(r = round_r) expansion ---------------
bp_face = -round_r - 0.01;             // → X=+0.01 after offset (tiny gap from backplate face)
y_top   = -round_r;                    // → Y=0  after offset (arm top)
y_bot   = -(arm_t - round_r);          // → Y=-arm_t after offset
inner_comp = -(arm_l - arm_t/2 + round_r);  // → -(arm_l - arm_t/2)
outer_comp = -(arm_l + arm_t/2 - round_r);  // → -(arm_l + arm_t/2)

/* ============================ UTILITY =================================== */
module rounded_block(size, r) {
    hull() for (x = [r, size.x - r])
        for (y = [r, size.y - r])
            for (z = [r, size.z - r])
                translate([x, y, z]) sphere(r = r);
}

module countersunk_hole() {
    // Through-hole and countersink cone, cut after union so bottom
    // screws (which pass through the arm body) are clean.
    // Every cut must overshoot BOTH faces — a cut ending coplanar with a
    // face leaves a zero-thickness skin (CGAL won't open the hole there).
    eps = 0.6;

    // Clearance through-hole, overshooting front and back faces.
    translate([0, 0, -eps])
        cylinder(d = screw_d, h = bp_t + 2*eps);

    // Countersink: exactly head_d at the front face (z = bp_t), the cone
    // continuing past the face so the opening breaks through cleanly.
    cone_h = csink_depth + eps;
    top_d  = screw_d + (head_d - screw_d) * cone_h / csink_depth;
    translate([0, 0, bp_t - csink_depth])
        cylinder(d1 = screw_d, d2 = top_d, h = cone_h);
}

/* ============================ BACKPLATE (solid, no holes) =============== */
module backplate_solid() {
    // Flat backplate — rear face (Z=0) against the wall, no rounding.
    // The front (top) edges have a 45° bevel for a clean finish.
    bevel = round_r;
    
    hull() {
        // Bottom: full rectangle (wall side, no bevel)
        translate([-bp_w/2, -bp_h/2 + bp_center_y, 0])
            cube([bp_w, bp_h, 0.01]);
        
        // Bevel start: full rectangle at the cut height
        translate([-bp_w/2, -bp_h/2 + bp_center_y, bp_t - bevel])
            cube([bp_w, bp_h, 0.01]);
        
        // Top: inset rectangle (front side, beveled)
        translate([-bp_w/2 + bevel, -bp_h/2 + bp_center_y + bevel, bp_t])
            cube([bp_w - 2*bevel, bp_h - 2*bevel, 0.01]);
    }
}

/* ============================ ARM ======================================= */
module j_profile_2d() {
    offset(r = round_r)
        polygon([
            [bp_face,     y_top],        // wall face  (→ Z=0)
            [-arm_l,      y_top],        // outer top  (J-corner)
            [outer_comp,  -arm_t / 2],   // 45° diagonal → outer face
            [outer_comp,  hy],           // outer face ↓ uniform thickness
            [inner_comp,  hy],           // inner bottom
            [inner_comp,  y_bot],        // inner face ↑
            [bp_face,     y_bot],        // wall face
        ]);
}

module arm() {
    // rotate([0, 90, 0]): (depth, vert, width) → (width, vert, depth)
    rotate([0, 90, 0])
        difference() {
            linear_extrude(hook_w, center = true)
                j_profile_2d();

            // Cradle cut-out
            translate([-arm_l, -drop, 0])
                cylinder(h = hook_w + 2, r = cradle_r, center = true);
        }
}

/* ============================ FULL ASSEMBLY ============================= */
module hanger_wall() {
    difference() {
        union() {
            backplate_solid();

            // Arm attachment line (top edge) centred at Y=0.
            // The arm drops below centre — acceptable.
            for (hx = [-hook_gap/2, hook_gap/2])
                translate([hx, 0, 0])
                    arm();
        }

        // Screw holes cut through everything (backplate + arm body).
        // Top screw above arm top; bottom screw below arm attachment bottom.
        for (sx = [-screw_x, screw_x]) {
            translate([sx, top_screw_y, 0])
                countersunk_hole();
            translate([sx, bot_screw_y, 0])
                countersunk_hole();
        }
    }
}

hanger_wall();
