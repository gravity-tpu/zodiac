// ====================================================================
// ZODIAC FX - "PANINI" MODULAR 3D CASING (SCREENLESS EDITION)
// Inspired by ROBOCO Panini Jetson Case Design Language
// Designed for Northbound Networks Zodiac FX 4-Port OpenFlow Switch
// ====================================================================

$fn = 40; // Circle facet resolution

// --- SELECT PART TO RENDER ---
// Options: "assembly", "bottom_tray", "top_cover", "front_bezel", "clamp_bracket"
render_part = "assembly"; 

// --- BOARD & COMPONENT DIMENSIONS (mm) ---
board_w = 100.0;          // PCB Width (X)
board_d = 80.0;           // PCB Depth (Y)
board_t = 1.6;            // PCB Thickness (Z)
board_clearance = 0.6;    // Per-side clearance tolerance
pcb_elevation = 5.5;      // Height of PCB underside above inner floor

// Mounting Holes (Top/Rear corners)
hole_rear_offset = 4.0;   // Distance from rear PCB edge to hole center
hole_side_offset = 4.0;   // Distance from side PCB edge to hole center
standoff_od = 7.0;        // Standoff outer diameter
insert_hole_d = 4.2;      // Pilot hole for M3 heat-set threaded insert (Ruthex style)
insert_depth = 5.5;

// RJ45 Ethernet Jacks (Shareway SRJ2113ABNL)
rj45_w = 16.2;            // Jack width
rj45_h = 13.8;            // Jack height above PCB
rj45_pitch = 19.5;        // Center-to-center spacing
rj45_overhang = 3.2;      // Port protrusion past front PCB edge
rj45_group_start_x = 9.5; // Offset from left board edge to center of Port 1

// Micro-USB Power / CLI Port (Rear edge)
usb_w = 9.0;
usb_h = 4.5;
usb_x_center = 15.0;      // Distance from left board edge

// --- ENCLOSURE EXTERNAL ENVELOPE ---
wall = 2.5;               // Base wall thickness
corner_r = 6.0;           // Outer fillet radius (Signature Panini soft corners)

inner_w = board_w + 2 * board_clearance; // 101.2 mm
inner_d = board_d + 2 * board_clearance + 12.0; // 93.2 mm (leaves room for front bezel & rear thumbscrew clamp)
inner_h = 28.0;           // Total internal height

outer_w = inner_w + 2 * wall; // ~106.2 mm
outer_d = inner_d + 2 * wall; // ~98.2 mm
outer_h = inner_h + wall;     // ~30.5 mm

// --- VENTILATION GRID PARAMETERS ---
vent_hole_size = 2.6;
vent_wall_size = 1.4;
vent_pitch = vent_hole_size + vent_wall_size;

// --- COLOR PALETTE (Panini Dual-Tone) ---
color_mint    = [0.45, 0.75, 0.66, 1.0]; // Panini accent bezel (Sage/Mint)
color_chassis = [0.93, 0.93, 0.91, 1.0]; // Off-white / light putty shell
color_dark    = [0.20, 0.22, 0.24, 1.0]; // Dark gray base tray & accents
color_pcb     = [0.10, 0.10, 0.10, 0.9]; // Matte black Zodiac FX PCB
color_metal   = [0.78, 0.80, 0.82, 1.0]; // RJ45 silver shield & brass
color_leather = [0.55, 0.32, 0.18, 1.0]; // Brown leather pull strap

// ====================================================================
// UTILITY MODULES
// ====================================================================

// Rounded box centered at origin in X and Y
module rounded_box(w, d, h, r) {
    hull() {
        translate([-w/2 + r, -d/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r, -d/2 + r, 0]) cylinder(r=r, h=h);
        translate([-w/2 + r,  d/2 - r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r,  d/2 - r, 0]) cylinder(r=r, h=h);
    }
}

