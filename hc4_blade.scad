/*
    Odroid-HC4 Blade Copyright 2021 Edward A. Kisiel
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

    20210320 Version 1.0    Odroid-HC4 Blade
    20210423 Version 1.1    fixed fan mount hole spacing, changed to sbc_case_builder_library.scad

*/

use <./lib/sbc_models.scad>;
use <./lib/sbc_case_builder_library.scad>;
use <./lib/fillets.scad>;

/* user configurable options */
mode = "model";                         // platter, model, explode, debug
model = "blade";                        // blade, node, dualnode, cluster, rack, accessories
top_height = 22;                        // blade=22mm, node & dualnode=18mm(minimum)
bottom_height = 10;                     // blade=10mm(minimum)
drvdepth = 105;                         // drive bay depth extension, blade=105mm, node & dualnode=0mm
drvwidth = 0;                           // drive bay width extension, blade=0mm, node=0mm
vents = 1;                              // side drive bay vents 0=disable, 1=enable
oled = 1;                               // hc4 oled holder 0=disable, 1=enable
ir_ports = 1;                           // openings for ir 0=disable, 1=sides, 2=end(diskless node)
sata_cutout = 2;                        // sata openings 0=disable, 1=opening, 2=punchout
sata_up_adapter = 1;                    // use sata up(left angle) adapter for drive location
sata_cable = 2;                         // sata cable restraint 0=disable, 1=front, 2=back, 3=both
rear_drv = 0;                           // drive location at far rear 0=disable, 1=enable
i_rack = 0;                             // integrated rack interconnects 0=disable, 1=enable

fillet = 0;
c_fillet = 9;
wall_thick = 2;
floor_thick = 1.5;
gap = .5;                               // distance between pcb and case
pcb_width = 90.6;
pcb_depth = 84;
pcb_z = 1.6;
width = pcb_width+(wall_thick*2)+(2*gap)+drvwidth;
depth = pcb_depth+(wall_thick*2)+(2*gap)+drvdepth;
hd25_xloc1 = 4;                         // blade 2.5" hd x axis location
hd25_yloc1 = 80;                        // blade 2.5" hd y axis location
hd25_xloc2 = 4;                         // rear 2.5" hd x axis location
hd25_yloc2 = depth-114;                 // rear 2.5" hd y axis location

top_standoff =    [6.75,                // diameter
                   top_height,          // height top_height
                   2.75,                // holesize
                   10,                  // supportsize
                   4,                   // supportheight
                   4,                   // 0=none, 1=countersink, 2=recessed hole, 3=nut holder, 4=blind hole
                   1,                   // standoff style 0=hex, 1=cylinder
                   0,                   // enable reverse standoff
                   0,                   // enable insert at top of standoff
                   0,                   // insert hole dia. mm
                   0];                  // insert depth mm

bottom_standoff = [7.5,                 // diameter
                   bottom_height-pcb_z, // height  bottom_height-pcb_z
                   3.6,                 // holesize
                   10,                  // supportsize
                   4,                   // supportheight
                   1,                   // 0=none, 1=countersink, 2=recessed hole, 3=nut holder, 4=blind hole
                   1,                   // standoff style 0=hex, 1=cylinder
                   0,                   // enable reverse standoff
                   0,                   // enable insert at top of standoff
                   0,                   // insert hole dia. mm
                   0];                  // insert depth mm
                   
connect = [12,14,36.5];                 // interconnection height integrated=36.5
i_hole = 5.5;                           // interconnection hole size

adjust = .1;
$fn=90;
/*
$vpt = [13, 11, 33];
$vpr = [67, 0, 360 * $t];
$vpd = 600;    
*/

echo("width=",top_height+bottom_height," depth=",depth," height=",width);

if(mode == "platter") {
    if(model == "blade" || model == "node") {
        hc4_blade_bottom();
        translate([(2*width)+20,0,0]) rotate([0,0,180]) hc4_blade_top(model);
        }
    if(model == "dualnode") {
        union() {
            translate([(width/2)-wall_thick-gap,(194/2)-wall_thick-gap,floor_thick/2]) 
                cube_fillet_inside([width,204-(depth*2),floor_thick], 
                    vertical=[1,1,1,1], top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);
            translate([0,0,0]) hc4_blade_bottom(model);
            translate([0,194-depth,0]) hc4_blade_bottom(model);
            }
        translate([(2*width)+20,0,0]) rotate([0,0,180]) hc4_blade_top(model);
        translate([(2*width)+20,194-depth,0]) rotate([0,0,180]) hc4_blade_top(model);
        }
    }
