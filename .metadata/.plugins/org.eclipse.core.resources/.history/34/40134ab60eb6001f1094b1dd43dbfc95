/**
* Model:        OrderOfExecution
* Author:       Upendra Oli
* Description:  This model demonstrates the order of execution of different parts of a GAMA model.
*/
model OrderOfExecution


global
{
    int glob_var <- 1; 
    
 	list<int> age_list <- [];
// 	list<int> age_list_backup <- [];
 	
    
    init {
    	
        write "global variable init: " + glob_var;
//        create agent_B number: 3;  
		create agent_B number: 3;
		
//		create lions number:5;

		create agent_A number: 5;
//		// Assign values 1, 2, 3, 4, and 5 to each Agent_A's variable
//        loop i from: 0 to: 4 {
//            ask agent_A(i) {
//                agent_A_var <- i + 1;
//                write "Agent_A " + i + " value: " + agent_A_var;
//            }
//        }
		
		
        
        create agent_C number: 2;  
        ask agent_A[0] { // we can also use (0) it says agent_A number 0 as well. (0)is name and [0] is index. unless we shuffle these indexes its same. need to test it myself though
        	agent_A_var <- agent_A_var + 1;
        	write "Agent A variable from global: " + agent_A_var;
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
        ask CA[0] {
        	grid_var <- int(rnd(100));
        } 
    } 
}

species agent_A {
//    int agent_A_var <- 1 update: agent_A_var + 1;
	int agent_A_var <- index + 1 update:agent_A_var +1; // right way to do it: does the increment on index which starts from 0 to 4. The result will be 1 to 5 after adding 1 to each.
    
    init {
        write "Agent_A variable: " + agent_A_var;
    }    
    reflex reflex_A1 {
        write "Agent_A variable: " + agent_A_var;
    } 
    
    aspect default {
    	draw circle(2) color: #red;  
    }    
}

species agent_B {
//    int agent_B_var <- 1;
	int agent_B_var <- rnd(2,6); //creates agents with random numbers between 2 to 6. The number of agents defined in global block. 

    init {
        write "Agent_B variable: " + agent_B_var; 
    }

    reflex reflex_B1 {
        agent_B_var <- agent_B_var + 1;
        write "Agent_B variable: " + agent_B_var;     	
    }   
    
    aspect default {
    	draw circle(2) color: #orange;  
    }
}

species agent_C {
//    int agent_C_var <- 1;
	float agent_C_var <- 0.0; //creates all 0.0 float values in each agents inside agent_C.

    init {
        write "Agent_C variable: " + agent_C_var; 
    }

    reflex reflex_C1 {
        agent_C_var <- agent_C_var + 1;
    } 
    reflex reflex_C2 {
        write "Agent_C variable: " + agent_C_var;     	
    }
    
    aspect default {
    	draw circle(2) color: #grey;  
    }
}

//
//species lions {
//	int lion_age <- int(rnd(0,100));
//    
//	init {
//    	add lion_age to: age_list;
//    	write "lion_age: " + lion_age;
//	}
//	
//	reflex updateage{
////		add lion_age to: age_list_backup;
//		lion_age <- lion_age + 1;
//		
//		if index=0 {
//			age_list <- [];
//		}
//		
//		
//		add lion_age to: age_list;
//		write "Age: " + mean(age_list);
//		
//	}
//	
//	reflex mean_max {
//		if index = length(lions)-1{
//			write "The mean age of lions is: " + mean(age_list);
//		
//		}
//	}
//	
//	reflex reporting{
//		ask lions(3){
//			write "This is current agent: "+ self; // lions(3)
//			write "This is the calling agent: "+myself; 
//		}
//		
//	}
//}

grid CA width: 2 height: 2{
//    int grid_var <- 1 update: grid_var + 1;
	int grid_var <- grid_x update: grid_var + 1;  // cell values of a grid is equal to their x coordinate value  
    init{
    	grid_var <- grid_var + 1;
        write "CA variable init: " + grid_var;
    }

    reflex reflexA{
    	grid_var <- grid_var + 1;
        write "CA variable: " + grid_var;
    }
    
     aspect default{
     	draw square(1) color:#green border: #grey;
     }
}


experiment OrderOfExecution type: gui {
	output {
              display map {
                     species agent_A aspect: default;
                     species agent_B aspect: default;
                     species agent_C aspect: default;
                     species CA aspect: default;
              }
       }
}