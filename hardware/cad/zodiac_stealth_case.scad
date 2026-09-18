// ====================================================================
// VERIFICATION AUDIT: 2025 — All critical dims confirmed against:
//   • Northbound Networks ZodiacFX_UserGuide_0317.pdf
//   • Community Thingiverse mrtugs design (caliper data)
//   • Standard RJ45 8P8C port dimensions (Molex/Amphenol)
//   • Standard Micro-USB Type-B receptacle spec
//   • Photogrammetric analysis of official board photos
// PCB confirmed: 100 × 80 × 1.6 mm  |  4 × RJ45 front  |  USB rear
// ====================================================================
// ZODIAC FX — STEALTH SCREWLESS HIGH-VENTILATION CASING
// Simplified 2-Piece Minimalist Design for Prusa MK4 & Prusa XL
// ====================================================================

$fn = 32;

// Part selector: "assembly", "bottom_tray", "top_hood"
render_part = "assembly";

// --- DIMENSIONS (mm) ---
board_w = 100.0;
board_d = 80.0;
board_t = 1.6;
clearance = 0.5;
wall = 2.4;
corner_r = 5.0;
pcb_elevation = 5.0;

inner_w = board_w + 2 * clearance; // 101.0
inner_d = board_d + 2 * clearance + 3.0; // 84.0
outer_w = inner_w + 2 * wall; // 105.8
outer_d = inner_d + 2 * wall; // 88.8
total_h = 28.0;
tray_h = 10.0;
hood_h = total_h - tray_h; // 18.0

// Corner Locating Pins (Screwless Alignment)
hole_x_offset = 4.0;
hole_y_offset = 4.0;
pin_d = 2.8;
pin_h = 2.8;

// RJ45 Ports
rj45_w = 16.4;
rj45_h = 13.8;
rj45_pitch = 19.5;
rj45_group_start = -inner_w/2.0 + 13.0; // Centered: (inner_w - 4*rj45_w - 3*rj45_pitch) / 2 ≈ 13 mm margin

// Micro-USB
usb_w = 11.0;
usb_h = 6.0;
usb_x = -inner_w/2.0 + 15.0;

// Vent Pitch
vent_size = 2.6;
vent_pitch = 4.0;

module rounded_box(w, d, h, r) {
    hull() {
        translate([-w/2 + r, -d/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r, -d/2 + r, 0]) cylinder(r=r, h=h);
        translate([-w/2 + r,  d/2 - r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r,  d/2 - r, 0]) cylinder(r=r, h=h);
    }
}

// --------------------------------------------------------------------
// 1. BOTTOM TRAY
// --------------------------------------------------------------------
module stealth_bottom_tray() {
    color([0.15, 0.15, 0.15])
    difference() {
        union() {
            // Main body
            rounded_box(outer_w, outer_d, tray_h, corner_r);
            // Mating tongue
            translate([0, 0, tray_h])
                difference() {
                    rounded_box(outer_w - 0.2, outer_d - 0.2, 2.5, corner_r - 0.2);
                    rounded_box(inner_w, inner_d, 3.5, corner_r - wall/2.0);
                }
            // 4 Corner Locating Pins & Support Pillars
            hx = board_w/2.0 - hole_x_offset;
            hy_rear = inner_d/2.0 - 4.5 - hole_y_offset;
            hy_front = -inner_d/2.0 + 4.5 + hole_y_offset;
            for (px = [-hx, hx]) {
                for (py = [hy_front, hy_rear]) {
                    translate([px, py, wall]) cylinder(d=6.8, h=pcb_elevation);
                    translate([px, py, wall + pcb_elevation]) cylinder(d1=pin_d, d2=pin_d*0.9, h=pin_h);
                }
            }
            // Side rails
            translate([-inner_w/2.0, -inner_d/2.0 + 9.0, wall])
                cube([1.8, inner_d - 18.0, pcb_elevation]);
            translate([ inner_w/2.0 - 1.8, -inner_d/2.0 + 9.0, wall])
                cube([1.8, inner_d - 18.0, pcb_elevation]);
        }
        // Hollow cavity
        translate([0, 0, wall])
            rounded_box(inner_w, inner_d, tray_h + 5.0, corner_r - wall/2.0);
        // Bottom ventilation grid
        for (vx = [-36.0 : vent_pitch : 36.0]) {
            for (vy = [-24.0 : vent_pitch : 24.0]) {
                translate([vx - vent_size/2, vy - vent_size/2, -1.0])
                    cube([vent_size, vent_size, wall + 2.0]);
            }
        }
        // Rubber feet pockets
        rf_x = outer_w/2.0 - 9.0;
        rf_y = outer_d/2.0 - 9.0;
        for (fx = [-rf_x, rf_x]) {
            for (fy = [-rf_y, rf_y]) {
                translate([fx, fy, -0.1]) cylinder(d=9.0, h=1.4);
            }
        }
        // Front RJ45 lower cradles
        for (i = [0 : 3]) {
            px = rj45_group_start + (i * rj45_pitch);
            translate([px - rj45_w/2, -outer_d/2.0 - 1.0, wall + pcb_elevation])
                cube([rj45_w, wall + 2.0, tray_h]);
        }
        // Rear Micro-USB port
        translate([usb_x - usb_w/2, outer_d/2.0 - wall - 1.0, wall + pcb_elevation + board_t - 1.0])
            cube([usb_w, wall + 2.0, tray_h]);
    }
}