// ====================================================================
// MODULE 1: BOTTOM CHASSIS TRAY
// ====================================================================
module bottom_tray() {
    color(color_dark)
    difference() {
        union() {
            // Main tray body with side slide rails
            rounded_box(outer_w, outer_d, outer_h * 0.45, corner_r);

            // Integrated PCB Standoffs (Rear Left & Rear Right)
            // Standoff rear left
            translate([-inner_w/2 + hole_side_offset, inner_d/2 - 14.0 - hole_rear_offset, wall])
                cylinder(d=standoff_od, h=pcb_elevation);
            
            // Standoff rear right
            translate([inner_w/2 - hole_side_offset, inner_d/2 - 14.0 - hole_rear_offset, wall])
                cylinder(d=standoff_od, h=pcb_elevation);

            // Side PCB Resting Ledges (Slide channels)
            translate([-inner_w/2, -inner_d/2 + 10, wall])
                cube([2.0, inner_d - 25, pcb_elevation]);
            translate([inner_w/2 - 2.0, -inner_d/2 + 10, wall])
                cube([2.0, inner_d - 25, pcb_elevation]);

            // Rear Thumbscrew Bosses (Left and Right sides)
            translate([-outer_w/2 - 3.0, inner_d/2 - 10, 0])
                cube([3.0, 8.0, outer_h * 0.45]);
            translate([outer_w/2, inner_d/2 - 10, 0])
                cube([3.0, 8.0, outer_h * 0.45]);
        }

        // Hollow interior pocket
        translate([0, 0, wall])
            rounded_box(inner_w, inner_d, outer_h, corner_r - wall/2);

        // Pilot holes for M3 Heat-Set Inserts in Rear Standoffs
        translate([-inner_w/2 + hole_side_offset, inner_d/2 - 14.0 - hole_rear_offset, wall + pcb_elevation - insert_depth])
            cylinder(d=insert_hole_d, h=insert_depth + 1.0);
        translate([inner_w/2 - hole_side_offset, inner_d/2 - 14.0 - hole_rear_offset, wall + pcb_elevation - insert_depth])
            cylinder(d=insert_hole_d, h=insert_depth + 1.0);

        // Bottom Ventilation Grid (Signature Panini Matrix)
        for (vx = [-30 : vent_pitch : 30]) {
            for (vy = [-25 : vent_pitch : 20]) {
                translate([vx, vy, -1])
                    cube([vent_hole_size, vent_hole_size, wall + 2]);
            }
        }

        // 4x Rubber Foot Inset Pockets (Bottom corners)
        translate([-outer_w/2 + 10, -outer_d/2 + 10, -0.5])
            cylinder(d=9.0, h=1.5);
        translate([ outer_w/2 - 10, -outer_d/2 + 10, -0.5])
            cylinder(d=9.0, h=1.5);
        translate([-outer_w/2 + 10,  outer_d/2 - 10, -0.5])
            cylinder(d=9.0, h=1.5);
        translate([ outer_w/2 - 10,  outer_d/2 - 10, -0.5])
            cylinder(d=9.0, h=1.5);

        // Rear Micro-USB Port Cutout
        translate([-inner_w/2 + usb_x_center - usb_w/2, inner_d/2 - 2, wall + pcb_elevation + board_t])
            cube([usb_w, wall + 5, usb_h + 1.5]);

        // Front Cutout for Bezel Interlock
        translate([-inner_w/2 - 1, -outer_d/2 - 1, wall])
            cube([inner_w + 2, wall + 2, outer_h]);

        // M3 Thumbscrew Threaded Holes on Sides
        translate([-outer_w/2 - 4, inner_d/2 - 6, (outer_h * 0.45) / 2])
            rotate([0, 90, 0]) cylinder(d=3.2, h=outer_w + 8);
    }
}

