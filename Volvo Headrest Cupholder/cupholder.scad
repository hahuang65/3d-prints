// ============================================================================
//  KEYHOLE-SLIDE CLAMSHELL that WRAPS THE THICK NECK  -- double bottle holder
//  Two halves wrap the rounded-rectangular headrest neck. On each side a
//  "chess-pawn" (bulb-on-stem) vertical dovetail: the FRONT half slides DOWN
//  so its bulb tongue drops into the BACK half's socket and locks the two
//  front-to-back WITHOUT screws (mates top-bottom). A rear-entry M4 bolt then
//  runs through the joint into a CAPTIVE NUT and pins the slide. Internal ridges
//  bite the smooth plastic. The two holders form one PILL/stadium body joined
//  by a HALF-HEIGHT center web (TOP half = tension side, ties the rims). A
//  haunched, filleted GOOSENECK arm (deep at the clamp, slim at the web) carries
//  it.  Print PETG/ASA, never PLA. ~3 walls, 25-30% infill.
//
//  TEST FIT: body=false + screws=false + clamp_h=3 prints just the clamp ring.
// ============================================================================

mode = "assembled";   // "assembled" | "exploded" | "back_only" | "front_only"
body = true;          // false = clamp only (cheap fit-test print)
screws = true;        // false = skip all bolt/nut-trap features (fit test)
show_bottles = false; // ghost water bottles to check spacing/flare clearance
show_leg = true;      // ghost headrest neck (visualisation only; not printed)

/* --------------------- NECK (the whole support to wrap) ----------------- */
leg_w     = 58.75;    // neck width left-right (mm)                MEASURED
leg_d     = 50.0;     // neck depth front-back (mm)                MEASURED
corner_r  = 10.0;     // neck corner radius (mm)                   MEASURED
clamp_h   = 24.0;     // wrap height (also the slide travel)       MEASURED~50

/* ------------------------------- FIT ------------------------------------- */
grip_clear  = 0.3;    // bore oversize per side (mm)
parting_gap = 0.4;    // tiny gap where the two shells meet
grip_ribs   = true;   // internal ridges that bite the smooth plastic

/* --------------------- KEYHOLE / "CHESS PAWN" JOINT --------------------- */
boss_len  = 22;       // how far the joint boss sticks past the neck (mm)
boss_w    = 30;       // boss depth front-back (mm)
bulb_d    = 12;       // pawn HEAD diameter (mm)
stem_w    = 5.5;      // pawn STEM width (mm)  (< bulb_d so it locks)
bulb_off  = 6.0;      // pawn head center, back of the parting line (mm)
key_clear = 0.35;     // sliding clearance of the socket (mm)
joint_floor = 3;      // solid floor the tongue bottoms onto (mm)

/* ----------------------- SCREW + NUT TRAP (M4) -------------------------- */
scr_free  = 4.4;      // bolt clearance hole
bolt_head = 8.0;      // head counterbore (rear face)
head_depth= 4.0;
nut_af    = 7.2;      // M4 nut across-flats + clearance (mm)
nut_th    = 3.4;      // M4 nut thickness + clearance (mm)
nut_y     = 6.0;      // nut position inside the front boss (mm, +Y)

/* ----------------------------- CLAMP ------------------------------------- */
wall = 8;             // shell wall thickness (mm) — +2 over the flexy v1
explode = 46;

/* ------------------------------- BODY ------------------------------------ */
drop    = 28;         // holder TOP, below the clamp bottom (mm)
reach   = 78;         // how far back the holders sit (mm)
web_frac = 0.5;       // center-web height as a fraction of holder height
web_top  = true;      // true = web on the TOP half (stronger), false = bottom
arm_r    = 11;        // gooseneck radius (uniform along the sweep, mm) -> Ø22
arm_weld = 2;         // how far the arm root overlaps INTO the back wall (mm)
arm_stub = 8;         // straight, flat-capped run off the wall before it curves (mm)

/* --------------------- BOTTLE / CUP HOLDERS ----------------------------- */
bore_bot  = 75.0;     // holder bore Ø at the floor (bottom of cup)
bore_top  = 85.0;     // holder bore Ø at the rim (top) — flares out, captures more
flare_dia = 80.0;     // bottle TOP/flare diameter (sets spacing)    MEASURED
body_dia  = 72.0;     // nominal bottle body Ø (ghost-bottle viz only) MEASURED
cup_wall  = 3.0;      // holder wall thickness
cup_ring_h = 66;      // holder height (was 50; +~33% so more of the cup drops in)
floor_t   = 3.0;      // floor thickness
base_open = bore_bot/3;  // central floor opening Ø ≈ ⅓ bore → wide retaining ring
top_gap = 18;         // clearance between the two flared tops (mm)

