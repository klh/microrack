// =====================================================================
//  UDM SE 1U hanger kit — exact 1U pitch, M5x45 assembly
//
//  All side pieces are identical. Each side has two kinds of vertical holes:
//   HANG holes (front + rear): 1U -> M5x45 from below into the top plate's
//     nuts (4 screws per kit). More levels -> M5 threaded rod through every
//     side, nut + washer under the lowest side. Head/nut sits recessed in a
//     13 mm counterbore so a socket fits and the underside stays flat.
//   ATTACH points (front + rear): captive M5 nut slot in the bottom of every
//     side, so anything can be hung from the lowest side with M5 screws.
//  Top plates are screwed to the underside of the cabinet top with
//  4.5 mm countersunk wood screws.
//
//  Devices hang on their front ears only (2-post style), 3 EIA holes/U,
//  each with a captive M5 nut slot sized for the same M5x45 screws.
//
//  Bambu Lab P1S (256 mm bed). PETG or ASA. No supports.
//
//  Export: openscad -o side_right.stl -D 'part="side_right"' udm_se_1u_kit.scad
//  parts: assembly | top_right | top_left | side_right | side_left
//
//  Coordinates (right side; left is mirrored):
//    x lateral (0 = device centreline), y depth (0 = rear face of ears,
//    + towards the back), z up (0 = bottom of the 1U level)
// =====================================================================

/* [Part to render] */
part  = "assembly"; // [assembly, top_right, top_left, side_right, side_left]
units = 2;          // levels in the assembly preview (and rod length echo)

/* [Device: UniFi Dream Machine SE] */
dev_w = 442.4;
dev_h = 43.7;
dev_d = 285.6;
U     = 44.45;                       // 1U = 1.75 in
ear_pitch = 465.1;                   // EIA-310 hole centre spacing
ear_z = [6.35, 22.225, 38.1];        // EIA hole heights within one U

/* [Frame] */
clear    = 1.5;     // device body to side, per side
frame_t  = 5;       // side plate thickness
L        = 240;     // side depth (P1S bed is 256)
post_d   = 46;      // front post depth (long enough for M5x45 ear screws)
col_d    = 34;      // rear column depth
outer_x  = 255;     // half overall width
flange_w = 8.3;     // small outward stiffening flange at the bottom
flange_t = 3;

/* [M5 hardware] */
hole   = 5.5;       // M5 clearance
nut_af = 8.3;       // M5 nut (8 mm AF) + clearance
nut_t  = 4.4;       // M5 nut (4 mm) + clearance
nut_z  = 3;         // floor under each captive nut
cb_d   = 13;        // counterbore: screw head, or rod nut + washer + 8 mm socket
cb_h   = 9;         // head seat height -> M5x45 reaches 9.55 mm into the top plate
vx     = 245.5;     // x of the vertical holes (outboard of the ear holes)
ear_nut_y = 36;     // ear nut slot depth, for M5x45 ear screws

/* [Top plate] */
top_t       = 12;
top_inner_x = 200;
wood        = 4.5;  // countersunk wood screws
cs_d        = 9.5;

/* [Hidden] */
$fn    = 48;
eps    = 0.01;
x_in   = dev_w/2 + clear;
ear_x  = ear_pitch/2;
nut_ac = nut_af / cos(30);
hang   = [[vx, 12], [vx, L - 10]];   // M5x45 (1U) or threaded rod (more levels)
attach = [[vx, 27], [vx, L - 26]];   // captive nuts in the bottom, for hanging extras
wood_pos = [[208, 20], [208, L/2], [208, L - 20], [246, 85], [246, L - 85]];

echo(str("1U: M5x45 reaches ", cb_h + 45 - U, " mm into the top plate (nut at ", nut_z, "-", nut_z + nut_t, ")"));
echo(str("threaded rod for ", units, " levels: ", units * U + 8, " mm"));

// vertical M5 nut slot, open to the outside (+x)
module nut_slot_vertical(p) {
    hull() {
        translate([p[0], p[1], nut_z]) cylinder(d = nut_ac, h = nut_t, $fn = 6);
        translate([outer_x, p[1] - nut_af/2, nut_z]) cube([1, nut_af, nut_t]);
    }
}

