/*
    SBC Case Framework Library Copyright 2016,2017,2018,2019,2020,2021 Edward A. Kisiel
    hominoid @ www.forum.odroid.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    Code released under GPLv3: http://www.gnu.org/licenses/gpl.html

    20190721 Version 1.0.0 beta SBC Water Cooled Case Library
    20190801 Version 1.0.1 Added heat_exchanger_plate()
    20201201 Version 1.1.0 Added hd25(height),hd35(),hdd35_25holder(length)
    20210128 Version 1.1.1 changed width of hd35() and hdd35_25holder from 100mm to 101.6mm
                           standardized circle segments to $fn=90
    20210226 Version 1.1.2 updated stud(loc, standoff) standoff types, fixed xu4_caseback_heatsink_mount()
                           added slot() and washer() module
                           updated art() for custom dxf
    20210320 Version 1.1.3 updated stud(loc, standoff, style) standoff styles hex and cylinder added
*/

use <./fillets.scad>;

/* placement module *must be first* for children() */
module place(x,y,size_x,size_y,rotation,side,case_z) {       
    if (side == "top") {
        if (rotation == 0 || rotation == 90 || rotation == 180 || rotation == 270) {    
            if ((rotation >= 0 && rotation < 90) || (rotation < -270 && rotation > -360))
                translate([x,y,case_z]) rotate([0,0,-rotation]) children();

            if ((rotation >= 90 && rotation < 180) || (rotation < -180 && rotation >= -270))
                translate([x,y+size_x,case_z]) rotate([0,0,-rotation]) children();
           
            if ((rotation >= 180 && rotation < 270) || (rotation < -90 && rotation >= -180))
                translate([x+size_x,y+size_y,case_z]) rotate([0,0,-rotation]) children(0);
           
            if ((rotation >= 270 && rotation < 360) || (rotation < 0 && rotation >= -90))
                translate([x+size_y,y,case_z]) rotate([0,0,-rotation]) children(); }
        else {
            translate([x,y,case_z]) rotate([0,0,-rotation]) children();            
        }
    }   
    if (side == "bottom") {
        if (rotation == 0 || rotation == 90 || rotation == 180 || rotation == 270) {   
            if ((rotation >= 0 && rotation < 90) || (rotation < -270 && rotation > -360))
                translate([x+size_x,y,case_z]) rotate([0,180,rotation]) children();
           
            if ((rotation >= 90 && rotation < 180) || (rotation < -180 && rotation >= -270))
                translate([x+size_y,y+size_x,case_z]) rotate([0,180,rotation]) children();
               
            if ((rotation >= 180 && rotation < 270) || (rotation < -90 && rotation >= -180))
                translate([x,y+size_y,case_z]) rotate([0,180,rotation]) children();
           
            if ((rotation >= 270 && rotation < 360) || (rotation < 0 && rotation >= -90))
                translate([x,y,case_z]) rotate([0,180,rotation]) children(); }
        else {
            translate([x,y,case_z]) rotate([0,180,rotation]) children();
            
        }
    }    
    children([1:1:$children-1]);
}


/* addition module */
module add(size_x,size_y,loc_x,loc_y,rotation,side,type,case_z,data_1,data_2) {
    if(type == "square") {
        rotate([0,0,rotation]) translate([loc_x,loc_y,0])
            cube([size_x,size_y,case_z]);
    }
    if(type == "round") {
        translate([loc_x,loc_y,0])
            cylinder(d=data_1,h=case_z);
    }
    if(type == "batt_holder1") {
        place(loc_x,loc_y,size_x,size_y,rotation,"bottom",case_z)
            batt_holder1();
    }
    if(type == "uart_holder1") {
        place(loc_x,loc_y,size_x,size_y,rotation,"bottom",case_z)
            uart_holder1();
        if (model == 0) {
            translate([case_x+15,-95,11]) rotate([180,0,0]) uart_strap ();
        }
        else {
            place(loc_x,loc_y,size_x,size_y,rotation,"bottom",case_z)    
            uart_strap ();
        }
    }
    if(type == "xu4_caseback") {
        place(loc_x,loc_y,size_x,size_y,rotation,"bottom",case_z)
            xu4_caseback_heatsink_mount();
    }
    if(type == "stud") {
            standoff([loc_x,loc_y,0], [case_so_diameter,case_bso_height,(case_holesize*.77),case_so_support_diameter,case_so_support_height,case_countersink,data_1,data_2]);
    }
    
}

/* subtractive module */
module sub(size_x,size_y,loc_x,loc_y,rotation,side,type,case_z,data_1,data_2) {
    // square
    if(type == "square") {
        rotate([0,0,rotation]) translate([loc_x,loc_y,-4])
            cube([size_x,size_y,case_z+5]);
    }
    if(type == "round") {
        translate([loc_x,loc_y,-1])
            cylinder(d=data_1,h=case_z+4);
    }
    if(type == "art") {
        rotate([0,0,rotation]) translate([loc_x,loc_y,-1])
            art(data_1,data_2); 
    }
    if(type == "case_text") {
        translate([loc_x,loc_y,-1]) rotate([0,0,rotation]) 
        linear_extrude(height = 5) text(data_2, size=data_1);
    }
    if(type == "hk_fan_top") {
        rotate([0,0,rotation]) translate([loc_x,loc_y,-1])
            hk_fan_top();
    }    
}

/* slab module */
module slab(size, radius) {
    x = size[0];
    y = size[1];
    z = size[2];   
    linear_extrude(height=z)
    hull() {
        translate([0+radius ,0+radius, 0]) circle(r=radius);	
        translate([0+radius, y-radius, 0]) circle(r=radius);	
        translate([x-radius, y-radius, 0]) circle(r=radius);	
        translate([x-radius, 0+radius, 0]) circle(r=radius);
    }  
}

/* slot module */
module slot(hole,length,depth) {
    hull() {
        translate([0,0,0]) cylinder(d=hole,h=depth);
        translate([length,0,0]) cylinder(d=hole,h=depth);        
        }
    } 

/* washer() module */
module washer(size, thick, hole, indent, indent_dia) {
    difference() {
        cylinder(d=size, h=thick);
        translate([0,0,-adjust]) cylinder(d=hole, h=thick+(2*adjust));
        translate([0,0,thick-indent]) cylinder(d=indent_dia, h=thick+(2*adjust));
    }
}

/* standoff module
    stud(loc[x,y,z], standoff[radius,height,holesize,supportsize,supportheight,sink], style)
        sink=0 none
        sink=1 countersink
        sink=2 recessed hole
        sink=3 nut holder
        sink=4 blind hole
        style=0 hex shape
        style=1 cylinder
*/
module stud(loc, standoff, style){
    x = loc[0];
    y = loc[1];
    z = loc[2];
    radius = standoff[0];
    height = standoff[1];
    holesize = standoff[2];
    supportsize = standoff[3];
    supportheight = standoff[4];
    sink = standoff[5];
    offset = 0.01;
    
