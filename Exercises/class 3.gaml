/**
* Model:        OrderOfExecution
* Author:       Upendra Oli
* Description:  This model demonstrates the how list can be used and modified in GAMA.
*/
model ListExample


global
{ 
 	list<int> age_list <- [];
 	int heading_of_cow <- 90;
 	int heading_of_sheep <- 90; // move towards south
// 	geometry action_area_sheep <- polygon([(10,10), (30,10), (30,30), (10,30)]);
// 	geometry action_area_goat <- polygon([(10,10), (30,10), (30,30), (10,30)]);
// 	target_of_goat <- {0,0};
 	init{
 		create cows number:5 {
 			speed <- 2.0;
 		}
 		
 		create sheeps number:3 {
 			speed <- 1.0;
 		}
 		
 		create goats number:2 {
 			speed <- 0.5;
 		}
 		
 	}
 	

	

//	
//	reflex update_actionArea_sheeps {
//		ask sheeps{
//			int next_heading_sheeps <- heading_of_sheep/2;
//			action_area_sheep <- circle(2) intersection cone(heading - next_heading_sheeps, heading + next_heading_sheeps);		
//			write "sheeps: "+next_heading_sheeps;
//			}
//	}
//	
//	reflex update_actionArea_goats {
//		ask goats{
//			action_area_goat <- line(self.location, {0,0}) intersection circle(0.5);
////			write "goats: "+action_area;
//		}
//	}

}


species cows skills:[moving]{
	geometry action_area_cow;
//	float cow_heading;
	init {
//		cow_heading <- rnd(0.0,360.0);
	}
	
//	action move_within_action_area_cow {	
//		action_area_cow <- circle(5) intersection cone(heading - 45.0, heading + 45.0);
//		write "cow "+index+" heading old: "+ cow_heading;
//
//		// need to write the actual action to restrict the cow to move within cow action area. 
////		if (cow_heading > heading+45 or cow_heading < heading-45) {
////			cow_heading <- (heading/360)*45;
////			write "cow "+index+" heading new: "+ cow_heading;
////	     }
//	}
	
	reflex move{
		do move;
		action_area_cow <- circle(6) intersection cone(heading - 45.0, heading + 45.0);
//		do move_within_action_area_cow;
	}
	

	
	 aspect default{
     	draw circle(2) color:rgb(165, 42,42) border: #green; // make color more darker red as the more population of lion is of older age.
     }
     
     aspect action_neighbourhood{
		draw action_area_cow color: rgb(165, 42,42); // draw circle instead
	}
     
//    aspect cow_3d{
//    	pair<float, point> r0 <- -90::{1,0,0};
//    	pair<float, point> pitch <- 0::{1,0,0};
//    	pair<float, point> roll <- 0::{0,1,0};
//    	pair<float, point> yaw <- heading::{1,0,0};
//    	draw obj_file("./images/18415_Cow_v1.obj", rotation_composition(r0,pitch,roll, yaw)) at: location +{0,0,3} rotate: heading-90 color: rgb(165, 42,42) ;
//    	
//    }
}

species sheeps skills:[moving]{
	geometry action_area_sheep;
	init {
	}
	reflex move{
//		action_area_sheep <- circle(6) intersection cone(heading - 45.0, heading + 45.0);
		action_area_sheep <- circle(6);
		do move heading: 90.0;
		
	}
	aspect default{
     	draw circle(2) color:#black border: #green; // make color more darker red as the more population of lion is of older age.
    }
    aspect action_neighbourhood{
		draw action_area_sheep color: #black; // draw circle instead
	}
}

species goats skills:[moving]{
	geometry action_area_goat;
	init {
	}
	reflex move{
		action_area_goat <- line(self.location, {0,0});
		do goto target: {0,0};
	}
	 aspect default{
     	draw circle(2) color:#yellow border: #green; // make color more darker red as the more population of lion is of older age.
     }
     aspect action_neighbourhood{
		draw action_area_goat color: #yellow; // draw circle instead
	}
    
}



grid CA {
//    int grid_var <- 1 update: grid_var + 1;
	int grid_var <- grid_x update: grid_var + 1;  // cell values of a grid is equal to their x coordinate value  
    init{
//    	grid_var <- grid_var + 1;
//        write "CA variable init: " + grid_var;
    }

    reflex reflexA{
    	grid_var <- grid_var + 1;
    	
//        write "CA variable: " + grid_var;
    }
    
     aspect default{
     	draw square(1) color:#green border: #grey;
     }
}


experiment OrderOfExecution type: gui {
	output {
              display map type:opengl{
                     species CA aspect: default;
                     species cows aspect: default;
                     species cows aspect: action_neighbourhood transparency: 0.5;
//                     species cows aspect: cow_3d transparency:0.3;
                     species sheeps aspect: default;
                     species sheeps aspect: action_neighbourhood transparency: 0.9;
                     species goats aspect: default;
                     species goats aspect: action_neighbourhood transparency: 0.5;
              }
       }
}