/*
 * Derivative trash can to use as "poop" collector for Kobra S1 3d printer.
 */

// Trash Can Parameters
can_width = 150;         // Outer width (X-axis)
can_depth = 75;          // Outer depth (Y-axis)
can_height = 220;        // Outer height (Z-axis)
notch_width = 30;        // Notch for poop
notch_height = 175;
notch_offset = 110;
wall_thickness = 2;      // Thickness of the walls
base_thickness = 3;      // Thickness of the base
corner_radius = 10;      // Radius for outer corners
notch_corner_radius = 10;      // Radius for outer corners

// Hexagonal Hole Parameters
hole_diameter = 5;      // Circumscribed diameter of the hexagon (vertex to vertex)
hole_spacing_x = 8;     // Center-to-center spacing of holes horizontally on faces
hole_spacing_z = 8;     // Center-to-center spacing of holes vertically on faces
hole_margin_sides = 10;   // Margin from side edges of a face to the first/last hole center
hole_margin_top_bottom = 10; // Margin from top/bottom edges of wall to first/last hole center

// Render Quality
$fn_smooth = 48; // For rounded corners and general smoothness
$fn_hex = 6;     // For hexagons (always 6)

// --- Derived Parameters & Helper calculations ---
// Inner dimensions for the cavity
inner_width = can_width - 2 * wall_thickness;
inner_depth = can_depth - 2 * wall_thickness;
inner_height = can_height - base_thickness;
inner_corner_radius = max(0.01, corner_radius - wall_thickness); // Avoid negative or zero radius

// Effective dimensions of a "pointy-top" hexagon on the face
hex_eff_width_on_face = hole_diameter * cos(30); // Width across flats
hex_eff_height_on_face = hole_diameter;          // Height point-to-point

// --- Modules ---

// Module for a 2D rounded rectangle
module rounded_rectangle_2d(size, radius, _fn, _ctr=true) {
    minkowski() {
        square([size[0] - 2 * radius, size[1] - 2 * radius], center = _ctr);
        circle(r = radius, $fn = _fn);
    }
}

// Module for a single hexagonal prism cutter (pointy-top orientation)
module hex_cutter_prism(dia, len) {
    rotate([0, 0, 30]) // Orient hexagon to be "pointy-top" along its local Y-axis
        cylinder(d = dia, h = len, $fn = $fn_hex, center = true);
}

// Module for the solid body of the trash can
module trash_can_solid_body() {
    difference() {
        // Outer solid
        linear_extrude(height = can_height)
            rounded_rectangle_2d([can_width, can_depth], corner_radius, _fn = $fn_smooth);

        // Inner cavity
        translate([0, 0, base_thickness])
            linear_extrude(height = inner_height + 0.1) // +0.1 for clean subtraction
                rounded_rectangle_2d([inner_width, inner_depth],
                                      inner_corner_radius, _fn = $fn_smooth);
        
        // notch
        translate([notch_offset - can_width/2, -can_depth/2, notch_height])
            rotate([90,0,0])
                linear_extrude(wall_thickness*3, center = true)
                    rounded_rectangle_2d(
                        [notch_width, notch_height],
                        notch_corner_radius, _fn = $fn_smooth, _ctr = false);
    }
}

// Module to generate all hole cutters
module all_hole_cutters() {
    cutter_length = max(can_width, can_depth) * 1.5; // Ensure cutters pass through

    // --- Holes on Front/Back faces (along Y-axis) ---
    face_width_for_x_holes = can_width;
    // Available width for hole pattern centers
    available_pattern_span_x = face_width_for_x_holes - 2 * hole_margin_sides - hex_eff_width_on_face;
    if (available_pattern_span_x >= 0) {
        num_holes_x = floor(available_pattern_span_x / hole_spacing_x) + 1;
        actual_pattern_width_centers_x = (num_holes_x - 1) * hole_spacing_x;
        start_x = -actual_pattern_width_centers_x / 2;

        // Available height for hole pattern centers
        available_wall_height = can_height - base_thickness - 2 * hole_margin_top_bottom;
        echo(can_height);
        echo(available_wall_height);
        available_pattern_span_z = available_wall_height - hex_eff_height_on_face;
        
        if (available_pattern_span_z >= 0) {
            num_holes_z = floor(available_pattern_span_z / hole_spacing_z) + 1;
            actual_pattern_height_centers_z = (num_holes_z - 1) * hole_spacing_z;
            start_z_center = base_thickness + hole_margin_top_bottom + hex_eff_height_on_face/2 + 
                             (available_pattern_span_z - actual_pattern_height_centers_z)/2;

            for (i = [0 : num_holes_x-1]) {
                for (j = [0 : num_holes_z-1]) {
                    x = start_x + i * hole_spacing_x;
                    z = start_z_center + j * hole_spacing_z;
                    back_only = (z > (notch_height - 2*hole_margin_top_bottom));
                    y_offset = back_only ? cutter_length/2 : 0;
                    translate([x, y_offset, z])
                        rotate([90, 0, 0]) // Align cutter axis with Y
                            hex_cutter_prism(hole_diameter, cutter_length);
                }
            }
        }
    }

    // --- Holes on Left/Right faces (along X-axis) ---
    face_width_for_y_holes = can_depth;
    // Available "width" (along Y) for hole pattern centers on side faces
    available_pattern_span_y = face_width_for_y_holes - 2 * hole_margin_sides - hex_eff_width_on_face;
     if (available_pattern_span_y >= 0) {
        num_holes_y = floor(available_pattern_span_y / hole_spacing_x) + 1; // Using hole_spacing_x for consistency
        actual_pattern_width_centers_y = (num_holes_y - 1) * hole_spacing_x;
        start_y = -actual_pattern_width_centers_y / 2;

        // Vertical hole pattern (num_holes_z, start_z_center) is the same as for front/back
        available_wall_height = can_height - base_thickness - 2 * hole_margin_top_bottom;
        available_pattern_span_z = available_wall_height - hex_eff_height_on_face;

        if (available_pattern_span_z >= 0) {
            num_holes_z = floor(available_pattern_span_z / hole_spacing_z) + 1;
            actual_pattern_height_centers_z = (num_holes_z - 1) * hole_spacing_z;
             start_z_center = base_thickness + hole_margin_top_bottom + hex_eff_height_on_face/2 + 
                             (available_pattern_span_z - actual_pattern_height_centers_z)/2;

            for (i = [0 : num_holes_y-1]) {
                for (j = [0 : num_holes_z-1]) {
                    translate([0, start_y + i * hole_spacing_x, start_z_center + j * hole_spacing_z])
                        rotate([0, 90, 0]) // Align cutter axis with X
                            hex_cutter_prism(hole_diameter, cutter_length);
                }
            }
        }
    }
}


// --- Main Assembly ---
difference() {
    trash_can_solid_body();
    all_hole_cutters();
}