if(mode == "model") { 
    if(model == "blade" || model == "node") {
        translate([0,0,3])blade();
        if(model == "blade") {
            color("grey",.4) translate([-32,-65,0]) rotate([0,0,0]) stand();
            }
        }
    if(model == "dualnode") {
        translate([-(top_height+bottom_height)/2,194/2,wall_thick+gap]) rotate([180,270,0]) {
            color("grey",.8) translate([(width/2)-wall_thick-gap,(194/2)-wall_thick-gap,floor_thick/2]) 
                cube_fillet_inside([width,204-(depth*2),floor_thick], 
                    vertical=[1,1,1,1], top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);
            color("grey",.3) translate([0,0,0]) hc4_blade_bottom(model);
            color("grey",.3) translate([0,194-depth,0]) hc4_blade_bottom(model);
            color("grey",.3) translate([0,0,28]) rotate([0,180,180]) hc4_blade_top(model);
            color("grey",.3) translate([0,194-depth,28]) rotate([0,180,180]) hc4_blade_top(model);
            translate([0,0,bottom_standoff[1]]) sbc("hc4");
            translate([0,194-depth,bottom_standoff[1]]) sbc("hc4");
            }
        }
    if(model == "cluster") {
        c_thick =  bottom_height+top_height;
        c_gap = 8;
        translate([0,0,0]) blade();
        translate([c_thick+c_gap,0,0]) blade();
        translate([(c_thick+c_gap)*2,0,0]) blade();
        translate([(c_thick+c_gap)*3,0,0]) blade();
        color("grey",1) translate([-24,-70,-3]) multi_stand(4);
        color("grey",1) translate([-24,60,-3]) multi_stand(4);
        }
    if(model == "rack") {
        c_thick =  bottom_height+top_height;
        c_gap = 4.5;
        translate([-21.5-c_gap-3,-87.5,109]) rotate([-90,0,0]) rack_end_bracket("left", 25, 122, 3);
        translate([458.5,-87.5,-13.5]) rotate([-90,180,0]) rack_end_bracket("right", 25, 122, 3);
        translate([((top_height+bottom_height)/2),0,0]) blade();
        translate([c_thick+c_gap+((top_height+bottom_height)/2),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*2),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*3),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*4),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*5),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*6),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*7),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*8),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*9),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*10),0,0]) blade();
        translate([((top_height+bottom_height)/2)+((c_thick+c_gap)*11),0,0]) blade();
        }
    }

    if(model == "accessories") {
        translate([0,0,0]) stand();
        translate([100,0,0]) blade_rack_bracket();
        translate([230,0,0]) multi_stand(6);
        translate([230,30,0]) multi_stand(5);
        translate([230,60,0]) multi_stand(4);
        translate([230,90,0]) multi_stand(3);
        translate([230,120,0]) multi_stand(2);
        translate([0,-36,0]) sata_restraint();
        translate([100,-30,8]) rotate([180,0,0]) feet(8);
        translate([115,-30,8]) rotate([180,0,0]) feet(8);
        translate([130,-30,8]) rotate([180,0,0]) feet(8);
        translate([145,-30,8]) rotate([180,0,0]) feet(8);
        translate([190,-50,25]) rotate([0,90,180]) rack_end_bracket("left", 25, 122, 3);
        translate([250,-170,25]) rotate([0,90,0]) rack_end_bracket("right", 25, 122, 3);
    }

if(mode == "explode") {
    feet = [$t*-100,0,0];
    top = [0,0,$t*100];
    bottom = [0,0,$t*-100];
    translate([-(top_height+bottom_height)/2,depth/2,wall_thick+gap+3]) rotate([180,270,0]) {
                if(oled) {
                    translate([30,depth+gap-(2*wall_thick)-4.25,floor_thick-.5+28.5]) 
                        rotate([0,90,0]) hc4_oled();
                    }
                if(model == "blade") {
                    translate([73,84+95,bottom_standoff[1]+8.6+13]) rotate([180,0,-90]) hd25(7);
                    }
            animate(feet) {
                translate([0,0,bottom_standoff[1]]) sbc("hc4");
                color("grey",.4) translate([-5,15,49]) rotate([0,90,0]) stand();
                }
            animate(top) {
                translate([0,0,bottom_standoff[1]]) sbc("hc4");
                color("grey",.3) translate([0,0,top_height+bottom_height]) 
                    rotate([180,0,0]) hc4_blade_top(model);
            }
            animate(bottom) {
                translate([0,0,bottom_standoff[1]]) sbc("hc4");
                color("grey",.3) hc4_blade_bottom(model);
            }
        }
    }

if(mode == "debug") {
    hc4_blade_top(model);
    }

// blade assembled
module blade() {
    translate([-(top_height+bottom_height)/2,depth/2,wall_thick+gap]) rotate([180,270,0]) {
        color("grey",.3) hc4_blade_bottom(model);
        color("grey",.3) translate([0,0,top_height+bottom_height]) rotate([180,0,0]) hc4_blade_top(model);
        translate([0,0,bottom_standoff[1]]) sbc("hc4");
        if(model == "blade") {
            translate([73,84+95,bottom_standoff[1]+8.6+13]) rotate([180,0,-90]) hd25(7);
            }
        if(oled) {
            translate([30,depth+gap-(2*wall_thick)-4.25,floor_thick-.5+28.5]) rotate([0,90,0]) hc4_oled();
            }
        }
    }

