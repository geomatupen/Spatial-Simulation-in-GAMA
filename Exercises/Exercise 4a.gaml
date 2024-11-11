model geometryTest

global
{ 
    // Load geospatial files
    file pasture_file <- file("./data/Vierkaser.geojson");
    file meadow_file <- file("./data/Meadow.geojson");
    file hirschanger_file <- file("./data/Hirschanger.geojson");
    file cleaned_2023_file <- file("./data/cleaned_2023.geojson");
    file cleaned_2022_file <- file("./data/cleaned_2022.geojson");
    file cleaned_2021_file <- file("./data/cleaned_2021.geojson");
    file cleaned_2020_file <- file("./data/cleaned_2020.geojson");
    
    // Convert files into GAMA geometry variables
    geometry pasture_polygon <- geometry(pasture_file);
    geometry meadow_polygon <- geometry(meadow_file);
    geometry hirschanger_polygon <- geometry(hirschanger_file);
    geometry cleaned_2023_polygon <- geometry(cleaned_2023_file);
    geometry cleaned_2022_polygon <- geometry(cleaned_2022_file);
    geometry cleaned_2021_polygon <- geometry(cleaned_2021_file);
    geometry cleaned_2020_polygon <- geometry(cleaned_2020_file);
    
    geometry all_grasslands_polygon <- meadow_polygon + hirschanger_polygon + cleaned_2023_polygon + cleaned_2022_polygon + cleaned_2021_polygon + cleaned_2020_polygon;
    geometry low_pasture_and_cutback_21_23 <- meadow_polygon + cleaned_2021_polygon + cleaned_2022_polygon + cleaned_2023_polygon;
    
    geometry action_area_cow;
    
    // Set the maximum biomass values for different areas
    int maxBiomass_21_23 <- 6;
    int maxBiomass_hirschanger <- 4;
    int maxBiomass_20 <- 7;
    
    
    init {
        create pasture_agent from: pasture_polygon;
        create meadow_agent from: meadow_polygon;
        create hirschanger_agent from: hirschanger_polygon;
        create cleaned_2023_agent from: cleaned_2023_polygon;
        create cleaned_2022_agent from: cleaned_2022_polygon;
        create cleaned_2021_agent from: cleaned_2021_polygon;
        create cleaned_2020_agent from: cleaned_2020_polygon;
        
        create cows number: 5 {
            location <- any_location_in(all_grasslands_polygon);
            speed <- 5.0;
        }
    }
}

species pasture_agent {
    aspect default {
        draw pasture_polygon color: #grey border: #green; 
    }
}

species meadow_agent {
    aspect default {
        draw meadow_polygon color: #cyan border: #green; 
    }
}

species hirschanger_agent {
    aspect default {
        draw hirschanger_polygon color: #green border: #green; 
    }
}

species cleaned_2023_agent {
    aspect default {
        draw cleaned_2023_polygon color: #cyan border: #green; 
    }
}

species cleaned_2022_agent {
    aspect default {
        draw cleaned_2022_polygon color: #cyan border: #green; 
    }
}

species cleaned_2021_agent {
    aspect default {
        draw cleaned_2021_polygon color: #cyan border: #green; 
    }
}

species cleaned_2020_agent {
    aspect default {
        draw cleaned_2020_polygon color: #magenta border: #green; 
    }
}

species cows skills: [moving] {
    grass best_spot;
    int action_radius <- 5;

    init {
        action_area_cow <- circle(action_radius) intersection cone(heading - 60.0, heading + 60.0);
    }
    
    aspect default {
        draw circle(10) color: #yellow border: #green; 
    }
    
    aspect action_neighbourhood {
        draw action_area_cow color: #green; 
    }

    reflex move {
        do move bounds: pasture_polygon;
        action_area_cow <- circle(action_radius) intersection cone(heading - 60.0, heading + 60.0);
    }
    
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
}

grid grass {
    float grid_value <- 0.0;

    init {
        bool isGrassland <- grass[index] intersects(all_grasslands_polygon);
        if (isGrassland) {
            grid_value <- 5.0;
        }
    }
    
    reflex grow {
   		bool is_cutback_21_23 <- grass[index] intersects(low_pasture_and_cutback_21_23);
    	bool is_cutback_20 <- grass[index] intersects(cleaned_2020_polygon);
    	bool is_hirschanger <- grass[index] intersects(hirschanger_polygon);
        
        if (is_cutback_21_23 and grid_value < maxBiomass_21_23) {
            grid_value <- grid_value + 1;
        } else if (is_cutback_20 and grid_value < maxBiomass_20) {
            grid_value <- grid_value + 1;
        } else if (is_hirschanger and grid_value < maxBiomass_hirschanger) {
            grid_value <- grid_value + 1;
        }
    }

    aspect default {
        draw square(2) color: rgb(75, 0, 0) border: #grey;
    }
}


experiment OrderOfExecution type: gui {
    output {
        display map {
            species grass aspect: default;
            species pasture_agent aspect: default transparency: 0.5;
            species meadow_agent aspect: default transparency: 0.5;
            species hirschanger_agent aspect: default transparency: 0.5;
            species cleaned_2023_agent aspect: default transparency: 0.5;
            species cleaned_2022_agent aspect: default transparency: 0.5;
            species cleaned_2021_agent aspect: default transparency: 0.5;
            species cleaned_2020_agent aspect: default transparency: 0.5;
            species cows aspect: default transparency: 0.5;
            species cows aspect: action_neighbourhood transparency: 0.5;
        }
    }
}
