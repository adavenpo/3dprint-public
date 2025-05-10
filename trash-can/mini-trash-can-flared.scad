// Trash Can Parameters
can_width_base = 120;     // Outer width (X-axis) at the base
can_depth_base = 80;      // Outer depth (Y-axis) at the base
can_height = 150;         // Outer height (Z-axis)
wall_thickness = 2;       // Thickness of the walls (approximate, measured perpendicular to base plane)
base_thickness = 3;       // Thickness of the base
corner_radius = 10;       // Radius for outer corners at the base
flare_angle = 5;         // Angle (degrees) for sides to flare outwards from vertical

// Hexagonal Hole Parameters
hole_diameter = 5;      // Circumscribed diameter of the hexagon (vertex to vertex)
hole_spacing_x = 8;     // Center-to-center spacing of holes horizontally (measured on the XY projection plane)
hole_spacing_z = 8;     // Center-to-center spacing of holes vertically (along Z)
hole_margin_sides = 20;   // Margin from side edges of a face to the first/last hole center (applied to face width at mid-height of holed area)
hole_margin_top_bottom = 10; // Margin from top/bottom edges of wall to first/last hole center (vertical Z distance)

// Render Quality
$fn_smooth = 48; // For rounded corners and general smoothness
$fn_hex = 6;     // For hexagons (always 6)
extrude_slices_per_mm = 1; // Slices per mm of height for linear_extrude, for smoother flare

// --- Derived Parameters & Helper calculations ---

// Outer top dimensions and scale
top_outer_width  = can_width_base + 2 * can_height * tan(flare_angle);
top_outer_depth  = can_depth_base + 2 * can_height * tan(flare_angle);
outer_scale_x    = (can_width_base > 0.01) ? top_outer_width / can_width_base : 1;
outer_scale_y    = (can_depth_base > 0.01) ? top_outer_depth / can_depth_base : 1;
outer_extrude_slices = ceil(can_height * extrude_slices_per_mm);

// Inner dimensions for the cavity
inner_height_for_flare = can_height - base_thickness; // Height over which inner wall flares
inner_width_base   = can_width_base - 2 * wall_thickness;
inner_depth_base   = can_depth_base - 2 * wall_thickness;
inner_corner_radius = max(0.01, corner_radius - wall_thickness);

// Inner top dimensions and scale (flaring from inner base)
top_inner_width = inner_width_base + 2 * inner_height_for_flare * tan(flare_angle);
top_inner_depth = inner_depth_base + 2 * inner_height_for_flare * tan(flare_angle);

inner_scale_x = (inner_width_base > 0.01) ? top_inner_width / inner_width_base : 1;
inner_scale_y = (inner_depth_base > 0.01) ? top_inner_depth / inner_depth_base : 1;
inner_extrude_slices = ceil(max(0.1, inner_height_for_flare) * extrude_slices_per_mm);


// Effective dimensions of a "pointy-top" hexagon (used for layout on projection plane)
hex_eff_width_on_proj_plane = hole_diameter * cos(30); // Width across flats
hex_eff_height_on_proj_plane = hole_diameter;          // Height point-to-point

// --- Modules ---

// Module for a 2D rounded rectangle
module rounded_rectangle_2d(size, radius, _fn) {
    minkowski() {
        square([size[0] - 2 * radius, size[1] - 2 * radius], center = true);
        circle(r = radius, $fn = _fn);
    }
}

// Module for a single hexagonal prism cutter (pointy-top orientation)
module hex_cutter_prism(dia, len) {
    rotate([0, 0, 30]) // Orient hexagon to be "pointy-top" along its local Y-axis (when cutter is along Z)
        cylinder(d = dia, h = len, $fn = $fn_hex, center = true);
}

// Module for the solid body of the trash can
module trash_can_solid_body() {
    difference() {
        // Outer solid - flared
        linear_extrude(height = can_height,
                       scale = [outer_scale_x, outer_scale_y],
                       slices = outer_extrude_slices,
                       convexity = 10)
            rounded_rectangle_2d([can_width_base, can_depth_base], corner_radius, _fn = $fn_smooth);

        // Inner cavity - flared
        if (inner_width_base > 0.01 && inner_depth_base > 0.01 && inner_height_for_flare > 0.01) { // Ensure cavity has dimensions
            translate([0, 0, base_thickness])
                linear_extrude(height = inner_height_for_flare + 0.1, // +0.1 for clean subtraction
                               scale = [inner_scale_x, inner_scale_y],
                               slices = inner_extrude_slices,
                               convexity = 10)
                    rounded_rectangle_2d([inner_width_base, inner_depth_base], inner_corner_radius, _fn = $fn_smooth);
        }
    }
}

// Module to generate all hole cutters
module all_hole_cutters() {
    cutter_length = max(top_outer_width, top_outer_depth) * 1.5; // Ensure cutters pass through widest part

