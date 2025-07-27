use <threads/thread_profile.scad>

function thread_profile() = [
    [0,2.4],
    [0,2.35],
    [0.8,1.5],
    [0.9,1.35],
    [0.9,1.15],
    [0.8,1.0],
    [0,0.15],
    [0,0],
    [-1,0],
    [-1,2.4],
];
 
difference() {
    union() {
        straight_thread(section_profile=thread_profile(), pitch = 2.5, r = (32.4/2), turns = 2.);
        translate([0,0,4]) cylinder(8, d = 32.4, center = true, $fn = 180);
        translate([0,0,9]) cylinder(2, d = 25.7, center = true, $fn = 180);        
        translate([0,0,12.5]) cylinder(5, d = 23.6, center = true, $fn = 180);        
    }
    translate([0, 0, 0.5]) cylinder(3, d = 28.6, center = true, $fn = 180);
    translate([0, 0, 5]) cylinder(8, r1 = 14.3, r2 = 10.1, center = true, $fn = 180);
    translate([0, 0, 10]) cylinder(20, d = 20.2, center = true, $fn = 180);
}


//difference() {
//    union() {
//        translate([0,0,1]) cylinder(2, d = 34, center = true, $fn = 180);
//        translate([0,0,4.5]) cylinder(5, d = 32.5, center = true, $fn = 180);
//        translate([0,0,7]) cylinder(2, d = 25.7, center = true, $fn = 180);        
//        translate([0,0,9]) cylinder(5, d = 23.6, center = true, $fn = 180);        
//    }
//    translate([0, 0, 1]) cylinder(3, d = 28.6, center = true, $fn = 180);
//    translate([0, 0, 10]) cylinder(20, d = 20.2, center = true, $fn = 180);
//}