// odroid-hc4 blade bottom
module hc4_blade_bottom(model) {
    difference() {
        union() {
            difference() {
                translate([(width/2)-wall_thick-gap,(depth/2)-wall_thick-gap,bottom_height/2]) 
                    cube_fillet_inside([width,depth,bottom_height], 
                        vertical=[c_fillet,c_fillet,c_fillet,c_fillet], top=[0,0,0,0], 
                            bottom=[fillet,fillet,fillet,fillet,fillet], $fn=90);
                translate([(width/2)-wall_thick-gap,(depth/2)-wall_thick-gap,
                    (bottom_height/2)+floor_thick]) 
                        cube_fillet_inside([width-(wall_thick*2),depth-(wall_thick*2),bottom_height], 
                            vertical=[c_fillet-1,c_fillet-1,c_fillet-1,c_fillet-1],
                                top=[0,0,0,0],bottom=[2,2,2,2], $fn=90);
                // standoff holes
                translate([4,5.5,-adjust]) cylinder(d=6, h=bottom_height);
                translate([pcb_width-4,5.5,-adjust]) cylinder(d=6, h=bottom_height);
                translate([4,58.5,-adjust]) cylinder(d=6, h=bottom_height);
                translate([pcb_width-4,pcb_depth-5.5,-adjust]) cylinder(d=6, h=bottom_height);
                if(drvdepth >= 13) {
                    translate([4,depth-(2*wall_thick)-5.5-(2*gap),-adjust]) 
                        cylinder(d=6, h=bottom_height);
                    translate([pcb_width-4,depth-(2*wall_thick)-5.5-(2*gap),-adjust]) 
                        cylinder(d=6, h=bottom_height);
                    }
                }
            // pcb standoffs
            translate([4,5.5,0]) standoff(bottom_standoff);
            translate([pcb_width-4,5.5,0]) standoff(bottom_standoff);
            translate([4,58.5,0]) standoff(bottom_standoff);
            translate([pcb_width-4,pcb_depth-5.5,0]) standoff(bottom_standoff);
            if(drvdepth >= 13) {
                // drive bay standoffs
                translate([4,depth-(2*wall_thick)-5.5-(2*gap),0]) standoff(bottom_standoff);
                translate([pcb_width-4,depth-(2*wall_thick)-5.5-(2*gap),0]) standoff(bottom_standoff);
                }
            // oled mount points
            if(oled) {
                // mounting blocks
                translate([77,depth-(2*wall_thick)-gap-9,floor_thick]) cube([5,9,3]);
                translate([26,depth-(2*wall_thick)-gap-8,floor_thick]) cube([5,8,3]);
                // display trim
                translate([54,depth-(2*wall_thick)-gap-2+adjust,floor_thick]) 
                    cube([2,2,bottom_height-floor_thick]);   
                translate([70,depth-(2*wall_thick)-gap-2+adjust,floor_thick]) 
                    cube([2,2,bottom_height-floor_thick]);   
                translate([54,depth-(2*wall_thick)-gap-2+adjust,floor_thick]) 
                    cube([16,2,1]);   
                }
            // heatsink fan hole support
            translate([21+(43/2),35-5.5,floor_thick-adjust]) cylinder(d=7, h=2);
            translate([21+(43/2),35+34+5.5,floor_thick-adjust]) cylinder(d=7, h=2);
            }
        // heatsink opening
        translate([21,35,-adjust]) cube([43,34,floor_thick+(2*adjust)]);
        // heatsink spring pin holes
        translate([16.91,44.52,-adjust]) cylinder(d=6.5, h=bottom_standoff[1]);
        translate([68.09,64.53,-adjust]) cylinder(d=6.5, h=bottom_standoff[1]);
        // heatsink fan holes
        translate([21+(43/2),35-5.5,-adjust]) cylinder(d=3, h=bottom_standoff[1]);
        translate([21+(43/2),35+34+5.5,-adjust]) cylinder(d=3, h=bottom_standoff[1]);
        translate([9+(43/2),69,-adjust]) cylinder(d=5, h=bottom_standoff[1]);
        // button hole
        translate([37.65,77.85,-adjust]) cylinder(d=5, h=floor_thick+(2*adjust));
        // hdmi opening
        translate([58.5,-adjust,floor_thick+bottom_height-10]) hdmi_open();
        // bottom side vents
        if(vents) {
            if(rear_drv) {
                for (r=[15:4:60]) {
                    for(c=[drvdepth-20:30:170]) {
                        translate([r,c,-adjust]) cube([2,25,floor_thick+(adjust*2)]);
                        }
                    }
                }
            if(sata_up_adapter) {
                for (r=[15:4:60]) {
                    for(c=[85:30:150]) {
                        translate([r,c,-adjust]) cube([2,25,floor_thick+(adjust*2)]);
                        }
                    }
                }
            }
        // ir ports
            if(ir_ports == 1) {
                for(c=[87:4:110]) {
                    translate([width-(wall_thick*2)-(2*gap)-14,c,-adjust]) 
                        cube([12,2,wall_thick+(2*adjust)]);
                }
            }
        // oled opening
        if(oled) {
            // bottom indent
            translate([31,depth-(2*wall_thick)-gap-3-2.5,floor_thick-1]) cube([46,3,bottom_height]);
            // mount block openings
            translate([76,depth-(2*wall_thick)-gap-4-1.75,floor_thick-1]) cube([3,1.75,bottom_height]);
            translate([29,depth-(2*wall_thick)-gap-2.5-1.6,floor_thick-1]) cube([3,1.6,bottom_height]);
            // display opening
            translate([56,depth-(2*wall_thick)-gap-adjust,floor_thick+1]) 
                cube([14,wall_thick+(2*adjust),top_height]);
            }
        }
    }