// ====================================================================
// MODULE 2: FRONT BEZEL (SCREENLESS PANINI RETRO-INSTRUMENT EDITION)
// ====================================================================
module front_bezel() {
    bezel_depth = 9.0;
    color(color_mint)
    difference() {
        // Outer curved face
        translate([0, -outer_d/2 + bezel_depth/2, outer_h/2])
            rotate([90, 0, 0])
            rounded_box(outer_w, outer_h, bezel_depth, corner_r);

        // Inner frame recess (Panini beveled accent frame)
        translate([0, -outer_d/2 + bezel_depth - 1.5, outer_h/2])
            rotate([90, 0, 0])
            rounded_box(outer_w - 7.0, outer_h - 7.0, bezel_depth, corner_r - 2.0);

        // 4x RJ45 Ethernet Port Cutouts (Grouped symmetrically on the left/center)
        for (i = [0 : 3]) {
            px = -inner_w/2 + rj45_group_start_x + (i * rj45_pitch);
            py = -outer_d/2 - 1.0;
            pz = wall + pcb_elevation + board_t;
            translate([px - rj45_w/2, py, pz]) {
                // Main plug entry
                cube([rj45_w, bezel_depth + 4, rj45_h]);
                // Latch release clearance slot at bottom
                translate([rj45_w/2 - 3.5, 0, -2.5])
                    cube([7.0, bezel_depth + 4, 3.0]);
            }
        }

        // Dual Recessed Pushbutton / Status Pin Openings (Right flank)
        // Upper button: Reset / Status
        translate([outer_w/2 - 13.0, -outer_d/2 - 1.0, outer_h * 0.58])
            rotate([-90, 0, 0])
            cylinder(d=6.2, h=bezel_depth + 2.0);

        // Lower button: Mode / Power
        translate([outer_w/2 - 13.0, -outer_d/2 - 1.0, outer_h * 0.38])
            rotate([-90, 0, 0])
            cylinder(d=6.2, h=bezel_depth + 2.0);

        // Debossed "ZODIAC FX" Nameplate (Screenless Replacement)
        translate([outer_w/2 - 24.0, -outer_d/2 + 0.6, outer_h * 0.18])
            rotate([90, 0, 0])
            linear_extrude(height = 1.0)
                text("ZODIAC FX", size=3.2, font="Liberation Sans:style=Bold", halign="center");
    }
}

// ====================================================================
// MODULE 3: TOP SLIDING PERFORATED HOOD
// ====================================================================
module top_cover() {
    color(color_chassis)
    difference() {
        union() {
            // Main curved shell
            difference() {
                translate([0, 0, outer_h * 0.35])
                    rounded_box(outer_w, outer_d, outer_h * 0.65, corner_r);
                
                // Hollow core
                translate([0, 0, outer_h * 0.35 - 1.0])
                    rounded_box(inner_w + 0.5, inner_d + 0.5, outer_h * 0.65 + 2.0, corner_r - wall/2);
            }

            // Top plate with curved edge transition
            translate([0, 0, outer_h - wall])
                rounded_box(outer_w, outer_d, wall, corner_r);

            // Rear Pull-Strap Anchor Tab
            translate([0, outer_d/2 + 1.5, outer_h - 4.5])
                cube([18.0, 3.0, 4.0], center=true);

            // Rear Thumbscrew Side Wings
            translate([-outer_w/2 - 3.0, inner_d/2 - 10, outer_h * 0.35])
                cube([3.0, 8.0, 10.0]);
            translate([outer_w/2, inner_d/2 - 10, outer_h * 0.35])
                cube([3.0, 8.0, 10.0]);
        }

        // Signature Panini Perforated Ventilation Matrix across Top Face
        for (vx = [-36 : vent_pitch : 36]) {
            for (vy = [-30 : vent_pitch : 28]) {
                translate([vx, vy, outer_h - wall - 1])
                    cube([vent_hole_size, vent_hole_size, wall + 3]);
            }
        }

        // Side Flank Ventilation Slots
        for (sy = [-25 : vent_pitch * 1.5 : 25]) {
            for (sz = [outer_h * 0.55 : 3.5 : outer_h * 0.85]) {
                // Left flank
                translate([-outer_w/2 - 1, sy, sz])
                    cube([wall + 2, vent_hole_size, 2.0]);
                // Right flank
                translate([outer_w/2 - wall - 1, sy, sz])
                    cube([wall + 2, vent_hole_size, 2.0]);
            }
        }

        // Slot for Leather / TPU Pull Strap (15mm wide x 2mm thick)
        translate([0, outer_d/2, outer_h - 4.5])
            cube([15.2, 8.0, 2.2], center=true);

        // Thumbscrew Holes (Ø3.4mm clearance for M3 thumbscrews)
        translate([-outer_w/2 - 4, inner_d/2 - 6, (outer_h * 0.45) / 2 + 5])
            rotate([0, 90, 0]) cylinder(d=3.4, h=outer_w + 8);
    }
}

