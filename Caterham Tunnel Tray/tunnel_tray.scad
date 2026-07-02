// ============================================================================
//  CATERHAM 420R S3 — TRANSMISSION TUNNEL STORAGE TRAY
//  Single-piece open tray that sits on the transmission tunnel, pushed
//  forward against the firewall.  Attaches via velcro on the front wall (to
//  the firewall) and silicone/rubber friction pads on the underside (no
//  adhesive on the leather tunnel cover).  A U-shaped notch at the front-
//  right clears the wiring harness tube.
//
//  COORDINATE SYSTEM:
//    Origin = centre of the firewall edge of the tray (Y=0)
//    +X = right (passenger side),  +Y = toward shifter,  +Z = up
//
//  PRINTING:
//    ASA or PETG (never PLA).  Print face-down (walls up).
//    No supports needed.  ≥4 walls, 25–30 % infill.
// ============================================================================

MODE = "test_plate";  // "assembled" | "exploded" | "test_plate"

/* ============================ DIMENSIONS ================================ */
// Tray
tray_w     = 152;    // tray width left-right            (6")
tray_l     = 178;    // tray length firewall→shifter     (7")
wall       = 3;      // wall thickness
floor_t    = 3;      // floor thickness
side_h     = 20;     // side wall height above floor
corner_r   = 6;      // outer corner radius (mm)

// Wiring tube notch (at the firewall edge, right side of centre)
notch_w    = 32;     // notch width  (tube 23 mm + slop)  (1.25")
notch_d    = 58;     // notch depth from firewall         (2.25")
notch_off  = -31;    // notch centre offset from tray centre (+X = right)

/* ============================ DERIVED =================================== */
_iw = tray_w - 2*wall;                // interior width
_il = tray_l - 2*wall;                // interior length
_notch_l = notch_off - notch_w/2;     // notch left edge (from centre)

/* ============================ 3D HELPERS =============================== */
module rbox(w, l, h, r) {
    // Rounded box centred at origin
    linear_extrude(h, center = true)
        offset(r = r) square([w - 2*r, l - 2*r], center = true);
}

/* ============================ TRAY BODY ================================= */
// Build the tray by starting with a solid rounded block, then subtracting
// the interior cavity and the notch as 3D boxes — avoids nested 2D CSG
// which can produce rendering artifacts.

_total_h = floor_t + side_h;

module tray() {
    difference() {
        // ---- Outer block: solid rounded tray ----
        translate([0, tray_l/2, _total_h/2])
            rbox(tray_w, tray_l, _total_h, corner_r);

        // ---- Interior cavity ----
        translate([0, tray_l/2, floor_t + side_h/2 + 0.05])
            rbox(_iw, _il, side_h + 0.1, corner_r - wall);

        // ---- Notch: cuts through the Y=0 wall and floor ----
        translate([_notch_l, -1, -1])
            cube([notch_w, notch_d + 1, _total_h + 2]);
    }
}

/* ============================ TEST PLATE =============================== */
// 1 mm thick, full 6" width, 3" long — quick print to verify the notch fits
// the wiring tube before committing to the full tray.
test_l = 76;  // 3"

module test_plate() {
    linear_extrude(1) {
        difference() {
            translate([0, test_l/2]) rrect_poly([tray_w, test_l], corner_r);
            translate([_notch_l, -1]) square([notch_w, notch_d + 1]);
        }
    }
}

module rrect_poly(size, r) {
    // Simple rounded rectangle as a 2D shape (no center option)
    offset(r = r) square([size.x - 2*r, size.y - 2*r], center = true);
}

/* ============================ MODE SELECTION ============================ */
if (MODE == "assembled") {
    tray();
} else if (MODE == "test_plate") {
    test_plate();
} else if (MODE == "exploded") {
    // For checking the notch and pocket geometry — colour-coded sections
    color([0.30, 0.55, 0.85, 0.9]) tray();
}