    // Calculate Z-range for holes based on margins
    wall_holed_area_start_z = base_thickness + hole_margin_top_bottom; // Lowest Z for bottom edge of a hole's center
    wall_holed_area_end_z = can_height - hole_margin_top_bottom;     // Highest Z for top edge of a hole's center
    wall_holed_area_height = wall_holed_area_end_z - wall_holed_area_start_z; // Total vertical span for placing holes

    if (wall_holed_area_height < hex_eff_height_on_proj_plane) {
         // Not enough height for even one row of holes
    } else {
        // Vertical hole pattern (common for all faces)
        // available_pattern_span_z_for_centers is the space for centers after one hole height is accounted for
        available_pattern_span_z_for_centers = wall_holed_area_height - hex_eff_height_on_proj_plane;
        num_holes_z = floor(available_pattern_span_z_for_centers / hole_spacing_z) + 1;
        actual_pattern_height_centers_z = (num_holes_z - 1) * hole_spacing_z; // Span of centers from first to last

        // Center the vertical pattern of holes within the 'wall_holed_area_height'
        // This calculates the Z for the center of the lowest row of holes
        start_z_center_first_hole = wall_holed_area_start_z + (wall_holed_area_height - actual_pattern_height_centers_z - hex_eff_height_on_proj_plane)/2 + hex_eff_height_on_proj_plane/2;


        // Average Z coordinate of the hole pattern centers (used to calculate face width for horizontal spacing)
        avg_z_of_holed_pattern_centers = (num_holes_z > 0) ? (start_z_center_first_hole + actual_pattern_height_centers_z / 2) : (wall_holed_area_start_z + wall_holed_area_height / 2);


        // --- Holes on Front/Back faces (cutters aligned with Y-axis) ---
        // Calculate width of face at the average Z height of the holed area for pattern calculation
        face_width_at_avg_z_for_x_holes = can_width_base + 2 * avg_z_of_holed_pattern_centers * tan(flare_angle);

        // available_pattern_span_x_for_centers is space for centers after one hole width is accounted for
        available_pattern_span_x_for_centers = face_width_at_avg_z_for_x_holes - 2 * hole_margin_sides - hex_eff_width_on_proj_plane;
        if (available_pattern_span_x_for_centers >= -0.001 && num_holes_z > 0) { // Allow for small floating point inaccuracies
            num_holes_x = floor(available_pattern_span_x_for_centers / hole_spacing_x) + 1;
            actual_pattern_width_centers_x = (num_holes_x - 1) * hole_spacing_x;

            for (j = [0 : num_holes_z-1]) {
                z_offset = start_z_center_first_hole + j * hole_spacing_z;
                x_offset = (z_offset * tan(flare_angle));
                start_x_center_first_hole = -actual_pattern_width_centers_x / 2 - x_offset; // Centered horizontally
                for (i = [0 : num_holes_x-1]) {
                    x = start_x_center_first_hole + i * (hole_spacing_x + (2*x_offset / num_holes_x));
                    translate([x, 0, z_offset])
                        rotate([90, 0, 0]) // Align cutter axis with Y
                            hex_cutter_prism(hole_diameter, cutter_length);
                }
            }
        }

        // --- Holes on Left/Right faces (cutters aligned with X-axis) ---
        // Calculate depth of face at the average Z height of the holed area
        face_depth_at_avg_z_for_y_holes = can_depth_base + 2 * avg_z_of_holed_pattern_centers * tan(flare_angle);

        available_pattern_span_y_for_centers = face_depth_at_avg_z_for_y_holes - 2 * hole_margin_sides - hex_eff_width_on_proj_plane;
        if (available_pattern_span_y_for_centers >= -0.001 && num_holes_z > 0) { // Allow for small floating point inaccuracies
            num_holes_y = floor(available_pattern_span_y_for_centers / hole_spacing_x) + 1; // Using hole_spacing_x for consistency
            actual_pattern_width_centers_y = (num_holes_y - 1) * hole_spacing_x;

            for (j = [0 : num_holes_z-1]) {
                z_offset = start_z_center_first_hole + j * hole_spacing_z;
                y_offset = (z_offset * tan(flare_angle));
                start_y_center_first_hole = -actual_pattern_width_centers_y / 2 - y_offset; // Centered horizontally
                for (i = [0 : num_holes_y-1]) {
                    y = start_y_center_first_hole + i * (hole_spacing_x + (2*y_offset / num_holes_y));
                    translate([0, y, z_offset])
                        rotate([0, 90, 0]) // Align cutter axis with X
                            hex_cutter_prism(hole_diameter, cutter_length);
                }
            }
        }
    }
}


// --- Main Assembly ---
// Origin is at the center of the base of the trash can on the XY plane (Z=0 is bottom).
difference() {
    trash_can_solid_body();
    all_hole_cutters();
}