    translate([x,y,z]) 
    difference (){ 
        union () {
            if(style == 0) {
                cylinder(d=radius,h=height,$fn=6);
            }
            if(style == 1) {
                cylinder(d=radius,h=height,$fn=90);
            }
            cylinder(d=(supportsize),h=supportheight,$fn=60);
        }
        // hole
        if( sink <= 3) {
                translate([0,0,-offset]) cylinder(d=holesize, h=height+(offset*2),$fn=90);
        }
        // countersink hole
        if(sink == 1) {
            translate([0,0,-offset]) cylinder(d1=6, d2=(holesize), h=2.5);
        }
        // recessed hole
        if(sink == 2) {
            translate([0,0,-offset]) cylinder(d=6, h=3);
        }
        // nut holder
        if(sink == 3) {
            translate([0,0,-offset]) cylinder(r=3.3,h=3,$fn=6);     
        }
        // blind hole
        if(sink == 4) {
            translate([0,0,2]) cylinder(d=holesize, h=height,$fn=90);
        }
    }
}


/* case feet */
module feet (height) {
    difference (){ 
        cylinder (r=4.5,h=height);
        translate([0,0,-1]) cylinder (d=3, h=height+2,$fn=90);
        translate ([0,0,-1]) cylinder(r=3.35,h=height-3,$fn=6);       
    }
}

/* water block module */
module water_block(spec) {
    socsize_x = spec[0];
    socsize_y = spec[1];
    soc_rotation = spec[2];
    wbsize_z = spec[3];
    wbp = spec[4];
    wbcu = spec[5];
    wbhole_size = spec[6];
    wbwall_thick = spec[7];
    wbsize_x = socsize_x +(wbwall_thick*2);
    wbsize_y = socsize_y +(wbwall_thick*2);
   
union() {
    difference () {
    translate([0,0,0])
        cube([wbsize_x,wbsize_y,wbsize_z+wbp]);
        // chamber cutout
        translate ([wbwall_thick, wbwall_thick, -1])
            cube([socsize_x, socsize_y, wbsize_z+wbp-wbwall_thick+1]);
        // cu inset
        translate ([wbwall_thick/2, wbwall_thick/2, -1])
            cube([socsize_x+wbwall_thick, socsize_y+wbwall_thick, wbcu+1]);
        //top holes
        if (soc_rotation == 0) {
            translate([wbwall_thick+(wbhole_size/2),wbwall_thick+(wbhole_size/2),wbsize_z+wbp-wbwall_thick-1]) 
                    cylinder (h=wbwall_thick+2, d=wbhole_size, $fn=90);
            translate([wbwall_thick+socsize_x-(wbhole_size/2),wbwall_thick+socsize_y-(wbhole_size/2),wbsize_z+wbp-wbwall_thick-1]) 
                    cylinder (h=wbwall_thick+2, d=wbhole_size, $fn=90);
        } else //change hole positions if rotated
            {
            translate([wbwall_thick+(socsize_x/2),wbwall_thick+(wbhole_size/2),wbsize_z+wbp-wbwall_thick-1]) 
                    cylinder (h=wbwall_thick+2, d=wbhole_size, $fn=90);
            translate([(socsize_x/2)+(wbwall_thick),wbwall_thick+socsize_y-(wbhole_size/2),wbsize_z+wbp-wbwall_thick-1]) 
                    cylinder (h=wbwall_thick+2, d=wbhole_size, $fn=90);
        }
    }
    //water block divide
    translate([wbsize_x-.75,0,wbcu+wbp+(wbwall_thick/2)]) rotate ([0,0,atan2(wbsize_x,wbsize_y)])
    cube([1,sqrt(pow(socsize_x+wbwall_thick,2)+pow(socsize_y+wbwall_thick,2)),wbsize_z-(wbcu+wbp+(wbwall_thick/2))]);
    }
}
 
/* odroid rtc battery holder */
module batt_holder1() {
    // rtc battery holder
    rotate([0,0,0]) 
    difference () {
        cylinder(r=12.75,h=6,$fn=90);
        translate ([0,0,-1]) cylinder(r=10.2,h=8,$fn=90);
        cube([14,26,13], true);
    }
    cylinder(r=12.75, h=2);
}

/* odroid uart holder */
module uart_holder1() {
    // micro usb uart module holder
    rotate([0,0,0]) 
    translate ([0,0,0])
        union () {
            difference () {
                translate ([0,0,0]) cube([18,24,9]);
                translate ([2,-2,3]) cube([14,27,7]);
                //pin slot
                translate ([3.5,16,-1]) cube([11,1,5]);
                //component bed
                translate ([3.5,1.5,2]) cube ([11,14,2]);
                //side trim
                translate ([-1,-1,6]) cube([20,18,4]);
            }    
            difference (){
                translate ([-1.5,20,0]) cylinder(r=3,h=9, $fn=90);
                translate ([-1.5,20,-1]) cylinder (r=1.375, h=11, $fn=90);
            }    
            difference (){
                translate ([19.5,20,0]) cylinder(r=3,h=9, $fn=90);
                translate ([19.5,20,-1]) cylinder (r=1.375, h=11,$fn=90);
            }  
        }
    }

/* odroid uart strap for holder */
module uart_strap () { 
    difference () {
        translate ([-4.5,17,9]) cube([27,6,3]);
        translate ([-1.5,20,8]) cylinder (r=1.6, h=5, $fn=90);
        translate ([19.5,20,8]) cylinder (r=1.6, h=5, $fn=90);
    }   
    difference (){
        translate ([-1.5,20,12]) cylinder(r=3,h=1, $fn=90);
        translate ([-1.5,20,11]) cylinder (r=1.6, h=7, $fn=90);
    }  
    difference (){
        translate ([19.5,20,12]) cylinder(r=3,h=1, $fn=90);
        translate ([19.5,20,11]) cylinder (r=1.6, h=7, $fn=90);
    }    
}

