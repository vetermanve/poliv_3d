font = "Liberation Sans:style=Bold";

letter_size = 1.8;
letter_height = 1;

module letter(l) {
	// Use linear_extrude() to make the letters 3D objects as they
	// are only 2D shapes when only using text()
	linear_extrude(height = letter_height) {
		text(l, size = letter_size, font = font, halign = "center", valign = "center", $fn = 16);
	}
}

// ring with cutout
// default values are for 1mm height, 10mm outside diameter and 5mm cutout
// de is epsilon environment to make cutouts non-manifold
module ring(
        h=1, // height
        od = 10, // outside diameter
        id = 5, // inside diameter
        de = 0.1, // delta 
        fn= 16 // quality
        )
{
    difference() {
        cylinder(h=h, r=od/2, $fn=fn);
        translate([0, 0, -de])
            cylinder(h=h+2*de, r=id/2, $fn=fn);
    }
}

module gear(
        sp_c = 24, // sprikes count
        sp_h = 0.35, // sprikes height
        g_r = 2.5, // gear_radius (without spikes)
        g_h = 1, // gear_height (z)
        de = 0.03, // delta
        )
{
    
    gear_s_count = sp_c;
    gear_h = sp_h;
    gear_r = g_r;
    gear_w = 2*3.1416926*gear_r/gear_s_count - de;
    gear_w_center_diff = gear_w/2;
    gear_z = g_h;
     
    cylinder(r=gear_r + de, h=gear_z, $fn=gear_s_count*4);
    for(i=[0:gear_s_count]) {
        rotate([0, 0, 360/gear_s_count*i]) {
            translate([gear_r, 0, 0])
            linear_extrude(gear_z)
                polygon([
                    [0,0 - gear_w_center_diff],
                    [gear_h,gear_w/2 - gear_w_center_diff],
                    [0,gear_w - gear_w_center_diff]]
                ); 
        }
    }
}

// включение-выключение деталей
ver = "Poliv 2.4.1";
top = 1;
bottom = 1;
shtift = 0;
facet = 0;


// переменные
DELTA=0.1;

r_tube_in = 1.1; // радиус внутренней трубки
r_tube_in_large = 2; // радиус расширения внутренней трубки у основания
r_tube_out = 3.7/2; // радиус трубки наружний
tube_len = 6;
tubes_count = 10;
tubes_place_r = 20;
fn=16;
tubes_radius=160;
tubes_radius_offset = 5;

plast_height = 3;
plast_tube_offset = 6;

//plast_hole_r = 9/2; 
plast_hole_r = 12/2; 
plast_hole_h = plast_height/2 + DELTA;

plast_hole_r_in = 3.2/2;

// фаска
face_h = 0.5; 

// угл расположения сосков
angle = tubes_radius/tubes_count;

    

if(top) {
    
    // version
//    translate([0, tubes_place_r, plast_height - DELTA]) {
    rotate([0, 0, -90])
    translate([0, -tubes_place_r, plast_height - DELTA])
    letter(ver);
    
    // сосчки на верхней 
    for(i=[1:tubes_count]) {
        rotate([0, 0, - tubes_radius_offset - angle*i]) {
          translate([0,tubes_place_r, plast_height - DELTA]) {
            translate([0, plast_tube_offset/1.5, - DELTA/2])
            letter(str(i));
              
            translate([0, -r_tube_out*2  , - DELTA/2])
            letter(str( 180 -tubes_radius_offset - angle*i));
            difference() {
                // сам сосок
                cylinder(r=r_tube_out, h=tube_len,$fn=fn*2);
                // центральная дырка
                translate([0, 0, -DELTA]) 
                    cylinder(r=r_tube_in, h=tube_len+DELTA*2,$fn=fn*2);
 ;
            }
        }
        }
    }
    

    

  difference() {
    // верхняя основа
    cylinder(
        r=tubes_place_r+plast_tube_offset, 
        h=plast_height,
        $fn=fn*4);
    
    // углубление для штифта
    translate([0, 0, -DELTA])
    cylinder(
        r=plast_hole_r + DELTA*2, 
        h=plast_hole_h + DELTA/2,
        $fn=fn*4);
    
    // дырки для сосчков 
    for(i=[1:tubes_count])
        rotate([0, 0, - tubes_radius_offset - angle*i]) {
            // сама дырка
            translate([0,tubes_place_r, -DELTA]) 
                cylinder(r=r_tube_in, h=tube_len+DELTA*2,$fn=fn*2);
            // расширение дырки снизу
            translate([0, tubes_place_r, -DELTA]) 
                cylinder(r1=r_tube_in_large, r2=r_tube_in, h=plast_height,$fn=fn*2);
    }
    
    // дырки для сосчков  // нижнее расширение в дырке
//    for(i=[0:tubes_count])
//        rotate([0, 0, tubes_radius_offset + angle*i]) {
//            // сама дырка
//            translate([0, tubes_place_r, -DELTA]) 
//                cylinder(r=r_tube_in + (r_tube_out - r_tube_in)/2, h=plast_height/2,$fn=fn*2);
//    }
    
//    // фаска
//    translate([0, 0, -DELTA])
//    ring(
//        h=face_h + DELTA, 
//        od=tubes_place_r*2 + plast_tube_offset*1.4 + DELTA, 
//        id=tubes_place_r*2 + plast_tube_offset*1.4 - 1.5 - DELTA, 
//        fn=fn*4
//    );
}


// закрепочный куб
translate([0, -tubes_place_r/2, plast_hole_h + DELTA*2]) 
difference() {   
    // закрепочный куб
    cube([tubes_place_r/2, tubes_place_r, plast_height*2 - plast_hole_h]);
    // дырки в кубе
    // left hole
    translate([tubes_place_r/4, tubes_place_r/2 - 5, -DELTA]) 
    cylinder(
        r=plast_hole_r_in, 
        h=plast_height + plast_hole_h + DELTA*2,
        $fn=fn*4);
    // right hole
    translate([tubes_place_r/4, tubes_place_r/2 + 5, -DELTA]) 
    cylinder(
        r=plast_hole_r_in, 
        h=plast_height + plast_hole_h + DELTA*2,
        $fn=fn*4);
}
}



