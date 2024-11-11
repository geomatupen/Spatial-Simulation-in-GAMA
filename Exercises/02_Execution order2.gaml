/**
* Model:        OrderOfExecution
* Author:       Upendra Oli
* Description:  This model demonstrates the order of execution of different parts of a GAMA model.
*/
model OrderOfExecution


global
{
    int glob_var <- 1; 
 
    
    init {
    	write "time step:" + cycle;
        write "global variable init: " + glob_var;
//        create Deer number: 3;  
		create Deer number: 3;

		create Tiger number: 5;
//		// Assign values 1, 2, 3, 4, and 5 to each Tiger's variable
//        loop i from: 0 to: 4 {
//            ask Tiger(i) {
//                Age_of_Tiger <- i + 1;
////                write "Tiger " + i + " value: " + Age_of_Tiger;
//            }
//        }
        
        create Fox number: 2;  
        ask Tiger[0] {
        	Age_of_Tiger <- Age_of_Tiger + 1;
        	write "Agent A variable from global: " + Age_of_Tiger;
        }
    }
    reflex global_reflex_1 {
    	write "time step:" + cycle;
    }

    reflex global_reflex_2 {
        glob_var <- glob_var + 1;       
    }
    reflex global_reflex_3 {
        write "global variable: " + glob_var;
    }  
    reflex global_reflex_4 {
        ask Jungle[0] {
        	ndvi <- int(rnd(100));
        } 
    } 
}

species Tiger {
//    int Age_of_Tiger <- 1 update: Age_of_Tiger + 1;
	int Age_of_Tiger <- index + 1 update:Age_of_Tiger +1; // best solution than loop in global, for report use this. does the increment on index which starts from 0 to 4. The result will be 1 to 5 after adding 1 to each.
//   	int Age_of_Tiger;
    init {
        write "Age of Tiger: " + Age_of_Tiger;
    }    
    reflex Tiger_age {
        write "Age of Tiger: " + Age_of_Tiger;
    }   
    
    aspect default {
    	draw circle(2) color: #red;
//        draw string(name) color: #orange;    
    }  
}

species Deer {
//    int Age_of_Deer <- 1;
	int Age_of_Deer <- rnd(2,6); //creates agents with random numbers between 2 to 6. The number of agents defined in global block. 

    init {
        write "Age of Deer: " + Age_of_Deer; 
    }

    reflex Deer_age_increment {
        Age_of_Deer <- Age_of_Deer + 1;
        write "Age of Deer: " + Age_of_Deer;     	
    } 
    
    aspect default {
    	draw circle(2) color: #orange;
//        draw string(name) color: #orange;    
    }  
}

species Fox {
//    int Age_of_Fox <- 1;
	float Age_of_Fox <- 0.0; //creates all 0.0 float values in each agents inside Fox.

    init {
        write "Age of Fox: " + Age_of_Fox; 
    }

    reflex Fox_age_increment {
        Age_of_Fox <- Age_of_Fox + 1;
    } 
    reflex Fox_age {
        write "Age of Fox: " + Age_of_Fox;     	
    }
    
    aspect default {
    	draw circle(2) color: #grey;
//        draw string(name) color: #orange;    
    }
}

grid Jungle width: 3 height: 3{
//    int ndvi <- 1 update: ndvi + 1;
	int ndvi <- grid_x update: ndvi + 1;  // cell values of a grid is equal to their x coordinate value  
    init{
    	ndvi <- ndvi + 1;
        write "vegetation index: " + ndvi;
    }

    reflex ndvi_value_increment{
    	ndvi <- ndvi + 1;
        write "vegetation index: " + ndvi;
    }
    
    aspect default{

              draw square(1) color:#green border: #grey;

       }
}


experiment OrderOfExecution type: gui {
//	parameter "global variable" var: glob_var;
       output {
              display map {
                     species Tiger aspect: default;
                     species Deer aspect: default;
                     species Fox aspect: default;
                     species Jungle aspect: default;
              }
       }
}