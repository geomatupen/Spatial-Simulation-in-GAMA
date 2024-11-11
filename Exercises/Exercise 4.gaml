/**
* Model:        OrderOfExecution
* Author:       Upendra Oli
* Description:  This exercise was provided to test and visualize different action neighbourhoods like random walk, correlated random walk, and movement towards target in GAMA platform.
*/
model geometryTest


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
	geometry grassLandsBbox <- envelope(all_grasslands_polygon);
	
	int maxBiomass_21_23 <- 20;
	int maxBiomass_hirschanger <- 4;
	int maxBiomass_20 <- 7;
	
	int grid_width <- 10;
	int grid_height <- 10;
	
	float biomass_cutback_20; 
	float biomass_cutback_21_23;
	float biomass_hirschanger;
	
	float display_biomass;
	

 	init{
 		create pasture_agent from: pasture_polygon;
 		create meadow_agent from: meadow_polygon;
 		create hirschanger_agent from: hirschanger_polygon;
 		create cleaned_2023_agent from: cleaned_2023_polygon;
 		create cleaned_2022_agent from: cleaned_2022_polygon;
 		create cleaned_2021_agent from: cleaned_2021_polygon;
 		create cleaned_2020_agent from: cleaned_2020_polygon;
 		
 		create cows number:1 {
 			location <- any_location_in(all_grasslands_polygon);
// 			speed <- 5.0;
			
 		}	
 	}
 	reflex cowsmoving{
// 			write "next !!" ;	
 	}
 	
 	reflex update {
	ask cows {
//	    do wander amplitude: 180.0;	
	    ask grass at_distance(1) {
		if(self overlaps myself) {
		    self.biomass <- 2;
		} else if (self.biomass != 2) {
		    self.biomass <- 1;
		}
	    }
	}
	ask grass {
	    do update_biomass;
	}	
    }
}


species pasture_agent {
	
	aspect default{
     	draw pasture_polygon color:#grey border: #green; 
     }
}

species meadow_agent {
	
	aspect default{
     	draw meadow_polygon color:#cyan border: #green; 
     }
}

species hirschanger_agent {
	
	aspect default{
     	draw hirschanger_polygon color:#green border: #green; 
     }
}

species cleaned_2023_agent {
	
	aspect default{
     	draw cleaned_2023_polygon color:#cyan border: #green; 
     }
}

species cleaned_2022_agent {
	
	aspect default{
     	draw cleaned_2022_polygon color:#cyan border: #green; 
     }
}

species cleaned_2021_agent {
	
	aspect default{
     	draw cleaned_2021_polygon color:#cyan border: #green; 
     }
}

species cleaned_2020_agent {
	
	aspect default{
     	draw cleaned_2020_polygon color:#magenta border: #green; 
     }
}



species cows skills:[moving]{
	geometry action_area_cow;
	grass best_spot;
	int action_radius <- 50;
	init {
	}
	
	reflex move{

		do move bounds: pasture_polygon;
		action_area_cow <- circle(action_radius) intersection cone(heading - 60.0, heading + 60.0);
	}
	

//	reflex graze{
//		best_spot <- one_of (grass at_distance(action_radius)).location;
//		ask best_spot{
////			biomass <- biomass-1;
////			go to best_spot;
//			write "yummieh!!";
//		}
//		
//			bool is_cutback_21_23 <- self.location intersects(low_pasture_and_cutback_21_23);
//	    	bool is_cutback_20 <- self.location intersects(cleaned_2020_polygon);
//	    	bool is_hirschanger <- self.location intersects(hirschanger_polygon);
//	    	
//	    	write "21_23: "+is_cutback_21_23;
//	    	write "20: "+is_cutback_20;
//	    	write "hirschanger: "+is_hirschanger;
//	    	
//	    	
//	    	if(is_cutback_21_23 and biomass_cutback_21_23< maxBiomass_21_23){
//	    		biomass_cutback_21_23 <- biomass_cutback_21_23-1;
//	    		display_biomass <- biomass_cutback_21_23;
////				grass[index].grid_value <- grass[index].grid_value-1;
//	    	}
//	    	
//	    	if(is_cutback_20 and biomass_cutback_20<maxBiomass_20){
//	    		biomass_cutback_20 <- biomass_cutback_20-1;
//	    		display_biomass <- biomass_cutback_20;
////				grass[index].grid_value <- grass[index].grid_value-1;
//	
//	    	}
//	    	if(is_hirschanger and biomass_hirschanger<maxBiomass_hirschanger){
//	    		biomass_hirschanger <- biomass_hirschanger-1;
//	    		display_biomass <- biomass_hirschanger;
////				grass[index].grid_value <- grass[index].grid_value-1;
//	    	}
//	
//	}

	reflex graze {
        grass best_spot;
        float max_value <- -1;
        ask grass at_distance(action_radius) {
            if (grid_value > max_value) {
                max_value <- grid_value;
                best_spot <- self;
            }
        }
        if (best_spot != nil) {
            do goto(best_spot);
            if (best_spot.grid_value > 0) {
                best_spot.grid_value <- best_spot.grid_value - 1;
                write "Grazed at (" + best_spot.grid_x + ", " + best_spot.grid_y + "). Remaining biomass: " + best_spot.grid_value;
            }
        }
    }

	
	 aspect default{
     	draw circle(10) color:rgb(165, 42,42) border: #green; 
     }
     
     aspect action_neighbourhood{
		draw action_area_cow color: #green; 
	}
}


