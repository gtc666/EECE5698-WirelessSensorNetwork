BEGIN {  bits = 0;  first_time = -1;  last_time = 0;  n=0;  t=0;  delay = 0;  total_delay = 0;  s=0;  r = 0;}{  if (($1 == "r")  && ($4 =="AGT" ) && ($7 =="cbr" ) ) {    last_time = $2;    t=t+1;    size=($8*1);    bits= bits + $8 * 8;    packet_end[$6] = $2;    n = n+1;    r= r+1;  }    if (first_time == -1)    first_time = $2;  if (($1 == "s") && ($4 == "AGT") && ($7 == "cbr")) {      packet_start[$6] = $2;      s =s+1;  }  if (($1 == "D") && ($7 == "cbr")){      packet_start[$6] = 0;        }}END {    rate = (bits/1000)/(last_time-first_time);  if ( n == 0) {total_delay =0;}  else {         for (packet_id = 0; packet_id < n;packet_id++){         total_delay = total_delay + packet_end[packet_id];         total_delay = total_delay - packet_start[packet_id];         }        delay = total_delay/n*1000;        }    printf "%f\n",rate;  printf "%f\n",delay;}