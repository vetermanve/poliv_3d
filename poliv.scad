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
        or = 5, // outside diameter
        ir = 2.5, // inside diameter
        de = 0.1, // delta 
        fn= 16 // quality
        )
{
    difference() {
        cylinder(h=h, r=or, $fn=fn);
        translate([0, 0, -de])
            cylinder(h=h+2*de, r=ir, $fn=fn);
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
ver = "Poliv 2.4.7";
top = 1;
//top = 0;
bottom = 1;
//bottom = 0;
shtift = 1;
//shtift = 0;
facet = 1;
//facet = 0;

// 0.65 - разница
// фактическая толщина пластинки 3.3

// переменные
DELTA=0.1;

// ребра жесткости
hard_rib_h = 2;
hard_rib_w = 2;

r_tube_in = 1.1; // радиус внутренней трубки
r_tube_in_large = 2; // радиус расширения внутренней трубки у основания
r_tube_out = 3.7/2; // радиус трубки наружний
tube_len = 5 + hard_rib_h;
tubes_count = 10;
tubes_place_r = 20;
fn=32;
tubes_radius=160;
tubes_radius_offset = 2;

plast_height = 3;
plast_tube_offset = 6;



plast_hole_r = 9/2; 
//plast_hole_r = 12/2; 
plast_hole_h = plast_height/2 + DELTA;

plast_hole_r_in = 3.6/2;

// фаска
face_h = 0.5; 

// угл расположения сосков
angle = tubes_radius/tubes_count;

// srewes
fit_offset = 5.5;
screw_count=6;
screw_hole_r=1.075;
screw_offset=2.6;

// 
out_r = tubes_place_r + plast_tube_offset + fit_offset;
mid_r = tubes_place_r + plast_tube_offset;


if(top) {
    

    
    // сосчки на верхней 
    for(i=[1:tubes_count]) {
        rotate([0, 0, - tubes_radius_offset - angle*i]) {
          translate([0,tubes_place_r, plast_height - DELTA]) {
            translate([0, plast_tube_offset/1.5, - DELTA/2])
            letter(str(i));
              
//            translate([0, -r_tube_out*2  , - DELTA/2])
//            letter(str( 180 -tubes_radius_offset - angle*i));
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
    

    cube_height = plast_height*2.5 - plast_hole_h;

  difference() {
    // верхняя основа
      translate([0,0,0]) {          
        // основа
        cylinder(
            r=out_r, 
            h=plast_height,
            $fn=fn*4);
          
          // ребра жесткости
        for(i=[0:6])
            rotate([0, 0, 360/6 *i]) {
             translate([0,0,plast_height - DELTA])
             cube([out_r*2 - DELTA*2, hard_rib_w, hard_rib_h ], center=  true);
            }
            
        // закрепочный куб
        translate([0, -tubes_place_r/2, plast_hole_h + DELTA*2]) 
        cube([tubes_place_r/2, tubes_place_r, cube_height]);
            
         // version
        rotate([0, 0, -90])
        translate([-out_r/3, -tubes_place_r, plast_height - DELTA])
        letter(ver);
            
      }
    
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
    
    // дырки для шурупов
    for (i=[0:screw_count]) {
        rotate([0, 0, 360/screw_count*i]) {
          translate([0, out_r - screw_offset, -DELTA]) {
              cylinder(
                r=screw_hole_r, 
                h=plast_height*2 + DELTA*2,
                $fn=fn*4);
          }
        }
    }

    // дырки в закрепочном кубе
    translate([0, -tubes_place_r/2, plast_hole_h + DELTA*2]){
        translate([tubes_place_r/4, tubes_place_r/2 - 5, -DELTA]) 
        cylinder(
            r1= plast_hole_r_in, 
            r2= plast_hole_r_in+DELTA, 
            h= cube_height + DELTA*2,
            $fn=fn*4);
        // right hole
        translate([tubes_place_r/4, tubes_place_r/2 + 5, -DELTA]) 
        cylinder(
            r1= plast_hole_r_in, 
            r2= plast_hole_r_in+DELTA, 
            h= cube_height + DELTA*2,
            $fn=fn*4);
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
}






if(shtift) {
    
    
    shtiftYPos = top || bottom ? -40 : 0; 
//    g_d = 0.2;
    
    
//    for(g_d=[0.15: 0.05: 0.5]) {
    
    translate([0, 0, shtiftYPos]) {
      difference() {
        // основной штифт
        cylinder(
            r=plast_hole_r, 
            h=plast_height,
            $fn=fn*4);
        
//        // дырка в шифте 
        translate([0, 0, -DELTA]) 
        cylinder(
            r=1, 
            h=plast_height  + DELTA*2,
            $fn=fn*4);
         
          

//         translate([0, 0, -DELTA])
//         gear(
//            g_h = plast_height + plast_hole_h + DELTA*2,
//            sp_h = 0.35 ,
//            g_r = 2.5 + 0.2,
//            de = 0.03 
//         );
      }
      
//      translate([0, plast_hole_r-2, plast_height + plast_hole_h - DELTA/2])
//      letter(str(g_d));
//    }
    }
  
}


if(facet) {
    shtiftZPos = top && bottom ? -40 : 0; 
    shtiftXPos = bottom && !top ? out_r*2 + 3  : 0; 
    
    
    facet_out_r = out_r;
    facet_mid_r = mid_r + DELTA*3;
    facet_inner_r = mid_r-2.5;

   // fitiing
    translate([0, shtiftXPos, shtiftZPos]) {
        
        difference() {
        translate([0,0,0]) {
            // большое кольцо
            ring(
                h=plast_height*2, 
                or = facet_out_r, 
                ir = facet_mid_r, 
                fn=fn*4
            );
            
            // придавочное кольцо
            ring(
                h = plast_height - DELTA*3 - 0.7, 
                or = facet_mid_r + DELTA*3, 
                ir = facet_inner_r, 
                fn=fn*4
            );
            
        }
        

        for (i=[0:screw_count]) {
            rotate([0, 0, 360/screw_count*i]) {
              // дырка под саморез
              translate([0, out_r - screw_offset, -DELTA]) {
                  cylinder(
                    r=screw_hole_r, 
                    h=plast_height*2 + DELTA*2,
                    $fn=fn*4);
              }
              
              // дырка под шляпку самореза
              translate([0, out_r - screw_offset, -DELTA]) {
                  cylinder(
                    r=screw_hole_r*2, 
                    h=plast_height + DELTA*2,
                    $fn=fn*4);
              }
              
              // дырка под шляпку самореза
              translate([0, out_r - screw_offset, plast_height -DELTA]) {
                  cylinder(
                    r1=screw_hole_r*2, 
                    r2=screw_hole_r, 
                    h=plast_height/4,
                    $fn=fn*4);
              }
              
//              translate([0, out_r - screw_offset, -DELTA]) {
//                cube([3,3,9], center = false);
//              }
              

          }
        }
        
        // version
        translate([out_r - (out_r-mid_r)/2, 0, letter_height-DELTA])
        rotate([180, 0, -90])
        letter(ver);
      }
    }
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
            r = tubes_place_r+plast_tube_offset - 0.5, 
            h=plast_height,
            $fn=fn*4);
        // дырочка для соска
        rotate([0,0, -tubes_radius_offset]) {
            // сама дырочка
            translate([0,tubes_place_r, -DELTA]) 
                cylinder(r=r_tube_in, h=tube_len+DELTA*2,$fn=fn*2);
            // расширение дырки снизу
            translate([0, tubes_place_r, -DELTA]) 
                cylinder(r1=r_tube_in_large, r2=r_tube_in, h=plast_height,$fn=fn*2);
         }
         
        
//         // дырка-шестеренка для крепления сервомотора 
//         translate([0, 0, -DELTA])
//         gear(
//            g_h = plast_height + plast_hole_h + DELTA*2,
//            sp_h = 0.35 ,
//            g_r = 2.5 + 0.2,
//            de = 0.03 
//         );
         
        
          for (i=[0:2]) {
             rotate([0, 0, 360/2*i + 30]) {
              // дырка под саморез
              translate([0, 16.5, -DELTA]) {
                  cylinder(
                    r1=screw_hole_r, 
                    r2=screw_hole_r + DELTA*2,
                    h=plast_height*2 + DELTA*2,
                    $fn=fn*4);
                }
             }
          }
        
        // дырка для закрепки штифта
        bottom_hole_height = plast_height;
        translate([0, 0, plast_height - bottom_hole_height - DELTA])
        cylinder(
            r=plast_hole_r + DELTA, 
            h=bottom_hole_height + DELTA*2,
            $fn=fn*4);
         
         
         
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
            cylinder(r=r_tube_out, h=tube_len ,$fn=fn*2);
            translate([0, 0, -DELTA]) 
                cylinder(r=r_tube_in, h=tube_len +DELTA*2,$fn=fn*2);
        }
    }
}
}