/* xu4 case back heatsink hold-down and support */
module xu4_caseback_heatsink_mount(case_bso_height,case_z, countersunk) {
    difference() {
        union() {
            // upper heatsink hold down support
            translate ([28.39,42,0])cylinder(r1=10,r2=3.5,h=3,$fn=90);
            // lower heatsink hold down support     
            translate ([79.61,22,0]) cylinder(r1=12,r2=3.5,h=3,$fn=90);
            // bottom ribs
            translate([66,15,0]) cube([19,2,2]);     
            difference () {  
                for (y=[20:5:50]) {
                    translate([20, y, 0]) cube([65,2,2]);
                }      
                translate ([79.61,22,-1]) cylinder (r=1.8, h=case_bso_height+2,$fn=90);
                translate ([28.39,42,-1]) cylinder (r=1.8, h=case_bso_height+2,$fn=90);
                }
            translate([77,25,0]) cube([6, 2, case_bso_height-case_z]);
            translate([20, 35, 0]) cube([8,2,case_bso_height-case_z]);
            translate([50, 35, 0]) cube([10,2,case_bso_height-case_z]);
            translate([77,40,0]) cube([6,2,case_bso_height-case_z]); 
            // emmc side, isolate
            translate ([68.8,11,0]) cube([14.2,2,case_bso_height-case_z]);
            translate ([20,19.5,0]) cube([40.9,2,case_bso_height-case_z]);
            translate ([59.75,20,0]) rotate ([0,0,-45]) cube([12.75,2,case_bso_height-case_z]);    
            translate ([28,50,0]) cube([55,2,case_bso_height-case_z]);
        }
        // upper heatsink hold down support
        translate ([28.39,42,-1])cylinder (d=3, h=case_bso_height+2,$fn=90);
        if(countersunk) {
            translate ([28.39,42,-.01]) cylinder(d1=6, d2=3, h=2.5, $fn=90);
            }
        // lower heatsink hold down support     
        translate ([79.61,22,-1]) cylinder (d=3, h=case_bso_height+2, $fn=90);
        if(countersunk) {
            translate ([79.61,22,-.01]) cylinder(d1=6, d2=3, h=2.5, $fn=90);
            }
        translate([85,11,-8]) cube([13,42,41]);
        }
}


/* Hardkernel OEM heatsink fan mount for top of case
   example: xu4 40mm heatsink's lower left corner is at 33,12.
   add half of x,y of object size since origin is at center. 
   53,32,"top" goes in sbc_water_cooled_case.cfg under user defined subtractive accessory.
*/
module hk_fan_top() {
    fan=41;
    height=6;
    hole=2;
    //mount holes
    translate([20,20,-1]) cylinder (d=fan-2,h=height);
    translate ([3,3,-1]) cylinder(d=hole,h=height+2, $fn=90);   //upper right hole
    translate ([37,3,-1]) cylinder(d=hole,h=height+2, $fn=90);  //lower right hole
    translate ([37,37,-1]) cylinder(d=hole,h=height+2, $fn=90); //lower left hole
    translate ([3,37,-1]) cylinder(d=hole,h=height+2, $fn=90);  //upper left hole
    //alignment tabs
    translate ([17,38,-1]) cube ([6,3,height]);  //upper tab
    translate ([38,17,-1]) cube ([3,6,height]);  //right tab
    translate ([17,-1,-1]) cube ([6,3,height]); //lower tab
    translate ([-1,17,-1]) cube ([3,6,height]); //left tab
}

// art work module
module art(scale_d1,type) {
    if(type == "hklogo_25") {
        linear_extrude(height = 5) import(file = "./dxf/hk_25mm.dxf", scale=scale_d1); 
        }
    if(type == "hklogo_50") {
        linear_extrude(height = 5) import(file = "./dxf/hk_50mm.dxf", scale=scale_d1); 
        }
    if(type == "odroid") {
        linear_extrude(height = 5) import(file = "./dxf/odroid.dxf", scale=scale_d1);
        }
    if(type == "custom") {
        linear_extrude(height = 5) import(file = "./dxf/custom.dxf", scale=scale_d1);
        }
}

module heatsink_gold () {
    difference() {
        cube([38, 40, 36.25]);
        // universal slots
        translate([-1,0,2]) heatsink_slot();
        // fins       
        for (y=[5:3.7:31.7]) {
            translate([y,-1,9.5]) cube ([1.85,48,28]);
            }          
        for (y=[6:6.65:38]) {
            translate([-5,y,9.5]) cube([48,1.85,28]);
            }     
        translate([(8.7-1.90),-1,34]) cube([2,42,4]);       
        translate([(12.4-1.90),-1,32]) cube([2,42,5]);      
        translate([(16.1-1.90),-1,30]) cube([2,42,7]);          
        translate([(19.8-1.87),-1,32]) cube([2,42,7]);       
        translate([(19.9+1.70),-1,30]) cube([2,42,7]);        
        translate([(23.6+1.70),-1,32]) cube([2,42,5]);        
        translate([(27.3+1.70),-1,34]) cube([2,42,4]);       
        translate([.3,-1,28]) cube([3,42,10]);
        translate([34.7,-1,28]) cube([3,42,10]);        
        translate([31,-1,35.25]) cube([10,42,10]);
        translate([-1,-1,35.25]) cube([10,42,10]); 
    }
    difference () {
        translate([-2,0,23.75]) cube([2,40,12.5]);
        for (y=[6:6.65:38]) {
            translate([-5,y,9.5]) cube([48,1.85,28]);
        }
    }
    difference () {
        translate([38,0,23.75]) cube([2,40,12.5]);       
        for (y=[6:6.65:38]) {
            translate([-5,y,9.5]) cube([48,1.85,28]);
        }
    }
    difference () {
        translate([1,40,23.75]) rotate([90,0,0]) cylinder(r=3,h=40,$fn=90); 
        for (y=[6:6.65:38]) {
            translate([-5,y,9.5]) cube([48,1.85,28]);
        }
    }
    difference () {
        translate([37,40,23.75]) rotate([90,0,0]) cylinder(r=3,h=40,$fn=90);
        for (y=[6:6.65:38]) {
            translate([-5,y,9.5]) cube([48,1.85,28]);
        }
    }
}
 
module heatsink_northbridge () {
    difference (){ 
        translate ([6.5,-5,0]) cube([7,5,2]);
        translate ([10,-5,-1]) cylinder(r=1.375, h=4);
        }
    difference (){ 
        translate ([26.5,40,0]) cube([7,5,2]);
        translate ([30,45,-1]) cylinder(r=1.375, h=4);
        }
    difference () {
       translate ([10,-5,0]) cylinder(r=3.5, h=2);
       translate ([10,-5,-1]) cylinder(r=1.375, h=4);
       }
    difference () {
        translate ([30,45,0]) cylinder(r=3.5, h=2);
        translate ([30,45,-1]) cylinder(r=1.375, h=4);
    }
    difference() {
        cube([40, 40, 25]);
        for (y=[1.5:2:38.5]) {
            translate([y,-1,2]) cube ([1,42,25]);
        }
        difference () {
            translate([40,40,25]);
            for (y=[4:6:40]) {
                translate([-1,y,2]) cube([42,2,23]);
            }
        }
    }
}

module heatsink_plate() {
    cube ([40,40,2]);
    difference (){ 
        translate ([6.5,-5,0]) cube([7,5,2]);
        translate ([10,-5,-1]) cylinder(r=1.375, h=4, $fn=90);
    }
    difference (){ 
        translate ([26.5,40,0]) cube([7,5,2]);
        translate ([30,45,-1]) cylinder(r=1.375, h=4, $fn=90);
    }
    difference () {
        translate ([10,-5,0]) cylinder(r=3.5, h=2);
        translate ([10,-5,-1]) cylinder(r=1.375, h=4, $fn=90);
    }
    difference () {
        translate ([30,45,0]) cylinder(r=3.5, h=2);
        translate ([30,45,-1]) cylinder(r=1.375, h=4, $fn=90);
    }
}

