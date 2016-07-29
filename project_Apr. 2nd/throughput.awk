# The BEGIN section, as noted above, is unnecessary.
{
  event = $1
  time = $2
  node_id = $3
  pkt_size = $8
  level = $4

  if (level == "AGT" && event == "s" && $7 == "exp") {
    sent++
# Note the change in the next line. This initializes the startTime with the first encountered "time" value.
    if (!startTime || (time < startTime)) {
      startTime = time
    }
  }

  if (level == "AGT" && event == "r" && $7 == "exp") {
    receive++
    if (time > stopTime) {
      stopTime = time
    }
    recvdSize += pkt_size
  }
}

END {
  printf("sent_packets\t %d\n",sent)
  printf("received_packets %d\n",receive)
  printf("For all pairs, Average Throughput[kbps] = %.2f\tStartTime=%.2f\tStopTime = %.2f\n", (recvdSize/(stopTime-startTime))*(8/1000),startTime,stopTime);
  rate = (recvdSize / (stopTime - startTime)) * (8 / 1000);
  pdr = (receive / sent) * 100;
  print rate >> "throughput.txt"

}
