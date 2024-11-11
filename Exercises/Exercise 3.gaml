/**
* Model:        OrderOfExecution
* Author:       Upendra Oli
* Description:  This exercise was provided to test and visualize different action neighbourhoods like random walk, correlated random walk, and movement towards target in GAMA platform.
*/
model actionNeighbourhoodExample


global
{ 
 	list<int> age_list <- [];
 	int heading_of_cow <- 90;
 	int heading_of_sheep <- 90; // move towards south

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
}


species cows skills:[moving]{
	geometry action_area_cow;
	init {
	}
	reflex move{
		do move;
		action_area_cow <- circle(6) intersection cone(heading - 45.0, heading + 45.0);
	}
	

	
	 aspect default{
     	draw circle(2) color:rgb(165, 42,42) border: #green; 
     }
     
     aspect action_neighbourhood{
		draw action_area_cow color: rgb(165, 42,42); 
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
     	draw circle(2) color:#black border: #green; 
    }
    aspect action_neighbourhood{
		draw action_area_sheep color: #black; 
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
     	draw circle(2) color:#yellow border: #green; 
     }
     aspect action_neighbourhood{
		draw action_area_goat color: #yellow; 
	}
    
}



grid CA {
	int grid_var <- grid_x update: grid_var + 1;  // cell values of a grid is equal to their x coordinate value  
    init{

    }

    reflex reflexA{
    	grid_var <- grid_var + 1;
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