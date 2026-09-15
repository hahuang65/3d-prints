// ============================================================================
//  NUMBER 3 COOKIE CUTTER
//  Cuts a 3.5 in Fredoka Bold number 3 with a rounded, playful shape.
//  The print-oriented outline is mirrored so the cut cookie reads normally.
//
//  PRINT ORIENTATION:
//    Place the top press rim on the bed at Z=0.
//    The tapered cutting edge points upward.
//    Flip the finished cutter over before use; the rim then becomes the top.
//
//  PRINTING:
//    0.4 mm nozzle, 0.20 mm layers, PLA, no supports.
// ============================================================================

/* ============================ USER DIMENSIONS =========================== */
cookie_height = 88.9;       // 3.5 in cut shape; user requirement (mm)
cutter_height = 31.75;      // 1.25 in overall tool depth; user requirement (mm)

/* ============================ PRINT GEOMETRY ============================ */
body_wall = 1.2;            // Three 0.4 mm nozzle widths (mm)
cutting_edge_wall = 0.8;    // Two 0.4 mm nozzle widths (mm)
cutting_edge_height = 4.0;  // Gradual tapered section (mm)
taper_steps = 10;           // Outline-preserving 0.4 mm taper steps
press_rim_height = 3.2;     // Eight layers at 0.20 mm (mm)
press_rim_outset = 0.4;     // One extra nozzle width; keeps both curls open (mm)

/* ============================ GLYPH SOURCE ============================== */
// Fredoka Bold: https://fonts.google.com/specimen/Fredoka
source_glyph_height = 88.9; // Measured vector height in fredoka_3.svg (mm)
glyph_file = "fredoka_3.svg";

/* ============================ QUALITY ================================== */
boolean_overlap = 0.1;
taper_overlap = 0.02;
$fn = 96;

assert(cookie_height > 0, "cookie_height must be positive");
assert(cutter_height > cutting_edge_height + press_rim_height,
    "cutter_height must leave room for the body wall");
assert(body_wall >= cutting_edge_wall,
    "body_wall must not be thinner than the cutting edge");
assert(cutting_edge_wall > 0, "cutting_edge_wall must be positive");
assert(taper_steps >= 2, "taper_steps must be at least 2");
assert(press_rim_outset > 0, "press_rim_outset must be positive");

/* ============================ 2D PROFILE ================================ */
module cookie_outline() {
    mirror([1, 0, 0])
        scale(cookie_height / source_glyph_height)
            import(glyph_file);
}

module outside_wall(outset) {
    difference() {
        offset(delta = outset)
            cookie_outline();
        cookie_outline();
    }
}

/* ============================ 3D FEATURES =============================== */
module straight_body() {
    body_height = cutter_height - cutting_edge_height;

    linear_extrude(height = body_height + boolean_overlap)
        outside_wall(body_wall);
}

module tapered_cutting_edge() {
    taper_start = cutter_height - cutting_edge_height;
    step_height = cutting_edge_height / taper_steps;

    // A global hull would bridge the deep concave openings of the 3.
    // Stacked outline shells preserve both curls through the full taper.
    for (step = [0 : taper_steps - 1]) {
        progress = step / (taper_steps - 1);
        step_wall = body_wall
            - (body_wall - cutting_edge_wall) * progress;
        step_overlap = step < taper_steps - 1 ? taper_overlap : 0;

        translate([0, 0, taper_start + step * step_height])
            linear_extrude(height = step_height + step_overlap)
                outside_wall(step_wall);
    }
}

// This rim is at the bed for printing and at the hand-contact top in use.
module press_rim() {
    linear_extrude(height = press_rim_height)
        outside_wall(body_wall + press_rim_outset);
}

/* ============================ COMPLETE CUTTER =========================== */
union() {
    straight_body();
    tapered_cutting_edge();
    press_rim();
}