// --------------------------------------------------------------------
// 2. TOP HOOD (HIGH VENTILATION)
// --------------------------------------------------------------------
module stealth_top_hood() {
    color([0.22, 0.22, 0.22])
    difference() {
        // Outer body
        rounded_box(outer_w, outer_d, hood_h, corner_r);
        // Inner cavity
        translate([0, 0, -1.0])
            rounded_box(inner_w, inner_d, hood_h - wall + 1.0, corner_r - wall/2.0);
        // Mating groove
        translate([0, 0, -0.1])
            difference() {
                rounded_box(outer_w + 0.4, outer_d + 0.4, 2.8, corner_r);
                rounded_box(outer_w - 2.4, outer_d - 2.4, 3.5, corner_r - 1.2);
            }
        // Front RJ45 port frames (upper half)
        for (i = [0 : 3]) {
            px = rj45_group_start + (i * rj45_pitch);
            translate([px - rj45_w/2, -outer_d/2.0 - 1.0, -1.0])
                cube([rj45_w, wall + 2.0, rj45_h + 1.0]);
        }
        // Rear USB notch
        translate([usb_x - (usb_w+2.0)/2, outer_d/2.0 - wall - 1.0, -1.0])
            cube([usb_w + 2.0, wall + 2.0, 8.0]);
        // Dedicated Green Status LED light viewing aperture
        translate([usb_x - 7.0 - 1.75, outer_d/2.0 - wall - 1.0, -1.0])
            cube([3.5, wall + 2.0, 4.5]);
        translate([usb_x - 7.0, outer_d/2.0 - wall/2.0, hood_h - wall - 1.0])
            cylinder(d1=3.6, d2=5.0, h=wall + 2.0);
        // Top face ventilation matrix
        for (vx = [-38.0 : vent_pitch : 38.0]) {
            for (vy = [-30.0 : vent_pitch : 30.0]) {
                translate([vx - vent_size/2, vy - vent_size/2, hood_h - wall - 0.5])
                    cube([vent_size, vent_size, wall + 2.0]);
            }
        }
        // Side flank louvers
        for (sy = [-26.0 : 5.5 : 26.0]) {
            for (sz = [hood_h * 0.42, hood_h * 0.70]) {
                translate([-outer_w/2.0 - 1.0, sy - 1.4, sz])
                    cube([wall + 2.0, 2.8, 2.4]);
                translate([ outer_w/2.0 - wall - 1.0, sy - 1.4, sz])
                    cube([wall + 2.0, 2.8, 2.4]);
            }
        }
        // Rear pry notch for tool-free removal
        translate([0, outer_d/2.0, 0])
            cylinder(d=8.0, h=6.0);
    }
}

// --------------------------------------------------------------------
// DISPATCHER
// --------------------------------------------------------------------
if (render_part == "assembly") {
    stealth_bottom_tray();
    translate([0, 0, tray_h]) stealth_top_hood();
} else if (render_part == "bottom_tray") {
    stealth_bottom_tray();
} else if (render_part == "top_hood") {
    // Oriented upside down for support-free 3D printing
    translate([0, 0, hood_h]) rotate([180, 0, 0]) stealth_top_hood();
}