// ====================================================================
// MODULE 4: BOARD HOLD-DOWN CLAMP BRACKET (Tool-Free Locking Wedge)
// ====================================================================
module clamp_bracket() {
    color(color_dark)
    difference() {
        union() {
            cube([16.0, 14.0, 3.5]);
            translate([0, 0, 3.5])
                cube([16.0, 6.0, 2.5]); // Downward lip pressing on PCB
        }
        // Center slot for M3 thumbscrew
        translate([8.0, 7.0, -1])
            cylinder(d=3.5, h=8.0);
    }
}

// ====================================================================
// SIMULATED PCB & ACCESSORIES FOR PREVIEW
// ====================================================================
module dummy_zodiac_pcb() {
    translate([-board_w/2, -inner_d/2 + 8.0, wall + pcb_elevation]) {
        // PCB substrate
        color(color_pcb)
            cube([board_w, board_d, board_t]);

        // 4x RJ45 Jacks
        for (i = [0 : 3]) {
            color(color_metal)
            translate([rj45_group_start_x + (i * rj45_pitch) - rj45_w/2, -rj45_overhang, board_t])
                cube([rj45_w, 21.5, rj45_h]);
        }

        // Micro-USB Jack
        color(color_metal)
        translate([usb_x_center - usb_w/2, board_d - 1.0, board_t])
            cube([usb_w, 6.5, usb_h]);

        // ATSAM4E8C MCU & KSZ8795 Switch ICs
        color([0.15, 0.15, 0.15])
        translate([55.0, 35.0, board_t])
            cube([16.0, 16.0, 1.8]); // SAM4E
        color([0.15, 0.15, 0.15])
        translate([25.0, 25.0, board_t])
            cube([14.0, 14.0, 1.6]); // KSZ8795
        
        // 2x4 SPI Header
        color([0.2, 0.2, 0.2])
        translate([45.0, board_d - 8.0, board_t])
            cube([10.16, 5.08, 8.5]);

        // 2x5 JTAG Header
        color([0.2, 0.2, 0.2])
        translate([board_w - 7.0, 45.0, board_t])
            cube([5.08, 12.7, 8.5]);
    }
}

// Leather Pull Strap Preview
module dummy_pull_strap() {
    color(color_leather)
    translate([0, outer_d/2 + 7.0, outer_h - 4.5])
        rotate([90, 0, 0])
        difference() {
            cylinder(r=7.0, h=14.0, center=true);
            cylinder(r=5.0, h=15.0, center=true);
        }
}

// Knurled Thumbscrews Preview
module dummy_thumbscrews() {
    color([0.15, 0.15, 0.15]) {
        translate([-outer_w/2 - 4.5, inner_d/2 - 6, (outer_h * 0.45)/2 + 5])
            rotate([0, 90, 0]) cylinder(d=9.0, h=5.0, center=true);
        translate([outer_w/2 + 4.5, inner_d/2 - 6, (outer_h * 0.45)/2 + 5])
            rotate([0, 90, 0]) cylinder(d=9.0, h=5.0, center=true);
    }
}

// ====================================================================
// MAIN DISPATCHER
// ====================================================================
if (render_part == "assembly") {
    bottom_tray();
    top_cover();
    front_bezel();
    dummy_zodiac_pcb();
    dummy_pull_strap();
    dummy_thumbscrews();
} else if (render_part == "bottom_tray") {
    bottom_tray();
} else if (render_part == "top_cover") {
    // Oriented for 3D printing (flat top on build plate)
    translate([0, 0, outer_h])
        rotate([180, 0, 0])
        top_cover();
} else if (render_part == "front_bezel") {
    // Oriented flat on front face for crisp text
    translate([0, -outer_d/2, 0])
        rotate([-90, 0, 0])
        front_bezel();
} else if (render_part == "clamp_bracket") {
    clamp_bracket();
}
