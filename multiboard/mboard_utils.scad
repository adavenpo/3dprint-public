//
// Required libs:
//   https://github.com/openscad/scad-utils
//   https://github.com/openscad/list-comprehension-demos
//   https://raw.githubusercontent.com/MisterHW/IoP-satellite/refs/heads/master/OpenSCAD%20bottle%20threads/thread_profile.scad
//

use <threads/thread_profile.scad>

module locking_bolt() {
    function thread_profile() = [
        [0,2.4],
        [0,2.35],
        [1.1,1.5],
        [1.25,1.35],
        [1.25,1.15],
        [1.1,1.0],
        [0,0.15],
        [0,0],
        [-1,0],
        [-1,2.4],
    ];

    union() {
        straight_thread(section_profile=thread_profile(), pitch = 2.5, r = 4.5, turns = 7.);
        translate([0, 0, 10]) cylinder(20, r = 4.5,center = true, $fn=120);
    }
}

module mid_thread_bolt(length, shank = 0, head_sides = 6) {
    // 12 inner, 13.8 outer
    function thread_profile() = [
        [0,2.9],
        [0,2.85],
        [0.65,2.00],
        [0.85,1.75],
        [0.9,1.65],
        [0.9,1.25],
        [0.85,1.15],
        [0.65,0.9],
        [0,0.15],
        [0,0],
        [-1,0],
        [-1,2.4],
    ];

    turns = ((length-shank) / 3.1) - 0.93;
    difference() {
        union() {
            translate([0,0,3]) {
                translate([0, 0, shank])
                    straight_thread(section_profile=thread_profile(), pitch = 3.1, r = 6, turns = turns);
                translate([0, 0, length/2-1])
                    cylinder(length+2, r = 6,center = true, $fn=120);
            }
            cylinder(h=3, r=12.85, $fn=head_sides);
        }
        for (i = [0:head_sides]) {
            rotate([0,0,i*(360/head_sides)]) translate([6.4,0,0])
                difference() {
                    cylinder(h=0.5, r=4.0, $fn=180, center = true);
                    cylinder(h=1.6, r=3.5, $fn=180, center = true);
                }
        }
        for (r = [2.9, 6.4, 10.4]) {
            difference() {
                cylinder(h=1.0, r=r, $fn=180, center = true);
                cylinder(h=1.2, r=r-0.4, $fn=180, center = true);
            }
        }
//        difference() {
//            cylinder(h=0.5, r=11, $fn=head_sides, center = true);
//            cylinder(h=0.6, r=10, $fn=head_sides, center = true);
//        }
//        difference() {
//            cylinder(h=0.5, r=8, $fn=head_sides, center = true);
//            cylinder(h=0.6, r=7, $fn=head_sides, center = true);
//        }
    }
}

module mid_thread_inner(length) {
    // 12 inner, 13.8 outer
    extra = 0.8;
    function thread_profile() = [
        [extra+0,2.9],
        [extra+0,2.85],
        [extra+0.65,2.00],
        [extra+0.85,1.75],
        [extra+0.9,1.65],
        [extra+0.9,1.25],
        [extra+0.85,1.15],
        [extra+0.65,0.9],
        [extra+0,0.15],
        [extra+0,0],
        [-1,0],
        [-1,2.4],
    ];

    turns = ((length) / 3.1) - 0.93;
    difference() {
        union() {
            //translate([0, 0, shank])
                straight_thread(section_profile=thread_profile(), pitch = 3.1, r = 6, turns = turns, higbee_arc = 0);
            translate([0, 0, length/2-1])
                cylinder(length+2, r = 6,center = true, $fn=120);
        }
    }
}
