


import os
import sys
RTSTH = 3000; #0 for (a); 3000 for (b)
packetSize = 500; #for (c) 100   300   500  1000
interval = 0.05;  #for (c) 0.01  0.03  0.05 0.1
avg_thpt=[]
avg_delay=[]

#pairs from 1 to 20
for pairs in range (1,21):
	ttlThpt=0
	ttlDelay=0
	result=[]
	#fix numbers(i) of pairs run 10 times
	for i in range (0,10):
		os.system('ns Gu_Tiancong_hwk1.tcl ' + str(pairs) + ' '+ str(packetSize) + 'B '+ str(interval) + ' '+ str(RTSTH))
		os.system('awk -f throughput_avg.awk hwk1.tr>result.txt')

		#read thpt and delay for each run and use result[] to record. odd line for thpt, even line for delay
		with open('result.txt','r') as f:
   			for line in f:
				result.append(float(line))
	f.close()

	#calculate avg_thpt and avg_delay for i pairs
	for l in range (0,20):
		if (l%2 == 0): ttlThpt+=result[l]
		else: ttlDelay += result[l]
	avg_thpt.append(str(ttlThpt/10))
	avg_delay.append(str(ttlDelay/10))

#for j in avg_thpt: print(j)
#for j in avg_delay: print(j)

#write result 
fo = open('resultThpt(b).txt','w')
for j in range (0,20):
	fo.write(avg_thpt[j]+' ')
fo.close()

fo = open('resultDelay(b).txt', 'w')
for j in range (0,20):
	fo.write(avg_delay[j]+' ')
fo.close()

