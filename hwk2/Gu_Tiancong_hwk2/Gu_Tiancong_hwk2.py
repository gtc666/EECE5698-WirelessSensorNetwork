


import os
import sys

runtimes = 30
src = 5

avg_energy=[]
avg_delay=[]

total_delay = 0
total_energy = 0
ttlDelay=0
result_d=[]
result_e=[]
#fix numbers(i) of pairs run 10 times
for i in range (0,runtimes):
	os.system('ns Gu_Tiancong_hwk2.tcl ' + ' '+ str(src) )
	os.system('awk -f delay.awk hw2.tr')

	#read thpt and delay for each run and use result[] to record. odd line for thpt, even line for delay
with open('delay.txt','r') as f:
  	for line in f:
		result_d.append(float(line))
f.close()

with open('energy.txt','r') as f:
  	for line in f:
		result_e.append(float(line))
f.close()

	#calculate avg_thpt and avg_delay for i pairs
for l in range (0,runtimes):
	total_delay = total_delay + result_d[l]
avg_delay.append(total_delay/runtimes)

for l in range (0,runtimes):
	total_energy = total_energy + result_e[l]
avg_energy.append(total_energy/runtimes)


#for j in avg_thpt: print(j)
print('############################')
for j in result_d: print(j)
print('avg_delay = ' + str(avg_delay))
for j in result_e: print(j)
print('avg_energy = ' + str(avg_energy))
print('############################')
os.remove('delay.txt')
os.remove('energy.txt')

#write result 
#fo = open('resultThpt(b).txt','w')
#for j in range (0,20):
#	fo.write(avg_thpt[j]+' ')
#fo.close()

#fo = open('resultDelay(b).txt', 'w')
#for j in range (0,20):
#	fo.write(avg_delay[j]+' ')
#fo.close()