// odroid-hc4 blade top
module hc4_blade_top(model) {
    difference() {
        union() {
            difference() {
                union() {
                    difference() {
                        translate([(width/2)-wall_thick-gap,-(depth/2)+wall_thick+gap,top_height/2]) 
                            cube_fillet_inside([width,depth,top_height], 
                                vertical=[c_fillet,c_fillet,c_fillet,c_fillet], top=[0,0,0,0], 
                                    bottom=[fillet,fillet,fillet,fillet,fillet], $fn=90);
                        translate([(width/2)-wall_thick-gap,-(depth/2)+wall_thick+gap,(top_height/2)+floor_thick])
                            cube_fillet_inside([width-(wall_thick*2),depth-(wall_thick*2),top_height], 
                                vertical=[c_fillet-1,c_fillet-1,c_fillet-1,c_fillet-1],
                                    top=[0,0,0,0],bottom=[2,2,2,2], $fn=90);
                    }
                // standoff supports
                translate([2,-2,0]) cylinder(d=4, h=top_height);
                translate([pcb_width-3,-1,0]) cylinder(d=4, h=top_height);
                translate([.25,-58.5,0]) cylinder(d=4, h=top_height);
                translate([pcb_width-.25,-pcb_depth+5.5,0]) cylinder(d=4, h=top_height);
                if(drvdepth >= 13) {
                    translate([2,-depth+(2*wall_thick)+2+(2*gap),0]) cylinder(d=4, h=top_height);
                    translate([pcb_width-2,-depth+(2*wall_thick)+2+(2*gap),0]) cylinder(d=4, h=top_height);
                    }
                }
                //standoff holes
                translate([4,-5.5,-adjust]) cylinder(d=6, h=bottom_height);
                translate([pcb_width-4,-5.5,-adjust]) cylinder(d=6, h=bottom_height);
                translate([4,-58.5,-adjust]) cylinder(d=6, h=bottom_height);
                translate([pcb_width-4,-pcb_depth+5.5,-adjust]) cylinder(d=6, h=bottom_height);
                if(drvdepth >= 13) {
                    translate([4,-depth+(2*wall_thick)+5.5+(2*gap),-adjust]) cylinder(d=6, h=bottom_height);
                    translate([pcb_width-4,-depth+(2*wall_thick)+5.5+(2*gap),-adjust]) 
                        cylinder(d=6, h=bottom_height);
                    }
                }
            // pcb standoffs
            translate([4,-5.5,0]) standoff(top_standoff);
            translate([pcb_width-4,-5.5,0]) standoff(top_standoff);
            translate([4,-58.5,0]) standoff(top_standoff);
            translate([pcb_width-4,-pcb_depth+5.5,0]) standoff(top_standoff);
            // drive bay standoffs
            if(drvdepth >= 13) {
                translate([4,-depth+(2*wall_thick)+5.5+(2*gap),0]) standoff(top_standoff);
                translate([pcb_width-4,-depth+(2*wall_thick)+5.5+(2*gap),0]) standoff(top_standoff);
                }
            // drive mount for sata up(left) adapter
            if(sata_up_adapter) {
                // 2.5 hdd bottom support
                translate([4.07+hd25_xloc1-gap,-9.4-hd25_yloc1,floor_thick]) cylinder(d=8,h=top_height-20);
                translate([65.79+hd25_xloc1-gap,-9.4-hd25_yloc1,floor_thick]) cylinder(d=8,h=top_height-20);
                translate([65.79+hd25_xloc1-gap,-86-hd25_yloc1,floor_thick]) cylinder(d=8,h=top_height-20);
                translate([4.07+hd25_xloc1-gap,-86-hd25_yloc1,floor_thick]) cylinder(d=8,h=top_height-20);
                }
            // sata cable restraint support for m3 nut
            if(sata_cable == 1 || sata_cable == 3) {
                translate([12.5,-65.55-5.75,floor_thick-adjust]) cylinder(d=10,h=3);
                translate([73.5,-65.55-5.75,floor_thick-adjust]) cylinder(d=10,h=3);
                }            
            if(sata_cable == 2 || sata_cable == 3) {
                translate([12.5,-28.85-1.75,floor_thick-adjust]) cylinder(d=10,h=3);
                translate([73.5,-28.85-1.75,floor_thick-adjust]) cylinder(d=10,h=3);
                }            
            // rear drive mount
            if(rear_drv) {
                // 2.5 hdd bottom support
                translate([4.07+hd25_xloc2-gap,-9.4-hd25_yloc2,floor_thick]) cylinder(d=8,h=top_height-20);
                translate([65.79+hd25_xloc2-gap,-9.4-hd25_yloc2,floor_thick]) cylinder(d=8,h=top_height-20);
                translate([65.79+hd25_xloc2-gap,-86-hd25_yloc2,floor_thick]) cylinder(d=8,h=top_height-20);
                translate([4.07+hd25_xloc2-gap,-86-hd25_yloc2,floor_thick]) cylinder(d=8,h=top_height-20);
                }
            // oled mount points
            if(oled) {
                // mounting blocks
                translate([77,-depth+(2*wall_thick)+gap,floor_thick]) cube([5,9,3]);
                translate([26,-depth+(2*wall_thick)+gap,floor_thick]) cube([5,8,3]);
                // display trim
                translate([54,-depth+(2*wall_thick)+gap-adjust,floor_thick]) 
                    cube([2,2,top_height-floor_thick]);   
                translate([70,-depth+(2*wall_thick)+gap-adjust,floor_thick]) 
                    cube([2,2,top_height-floor_thick]);   
                translate([54,-depth+(2*wall_thick)+gap-adjust,floor_thick]) 
                    cube([16,2,1]);   
                }
            // wall supports
            translate([49,.5,0]) cylinder(d=4, h=top_height);
            translate([60,.5,0]) cylinder(d=4, h=top_height);
            // integrated rack interconnects
            if(i_rack) {
                translate([-(connect[0]/2)-wall_thick-gap+adjust-.5,
                    -(connect[1]/2)+wall_thick+gap-10,connect[2]/2]) 
                        interconnect(connect, i_hole, 3, 0);
                translate([width+(connect[0]/2)-wall_thick-gap-adjust+.5,
                    -(connect[1]/2)+wall_thick+gap-10,connect[2]/2]) 
                        interconnect(connect, i_hole, 3, 0);
                translate([-(connect[0]/2)-wall_thick-gap+adjust-.5,
                    -depth+(connect[1]/2)+wall_thick+gap+10,connect[2]/2]) 
                        interconnect(connect, i_hole, 3, 0);
                translate([width+(connect[0]/2)-wall_thick-gap-adjust+.5,
                    -depth+(connect[1]/2)+wall_thick+gap+10,connect[2]/2]) 
                        interconnect(connect, i_hole, 3, 0);              

                translate([-(connect[0]/2)-wall_thick-gap+adjust-.6+6,
                    -(connect[1]/2)+wall_thick+gap-10-5,0]) 
                        cube([.7,10,top_height]);
                translate([width+(connect[0]/2)-wall_thick-gap-adjust-6.5+.5,
                    -(connect[1]/2)+wall_thick+gap-10-6,0]) 
                        cube([.7,12,top_height]);
                translate([-(connect[0]/2)-wall_thick-gap+adjust-.6+6,
                    -depth+(connect[1]/2)+wall_thick+gap+10-5,0]) 
                        cube([.7,10,top_height]);
                translate([width+(connect[0]/2)-wall_thick-gap-adjust-6.5+.5,
                    -depth+(connect[1]/2)+wall_thick+gap+10-6,0]) 
                        cube([.7,12,top_height]);              
                }
            }
        // power opening
        translate([7.75,gap-adjust,top_height-10]) cube([7,wall_thick+(2*adjust),top_height]);
        // sdcard opening
        translate([19,gap-adjust,top_height-3.75]) cube([12.5,wall_thick+(2*adjust),2.5]);
        // usb opening
        translate([35.25,gap-adjust,top_height-14.5]) cube([7,wall_thick+(2*adjust),top_height]);
        // rj45 opening
        translate([67,gap-adjust,top_height-14]) cube([16,wall_thick+(2*adjust),top_height]);
        // led viewport
        translate([width-(wall_thick*2)-(2*gap)-adjust,-69,top_height-2-12]) 
            cube([wall_thick+(2*gap)+(2*adjust),2,12]);
        translate([width-(wall_thick*2)-(2*gap)-adjust,-73,top_height-2-12]) 
            cube([wall_thick+(2*gap)+(2*adjust),2,12]);
        translate([width-(wall_thick*2)-(2*gap)-adjust,-77,top_height-2-12]) 
            cube([wall_thick+(2*gap)+(2*adjust),2,12]);
        // ir ports
        if(ir_ports == 1) {
            for(c=[-89:-4:-110]) {
                translate([width-(wall_thick*2)-(2*gap)-adjust,c,top_height-2-12]) 
                    cube([wall_thick+(2*gap)+(2*adjust),2,12]);
                }
            for(c=[-89:-4:-110]) {
                translate([width-(wall_thick*2)-(2*gap)-14,c,-adjust]) 
                    cube([12,2,wall_thick+(2*adjust)]);
                }
            }
        if(ir_ports == 2) {
            for(c=[74:4:85]) {
                translate([c,-depth+wall_thick,top_height-2-12]) 
                    cube([2,wall_thick+wall_thick+(2*adjust),12]);
                }            
            }
        // drive mount for sata up(left) adapter
        if(sata_up_adapter) {
            // hdd screw holes
            translate([4.07+hd25_xloc1-gap,-(9.4+hd25_yloc1),-adjust]) cylinder(d=3,h=top_height);
            translate([65.79+hd25_xloc1-gap,-(9.4+hd25_yloc1),-adjust]) cylinder(d=3,h=top_height);
            translate([65.79+hd25_xloc1-gap,-(86+hd25_yloc1),-adjust]) cylinder(d=3,h=top_height);
            translate([4.07+hd25_xloc1-gap,-(86+hd25_yloc1),-adjust]) cylinder(d=3,h=top_height);
            // hdd countersink holes
            translate([4.07+hd25_xloc1-gap,-(9.4+hd25_yloc1),-adjust]) cylinder(d1=6, d2=3, h=2.5);
            translate([65.79+hd25_xloc1-gap,-(9.4+hd25_yloc1),-adjust]) cylinder(d1=6, d2=3, h=2.5);
            translate([65.79+hd25_xloc1-gap,-(86+hd25_yloc1),-adjust]) cylinder(d1=6, d2=3, h=2.5);
            translate([4.07+hd25_xloc1-gap,-(86+hd25_yloc1),-adjust]) cylinder(d1=6, d2=3, h=2.5);        
            }
        // rear drive mount
        if(rear_drv) {
            // hdd screw holes
            translate([4.07+hd25_xloc2-gap,-(9.4+hd25_yloc2),-adjust]) cylinder(d=3,h=top_height);
            translate([65.79+hd25_xloc2-gap,-(9.4+hd25_yloc2),-adjust]) cylinder(d=3,h=top_height);
            translate([65.79+hd25_xloc2-gap,-(86+hd25_yloc2),-adjust]) cylinder(d=3,h=top_height);
            translate([4.07+hd25_xloc2-gap,-(86+hd25_yloc2),-adjust]) cylinder(d=3,h=top_height);
            // hdd countersink holes
            translate([4.07+hd25_xloc2-gap,-(9.4+hd25_yloc2),-adjust]) cylinder(d1=6, d2=3, h=2.5);
            translate([65.79+hd25_xloc2-gap,-(9.4+hd25_yloc2),-adjust]) cylinder(d1=6, d2=3, h=2.5);
            translate([65.79+hd25_xloc2-gap,-(86+hd25_yloc2),-adjust]) cylinder(d1=6, d2=3, h=2.5);
            translate([4.07+hd25_xloc2-gap,-(86+hd25_yloc2),-adjust]) cylinder(d1=6, d2=3, h=2.5);        
            }
        // top vents
        if(vents) {
            if(rear_drv) {
                for(r=[15:4:60]) {
                    for(c=[drvdepth+5:30:195]) {
                        translate([r,-c,-adjust]) cube([2,25,floor_thick+(adjust*2)]);
                        }
                    }
                }
            if(sata_up_adapter) {
                for(r=[15:4:60]) {
                    for(c=[110:30:175]) {
                        translate([r,-c,-adjust]) cube([2,25,floor_thick+(adjust*2)]);
                        }
                    }                    
                }
            }
        // oled openings
        if(oled) {
            // bottom indent
            translate([31,-depth+(2*wall_thick)+gap+2.5,floor_thick-1]) cube([46,3,bottom_height]);
            // mount block openings
            translate([76,-depth+(2*wall_thick)+gap+4,floor_thick-1]) cube([3,1.75,bottom_height]);
            translate([29,-depth+(2*wall_thick)+gap+2.5,floor_thick-1]) cube([3,1.6,bottom_height]);
            // display opening
            translate([56,-depth+(wall_thick)+gap-adjust,floor_thick+1]) 
                cube([14,wall_thick+(2*adjust),top_height]);
            }
        // sata openings
        if(sata_cutout == 1) {
            translate([22,-28.85-1.75,-adjust]) slot(7.5,42,floor_thick+(2*adjust));
            translate([22,-65.55-5.75,-adjust]) slot(7.5,42,floor_thick+(2*adjust));
            }
        // sata punchouts
        if(sata_cutout == 2) {
            difference() {
                union() {
                    translate([22,-28.85-1.75,-adjust]) slot(7.5,42,floor_thick+(2*adjust));
                    translate([22,-65.55-5.75,-adjust]) slot(7.5,42,floor_thick+(2*adjust));
                    }
                translate([22,-28.85-1.75,-(2*adjust)]) slot(5.5,42,floor_thick+(4*adjust));
                translate([22,-65.55-5.75,-(2*adjust)]) slot(5.5,42,floor_thick+(4*adjust));
                // cross ties    
                translate([24.5,-36,-(2*adjust)]) cube([2,10.5,floor_thick+(4*adjust)]);
                translate([42,-36,-(2*adjust)]) cube([2,10.5,floor_thick+(4*adjust)]);
                translate([59.5,-36,-(2*adjust)]) cube([2,10.5,floor_thick+(4*adjust)]);
                translate([24.5,-76.5,-(2*adjust)]) cube([2,10.5,floor_thick+(4*adjust)]);
                translate([42,-76.5,-(2*adjust)]) cube([2,10.5,floor_thick+(4*adjust)]);
                translate([59.5,-76.5,-(2*adjust)]) cube([2,10.5,floor_thick+(4*adjust)]);
                }
            }
        // sata cable restraint holes
        if(sata_cable == 1 || sata_cable == 3) {
            translate([12.5,-65.55-5.75,-adjust]) cylinder(d=2.75,h=top_height);
            translate([73.5,-65.55-5.75,-adjust]) cylinder(d=2.75,h=top_height);
            translate([12.5,-65.55-5.75,floor_thick+.5]) cylinder(r=3.3,h=top_height,$fn=6);
            translate([73.5,-65.55-5.75,floor_thick+.5]) cylinder(r=3.3,h=top_height,$fn=6);
            }
        if(sata_cable == 2 || sata_cable == 3) {
            translate([12.5,-28.85-1.75,-adjust]) cylinder(d=2.75,h=top_height);
            translate([73.5,-28.85-1.75,-adjust]) cylinder(d=2.75,h=top_height);
            translate([12.5,-28.85-1.75,floor_thick+.5]) cylinder(r=3.3,h=top_height,$fn=6);
            translate([73.5,-28.85-1.75,floor_thick+.5]) cylinder(r=3.3,h=top_height,$fn=6);
            }            
        }
    }