grid grass{
	float biomass <- 5;
    init{
		bool isGrassland <- grass[index] intersects(all_grasslands_polygon);
//		write "is Grassland"+isGrassland;
		if(isGrassland){
			biomass_cutback_21_23 <- 3.0;
			biomass_cutback_20 <- 2.0; 
			biomass_hirschanger <- 1.0;
//			biomass <- 5.0;
		}
		else{
			biomass_cutback_21_23 <- 0.0;
			biomass_cutback_20 <- 0.0; 
			biomass_hirschanger <- 0.0;
//			self.grid_value <- 0.0;
//			biomass <- 0.0;
		}
		
		//assign value to the grid cells
		if(grass[index] intersects(low_pasture_and_cutback_21_23)){
			display_biomass <- 	biomass_cutback_21_23;
		}
		if(grass[index] intersects(cleaned_2020_polygon)){
			display_biomass <- 	biomass_cutback_20;
		}
		if(grass[index] intersects(hirschanger_polygon)){
			display_biomass <- 	biomass_hirschanger;
		}
		
    }
    
    reflex grow {
    	bool is_cutback_21_23 <- grass[index] intersects(low_pasture_and_cutback_21_23);
    	bool is_cutback_20 <- grass[index] intersects(cleaned_2020_polygon);
    	bool is_hirschanger <- grass[index] intersects(hirschanger_polygon);
    	
    	if(is_cutback_21_23 and biomass_cutback_21_23< maxBiomass_21_23){
    		biomass_cutback_21_23 <- biomass_cutback_21_23+1;
    		display_biomass <- biomass_cutback_21_23;
//			grass[index].grid_value <- grass[index].grid_value+1;
    	}
    	
    	if(is_cutback_20 and biomass_cutback_20<maxBiomass_20){
    		biomass_cutback_20 <- biomass_cutback_20+1;
    		display_biomass <- biomass_cutback_20;
//			grass[index].grid_value <- grass[index].grid_value+1;

    	}
    	if(is_hirschanger and biomass_hirschanger< maxBiomass_hirschanger){
    		biomass_hirschanger <- biomass_hirschanger+1;
    		display_biomass <- biomass_hirschanger;
//			grass[index].grid_value <- grass[index].grid_value+1;
    	}
    }
    
    action update_biomass {
		if (biomass = 0) {
		    color <- #green;
		} else if (biomass = 1) {
		    color <- #yellow;
		} else if (biomass = 2) {
		    color <- #red;
		}
		biomass <- 0.0;
    }
     	    
     aspect default{
     	draw square(2) color:rgb(biomass_hirschanger*15,0,0) border: #grey;
     	draw string(display_biomass) color: #orange; 
//		draw string(biomass) color: #orange; 
     }
}


experiment OrderOfExecution type: gui {
	output {
              display map{
                     species grass aspect: default;
					 species pasture_agent aspect:default transparency: 0.5;
					 species meadow_agent aspect:default transparency: 0.5;
					 species hirschanger_agent aspect:default transparency: 0.5;
					 species cleaned_2023_agent aspect:default transparency: 0.5;
					 species cleaned_2022_agent aspect:default transparency: 0.5;
					 species cleaned_2021_agent aspect:default transparency: 0.5;
					 species cleaned_2020_agent aspect:default transparency: 0.5;
					 
                     species cows aspect: default;
                     species cows aspect: action_neighbourhood transparency: 0.5;
                      
					   
              }
       }
}


//https://gama-platform.org/wiki/GridSpecies#grid-from-a-matrix
//define the grass grid with biomass (maybe max or half) 
// assign the biomass to the cells only to those grasslands
// cows goes to the grass land and whereever it is reduce biomass by certain number
// there is always grass and cows dont die - steady state - ghass khayo vane kati ghataune. 


// if cell intersects polygons, set initial values otherwise it is 0
// https://gama-platform.org/wiki/Computation_of_the_shortest_path_on_a_Grid_of_Cells

