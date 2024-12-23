/**
* Model:        workingWithLists
* Author:       Upendra Oli
* Description:  This model demonstrates the how list can be used and modified in GAMA.
*/
model workingWithLists


global
{ 
 	list<int> age_list <- [];
 	init{
 		create lions number:5;
 	}
 	
 	 reflex show_list{
 		write "list: " + age_list;
		write "The mean age of lions is: " + mean(age_list);
		write "The minimum age of lions is: " + min(age_list);
		write "The maximum age of lions is: " + max(age_list);
 	}	
 	
 	reflex clearlist{ // clear age list, global reflexes are called first than other reflexes
		write "age list before clearing: "+age_list;
		age_list <- [];
		write "age list after cleared: "+ age_list;
 	}
}


species lions {
	list ages <- [47,51,49, 52, 11];
//	int lion_age <- int(rnd(0,60));
	int lion_age <- ages[index];
    
	init {
    	add lion_age to: age_list;
    	write "lion_age: " + lion_age;
	}

	reflex lion_life{
		if lion_age = 60 {
			create lions number:1 with: [lion_age : 0]{}
//			add 1 to: age_list;
		}
		
		if lion_age > 60 {
			do die;
		}

	}
	

	reflex updateage{
		lion_age <- lion_age +1;
		
		add lion_age to: age_list; // it keeps adding in the existing list. doesnot clear the list.
//		age_list[index] <- lion_age; // assign the value. which also can be done by above code. add lion_age to: age_list. However if you write like that you need to clear the existing list from global. ie. commented code.
		write "Age: " + lion_age;
		
	}

	
//	reflex reporting{
//		ask lions(3){
//			write "This is current agent: "+ self; // lions(3)
//			write "This is the calling agent: "+myself;  //(each iteration, 0 calls 3, 1 calls 3, 2 calls 3rd lion ie. 0, 1, 2,... are the myself
//		}
//		
//	}
	
	 aspect default{
	 	int mean_age <- int(mean(age_list));
     	draw circle(2) color:rgb(256 - mean_age*4, 0,0) border: #green; // make color more darker red as the more population of lion is of older age.
//     	draw circle(2) color:rgb(256- int(lion_age)*4, 0,0) border: #green; // make color more darker red as the lion gets older.
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


experiment workingWithLists type: gui {
	output {
              display map {
                    
                     species CA aspect: default;
                     species lions aspect: default;
              }
       }
}