$fn = 96;

/* ============================ DERIVED ================================== */
ow = leg_w + 2*wall;          od = leg_d + 2*wall;       or_ = corner_r + wall;
bw = leg_w + 2*grip_clear;    bd = leg_d + 2*grip_clear; br = corner_r + grip_clear;
cup_irb = bore_bot/2;   cup_irt = bore_top/2;         // bore radius: bottom, top
cup_orb = cup_irb + cup_wall;   cup_ort = cup_irt + cup_wall;   // outer radius
cup_pitch = max(cup_ort + 2, (flare_dia + top_gap)/2);   // space the widest (top) rims
function bxc() = ow/2 + boss_len/2;

cup_cy   = -reach - cup_orb + 10;         // holder centers (Y)
ring_top = -drop;                         // holder top (Z)
ring_bz  = -drop - cup_ring_h;            // holder bottom (Z)
web_h    = cup_ring_h * web_frac;         // center-web height
web_z    = web_top ? (ring_top - web_h) : ring_bz;   // web bottom Z
// Outer radius where the web meets the cup wall (so the web stays flush with
// the taper), and the cavity's top radius extrapolated 1 mm past the rim.
web_rb   = cup_orb + (cup_ort - cup_orb) * (web_z - ring_bz) / cup_ring_h;
cav_rt   = cup_irt + (cup_irt - cup_irb) / (cup_ring_h - floor_t);

/* ============================ HELPERS ================================= */
module rrect(x,y,r){ offset(r=r) square([x-2*r,y-2*r], center=true); }
module tube(){ linear_extrude(clamp_h) difference(){ rrect(ow,od,or_); rrect(bw,bd,br); } }
module ridges_front(){ if(grip_ribs) for(z=[clamp_h*0.30,clamp_h*0.70])
    translate([-leg_w*0.30, bd/2-0.9, z-0.75]) cube([leg_w*0.60,1.2,1.5]); }
module ridges_back(){  if(grip_ribs) for(z=[clamp_h*0.30,clamp_h*0.70])
    translate([-leg_w*0.30,-bd/2-0.3, z-0.75]) cube([leg_w*0.60,1.2,1.5]); }
module pawn2d(extra){                 // bulb head (-Y) + stem to the parting
    offset(delta=extra) union(){
        translate([bxc(), -bulb_off]) circle(d=bulb_d);
        translate([bxc()-stem_w/2, -bulb_off]) square([stem_w, bulb_off + parting_gap/2 + 0.1]);
    }
}
module boss_block(ylo, yhi){ translate([ow/2, ylo, 0]) cube([boss_len, yhi-ylo, clamp_h]); }

/* ----- M4 rear-entry bolt + captive nut (subtractions, +X side) ----- */
module screw_clear_R(){
    translate([bxc(), boss_w/2+1, clamp_h/2]) rotate([90,0,0]) cylinder(h=boss_w+2, d=scr_free);
}
module screw_head_R(){
    translate([bxc(), -boss_w/2-0.01, clamp_h/2]) rotate([-90,0,0]) cylinder(h=head_depth, d=bolt_head);
}
module nut_trap_R(){
    translate([bxc(), nut_y, clamp_h/2]) rotate([90,0,0]) rotate([0,0,30])
        cylinder(h=nut_th, d=nut_af/cos(30), $fn=6, center=true);
    translate([bxc()-nut_af/2, nut_y-nut_th/2, clamp_h/2]) cube([nut_af, nut_th, clamp_h]);
}
module both(){ for(m=[0,1]) mirror([m,0,0]) children(); }

/* ---- joint solids ---- */
module joint_front_R(){
    boss_block(parting_gap/2, boss_w/2);
    translate([0,0,joint_floor]) linear_extrude(clamp_h-joint_floor) pawn2d(0);
}
module joint_back_R(){
    difference(){
        boss_block(-boss_w/2, -parting_gap/2);
        translate([0,0,joint_floor]) linear_extrude(clamp_h-joint_floor+2) pawn2d(key_clear);
    }
}