// common hdmi opening
module hdmi_open() {
    translate([-11.5,0,5.5]) rotate([180,0,0]) {
    union() { 
        difference() {
            translate([0,0,0]) cube([15.5, 11.5, 5.5]);
            translate([0,-.2,0]) rotate ([-90,0,0]) cylinder(d=3, h=13.5,$fn=30);
            translate([15.5,-.2,0]) rotate ([-90,0,0]) cylinder(d=3, h=13.5,$fn=30);
            }
        translate([1.5,0,-.49]) cube([12.5, 11.5, .5]);
        }
    }       
}

// sata cable restriant
module sata_restraint() {
    length = 70;
    width = 12;
    height = 2.75;
    shole = 7.5;
    slength = 30;
    difference() {
        translate([length/2,width/2,height/2]) cube_fillet_inside([length,width,height], 
                    vertical=[4,4,4,4], top=[2,0,2,0], bottom=[0,0,0,0], $fn=90);
        translate([(length-slength)/2,4.5,-adjust]) slot(shole,slength,height+(2*adjust));
        // trim opening
        translate([(length-slength-shole)/2,-adjust,-adjust]) cube([slength+shole,4,height+(2*adjust)]);        
        // slots
        translate([4.5,(width/2)-2,-adjust]) rotate([0,0,90]) slot(3.6,4,height+(2*adjust));
        translate([length-4.5,(width/2)-2,-adjust]) rotate([0,0,90]) slot(3.6,4,height+(2*adjust));
        }
    }
 