// ---------------------------------------------------------------------
module side() {
    difference() {
        union() {
            translate([x_in, 0, 0])          cube([frame_t, L, U]);                 // side plate
            translate([x_in, 0, 0])          cube([frame_t + flange_w, L, flange_t]); // flange
            translate([x_in, 0, 0])          cube([outer_x - x_in, post_d, U]);     // front post
            translate([x_in, L - col_d, 0])  cube([outer_x - x_in, col_d, U]);      // rear column
        }
        // vertical holes at all four positions
        for (p = concat(hang, attach))
            translate([p[0], p[1], -1]) cylinder(d = hole, h = U + 2);
        // counterbores under the hang holes (screw head / rod nut + washer)
        for (p = hang)
            translate([p[0], p[1], -1]) cylinder(d = cb_d, h = cb_h + 1);
        // captive nuts in the bottom: attachment points
        for (p = attach) nut_slot_vertical(p);

        // ear holes (EIA pattern) + captive nut slots
        for (ez = ear_z) {
            translate([ear_x, -1, ez]) rotate([-90, 0, 0])
                cylinder(d = hole, h = post_d + 2);
            hull() {
                translate([ear_x, ear_nut_y, ez]) rotate([-90, 0, 0])
                    cylinder(d = nut_ac, h = nut_t, $fn = 6);
                translate([outer_x, ear_nut_y, ez - nut_af/2])
                    cube([1, nut_t, nut_af]);
            }
        }

        // diamond windows (self-supporting, airflow)
        win = 28;  web = 8;
        ys  = post_d + 6;  ye = L - col_d - 6;
        n   = floor((ye - ys - win) / (win + web)) + 1;
        zc  = (8 + (U - 7)) / 2;
        for (i = [0 : n - 1]) {
            yc = (ys + ye)/2 + (i - (n - 1)/2) * (win + web);
            translate([x_in + frame_t/2, yc, zc]) rotate([45, 0, 0])
                cube([frame_t + 2, win/sqrt(2), win/sqrt(2)], center = true);
        }
    }
}

// ---------------------------------------------------------------------
module top_plate() {
    difference() {
        translate([top_inner_x, 0, 0]) cube([outer_x - top_inner_x, L, top_t]);
        // captive nuts for the hang screws/rods (and the attach positions)
        for (p = concat(hang, attach)) {
            translate([p[0], p[1], -1]) cylinder(d = hole, h = top_t + 2);
            nut_slot_vertical(p);
        }
        // countersunk wood screws, heads flush with the underside
        for (w = wood_pos) translate([w[0], w[1], 0]) {
            translate([0, 0, -1]) cylinder(d = wood + 0.3, h = top_t + 2);
            translate([0, 0, -eps])
                cylinder(d1 = cs_d, d2 = wood + 0.3, h = (cs_d - wood - 0.3)/2);
        }
    }
}

// ---------------------------------------------------------------------
module device() {
    color("Gainsboro") translate([-dev_w/2, -2.5, 0]) cube([dev_w, dev_d, dev_h]);
    color("Silver") for (m = [0, 1]) mirror([m, 0, 0])
        translate([dev_w/2, -2.5, 0]) cube([ear_pitch/2 + 8.75 - dev_w/2, 2.5, dev_h]);
}

module assembly() {
    for (i = [0 : units - 1]) translate([0, 0, i * U]) {
        color(i % 2 ? "SteelBlue" : "CadetBlue") { side(); mirror([1, 0, 0]) side(); }
        translate([0, 0, (U - dev_h)/2]) device();
    }
    translate([0, 0, units * U]) color("SlateGray") { top_plate(); mirror([1, 0, 0]) top_plate(); }
    // M5x45 (1U) or threaded rods
    color("DarkGoldenrod") for (m = [0, 1], p = hang) mirror([m, 0, 0])
        translate([p[0], p[1], 2]) cylinder(d = 5, h = units * U + 8);
}

// ---------------------------------------------------------------------
// Exported in print orientation, as installed (bottom face on the bed).
if      (part == "assembly")     assembly();
else if (part == "top_right")    translate([-top_inner_x, 0, 0]) top_plate();
else if (part == "top_left")     translate([ top_inner_x, 0, 0]) mirror([1, 0, 0]) top_plate();
else if (part == "side_right")   translate([-x_in, 0, 0]) side();
else if (part == "side_left")    translate([ x_in, 0, 0]) mirror([1, 0, 0]) side();
