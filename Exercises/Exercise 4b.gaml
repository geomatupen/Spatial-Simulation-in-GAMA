/**
* Model:        grazingCows
* Author:       Upendra Oli
* Description:  This exercise was provided to test and visualize different action neighbourhoods like random walk, correlated random walk, and movement towards target in GAMA platform.
*/
model grazingCows

global
{ 
	//load geospatial file
	file pasture_file <- file("./data/Vierkaser.geojson");
	file meadow_file <- file("./data/Meadow.geojson");
	file hirschanger_file <- file("./data/Hirschanger.geojson");
	file cleaned_2023_file <- file("./data/cleaned_2023.geojson");
	file cleaned_2022_file <- file("./data/cleaned_2022.geojson");
	file cleaned_2021_file <- file("./data/cleaned_2021.geojson");
	file cleaned_2020_file <- file("./data/cleaned_2020.geojson");
	
	//convert the file into GAMA geometry variables
	geometry pasture_polygon <- geometry(pasture_file);
	geometry meadow_polygon <- geometry(meadow_file);
	geometry hirschanger_polygon <- geometry(hirschanger_file);
	geometry cleaned_2023_polygon <- geometry(cleaned_2023_file);
	geometry cleaned_2022_polygon <- geometry(cleaned_2022_file);
	geometry cleaned_2021_polygon <- geometry(cleaned_2021_file);
	geometry cleaned_2020_polygon <- geometry(cleaned_2020_file);
	
	geometry all_grasslands_polygon <- meadow_polygon+ hirschanger_polygon+ cleaned_2023_polygon+ cleaned_2022_polygon+ cleaned_2021_polygon+ cleaned_2020_polygon;
	geometry low_pasture_and_cutback_21_23 <- meadow_polygon+cleaned_2021_polygon+ cleaned_2022_polygon+ cleaned_2023_polygon;
	
	


	
	//this is the bounding box (ie. extent)
	geometry shape <- envelope(pasture_file);

	
	int maxBiomass_21_23 <- 6;
	int maxBiomass_hirschanger <- 4;
	int maxBiomass_20 <- 7;
	
	int grid_width <- 10;
	int grid_height <- 10;
	
	int steps_total <- 0;
	
	
	

 	init{
 		create pasture_agent from: pasture_polygon;
 		create meadow_agent from: meadow_polygon;
 		create hirschanger_agent from: hirschanger_polygon;
 		create cleaned_2023_agent from: cleaned_2023_polygon;
 		create cleaned_2022_agent from: cleaned_2022_polygon;
 		create cleaned_2021_agent from: cleaned_2021_polygon;
 		create cleaned_2020_agent from: cleaned_2020_polygon;
 		
 		create cows number:12 {
 			location <- any_location_in(all_grasslands_polygon);
// 			speed <- 5.0;
			
 		}	
// 		write shape.width;
//		write shape.height;
 	}
 	reflex equilibrium{
 		int total_pixels <- 0; //number of pixels in that polygon ie. individual grass
 		float avg_biomass_initial <- 4.0;
 		float total_biomass_this_step <- 0.0;
 		
 		ask grass{
 					
		//to find equilibrium, find number of pixels in polygons
		   	if(self.location overlaps all_grasslands_polygon){
		    	total_pixels <- total_pixels +1;
		    	total_biomass_this_step <- total_biomass_this_step+self.biomass;
		    }
 		}
// 			write "next !!" ;	
//		write "total pixels"+ total_pixels;
		float avg_biomass_this_step <- total_biomass_this_step/total_pixels; //average biomass of current step
		steps_total <- steps_total +1;
		write "step: "+steps_total;
		write avg_biomass_this_step;
		
 	}
 	
 	

}


species pasture_agent {
	
	aspect default{
     	draw pasture_polygon color:#transparent border: #grey; 
     }
}

species meadow_agent {
	
	aspect default{
     	draw meadow_polygon color:#transparent border: #blue; 
     }
}

species hirschanger_agent {
	
	aspect default{
     	draw hirschanger_polygon color:#transparent border: rgb(0, 128, 128); 
     }
}

species cleaned_2023_agent {
	
	aspect default{
     	draw cleaned_2023_polygon color:#transparent border: #blue; 
     }
}

species cleaned_2022_agent {
	
	aspect default{
     	draw cleaned_2022_polygon color:#transparent border: #blue; 
     }
}

species cleaned_2021_agent {
	
	aspect default{
     	draw cleaned_2021_polygon color:#transparent border: #blue; 
     }
}

species cleaned_2020_agent {
	
	aspect default{
     	draw cleaned_2020_polygon color:#transparent border: #magenta; 
     }
}