// vertical single stand
module stand() {
    width = 64;
    depth = 20;
    thick = 15;
    fillet = 4;
    c_fillet = 9;   
    difference() {
        translate([width/2,depth/2,thick/2]) cube_fillet_inside([width,depth,thick], 
            vertical=[c_fillet,c_fillet,c_fillet,c_fillet], top=[0,c_fillet*2,0,c_fillet*2], 
                bottom=[0,0,0,0], $fn=90);
       translate([16.5,-adjust,3]) cube([top_height+bottom_height,depth+(2*adjust),thick]);
    }
    translate([0,125,0])
    difference() {
        translate([width/2,depth/2,thick/2]) cube_fillet_inside([width,depth,thick], 
            vertical=[c_fillet,c_fillet,c_fillet,c_fillet], top=[0,c_fillet*2,0,c_fillet*2], 
                bottom=[0,0,0,0], $fn=90);
       translate([16.5,-adjust,3]) cube([top_height+bottom_height,depth+(2*adjust),thick]);
    }
    translate([width/2,(depth/2)+62.5,3/2]) cube_fillet_inside([10,125,3], 
        vertical=[0,0,0,0], top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);
}

// multi blade stand
module multi_stand(number) {
    width = 32;
    depth = 20;
    thick = 15;
    fillet = 2;
    c_fillet = 2;
    space = 8;
    