module heatsink_adapter(NUT) {
    difference () {
        heatsink_plate ();
        translate ([0,-.1,1.7]) cube ([40,40.2,.4]);             
        translate ([-1,-1,-1]) cube ([3,42,4]);
        translate ([38,-1,-1]) cube ([3,42,4]);       
        translate ([9.65,-.1,-1]) cube ([20.7,40.2,5]);
    }
    difference () {
        translate ([5.65,0,1.7]) cube ([4,40,1.3]);
        translate ([9.10,-.1,1.7]) cube ([2,40.2,1.31]);
    }
    difference () {
        translate ([30.35,0,1.7]) cube ([4,40,1.3]);
        translate ([30.349,-.1,1.7]) cube ([.501,40.2,1.31]);
    }   
    translate ([2,-4,0]) cube ([6,4,1.7]);
    translate ([32.75,40,0]) cube ([5.25,4,1.7]);   
    translate ([5.65,-1,.3]) rotate ([45,0,0]) cube ([3.45,2.6,1.3]);
    translate ([30.85,39,2.08]) rotate ([-45,0,0]) cube ([3.5,2.6,1.3]);
    if ( NUT == 1 ) {
        difference (){
            translate ([10,-5,0]) 
            cylinder(r1=4, r2=4.75, h=4.5,$fn=90);
            translate ([10,-5,-1])
            cylinder (r=1.375, h=5,$fn=90);
            translate ([10,-5,2])
            cylinder(r=3.35,h=5,$fn=6);
            
        }
            difference (){
            translate ([30,45,0]) 
            cylinder(r1=4,r2=4.75,h=4.5,$fn=90);
            translate ([30,45,-1])
            cylinder (r=1.375,h=5,$fn=90);
            translate ([30,45,2])
            cylinder(r=3.35,h=5,$fn=6);
            
        }
    }
}

module heatsink_plate_gold() {
    cube ([40,40,2]);
    difference (){ 
        translate ([2,-5,0]) cube([13.5,5,2]);
        translate ([11,-5,-1]) cylinder(r=1.375, h=4, $fn=90);
    }
    difference (){ 
        translate ([24.5,40,0]) cube([13.5,5,2]);
        translate ([29,45,-1]) cylinder(r=1.375, h=4, $fn=90);
    }
    difference () {
        translate ([11,-5,0]) cylinder(r=3.5, h=2);
        translate ([11,-5,-1]) cylinder(r=1.375, h=4, $fn=90);
    }
    difference () {
        translate ([29,45,0]) cylinder(r=3.5, h=2);
        translate ([29,45,-1]) cylinder(r=1.375, h=4, $fn=90);
    }
}

module heatsink_adapter_gold(NUT) {
    difference () {
        heatsink_plate_gold ();
        translate ([0,0,1.7]) cube ([40,40,.3]);
        translate ([9.65,0,-1]) cube ([20.7,40,5]);
        translate ([0,0,-1]) cube ([2,40,4]);
        translate ([38,0,-1]) cube ([2,40,4]);
    }
    difference () {
        translate ([5.65,0,1.7]) cube ([4,40,1.3]);
        translate ([9.10,0,1.7]) cube ([2,40,1.3]);
    }
    difference () {
        translate ([30.35,0,1.7]) cube ([4,40,1.3]);
        translate ([30.35,0,1.7]) cube ([.5,40,1.3]);
    }
    
    translate ([2,-4,0]) cube ([6,4,1.7]);
    translate ([32.75,40,0]) cube ([5.25,4,1.7]);    
    translate ([5.65,-1,.3]) rotate ([45,0,0]) cube ([3.45,2.6,1.3]);
    translate ([30.85,39,2.08]) rotate ([-45,0,0]) cube ([3.5,2.6,1.3]);
    if ( NUT == 1 ) {
        difference (){
            translate ([11,-5,0]) 
            cylinder(r1=4, r2=4.75, h=4.5,$fn=90);
            translate ([11,-5,-1])
            cylinder (r=1.375, h=5,$fn=90);
            translate ([11,-5,2])
            cylinder(r=3.35,h=5,$fn=6);
            
        }
            difference (){
            translate ([29,45,0]) 
            cylinder(r1=4,r2=4.75,h=4.5,$fn=90);
            translate ([29,45,-1])
            cylinder (r=1.375,h=5,$fn=90);
            translate ([29,45,2])
            cylinder(r=3.35,h=5,$fn=6);
            
        }
    }
}

module heatsink_slot() {
    difference () {
        translate([-0,-1,0]) cube([40,42,2]);
        translate ([0,-1,1.7]) cube ([40,42,.3]);             
        translate ([9.65,-2,-1]) cube ([20.7,44,5]);
    }
    difference () {
        translate ([5.65,-1,1.7]) cube ([4,42,1.3]);
        translate ([9.10,-1,1.7]) cube ([2,42,1.3]);
    }
    difference () {
        translate ([30.35,-1,1.7]) cube ([4,42,1.3]);
        translate ([30.35,-1,1.7]) cube ([.5,42,1.3]);
    }
}

module heatsink_spacer() {
    difference () {
        translate ([0,0,0]) cube ([8,8,1]);
        translate ([1.5,1.5,-1]) cube ([5,5,3]);
    }
        difference () {
        translate ([15,0,0]) cube ([8,8,1.05]);
        translate ([16.5,1.5,-1])cube ([5,5,3]);
    }    difference () {
        translate ([0,15,0]) cube ([8,8,1]);
        translate ([1.5,16.5,-1]) cube ([5,5,3]);
    }
        difference () {
        translate ([15,15,0]) cube ([8,8,1.05]);
        translate ([16.5,16.5,-1])cube ([5,5,3]);
    }
}

// micro-pump ettech 23 series
module ettech_23() {
$fn=90;
    difference () {
        union () {
            translate ([0, 0, 0]) cylinder (h=21.7, d=26, center=0);
            translate ([0, 0, 21.7]) cylinder (h=4, d=21, center=0);
            translate ([0, 0, 25.7]) cylinder (h=10, d=9.5, center=0);
            translate ([6.7, 23, 21.7]) rotate ([90, 0, 0]) cylinder (h=20, d=6, center=0);
            translate ([6.7, 23, 21.7]) rotate ([90, 0, 0]) cylinder (h=2, d1=6, d2=6.88, center=0);
            translate ([6.7, 21, 21.7]) rotate ([90, 0, 0]) cylinder (h=2, d1=6, d2=6.88, center=0);
            translate ([6.7, 19, 21.7]) rotate ([90, 0, 0]) cylinder (h=2, d1=6, d2=6.88, center=0);
            translate ([-1.5, 9.5, 21.7]) cube([3,3,3]);
            translate ([-1.5, -12.5, 21.7]) cube([3,3,3]);
            translate ([-12.5, -1.5, 21.7]) cube([3,3,3]);
            translate ([9.5, -1.5, 21.7]) cube([3,3,3]);
            }
        translate ([0, 0, 26.7]) cylinder ( h=10, d=8, center=0);
        translate ([6.7, 24, 21.7]) rotate ([90, 0, 0]) cylinder (h=21, d=5, center=0);
        }
}