species cows skills:[moving]{
	geometry action_area_cow;
	
	int action_radius <- 10;
	init {
	}
	
	reflex move{

		do move bounds: pasture_polygon;
		action_area_cow <- circle(action_radius) intersection cone(heading - 60.0, heading + 60.0);
	}
	
	reflex graze {
//			write "location: "+self.location;
//			write "overlaps?: "+ self.location overlaps hirschanger_polygon;
//			write "grasses at action radius: "+ grass at_distance(action_radius);
			
			list<grass> grasses_within_actionradius;
			ask grass{
//				if (self.biomass >5){write "self: "+self.biomass;}
//				write "myself location: "+myself.location;
//				write "grass at 0: "+ grass at_distance(1);
				if(self overlaps myself and biomass-4>=0){
//					write "original biomass: "+ self.biomass;
//					write "self location overlaps: " + self overlaps myself;
					self.biomass <- self.biomass-4;
//					write "updated: "+self.biomass;
				}
				
				if(self overlaps myself.action_area_cow){
					grasses_within_actionradius <- grasses_within_actionradius+self;
				}
				
//				write "myself: "+myself.name;
			}
			

        grass best_spot;
//        list<grass> grasses_within_actionradius <- grass at_distance(action_radius); //checks the distance and takes all grass within that polygon and doesnot consider the cone action area. considers circle action area inste
		  
//        write "grasses within actionradius: "+ grasses_within_actionradius[0].biomass;
//        best_spot <- one_of(grass at_distance(action_radius)); //this only takes one of the elements inside list. doesnot make sure it is max value
//        write "best spot: "+best_spot.biomass;

        
//        ask best_spot{
//        	biomass <- biomass-1;
//        }
		float max_value <- 0.0;
		
        loop individual_grass over: grasses_within_actionradius {
//		    write "individual biomass: "+individual_grass.biomass;
		    if(individual_grass.biomass > max_value){
		    	max_value <- individual_grass.biomass;
		    	best_spot <- individual_grass;
		    }
		    
		}
		

        
        //        do goto(best_spot); //this also takes cows to best spot
        
        bool is_there_cow <- false; 
        loop individual_cow over: cows {
        	if(individual_cow != self and action_area_cow overlaps individual_cow){
        		is_there_cow <- true;
//        		write "there is a cow alrady in that location";
        	}
        }
		
		if(is_there_cow){ //if there is already a cow, go to any other spot
        	best_spot <- one_of(grass at_distance(action_radius));
        }
		
//        write best_spot;
        if(best_spot !=nil){
//        	write "best spot inside: "+ best_spot;
        	do goto target: best_spot.location;
        }
        else{
//        	do move heading:heading+rnd(0,180); 
			do move heading: rnd(0.0,180.0);
//        	write "heading changed cow: "+self.name;
        } 
        

    }

	
	 aspect default{
     	draw circle(3) color:rgb(165, 42,42) border: #green; 
//     	draw string(self.name) color: #orange; 
     }
     
     aspect action_neighbourhood{
		draw action_area_cow color: #red; 
	}
}


grid grass width:int(shape.width/5) height:int(shape.height/5){ //5m resolution grid
//grid grass{
	float biomass;
    init{
		bool isGrassland <- grass[index] intersects(all_grasslands_polygon);
//		write "is Grassland"+isGrassland;
		if(isGrassland){
			biomass <- 4.0;
		}
		else{
			biomass <- 0.0;
		}

		
    }
    
    reflex grow {
    	bool is_cutback_21_23 <- grass[index] intersects(low_pasture_and_cutback_21_23);
    	bool is_cutback_20 <- grass[index] intersects(cleaned_2020_polygon);
    	bool is_hirschanger <- grass[index] intersects(hirschanger_polygon);
    	
    	if(is_cutback_21_23 and biomass< maxBiomass_21_23){
    		biomass <- biomass+0.00295;
    	}
    	
    	if(is_cutback_20 and biomass<maxBiomass_20){
			biomass <- biomass+0.00295;
    	}
    	if(is_hirschanger and biomass< maxBiomass_hirschanger){
    		biomass <- biomass+0.00295;
    	}
    }
   
      
     aspect default{
     	int r <- 0; 
     	int g <- int(256-(biomass*25)); 
     	int b <- 0; 
     	
     	int rb <- 128; int gb <- 128; int bb <- 128;
     	
     	if(biomass=0){
     		r<-256; g<-256; b<-256;
     		rb<-256; gb<-256; bb<-256;
     		
     	} // remove colors in shrubland
     	
     	draw square(10) color:rgb(r,g,b) border:rgb(rb,gb,bb);
     	
     	int v <- int(biomass);
     	if(v>0){
//     		draw string(v) color: #orange size:50;
     	}
     	 
//		draw string(biomass) color: #orange; 
     }
}


experiment OrderOfExecution type: gui {
	output {
              display map{
                     
					 species grass aspect: default transparency:0;
					 species pasture_agent aspect:default transparency: 0;
					 species hirschanger_agent aspect:default transparency: 0;
					 
					 species cleaned_2020_agent aspect:default transparency: 0.2;
					 species meadow_agent aspect:default transparency: 0.4;
					 
					 species cleaned_2023_agent aspect:default transparency: 0.4;
					 species cleaned_2022_agent aspect:default transparency: 0.4;
					 species cleaned_2021_agent aspect:default transparency: 0.4;
					 
					 
                     species cows aspect: default;
                     species cows aspect: action_neighbourhood transparency: 0.5;
                      
					   
              }
       }
}


