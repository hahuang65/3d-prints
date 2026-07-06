// Sponge Holder - SpongeButler style
// A tapered pill lies FLAT against the wall (its flat back is the adhesive
// face). On the pill's FRONT face is a U-shaped grip that stands off the wall;
// the sponge drops into the U and is held STICKING STRAIGHT OUT, perpendicular
// to the wall, so it air-dries. The grip's bottom follows the pill's rounded
// bottom, and a small lip along the grip's front edge helps retain the sponge.
//
// Print orientation: pill back (adhesive face) flat on the bed, U-grip up.

/* ===================== SPONGE ===================== */
sponge_t = 25;      // sponge thickness — gripped between the U side walls

/* ======================= FIT ===================== */
grip     = 3;       // slot narrower than the sponge -> friction wedge

/* ================= PILL (wall plate) ============= */
tab_h    = 116;     // pill height
r_top    = 15;      // fuller rounded top
r_bot    = 13;      // narrower rounded bottom (keeps the walls slim)
plate_t  = 6;       // pill thickness (sits flat on the wall)

/* ================= U-GRIP (front) =============== */
grip_depth = 13;    // how far the U stands off the pill (sponge sticks out past this)
grip_top   = 92;    // height the grip walls rise to (open above this)
lip        = 2;     // inward retaining lip along the grip's front edge
lip_z      = 3;     // how deep the lip runs back from the front edge
$fn = 120;

/* ===================== DERIVED =================== */
slot_w = sponge_t - grip;              // wedged slot width = 22

module taper_pill(shrink = 0)
    hull() {
        translate([0, tab_h - r_top]) circle(r = r_top - shrink);
        translate([0, r_bot])         circle(r = r_bot - shrink);
    }

// Sponge slot outline: constant-width channel, open at the top, with a rounded
// bottom concentric with the pill's own rounded bottom.
module slot_profile(w)
    union() {
        translate([0, r_bot])      circle(r = w/2);
        translate([-w/2, r_bot])   square([w, grip_top]);
    }

module sponge_holder() {
    // Pill plate flat against the wall
    linear_extrude(plate_t) taper_pill();

    // U-grip on the front: the pill's lower profile pushed forward, with the
    // sponge slot cut out (open at the top) and a lip at the front edge.
    translate([0, 0, plate_t])
        difference() {
            // grip body = the pill's lower profile, extruded out from the wall
            linear_extrude(grip_depth)
                intersection() {
                    taper_pill();
                    translate([-100, 0]) square([200, grip_top]);
                }

            // main sponge slot (rounded bottom; does not reach the front face)
            translate([0, 0, -1])
                linear_extrude(grip_depth - lip_z + 1) slot_profile(slot_w);

            // front slot, narrower -> leaves an inward lip on each wall
            translate([0, 0, grip_depth - lip_z])
                linear_extrude(lip_z + 2) slot_profile(slot_w - 2*lip);
        }
}

sponge_holder();