// DIG 1/4" barb, straight and elbow
module dig_barb(type) {
$fn=90;
if (type == 0 || type == 06) {
    translate ([0,0,-(type)])
    difference () {
        union () {
            translate ([0, 0, 0]) cylinder (h=29, d=4, center=0);
            translate ([0, 0, 6]) cylinder (h=5, d=4.75, center=0);
            translate ([0, 0, 6]) rotate ([0, 180, 0]) cylinder (h=4, d1=6, d2=4, center=0);                       
            translate ([0, 0, 11]) cylinder (h=7, d=6.2, center=0);
            translate ([0, 0, 18]) cylinder (h=5, d=4.75, center=0);
            translate ([0, 0, 23]) rotate ([0, 0, 0]) cylinder (h=4, d1=6, d2=4, center=0);
            hull() {
                translate([1,0,13.5]) cylinder(h=2, d=9.4);
                translate([-1,0,13.5]) cylinder(h=2, d=9.4);
                }
            }
        translate ([0, 0, -1]) cylinder ( h=31, d=3 , center=0);
        if (type == 06) {
            translate ([-3,-3,-.99]) cube ([6,6,7]);        
        }
    }
}
if (type == 90 || type == 96) {
    translate ([0,0,-(type-90)])
    difference () {
        union () {
            //bottom end
            translate ([0, 0, 0]) cylinder (h=18, d=4, center=0);
            translate ([0, 0, 6]) cylinder (h=5, d=4.75, center=0);
            translate ([0, 0, 6]) rotate ([0, 180, 0]) cylinder (h=4, d1=6, d2=4, center=0);
            // thick corner
            translate ([0, 0, 11]) cylinder (h=7.5, d=6.2, center=0);
            translate ([-1.5, 0, 17]) rotate ([0,90,0]) cylinder (h=7.5, d=6.2, center=0);
            // elbow end
            translate ([15, 0, 17]) rotate ([0,90,0]) cylinder (h=2, d=4, center=0);
            translate ([6, 0, 17]) rotate ([0,90,0]) cylinder (h=5, d=4.75, center=0);
            translate ([11, 0, 17]) rotate ([0, 90, 0]) cylinder (h=4, d1=6, d2=4, center=0);
            // corner tab
            rotate ([0,45,0]) translate ([-12.4,0,-2.5]) 
            hull() {
                translate([1,0,13.5]) cylinder(h=2, d=9.4);
                translate([-1,0,13.5]) cylinder(h=2, d=9.4);
                }
            }
        translate ([0, 0, -1]) cylinder ( h=18, d=3 , center=0);
        translate ([-1.5, 0, 17]) rotate ([0,90,0]) cylinder ( h=19, d=3 , center=0);
        if (type == 96) {
            translate ([-3,-3,-.99]) cube ([6,6,7]);
            }
        }
    }        
}

// pipe length
module pipe(od,id,length) {
    translate([0,0,0]) rotate([-90,0,0])
        difference() {
            translate([0,0,0]) cylinder(d=od, h=length);
            translate([0,0,-1]) cylinder(d=id, h=length+3);
        }
}

// pipe end connectors
module pipe_connector(pipe_od,pipe_id,connector_length,) {
    $fn = 60;
    z = pipe_od+2;
    radius = z/2;
    translate([-(z/2),-(z/2),-z])
        difference() {
            union() {
                slab([connector_length,z,z], radius);
                translate([radius,radius,z-1]) cylinder(d=z, h=pipe_od);
                translate([connector_length-radius,radius,z-1]) cylinder(d=z, h=pipe_od);
            }
            translate([radius,radius,z-1]) cylinder(d=pipe_od, h=6);
            translate([radius,radius,z/3.5]) cylinder(d=pipe_id, h=6+pipe_id);
            translate([connector_length-radius,radius,z-1]) cylinder(d=pipe_od, h=6);
            translate([connector_length-radius,radius,z/3.5]) cylinder(d=pipe_id, h=6+pipe_id);
        
            translate([pipe_id,radius,radius]) rotate([0,90,0]) cylinder(d=pipe_id, h=connector_length-(pipe_od+1.5));
        }
}

// pipe elbow connectors
module pipe_elbow(pipe_od,pipe_id,connector_length,) {
    $fn = 90;
    z = pipe_od+2;
    radius = z/2;
//    translate([-(z/2),-(z/2),-z])
        difference() {
            union() {
                slab([connector_length,z,z], radius);
                translate([radius,radius,z-1]) cylinder(d=z, h=3);
                //translate([connector_length-(2*radius),radius,radius]) rotate([0,90,0]) cylinder(d=z, h=pipe_od);
            }
            translate([radius,radius,z-2]) cylinder(d=pipe_od, h=connector_length);
            translate([radius,radius,z/3.5]) cylinder(d=pipe_id, h=6+pipe_id);
            translate([radius*2,radius,radius]) rotate([0,90,0]) cylinder(d=pipe_od, h=connector_length);
            translate([radius,radius,radius]) rotate([0,90,0]) cylinder(d=pipe_id, h=connector_length);
        
            //translate([pipe_id,radius,radius]) rotate([0,90,0]) cylinder(d=pipe_id, h=connector_length-(pipe_od+1.5));
        }
}

