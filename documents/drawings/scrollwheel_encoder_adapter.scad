pnl_thickness = 1.58;
pnl_hole_dia = 22;
pnl_ledge_ht = 5;
pnl_mounting_holes_dia = 28;
enc_hub_dia = 20;
enc_hub_ht = 5;
enc_dia = 38;
enc_shaft_height = 14.7;
adp_mounting_holes_dia = 30;
mounting_hole_dia = 3.5;

$fn = $preview ? 64 : 84;
difference(){
    union(){
        cylinder(h = enc_hub_ht - pnl_thickness, d = enc_dia);
        translate([0, 0, enc_hub_ht - pnl_thickness]){
            cylinder(h = pnl_thickness, d = pnl_hole_dia);
        }
    }
    cylinder(h = enc_hub_ht + pnl_thickness, d = enc_hub_dia);
    triangle_hole_pattern(0,mounting_hole_dia,pnl_mounting_holes_dia);
    triangle_hole_pattern(30,mounting_hole_dia,adp_mounting_holes_dia);
    triangle_pattern_countersink(30,6.94,adp_mounting_holes_dia);
    translate([-(enc_dia/2)-17,-enc_dia/2,0])
        cube([enc_dia/2,enc_dia,enc_hub_ht + pnl_thickness]); 
    
}

module triangle_hole_pattern(start, hole, diameter) {
    union(){
        for(z=[start:120:start + 360]){
            rotate([0,0,z])
                translate([diameter/2,0,0])
                    cylinder(h = enc_hub_ht + pnl_thickness, d = hole);
        }
    }
}

module triangle_pattern_countersink(start, countersink, diameter) {
    translate([0,0,enc_hub_ht - pnl_thickness - (countersink/2)]){
        union(){
            for(z=[start:120:start+360]){
                rotate([0,0,z])
                    translate([diameter/2,0,0])
                        cylinder(h = countersink/2, d1 = 0, d2 = countersink);
            }
        }
    }
}