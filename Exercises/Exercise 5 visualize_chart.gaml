/**
* Model:  interactionInSpatialSpace      
* Author:       Upendra Oli
* Description:  This code shows how to visualise and export the results of your Vierkaseralm virtual pasture. 
* Building on the previous exercise of spatial interaction where grazing cows on the Vierkaser pasture on Untersberg was developed with different spatial data of the areas inside the Vierkaser property. 

*/
model interactionInSpatialSpace

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

	int total_cows <- 12;
	int maxBiomass_21_23 <- 6;
	int maxBiomass_hirschanger <- 4;
	int maxBiomass_20 <- 7;
	
	int grid_width <- 10;
	int grid_height <- 10;
	
	int steps_total <- 0;
	
	float total_grass_eaten_this_step;
	
	
//	int serie_length <- 1000;
	list<float> xlist <- [];
	list<float> minlist <- [];
	list<float> maxlist <- [];
	list<float> meanlist <- [];
	
	list<float> mean_grass_eaten_list <- [];
	
	//for xy plot
	int steps <- 0;
	float avg_available_grass;

	
 	reflex equilibrium{

 		int total_pixels <- 0; //number of pixels in that polygon ie. individual grass
 		float avg_biomass_initial <- 4.0;
 		bool first_loop <- true;
 		
 		float total_value <- 0.0;
 		float average_value; 
 		float min_value <- 1.0;
 		float max_value <- -1.0;
 		float total_biomass_this_step <- 0.0;
 		
 		total_grass_eaten_this_step <- 0.0;
 		
 		ask grass { 
 			float my_value <- self.biomass;
			if(self.location overlaps all_grasslands_polygon){
 				total_value <- total_value + my_value;
 			
	 			if my_value < min_value {
	 				min_value <- my_value;
//	 				write "min value changed";
	 			} 
	 			if my_value > max_value {
	 				max_value <- my_value;
//	 				write "max value changed";
	 			}
	 			if(first_loop = true){
			    	total_pixels <- total_pixels +1;
	//		    	total_biomass_this_step <- total_biomass_this_step+self.biomass;
			    }
		  	}
		  	
 		} 

 		average_value <- total_value / total_pixels;
 		
 		add average_value to: meanlist;
 		add min_value to: minlist;
 		add max_value to: maxlist;
 		
 		first_loop <- false;
 		
 		steps <- steps+1;
 		avg_available_grass <- average_value;
 		
 		write steps;
		write avg_available_grass;
		
 	}
 	
 	
 	//export data
//	reflex save_data when: cycle = 10{
	reflex save_data{
			if(steps=1){
				// Clear the CSV file by overwriting it
				save [] to: "./results/mean_min_max.csv" format: "csv" rewrite: true;
				save ["Steps", "Mean Biomass", "Minimum Biomass", "Maximum Biomass"] to: "./results/mean_min_max.csv" format: "csv" rewrite: false;
			}
			
			// save the values to the csv file; the rewrite facet is set to false to continue to write in the same file
			save [steps-1, meanlist[steps-1], minlist[steps-1], maxlist[steps-1]] to: "./results/mean_min_max.csv" format:"csv" rewrite: false;

		//Pause the model as the data are saved
//		do pause;
	}
	

 	init{
 		create pasture_agent from: pasture_polygon;
 		create meadow_agent from: meadow_polygon;
 		create hirschanger_agent from: hirschanger_polygon;
 		create cleaned_2023_agent from: cleaned_2023_polygon;
 		create cleaned_2022_agent from: cleaned_2022_polygon;
 		create cleaned_2021_agent from: cleaned_2021_polygon;
 		create cleaned_2020_agent from: cleaned_2020_polygon;
 		
 		create cows number:total_cows {
 			location <- any_location_in(all_grasslands_polygon);
// 			speed <- 5.0;
			
 		}		
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
	init {}
	
	reflex move{

		do move bounds: pasture_polygon;
		action_area_cow <- circle(action_radius) intersection cone(heading - 60.0, heading + 60.0);
	}
	
	reflex graze {
			list<grass> grasses_within_actionradius;
			ask grass{
				if(self overlaps myself and self.biomass-4>=0){
					self.biomass <- self.biomass-4;
					total_grass_eaten_this_step <- total_grass_eaten_this_step + 4;
				}
				
				if(self overlaps myself.action_area_cow and self.biomass>0){
					grasses_within_actionradius <- grasses_within_actionradius+self;
				}
			}
			

        grass best_spot;
		float max_value <- 0.0;

        loop individual_grass over: grasses_within_actionradius {
		    if(individual_grass.biomass > max_value){
		    	max_value <- individual_grass.biomass;
		    	best_spot <- individual_grass;
		    }
		    
		}

      
        bool is_there_cow <- false; 
        loop individual_cow over: cows {
        	if(individual_cow != self and action_area_cow overlaps individual_cow){
        		is_there_cow <- true;
//        		write "there is a cow alrady in that location";
        	}
        }
		
		if(is_there_cow){ //if there is already a cow, go to any other spot
        	best_spot <- one_of(grass at_distance(action_radius));
        	write "there is a cow for cow: "+self.name;
        }

        if(best_spot !=nil){
//        	write "best spot inside: "+ best_spot;
        	do goto target: best_spot.location;
        }
        else{
			do move heading:rnd(0.0,360.0); 
        	write "no best spot for cow: "+self.name;
        } 
        
        
        //for chart
        if(index = total_cows-1){
			add total_grass_eaten_this_step/total_cows to: mean_grass_eaten_list;
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
	float biomass;
    init{
		bool isGrassland <- grass[index] intersects(all_grasslands_polygon);
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
              
              display "Mean, Min and Max Biomass each step" type: 2d {
				chart "Line Chart" type: series x_label: "Mean biomass at each step" memorize: false {
					data "mean biomass" value: meanlist color: #blue marker: false style: line;
//					data "min biomass" value: minlist color: #red marker: false style: line;
//					data "max biomass" value: maxlist color: #green marker: false style: line;
				}
			 }
			 display "Mean grass eaten by cows each step" type: 2d {
				chart "Line Chart" type: series x_label: "Mean grass eaten at each step" memorize: false {
					data "mean grass eaten" value: mean_grass_eaten_list color: #blue marker: false style: line;
				}
			 }
			 
			 display charts  type: 2d {
				//at each simulation step, display the value of y according to the value of x
//				chart "XY Plot" type: xy size: {1.0,0.75} position: {0,0.1}{
////						data legend: "average available grass per pixel" value:[steps-1,avg_available_grass] line_visible: false color: #green;
////						data legend: "mean eaten grass per cows" value:[steps-1,total_grass_eaten_this_step/total_cows] line_visible: false color: #red;
//				}
				chart "serie_x and serie_y" type: xy size: {1.0,0.5}{
				 data legend: "x" value:rows_list(matrix([meanlist, mean_grass_eaten_list])) ;
				}
			}
       }
}


