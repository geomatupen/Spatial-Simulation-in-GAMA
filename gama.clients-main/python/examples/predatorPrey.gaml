/**
* Name: Breeding of prey and predator agents
* Author:
* Description: 6th part of the tutorial : Predator Prey
* Tags: reproduce, myself, self
*/
model prey_predator

global {
	int nb_preys_init <- 200;
	int nb_predators_init <- 20;
	float prey_max_energy <- 1.0;
	float prey_max_transfer <- 0.1;
	float prey_energy_consum <- 0.05;
	float predator_max_energy <- 1.0;
	float predator_energy_transfer <- 0.5;
	float predator_energy_consum <- 0.02;
	float prey_proba_reproduce <- 0.01;
	int prey_nb_max_offsprings <- 5;
	float prey_energy_reproduce <- 0.5;
	float predator_proba_reproduce <- 0.01;
	int predator_nb_max_offsprings <- 3;
	float predator_energy_reproduce <- 0.5;
	int nb_preys -> {length(prey)};
	int nb_predators -> {length(predator)};
	bool is_batch <- false;

	init {
		create prey number: nb_preys_init;
		create predator number: nb_predators_init;
		write(self);
	}	
	
	reflex stop_simulation when: ((nb_preys = 0) or (nb_predators = 0)) and !is_batch {
		do pause;
	} 
	
	reflex coucou {
	//	int i <- save_simulation("haha.gsim");
	}
}

species generic_species {
	float size <- 1.0;
	rgb color;
	float max_energy;
	float max_transfer;
	float energy_consum;
	float proba_reproduce;
	int nb_max_offsprings;
	float energy_reproduce;
	vegetation_cell my_cell <- one_of(vegetation_cell);
	float energy <- rnd(max_energy) update: energy - energy_consum max: max_energy;

	init {
		location <- my_cell.location;
	}

	reflex basic_move {
		my_cell <- one_of(my_cell.neighbors2);
		location <- my_cell.location;
	}

	reflex eat {
		energy <- energy + energy_from_eat();
	}

	reflex die when: energy <= 0 {
		do die;
	}

	reflex reproduce when: (energy >= energy_reproduce) and (flip(proba_reproduce)) {
		int nb_offsprings <- rnd(1, nb_max_offsprings);
		create species(self) number: nb_offsprings {
			my_cell <- myself.my_cell;
			location <- my_cell.location;
			energy <- myself.energy / nb_offsprings;
		}

		energy <- energy / nb_offsprings;
	}

	float energy_from_eat {
		return 0.0;
	}

	aspect base {
		draw circle(size) color: color;
	}
}

species prey parent: generic_species  {
	rgb color <- #blue;
	float max_energy <- prey_max_energy;
	float max_transfer <- prey_max_transfer;
	float energy_consum <- prey_energy_consum;
	float proba_reproduce <- prey_proba_reproduce;
	int nb_max_offsprings <- prey_nb_max_offsprings;
	float energy_reproduce <- prey_energy_reproduce;

	float energy_from_eat {
		float energy_transfer <- 0.0;
		if(my_cell.food > 0) {
			energy_transfer <- min([max_transfer, my_cell.food]);
			my_cell.food <- my_cell.food - energy_transfer;
		} 			
		return energy_transfer;
	}

	
}

species predator parent: generic_species {
	rgb color <- #red;
	float max_energy <- predator_max_energy;
	float energy_transfer <- predator_energy_transfer;
	float energy_consum <- predator_energy_consum;
	float proba_reproduce <- predator_proba_reproduce;
	int nb_max_offsprings <- predator_nb_max_offsprings;
	float energy_reproduce <- predator_energy_reproduce;

	float energy_from_eat {
		list<prey> reachable_preys <- prey inside (my_cell);
		if(! empty(reachable_preys)) {
			ask one_of (reachable_preys) {
				do die;
			}
			return energy_transfer;
		}
		return 0.0;
	}
}

grid vegetation_cell width: 50 height: 50 neighbors: 4 {
	float max_food <- 1.0;
	float food_prod <- rnd(0.01);
	float food <- rnd(1.0) max: max_food update: food + food_prod;
	rgb color <- rgb(int(255 * (1 - food)), 255, int(255 * (1 - food))) update: rgb(int(255 * (1 - food)), 255, int(255 * (1 - food)));
	list<vegetation_cell> neighbors2 <- (self neighbors_at 2);
}

experiment prey_predator type: gui record:true{
	parameter "Initial number of preys: " var: nb_preys_init min: 0 max: 1000 category: "Prey";
	parameter "Prey max energy: " var: prey_max_energy category: "Prey";
	parameter "Prey max transfer: " var: prey_max_transfer category: "Prey";
	parameter "Prey energy consumption: " var: prey_energy_consum category: "Prey";
	parameter "Initial number of predators: " var: nb_predators_init min: 0 max: 200 category: "Predator";
	parameter "Predator max energy: " var: predator_max_energy category: "Predator";
	parameter "Predator energy transfer: " var: predator_energy_transfer category: "Predator";
	parameter "Predator energy consumption: " var: predator_energy_consum category: "Predator";
	parameter 'Prey probability reproduce: ' var: prey_proba_reproduce category: 'Prey';
	parameter 'Prey nb max offsprings: ' var: prey_nb_max_offsprings category: 'Prey';
	parameter 'Prey energy reproduce: ' var: prey_energy_reproduce category: 'Prey';
	parameter 'Predator probability reproduce: ' var: predator_proba_reproduce category: 'Predator';
	parameter 'Predator nb max offsprings: ' var: predator_nb_max_offsprings category: 'Predator';
	parameter 'Predator energy reproduce: ' var: predator_energy_reproduce category: 'Predator';

	output {
		display main_display {
			grid vegetation_cell border: #black;
			species prey aspect: base;
			species predator aspect: base;
		}

		monitor "Number of preys" value: nb_preys;
		monitor "Number of predators" value: nb_predators;
	}
}

experiment Optimization type: batch repeat: 2 keep_seed: true until: ( time > 200 ) {
	parameter "Predator energy reproduce:" var: predator_energy_reproduce min: 0.25 max: 1.0 step: 0.25;
	parameter "Batch mode:" var: is_batch <- true;
	
	method tabu maximize: nb_preys + nb_predators iter_max: 10 tabu_list_size: 3;
	
	
	reflex save_results_explo {
		ask simulations {
			save [int(self),prey_max_transfer,prey_energy_reproduce,predator_energy_transfer,predator_energy_reproduce,self.nb_predators,self.nb_preys] 
		   		to: "results.csv" format:"csv" rewrite: (int(self) = 0) ? true : false header: true;
		}		
	}
}


