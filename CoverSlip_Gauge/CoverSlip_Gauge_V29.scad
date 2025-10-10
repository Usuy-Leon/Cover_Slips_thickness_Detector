
// COVER-SLIP THICKNESS GAUGE — Back Plate v29
/* 
                             COVER-SLIP THICKNESS GAUGE — Back Plate v29
                    
   Dark Field Filters v29

A device to messure CoverSlips in an easy and reliable way

This 3D file is designed to be for microscopy enthusiast and professionals.
     
Source :https://github.com/Usuy-Leon/CoverSlip_Gauge
Inspired on the beutifull work of Shinya Inoue

This project is an Open Source project,
by Usuy D. Leon, 2025.10.26
Microscopist, National University of Colombia, Bogota DC,

    */
// 
// =======================================================================

part = "assembly";  // "base", "back", or "assembly"
show_debug = true;  
$fn = 120;

// ---------------- GLOBAL PARAMETERS ----------------
base_x = 20; base_y = 8; base_z = 2;
back_h = 8; back_thick = base_z; clearance = 0.05;  // tight fit

// Joinery
edge_margin = 2;
joint_pairs = 5;
finger_h = base_z / 2;
available_width = base_x - 2 * edge_margin;
n_segments = 2 * joint_pairs - 1;
seg_w = available_width / n_segments;
male_w = seg_w - clearance;
cavity_w = seg_w + clearance;

// Shim
shim_thick = 0.20;
shim_length = (base_x - 2) / 2;
shim_z = base_z + back_h / 2 - shim_thick / 2;
shim_y = base_y - back_thick - shim_thick;

// Coverslip recess
recess_w = 2;
recess_h = 8;
recess_depth = 1;
recess_x = (base_x - recess_w) / 2;
recess_z = base_z + (back_h - recess_h) / 3;

// Blade-holding plates (one on each side of recess)
blade_thick = 0.8;       
blade_gap = 0.2;         
blade_height = back_h;  
blade_y_front = shim_y - blade_gap - blade_thick;

// Left and right blade-holder x dimensions
blade_left_x = 0;
blade_right_x = recess_x + recess_w;
blade_left_len = recess_x;                 
blade_right_len = base_x - (recess_x + recess_w);

// Tweezer tip taper (thinning near the recess)
taper_len = 1.5;        // how far the taper goes inward
taper_thin = 0;       // final thickness at the inner edge

// M2 screw holes (2 per side)
m2_diam = 2.1; // clearance for M2 screws
m2_rad = m2_diam / 2;
hole_offset_x1 = 4;
hole_offset_x2 = 16;
hole_offset_z = base_z + back_h / 2; // centered vertically
hole_positions = [
    [hole_offset_x1, hole_offset_z],
    [hole_offset_x2, hole_offset_z]
];

// Precision scale (0.15–0.20)
start_value = 0.15;
end_value   = 0.19;
major_step  = 0.01;
minor_step  = 0.005;
scale_length = 5.0;
tick_depth  = 0.35;
tick_long   = 0.9;
tick_short  = 0.45;
font_size   = 0.2;
font_depth  = 0.3;
text_v_gap  = 1.1;
scale_center_x = (base_x) / 2;
scale_center_y = base_y / 3;

// ---- Helper: format exactly two decimals ----
function fmt2(x) =
    let(v = round(x * 100))
    str(floor(v / 100), ".", (v % 100 < 10 ? "0" : ""), v % 100);

// =======================================================================
// BASE PLATE
// =======================================================================
module base_plate() {
    difference() {
        color("silver") cube([base_x, base_y, base_z]);

        // joinery cavities (odd segments)
        for (seg = [0 : n_segments - 1]) {
            if (seg % 2 == 1) {
                seg_x = edge_margin + seg * seg_w;
                cx = seg_x - (cavity_w - seg_w) / 2;
                translate([cx, base_y - base_z, base_z - finger_h])
                    cube([cavity_w, base_z, finger_h + 0.02]);
            }
        }

        // tick + label engraving
        total_minor = floor((end_value - start_value) / minor_step + 0.001);
        total_major = floor((end_value - start_value) / major_step + 0.001);
        spacing = scale_length / total_minor;
        scale_start = scale_center_x - (scale_length / 2);

        for (i = [0 : total_minor]) {
            x_tick = scale_start + i * spacing;
            tick_len = (i % 2 == 0) ? tick_long : tick_short;
            translate([x_tick, scale_center_y - tick_len / 2, base_z - tick_depth])
                cube([0.04, tick_len, tick_depth]);
        }

        for (k = [0 : total_major]) {
            val = start_value + k * major_step;
            label = fmt2(val);
            x_num = scale_start + (k * (major_step / minor_step)) * spacing;
            translate([x_num, scale_center_y - tick_long / 2 - text_v_gap, base_z - font_depth])
                linear_extrude(height = font_depth)
                    text(label, size = font_size, halign = "center", valign = "top");
        }
    }