if(shtift) {
    shtiftYPos = top ? -10 : 0; 
//    g_d = 0.1;
    
    
    for(g_d=[0.15: 0.05: 0.5]) {
    
    translate([-90 + g_d*260, 0, shtiftYPos]) {
      difference() {
        // основной штифт
        cylinder(
            r=plast_hole_r, 
            h=plast_height+ plast_hole_h,
            $fn=fn*4);
        
//        // дырка в шифте 
        translate([0, 0, -DELTA]) 
        cylinder(
            r=1, 
            h=plast_height + plast_hole_h + DELTA*2,
            $fn=fn*4);
         
          

         translate([0, 0, -DELTA])
         gear(
            g_h = plast_height + plast_hole_h + DELTA*2,
            sp_h = 0.35 + g_d,
            g_r = 2.5 + g_d,
            de = 0.03 
         );
      }
      
      translate([0, plast_hole_r-2, plast_height + plast_hole_h - DELTA/2])
      letter(str(g_d));
    }
}
  
}


if(facet) {
    shtiftYPos = top ? -30 : 0; 
   
}


if(bottom) {
    
bottomYPost = top ? -20 : 0; 

translate([0, 0, bottomYPost]) {
    
    // version
    rotate([0, 0, -90])
    translate([0, -tubes_place_r, plast_height - DELTA])
    letter(ver);
    
    // подложка
    difference() {
        
        // основа подложки
        cylinder(
            r=tubes_place_r+plast_tube_offset, 
            h=plast_height,
            $fn=fn*4);
        // дырочка для соска
        rotate([0,0, -tubes_radius_offset]) {
            // сама дырочка
            translate([0,tubes_place_r, -DELTA]) 
                cylinder(r=r_tube_in, h=tube_len+DELTA*2,$fn=fn*2);
            // расширение дырки снизу
            translate([0, tubes_place_r, -DELTA]) 
                cylinder(r1=r_tube_in_large, r2=r_tube_in, h=plast_height/2,$fn=fn*2);
         }
         
         translate([0, 0, -DELTA])
         gear(
            g_h = plast_height+ DELTA*2
         );
         
        // дырки для крепления сервомотора
         
         
        // дырка для закрепки штифта
//        translate([0, 0, -DELTA])
//        cylinder(
//            r=plast_hole_r + DELTA, 
//            h=plast_height + DELTA*2,
//            $fn=fn*4);
         
         
         
//         // фаска
//        translate([0, 0, -DELTA])
//        ring(
//            h=face_h +DELTA, 
//            od=tubes_place_r*2 + plast_tube_offset*1.4 + DELTA, 
//            id=tubes_place_r*2 + plast_tube_offset*1.4 - 1.5 - DELTA, 
//            fn=fn*4
//        );
    
    }
    

    // нижний сосок
    rotate([0,0 , -tubes_radius_offset]){
      translate([0,tubes_place_r, plast_height - DELTA]) 
        difference() {
            cylinder(r=r_tube_out, h=tube_len,$fn=fn*2);
            translate([0, 0, -DELTA]) 
                cylinder(r=r_tube_in, h=tube_len+DELTA*2,$fn=fn*2);
        }
    }
}
}