/* plate heat exchanger */
module heat_exchanger_plate(side, heat_exchanger_x, heat_exchanger_y, heat_exchanger_z, corner_radius, corner_holes) {
$fn=90;
floor = -1;
overhang = 27;
    
difference() {
    union() {
        difference() {
            translate([0,0,0]) slab([heat_exchanger_x, heat_exchanger_y, heat_exchanger_z], corner_radius);
            translate([10,5,floor]) cube([heat_exchanger_x-20,heat_exchanger_y-10,heat_exchanger_z+2]);
            }
        // divider end support
        translate([10,5,0]) cube([4,heat_exchanger_y-10,1]);
        translate([heat_exchanger_x-14,5,0]) cube([4,heat_exchanger_y-5,1]);
        if(legs == 1) {
            // legs
            translate([-overhang,0,0]) cube([overhang+2,heat_exchanger_y,3]);
        }
        // dividers
        if(side == "right") {
            for (c=[heat_exchanger_y-5:-9:8]) {
                translate([10,c,0]) cube([heat_exchanger_x-23,2,heat_exchanger_z]);
                translate([13,c-4.5,0]) cube([heat_exchanger_x-23,2,heat_exchanger_z]);
                }
            // pump support
            translate([20,heat_exchanger_y-9,heat_exchanger_z-2]) cylinder (h=6, d=12.5);
            translate([20,heat_exchanger_y-9,heat_exchanger_z-2]) cylinder (h=2, d=18);
            translate([20,heat_exchanger_y-9,0]) cylinder (h=1, d=18);
            // fan mount
            translate([-fan_mount_thick,8,heat_exchanger_z+fan_size]) rotate([0,90,0])
                fan_mount(fan_size,fan_mount_thick,"right",fan_hole_size,fan_hole_offset);
            translate([-fan_mount_thick,8,0]) cube([fan_mount_thick+.5,fan_size,7]);
            //trans hole support
            translate([heat_exchanger_x-12,7.25,heat_exchanger_z-4]) cylinder (h=4, d=9);
            // corner standoffs
            if(standoffs == 1 || standoffs == 3) {
                standoff([heat_exchanger_x-4,heat_exchanger_y-4,heat_exchanger_z], [8,standoff_right_size,standoff_right_holesize,0,0,0,0,1]);
                standoff([heat_exchanger_x-4,4,heat_exchanger_z], [8,standoff_right_size,standoff_right_holesize,0,0,0,0,1]);
                standoff([4,heat_exchanger_y-4,heat_exchanger_z], [8,standoff_right_size,standoff_right_holesize,0,0,0,0,1]);
                standoff([4,4,heat_exchanger_z], [8,standoff_right_size,standoff_right_holesize,0,0,0,0,1]);
            }
        }
        if(side == "left") {
            for (c=[heat_exchanger_y-5:-9:8]) {
                translate([10,c-4.5,0]) cube([heat_exchanger_x-23,2,heat_exchanger_z]);
                translate([13,c,0]) cube([heat_exchanger_x-23,2,heat_exchanger_z]);
                }
            //trans hole support
            translate([heat_exchanger_x-12,heat_exchanger_y-7.25,heat_exchanger_z-4]) cylinder (h=4, d=9);
            // fan mount
            translate([-fan_mount_thick,(heat_exchanger_y-8)-fan_size,heat_exchanger_z+fan_size]) rotate([0,90,0])
                fan_mount(fan_size,fan_mount_thick,"right",fan_hole_size,fan_hole_offset);
            translate([-fan_mount_thick,(heat_exchanger_y-8)-fan_size,0]) cube([fan_mount_thick+.5,fan_size,7]);
            // pump support peg
            translate([20,9,heat_exchanger_z-1.5]) cylinder (h=1.5, d=16);
            translate([20,9,heat_exchanger_z]) cylinder (h=6, d=8);          
            // corner standoffs
            if(standoffs == 1 || standoffs == 2) {
                standoff([heat_exchanger_x-4,heat_exchanger_y-4,heat_exchanger_z], [8,standoff_left_size,standoff_left_holesize,0,0,0,0,0]);
                standoff([heat_exchanger_x-4,4,heat_exchanger_z], [8,standoff_left_size,standoff_left_holesize,0,0,0,0,0]);
                standoff([4,heat_exchanger_y-4,heat_exchanger_z], [8,standoff_left_size,standoff_left_holesize,0,0,0,0,0]);
                standoff([4,4,heat_exchanger_z], [8,standoff_left_size,standoff_left_holesize,0,0,0,0,0]);
            }
        }
    }
    if(side == "right") {
        // pump inlet hole
        translate([20,heat_exchanger_y-9,heat_exchanger_z-3]) cylinder (h=9, d=10);
        translate([20,heat_exchanger_y-9,-1]) cylinder (h=11, d=8);
        // exchanger internal trim
        translate([32,heat_exchanger_y-11,-1]) cube([heat_exchanger_x-46,5,heat_exchanger_z+2]);
        translate([heat_exchanger_x-15,heat_exchanger_y-11,1]) cube([5,5,heat_exchanger_z+2]);
        // fill hole
        translate([heat_exchanger_x-11, heat_exchanger_y-10, heat_exchanger_z/2]) rotate ([0,90,0]) cylinder (h=12, d=5);
        // trans holes side
        translate([heat_exchanger_x-12,7.25,1]) cylinder (h=heat_exchanger_z+2, d=3);
        translate([heat_exchanger_x-12,7.25,heat_exchanger_z-3]) cylinder (h=5, d=5);
        }
    if(side == "left") {
        // exchanger internal trim
        translate([14,heat_exchanger_y-11,-1]) cube([heat_exchanger_x-30.5,5,heat_exchanger_z+2]);
        translate([10,heat_exchanger_y-11,1]) cube([5,5,heat_exchanger_z+2]);
        
        // trans holes side
        translate([heat_exchanger_x-12,heat_exchanger_y-7.25,1]) cylinder (h=heat_exchanger_z+2, d=3);
        translate([heat_exchanger_x-12,heat_exchanger_y-7.25,heat_exchanger_z-3]) cylinder (h=5, d=5);
        // barb inlet holes
        translate([13, 8, heat_exchanger_z/2]) rotate ([90,0,0]) cylinder (h=9, d=5); 
        // pump support peg hollow
        translate([20,9,heat_exchanger_z+1]) cylinder (h=7, d=6);
    }
    // holes and legs
    // corner thru holes
    if(corner_holes == 1) {
        // corner holes
        translate([heat_exchanger_x-4,heat_exchanger_y-4,-1]) cylinder(d=corner_holesize, h=heat_exchanger_z+2);
        translate([heat_exchanger_x-4,4,-1]) cylinder(d=corner_holesize, h=heat_exchanger_z+2);
        translate([4,heat_exchanger_y-4,-1]) cylinder(d=corner_holesize, h=heat_exchanger_z+2);
        translate([4,4,-1]) cylinder(d=corner_holesize, h=heat_exchanger_z+2);
    }
    // plate screw holes long side
    translate([12,heat_exchanger_y-2.5,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    translate([((heat_exchanger_x-29)/3)+12,heat_exchanger_y-2.5,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    translate([((heat_exchanger_x-29)/3)+12,2.5,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    translate([((heat_exchanger_x-29)/3)*2+12,heat_exchanger_y-2.5,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    translate([((heat_exchanger_x-29)/3)*2+12,2.5,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    translate([heat_exchanger_x-17,heat_exchanger_y-2.5,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    // hole move for pump support
    if(side == "left") {
        translate([20,2.5,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    } else
        translate([12,2.5,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    translate([heat_exchanger_x-17,2.5,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    // plate screw holes short side
    translate([6,heat_exchanger_y-12,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    translate([6,(heat_exchanger_y-24)/2+12,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);    
    translate([6,12,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    // move for fill hole clearance
    if(side == "right") {
        translate([heat_exchanger_x-6,heat_exchanger_y-15,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    } else
        translate([heat_exchanger_x-6,heat_exchanger_y-12,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    translate([heat_exchanger_x-6,(heat_exchanger_y-24)/2+12,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    translate([heat_exchanger_x-6,12,-1]) cylinder(d=heat_exchanger_holesize, h=heat_exchanger_z+2);
    if(legs == 1) {
        // legs cut out
        translate([-42,heat_exchanger_y/2,-1]) cylinder(d=heat_exchanger_y-10, h=heat_exchanger_z+2);
    }
  }
}

/* fan */
module fan(size) {

$fn=90;
thick = 11;

difference () {
    cube ([size,size,thick]);
    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-2);
    // mount holes
    translate ([size-4,size-4,-1]) cylinder(h=thick+2, d=3);
    translate ([size-4,4,-1]) cylinder(h=thick+2, d=3);
    translate ([4,size-4,-1]) cylinder(h=thick+2, d=3);
    translate ([4,4,-1]) cylinder(h=thick+2, d=3);
    // trim
    //translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=75);


    }
}

/* fan mounting block */
module fan_mount(fan_size, fan_mount_thick, side, fan_hole_size, fan_hole_offset) {

$fn=90;

if(side == "both") {
    difference () {
        cube([fan_size,fan_size,fan_mount_thick]);
        translate ([fan_size/2,fan_size/2,-1]) cylinder(h=fan_mount_thick+2, d=fan_size-2);
        // mount holes
        translate([size-fan_hole_offset,size-fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        translate([size-fan_hole_offset,fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        translate([fan_hole_offset,size-fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        translate([fan_hole_offset,fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        // trim
        translate([fan_size/2,fan_size/2,fan_mount_thick/2]) cube([fan_size*.6,fan_size+2,fan_mount_thick+2], center=true);
        }
    }
if(side == "right") {
    difference () {
        cube([fan_size,fan_size,fan_mount_thick]);
        translate ([fan_size/2,fan_size/2,-1]) cylinder(h=fan_mount_thick+2, d=fan_size-2);
        // mount holes
        translate([fan_size-fan_hole_offset,fan_size-fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        translate([fan_size-fan_hole_offset,fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        translate([fan_hole_offset,fan_size-fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        translate([fan_hole_offset,fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        // trim
        translate([fan_size/2,fan_size/2,fan_mount_thick/2]) cube([fan_size*.6,fan_size+2,fan_mount_thick+2], center=true);
        translate([-1,-1,-1]) cube([fan_size*.5,fan_size+2,fan_mount_thick+2]);       
        }
    }
if(side == "left") {
    difference () {
        cube([fan_size,fan_size,fan_mount_thick]);
        translate ([fan_size/2,fan_size/2,-1]) cylinder(h=fan_mount_thick+2, d=fan_size-2);
        // mount holes
        translate([fan_size-fan_hole_offset,fan_size-fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        translate([fan_size-fan_hole_offset,fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        translate([fan_hole_offset,fan_size-fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        translate([fan_hole_offset,fan_hole_offset,-1]) cylinder(h=fan_mount_thick+2, d=fan_hole_size);
        // trim
        translate([fan_size/2,fan_size/2,fan_mount_thick/2]) cube([fan_size*.6,fan_size+2,fan_mount_thick+2], center=true);
        translate([fan_size/2,-1,-1]) cube([fan_size*.5,fan_size+2,fan_mount_thick+2]);      
        }
    }
}

/* hard drive 2.5", height=drive height */
module hd25(height) {
    hd25_x = 100;
    hd25_y = 69.85;
    hd25_z = height;
    offset = .01;
    $fn=90;
    
    difference() {
        color("LightGrey",.6) cube([hd25_x,hd25_y,hd25_z]);
        
        // bottom screw holes
        color("Black",.6) translate([9.4,4.07,-offset]) cylinder(d=3,h=3+offset);
        color("Black",.6) translate([86,4.07,-offset]) cylinder(d=3,h=3+offset);
        color("Black",.6) translate([86,65.79,-offset]) cylinder(d=3,h=3+offset);
        color("Black",.6) translate([9.4,65.79,-offset]) cylinder(d=3,h=3+offset);

        // side screw holes
        color("Black",.6) translate([9,-offset,3.5]) rotate([-90,0,0]) cylinder(d=3,h=3);
        color("Black",.6) translate([86,-offset,3.5]) rotate([-90,0,0])  cylinder(d=3,h=3);
        color("Black",.6) translate([86,hd25_y+offset,3.5]) rotate([90,0,0])  cylinder(d=3,h=3);
        color("Black",.6) translate([9,hd25_y+offset,3.5]) rotate([90,0,0])  cylinder(d=3,h=3);

        // connector opening
        color("LightSlateGray",.6) translate([hd25_x-5,11,-1]) cube([5+offset,32,5+offset]);
    }
}


 /* hard drive 3.5" */
module hd35() {
    hd35_x = 145;
    hd35_y = 101.6;
    hd35_z = 25;
    offset = .01;    
    $fn=90;
    
    difference() {
        color("LightGrey",.6) cube([hd35_x,hd35_y,hd35_z]);
        
        // bottom screw holes
        color("Black",.6) translate([60,3.5,-offset]) cylinder(d=3,h=3+offset);
        color("Black",.6) translate([105,3.5,-offset]) cylinder(d=3,h=3+offset);
        color("Black",.6) translate([105,96.5,-offset]) cylinder(d=3,h=3+offset);
        color("Black",.6) translate([60,96.5,-offset]) cylinder(d=3,h=3+offset);
        
        // side screw holes
        color("Black",.6) translate([16,-offset,7]) rotate([-90,0,0]) cylinder(d=3,h=3);
        color("Black",.6) translate([76,-offset,7]) rotate([-90,0,0])  cylinder(d=3,h=3);
        color("Black",.6) translate([117.5,-offset,7]) rotate([-90,0,0])  cylinder(d=3,h=3);
        color("Black",.6) translate([117.5,hd35_y+offset,7]) rotate([90,0,0])  cylinder(d=3,h=3);
        color("Black",.6) translate([76,hd35_y+offset,7]) rotate([90,0,0])  cylinder(d=3,h=3);
        color("Black",.6) translate([16,hd35_y+offset,7]) rotate([90,0,0])  cylinder(d=3,h=3);

        // connector opening
        color("LightSlateGray",.6) translate([hd35_x-5,11,-1]) cube([5+offset,32,5+offset]);

    }
}


/* 3.5" hdd to 2.5" hdd holder */
module hdd35_25holder(length) {
    wallthick = 3;
    floorthick = 2;
    hd35_x = length;                    // 145mm for 3.5" drive
    hd35_y = 101.6;
    hd35_z = 12;
    hd25_x = 100;
    hd25_y = 69.85;
    hd25_z = 9.5;
    hd25_xloc = 2;                     // or (hd35_x-hd25_x)/2
    hd25_yloc = (hd35_y-hd25_y)/2;
    hd25_zloc = 9.5;
    offset = .01;    
    $fn=90;
    difference() {
        union() {
            difference() {
                translate([(hd35_x/2),(hd35_y/2),(hd35_z/2)])         
                    cube_fillet_inside([hd35_x,hd35_y,hd35_z], 
                        vertical=[3,3,3,3], top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);      
                translate([(hd35_x/2),(hd35_y/2),(hd35_z/2)+floorthick])           
                    cube_fillet_inside([hd35_x-(wallthick*2),hd35_y-(wallthick*2),hd35_z], 
                        vertical=[0,0,0,0], top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);
                   
                // end trim
                translate([-offset,5,wallthick+2]) cube([wallthick+(offset*2),hd35_y-10,10]);
                translate([hd35_x-wallthick-offset,5,wallthick+2]) cube([wallthick+(offset*2),hd35_y-10,10]);
                
                // bottom vents
                for ( r=[15:40:hd35_x-40]) {
                    for (c=[25:4:75]) {
                        translate ([r,c,-offset]) cube([35,2,wallthick+(offset*2)]);
                    }
                }       
            }
            // 2.5 hdd bottom support
            translate([9.4+hd25_xloc,4.07+hd25_yloc,floorthick-offset]) cylinder(d=8,h=wallthick);
            translate([86+hd25_xloc,4.07+hd25_yloc,floorthick-offset]) cylinder(d=8,h=wallthick);
            translate([86+hd25_xloc,65.79+hd25_yloc,floorthick-offset]) cylinder(d=8,h=wallthick);
            translate([9.4+hd25_xloc,65.79+hd25_yloc,floorthick-offset]) cylinder(d=8,h=wallthick);
        
        // side nut holder support    
        translate([16,wallthick-offset,7]) rotate([-90,0,0]) cylinder(d=10,h=3);
        translate([76,wallthick-offset,7]) rotate([-90,0,0])  cylinder(d=10,h=3);
            if(length >= 120) {
                translate([117.5,wallthick-offset,7]) rotate([-90,0,0])  cylinder(d=10,h=3);
                translate([117.5,hd35_y-wallthick-offset,7]) rotate([90,0,0])  cylinder(d=10,h=3);
            }
        translate([76,hd35_y-wallthick-offset,7]) rotate([90,0,0])  cylinder(d=10,h=3);
        translate([16,hd35_y-wallthick-offset,7]) rotate([90,0,0])  cylinder(d=10,h=3);
        
        // bottom-side support
        translate([wallthick,wallthick,floorthick-2]) rotate([45,0,0]) cube([hd35_x-(wallthick*2),3,3]);
        translate([wallthick,hd35_y-wallthick+offset,floorthick-2]) rotate([45,0,0]) cube([hd35_x-(wallthick*2),3,3]);
         
        }
        // bottom screw holes
        translate([9.4+hd25_xloc,4.07+hd25_yloc,-offset]) cylinder(d=3,h=(floorthick*3)+(offset*2));
        translate([86+hd25_xloc,4.07+hd25_yloc,-offset]) cylinder(d=3,h=(floorthick*3)+(offset*2));
        translate([86+hd25_xloc,65.79+hd25_yloc,-offset]) cylinder(d=3,h=(floorthick*3)+(offset*2));
        translate([9.4+hd25_xloc,65.79+hd25_yloc,-offset]) cylinder(d=3,h=(floorthick*3)+(offset*2));
        
         // countersink holes
        translate([9.4+hd25_xloc,4.07+hd25_yloc,-offset]) cylinder(d1=6, d2=3.6, h=2);
        translate([86+hd25_xloc,4.07+hd25_yloc,-offset]) cylinder(d1=6, d2=3.6, h=2);
        translate([86+hd25_xloc,65.79+hd25_yloc,-offset]) cylinder(d1=6, d2=3.6, h=2);
        translate([9.4+hd25_xloc,65.79+hd25_yloc,-offset]) cylinder(d1=6, d2=3.6, h=2);
       
        // side screw holes
        translate([16,-offset,7]) rotate([-90,0,0]) cylinder(d=3.6,h=7);
        translate([76,-offset,7]) rotate([-90,0,0])  cylinder(d=3.6,h=7);
        translate([117.5,-offset,7]) rotate([-90,0,0])  cylinder(d=3.6,h=7);
        translate([117.5,hd35_y+offset,7]) rotate([90,0,0])  cylinder(d=3.6,h=7);
        translate([76,hd35_y+offset,7]) rotate([90,0,0])  cylinder(d=3.6,h=7);
        translate([16,hd35_y+offset,7]) rotate([90,0,0])  cylinder(d=3.6,h=7);
        
        // side nut trap    
        translate([16,wallthick-offset,7]) rotate([-90,0,0]) cylinder(r=3.30,h=5,$fn=6);
        translate([76,wallthick-offset,7]) rotate([-90,0,0])  cylinder(r=3.30,h=5,$fn=6);
        translate([117.5,wallthick-offset,7]) rotate([-90,0,0])  cylinder(r=3.30,h=5,$fn=6);
        translate([117.5,hd35_y-wallthick-offset,7]) rotate([90,0,0])  cylinder(r=3.30,h=5,$fn=6);
        translate([76,hd35_y-wallthick-offset,7]) rotate([90,0,0])  cylinder(r=3.30,h=5,$fn=6);
        translate([16,hd35_y-wallthick-offset,7]) rotate([90,0,0])  cylinder(r=3.30,h=5,$fn=6);
    }
}

/* odroid-hc4 oled */
module hc4_oled() {
offset = .01;
$fn=90;

oled_x = 28.5;
oled_y = 1.25;
oled_z = 48.6;

oled_open_x = 29;
oled_open_y = 1.5;
    difference() {
        union() {
            // pcb board
            color("Tan", 1) translate([0,0,0]) cube([oled_x,oled_y,oled_z]);
            // oled
            color("Black", 1) translate([.5,-.625,25.5]) cube([oled_x-1,.625,15]);
            color("DarkGrey", 1) translate([.5,-.625,40.5]) cube([oled_x-1,.625,4]);
        }
        translate([2.8,0,46.7]) {
            translate([-.6,1.26,0]) rotate([90,0,0])
                hull() {
                translate([1.2,0,0]) cylinder(d=1.8, h=1.25+(offset*2));
                cylinder(d=1.8, h=1.25+(offset*2));
                }
        }
        translate([25.7,0,46.7]) {
            translate([-.6,1.26,0]) rotate([90,0,0])
                hull() {
                translate([1.2,0,0]) cylinder(d=1.8, h=1.25+(offset*2));
                cylinder(d=1.8, h=1.25+(offset*2));
                }
        }
        
    }
}
