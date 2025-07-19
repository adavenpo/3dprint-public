use <mboard_utils.scad>

// An example / test usage of the inner threads... also a handy "wrench" for bolts
difference() {
    translate([-15, -15, 0]) cube(30);
    translate([0,0,-10]) mid_thread_inner(30);
    translate([15,0,15]) rotate([0,90,0]) cylinder(h=6, r=13.25, $fn=6, center = true);
    translate([-15,0,15]) rotate([0,90,0]) cylinder(h=8, r=13.25, $fn=8, center = true);
}