    difference() {
        translate([(((width+space)*(number))+8)/2,depth/2,thick/2]) 
            cube_fillet_inside([((number)*(width+space))+24,depth,thick], 
                vertical=[c_fillet,c_fillet,c_fillet,c_fillet], top=[0,c_fillet*2,0,c_fillet*2], 
                    bottom=[0,0,0,0], $fn=90);
        for (c=[8:width+8:(number)*(space+width)]) {
            translate([c,-adjust,3]) cube([width,depth+(2*adjust),thick], $fn=90);
            }
        }
    }

module interconnect(size, hole, i_fillet, fillet) {
    difference() {
        cube_fillet_inside(size, vertical=[i_fillet,i_fillet,i_fillet,i_fillet], 
            top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);
        // center hole
        cylinder(d=hole, h=size[2]+(adjust*2), center=true);
        // structural holes
        translate([size[0]/4,size[1]/4,0]) 
            difference() {
                cylinder(d=hole-1.25, h=size[2]+(adjust*2), center=true);
                translate([-hole/3,-hole/3,0]) cylinder(d=hole-1, h=size[2]+(adjust*2), center=true);
            }   
        translate([size[0]/4,-size[1]/4,0])
            difference() {
                cylinder(d=hole-1.25, h=size[2]+(adjust*2), center=true);
                translate([-hole/3,hole/3,0]) cylinder(d=hole-1, h=size[2]+(adjust*2), center=true);
            }   
        translate([-size[0]/4,size[1]/4,0]) 
            difference() {
                cylinder(d=hole-1.25, h=size[2]+(adjust*2), center=true);
                translate([hole/3,-hole/3,0]) cylinder(d=hole-1, h=size[2]+(adjust*2), center=true);
            }   
        translate([-size[0]/4,-size[1]/4,0]) 
            difference() {
                cylinder(d=hole-1.25, h=size[2]+(adjust*2), center=true);
                translate([hole/3,hole/3,0]) cylinder(d=hole-1, h=size[2]+(adjust*2), center=true);
            }   
    }
}