    // male joinery teeth (even segments, skip center)
    for (seg = [0 : n_segments - 1]) {
        if (seg % 2 == 0 && seg != floor(n_segments / 2)) {
            seg_x = edge_margin + seg * seg_w;
            mx = seg_x + (seg_w - male_w) / 2;
            translate([mx, base_y - base_z, base_z])
                color([0.78, 0.62, 0.4])
                cube([male_w, base_z, finger_h]);
        }
    }
}

// =======================================================================
// BACK PLATE
// =======================================================================
module tapered_plate(x_pos, y_pos, length, color_name) {
    color(color_name)
    hull() {
        translate([x_pos, y_pos, base_z]) cube([length, blade_thick, blade_height]);
        translate([x_pos + length - taper_len, y_pos, base_z]) cube([taper_len, taper_thin, blade_height]);
    }
}

module back_plate() {
    difference() {
        union() {
            // Main wall
            color("lightblue")
                translate([0, base_y - back_thick, base_z])
                    cube([base_x, back_thick, back_h]);

            // Shim I decided to duion it to the structure, color to debugg
            if (show_debug)
                color("magenta")
                    translate([0, shim_y, shim_z - 3])
                        cube([shim_length, shim_thick, 6]);
            else
                color("deepskyblue")
                    translate([0, shim_y, base_z + back_h - shim_thick])
                        cube([shim_length, shim_thick, shim_thick]);

            // Downward Kigumi teeth (odd segments)
            for (seg = [0 : n_segments - 1]) {
                if (seg % 2 == 1) {
                    seg_x = edge_margin + seg * seg_w;
                    tx = seg_x + (seg_w - male_w) / 2;
                    translate([tx, base_y - back_thick, base_z - finger_h])
                        color([0.72, 0.55, 0.4])
                            cube([male_w, back_thick, finger_h]);
                }
            }

            // Blade holder plates 
            tapered_plate(blade_left_x, blade_y_front, blade_left_len, "orange");
            tapered_plate(blade_right_x, blade_y_front, blade_right_len, "orange");
        }

        // Cavities for even segments (fit base)
        for (seg = [0 : n_segments - 1]) {
            if (seg % 2 == 0 && seg != floor(n_segments / 2)) {
                seg_x = edge_margin + seg * seg_w;
                cx = seg_x - (cavity_w - seg_w) / 2;
                translate([cx, base_y - back_thick - 0.01, base_z])
                    cube([cavity_w, back_thick + 0.02, finger_h + 0.02]);
            }
        }

        // Central recess for coverslip
        translate([recess_x+1, base_y - back_thick - 0.001, recess_z])
            cylinder(h=20, r=1.25, center=true);

        // M2 screw holes through both blade holders + back plate 
        for (p = hole_positions) {
            x_h = p[0];
            z_h = p[1];
            // Centered through both blade holders and back plate
            y_center = blade_y_front + blade_thick / 2 + (shim_thick + blade_gap * 2 + back_thick) / 2;
            total_depth = blade_thick * 2 + shim_thick + blade_gap * 2 + back_thick + 0.4;
            translate([x_h, y_center, z_h])
                rotate([90, 0, 0])
                    color("black")
                    cylinder(h = total_depth, r = m2_rad, center = true);
        }
    }
}

// =======================================================================
// Others ......................
// =======================================================================
module assembly() {
    rotate([-90, 0, 0]) {
        base_plate();
        back_plate();
    }
}

if (part == "base") {
    rotate([-90, 0, 0]) base_plate();
} else if (part == "back") {
    rotate([-90, 0, 0]) back_plate();
} else {
    assembly();
}