/* ---- uniform-diameter gooseneck arm: round sweep along a Bezier ----
   Begins as a straight, FLAT-CAPPED cylinder whose axis is normal to the
   back face, so the tube meets the clamp with a clean flat interface (no
   spherical rounding) and only arm_weld enters the wall -- never the bore. */
function bez(a,b,c,t) = [ for(k=[0:2]) (1-t)*(1-t)*a[k] + 2*(1-t)*t*b[k] + t*t*c[k] ];
module arm_gooseneck(){
    ty     = cup_cy + cup_orb - arm_r - 6;  // tip Y, tube fully inside pill
    z0     = clamp_h*0.45;                   // exit height on the back wall
    stub_y = -od/2 - arm_stub;               // where the straight run ends

    // 1) straight flat-capped stub plugged square into the wall
    translate([0, stub_y, z0]) rotate([-90,0,0])
        cylinder(h = arm_stub + arm_weld, r = arm_r, $fn=48);

    // 2) curved gooseneck from the stub end down into the pill web
    root = [0, stub_y, z0];
    tip  = [0, ty,     ring_top - 8];
    ctrl = [0, ty,     z0];
    N = 16;
    for (i=[0:N-1]){
        t0=i/N; t1=(i+1)/N;
        hull(){
            translate(bez(root,ctrl,tip,t0)) sphere(r=arm_r, $fn=32);
            translate(bez(root,ctrl,tip,t1)) sphere(r=arm_r, $fn=32);
        }
    }
}

/* ---- pill double holder: tapered rings + half-height web, bored ---- */
module holders(){
    difference(){
        union(){
            // Outer body: cones that flare from cup_orb (floor) to cup_ort (rim)
            for(sx=[-1,1]) translate([sx*cup_pitch, cup_cy, ring_bz])
                cylinder(h=cup_ring_h, r1=cup_orb, r2=cup_ort);
            // Center web, flush with the cup taper over its height band
            hull() for(sx=[-1,1]) translate([sx*cup_pitch, cup_cy, web_z])
                cylinder(h=web_h, r1=web_rb, r2=cup_ort);
        }
        for(sx=[-1,1]) translate([sx*cup_pitch, cup_cy, ring_bz]){
            // Tapered cavity: bore_bot at the floor -> bore_top at the rim
            translate([0,0,floor_t])
                cylinder(h=cup_ring_h - floor_t + 1, r1=cup_irb, r2=cav_rt);
            // Central floor opening: wide retaining ring + drain
            translate([0,0,-1]) cylinder(h=floor_t+2, r=base_open/2);
        }
    }
}

/* ============================ HALVES ================================== */
module front_half(){
    color([0.30,0.55,0.85]) difference(){
        union(){
            intersection(){ tube(); translate([-ow,parting_gap/2,-1]) cube([2*ow,od,clamp_h+2]); }
            ridges_front();
            both() joint_front_R();
        }
        if (screws) { both() screw_clear_R(); both() nut_trap_R(); }
    }
}
module back_half(){
    color([0.20,0.42,0.72]) difference(){
        union(){
            intersection(){ tube(); translate([-ow,-od,-1]) cube([2*ow,od-parting_gap/2,clamp_h+2]); }
            ridges_back();
            both() joint_back_R();
            if (body) { arm_gooseneck(); holders(); }
        }
        if (screws) { both() screw_clear_R(); both() screw_head_R(); }
    }
}
module ghost_leg(){ if(show_leg) color([0.55,0.55,0.6,0.30]) translate([0,0,-8])
    linear_extrude(clamp_h+16) rrect(leg_w,leg_d,corner_r); }
module ghost_bottles(){
    color([0.45,0.7,0.95,0.28]) for(sx=[-1,1])
        translate([sx*cup_pitch, cup_cy, ring_bz+floor_t]){
            cylinder(h=150, d=body_dia);
            translate([0,0,140]) cylinder(h=22, d1=body_dia, d2=flare_dia);
            translate([0,0,162]) cylinder(h=18, d=flare_dia-6);
        }
}

/* ============================ RENDER ================================== */
if (mode=="back_only") back_half();
else if (mode=="front_only") front_half();
else if (mode=="exploded"){ translate([0,0,explode]) front_half(); back_half(); ghost_leg(); }
else { front_half(); back_half(); ghost_leg(); if(show_bottles) ghost_bottles(); }
