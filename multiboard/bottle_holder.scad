//
// Holder for a bottle.  Inspired by
//   https://thangs.com/designer/KrazenLabs/3d-model/Multiboard%20Spray%20Bottle%20Holder-1032627
// However I had trouble printing that one, so I made my own with slightly beefier construction.
// Fasten to Multiboard with 10mm mid-thread T-bolt.
//


width = 85;
depth = 88;
height = 100;
hex_size = 7;
wall_thickness = 4;

function hex_factor(r) = r * cos(60/2);

difference() {
    cube([width, depth, height], center = true);
    translate([0, 1.5, 2])
        cube([width-(wall_thickness*2), depth - (wall_thickness*2) - 3, height],
             center = true);

    for ( z = [ 0 : 9 ] ) {
        ztop = height /2 - wall_thickness - (z*1.5*hex_factor(hex_size));
        for ( x = [ 0 : 5 ] ) {
            xoffset = depth/2 - 5 - (hex_size/2) - (x * (hex_size+5));
            translate([0, xoffset, ztop])
                rotate([0, 90, 0]) rotate([0, 0, 90])
                    cylinder(width + 4, r = (hex_size/2), center = true, $fn = 6);
            translate([0, xoffset - hex_size + 1, ztop - hex_factor(hex_size) + 2])
                rotate([0, 90, 0]) rotate([0, 0, 90])
                    cylinder(width + 4, r = (hex_size/2), center = true, $fn = 6);
        }
        rotate([0,0,90])
        for ( x = [ 0 : 5 ] ) {
            xoffset = depth/2 - 7.5 - (hex_size/2) - (x * (hex_size+5));
            translate([width/2, xoffset, ztop])
                rotate([0, 90, 0]) rotate([0, 0, 90])
                    cylinder(10, r = (hex_size/2), center = true, $fn = 6);
        }
        rotate([0,0,90])
        for ( x = [ 0 : 5 ] ) {
            xoffset = depth/2 - 7.5 - (hex_size/2) - (x * (hex_size+5));
            translate([width/2, xoffset - hex_size + 1, ztop - hex_factor(hex_size) + 2])
                rotate([0, 90, 0]) rotate([0, 0, 90])
                    cylinder(10, r = (hex_size/2), center = true, $fn = 6);
        }
    }

    for (z = [10, 60]) {
        zctr = height/2 - (z + 7.5);
        translate([0,-width/2, zctr])
            rotate([90, 0, 0])
                cylinder(100, r=7.5, center = true, $fn=360);
        translate([0,-width/2+1.5+2.5, zctr])
            rotate([90, 0, 0])
                cylinder(5, r=13.5, center = true, $fn=360);
    }
}