module blade_rack_bracket() {
    difference() {
        union() {
            translate([((width+1)/2)-wall_thick-gap,(depth/2)-wall_thick-gap,1]) 
                cube_fillet_inside([(width+1),depth,2], 
                    vertical=[c_fillet,c_fillet,c_fillet,c_fillet], 
                        top=[0,0,0,0], bottom=[0,0,0,0,0], $fn=90);
            // interconnectors
            translate([-(connect[0]/2)-wall_thick-gap+adjust,
                (connect[1]/2)-wall_thick-gap+10,connect[2]/2]) 
                    interconnect(connect, i_hole, 3, 0);
            translate([(width+1)+(connect[0]/2)-wall_thick-gap-adjust,
                (connect[1]/2)-wall_thick-gap+10,connect[2]/2]) 
                    interconnect(connect, i_hole, 3, 0);
            translate([-(connect[0]/2)-wall_thick-gap+adjust,
                depth-(connect[1]/2)-wall_thick-gap-10,connect[2]/2]) 
                    interconnect(connect, i_hole, 3, 0);
            translate([(width+1)+(connect[0]/2)-wall_thick-gap-adjust,
                depth-(connect[1]/2)-wall_thick-gap-10,connect[2]/2]) 
                    interconnect(connect, i_hole, 3, 0);
        }
    // holes
    translate([4,5.5,-adjust]) 
        cylinder(d=top_standoff[2], h=bottom_height);
    translate([width-4-wall_thick-gap,5.5,-adjust]) 
        cylinder(d=top_standoff[2], h=bottom_height);
    translate([4,pcb_depth-5.5,-adjust]) 
        cylinder(d=top_standoff[2], h=bottom_height);
    translate([width-4-wall_thick-gap,58.5,-adjust]) 
        cylinder(d=top_standoff[2], h=bottom_height);
    translate([4,depth-(2*wall_thick)-5.5+(2*gap),-adjust]) 
        cylinder(d=top_standoff[2], h=bottom_height);
    translate([width-wall_thick-(2*gap)-4,depth-(2*wall_thick)-5.5+(2*gap),-adjust]) 
        cylinder(d=top_standoff[2], h=bottom_height);
    // frame
    translate([10-wall_thick-gap,10-wall_thick-gap,-adjust]) cube([width-20,depth/4,2+(2*adjust)]);    
    translate([10-wall_thick-gap,depth-10-(depth/4)-wall_thick-gap,-adjust]) 
        cube([width-20,depth/4,2+(2*adjust)]);
    translate([10-wall_thick-gap,20+(depth/4)+wall_thick+gap,-adjust]) cube([width-20,depth/4,2+(2*adjust)]);
    }
}

module rack_end_bracket(side, width, depth, height) {
i_fillet = 12.5;
c_fillet = 2;
hole = 3.2;
rack_hole = 6;
b_width = 3;
b_depth = depth;
b_height = 190;
b_loc = [22,0,0];
adjust = .1;
$fn=90;  
difference() {
    union() {
        translate([(width/2),(depth/2),height/2]) 
            cube_fillet_inside([width,depth,height], 
                vertical=[0,c_fillet,c_fillet,0],top=[0,0,0,0],bottom=[0,0,0,0], $fn=90);
        translate([(b_width/2)+b_loc[0],(b_depth/2)+b_loc[1],(b_height/2)+b_loc[2]])         
            cube_fillet_inside([b_width,b_depth,b_height], 
                vertical=[0,0,0,0],top=[c_fillet,0,c_fillet,0],bottom=[0,0,0,0], $fn=90);
    }
    // holes
    if(side == "left") {
        translate([width-b_width-adjust,7.5,10]) rotate([0,90,0]) cylinder(d=5.5,h=b_width+(adjust*2));
        translate([width-b_width-adjust,depth-6.5,10]) rotate([0,90,0]) cylinder(d=5.5,h=b_width+(adjust*2));
        translate([width-b_width-adjust,7.5,170]) rotate([0,90,0]) cylinder(d=5.5,h=b_width+(adjust*2));
        translate([width-b_width-adjust,depth-6.5,170]) rotate([0,90,0]) cylinder(d=5.5,h=b_width+(adjust*2));
        // rack slots
            for (c=[7.5:15:depth]) {
                translate([10,c,-adjust]) slot(rack_hole,3,height+(adjust*2));
                }
    }
    if(side == "right") {
        translate([width-b_width-adjust,7.5,10]) rotate([0,90,0]) cylinder(d=5.5,h=b_width+(adjust*2));
        translate([width-b_width-adjust,depth-6.5,10]) rotate([0,90,0]) cylinder(d=5.5,h=b_width+(adjust*2));
        translate([width-b_width-adjust,7.5,170]) rotate([0,90,0]) cylinder(d=5.5,h=b_width+(adjust*2));
        translate([width-b_width-adjust,depth-6.5,170]) rotate([0,90,0]) cylinder(d=5.5,h=b_width+(adjust*2));
        // rack slots
            for (c=[depth-7.5:-15:0]) {
                translate([10,c,-adjust]) slot(rack_hole,3,height+(adjust*2));
                }
    }
    // panel cutouts
    translate([width-b_width-adjust,(depth/2)-35,25]) rotate([90,0,90])
        hull() {
            cylinder(d=6,h=3+(adjust*2));
            translate([70,0,0]) cylinder(d=6,h=3+(adjust*2));
            translate([70/2,40,0]) cylinder(d=6,h=3+(adjust*2));
            }
    translate([width+adjust,(depth/2)-35,155]) rotate([-90,0,90])
        hull() {
            cylinder(d=6,h=3+(adjust*2));
            translate([70,0,0]) cylinder(d=6,h=3+(adjust*2));
            translate([70/2,40,0]) cylinder(d=6,h=3+(adjust*2));
            }
    translate([width-b_width-adjust,(depth/2)-50,125]) rotate([90,90,90])
        hull() {
            cylinder(d=6,h=3+(adjust*2));
            translate([70,0,0]) cylinder(d=6,h=3+(adjust*2));
            translate([70/2,40,0]) cylinder(d=6,h=3+(adjust*2));
            }
    translate([width+adjust,(depth/2)+50,125]) rotate([90,90,-90])
        hull() {
            cylinder(d=6,h=3+(adjust*2));
            translate([70,0,0]) cylinder(d=6,h=3+(adjust*2));
            translate([70/2,40,0]) cylinder(d=6,h=3+(adjust*2));
            }
    }
}
   
// animate pieces
module animate(distance) {
    for ( i= [0:1:$children-1])            
        translate( [i*distance[0],i*distance[1],i*distance[2]] ) {
        children(i);
    } 
}

