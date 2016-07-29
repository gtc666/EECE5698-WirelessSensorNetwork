BEGIN {
  printf "Start\n";
  first_time = -1;
  last_time = 0;
  node_count = 0;
}
{
  if (($1 == "r")  ) {
    last_time = $2;
  }  
  if ( (first_time == -1) && ( $1 == "s" ) )    
    first_time = $2;  
   
  if ( ( $1 == "s" ) || ($1 == "r") ) {
     node_id = substr($3,2,1);
     energy_initial[node_id] = $14 + $16 + $18 + $20 + $22;
     if (node_id > node_count) node_count = node_id;
  } 

    if ($1 == "N") {
        energy_left[$5] = $7;
    }
}
END {
  printf "First time: %7.1f Last time: %7.1f\n", first_time,last_time;
  for (i = 0;i < node_count+1; i++){
  printf "initial energy of node %d is %f\n", i,energy_initial[i];
  }
  for (i = 0;i < node_count+1; i++){
  printf "left energy of node %d is %f\n", i,energy_left[i];
}
  total_energy = 0;
  for (i = 0; i < node_count+1; i ++) {
    total_energy += energy_initial[i] - energy_left[i];
  }
  printf "Total energy consumed: %7.4f", total_energy
  print total_energy >> "energy.txt"
}
