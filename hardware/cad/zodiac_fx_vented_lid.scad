// ====================================================================
// ZODIAC FX — VENTED LID (based on mrtugs community case)
// Thingiverse: https://www.thingiverse.com/thing:4766265
//
// Imports the validated community lid (correct board fit, tested clips)
// and subtracts a high-density ventilation grid from the top face.
//
// Print: base from ZodiacFXCase_Base.stl (UNCHANGED — perfect as-is)
//        lid  from this file (vented modification)
// ====================================================================

$fn = 32;

// Lid geometry from trimesh inspection of original STL:
//   X: -54.08 → +54.08   width  = 108.16mm
//   Y: -2.00  → +86.15   depth  =  88.15mm
//   Z: -1.76  → +25.80   height =  27.56mm

lid_x0    = -54.08;
lid_y0    = -2.00;
lid_w     = 108.16;
lid_d     = 88.15;
lid_top_z = 25.80;    // top face Z
wall_t    = 2.4;      // top skin to preserve

// Ventilation grid
vent_size  = 2.8;     // square hole (mm)
vent_pitch = 4.5;     // center-to-center
vent_margin = 7.0;    // edge keep-out
vent_depth  = wall_t + 2.0;  // punch depth

module vent_grid() {
    x_start = lid_x0 + vent_margin;
    x_end   = lid_x0 + lid_w - vent_margin - vent_size;
    y_start = lid_y0 + vent_margin;
    y_end   = lid_y0 + lid_d - vent_margin - vent_size;
    z_start = lid_top_z - wall_t - 0.5;

    for (gx = [x_start : vent_pitch : x_end]) {
        for (gy = [y_start : vent_pitch : y_end]) {
            translate([gx, gy, z_start])
                cube([vent_size, vent_size, vent_depth]);
        }
    }
}

difference() {
    import("thingiverse_base/files/ZodiacFXCase_Lid.stl", convexity=10);
    vent_grid();
}
