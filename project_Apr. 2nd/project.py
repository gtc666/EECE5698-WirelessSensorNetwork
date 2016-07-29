#!/usr/bin/python

import sys
import re
import os
import subprocess




def main(runtimes, pairs, BO, SO, moveflag):
    # Definition of performance metrics
    lst_throughput = [None] * runtimes
    lst_delay = [None] * runtimes
    lst_energy = [None] * runtimes
    lst_pdr = [None] * runtimes
    average_throughput = [None] * pairs
    average_delay = [None] * pairs
    average_energy = [None] * pairs
    average_pdr = [None] * pairs
    
    #seed
    seed = [10, 100, 1000, 50, 500, 0, 2000, 888, 280, 5000, 
            1000, 9999, 800, 70, 990, 15, 800, 60, 9, 666, 
            1, 500, 9000, 45, 555, 100, 900, 20, 800, 10000,
            15, 510, 26, 6200, 370, 73, 4800, 84, 5999, 95,
            9000, 900, 90, 9, 80, 800, 8000, 80000, 70, 326]

    for pair_times in range(0, pairs):
        # Run simulation for up to 50 times
        for run_times in range(0, runtimes):
            # Generate ns command and generate trace file
            command = "ns project.tcl -trfile trace_"
            command += str(pair_times + 1)
            command += "_"
            command += str(run_times)
            command += ".tr -pair "
            command += str(pair_times + 1)
            command += " -fch "
            command += str(seed[run_times])
            command += " -BO"
            command += str(BO)
            command += " -SO"
            command += str(SO)
            command += " -moveflag"
            command += "moveflag"
            # Run ns command: ns project.tcl -trfile tracefile -pair pair_times -fch seed -BO BO -SO SO -moveflag moveflag
            os.system(command)
            # Read trace file and output throughput to .txt
            trace = "trace_"
            trace += str(pair_times + 1)
            trace += "_"
            trace += str(run_times)
            trace += ".tr"
            # Run awk command to calculate the throughput
            subprocess.check_call(["awk", "-f", "throughput.awk", trace])
            # Run awk command to calculate the delay
            subprocess.check_call(["awk", "-f", "delay.awk", trace])
            # Run awk command to calculate the energy
            subprocess.check_call(["awk", "-f", "energy.awk", trace])

        # Read the throughput file and delay file
        f_throughput = open('throughput.txt', 'r')
        f_delay = open('delay.txt', 'r')
        f_energy = open('energy.txt', 'r')
        f_pdr = open('pdr.txt', 'r')
        for i in range(0, runtimes):
            throu = f_throughput.readline()
            lst_throughput[i] = float(throu[:-1])
            delay = f_delay.readline()
            lst_delay[i] = float(delay[:-1])
            energy = f_energy.readline()
            lst_energy[i] = float(energy[:-1])
            pdr = f_pdr.readline()
            lst_pdr[i] = float(pdr[:-1])

        # Remove record file
        os.remove('throughput.txt')
        os.remove('delay.txt')
        os.remove('energy.txt')
        os.remove('pdr.txt')
        # Calculate the average throughput
        average_throughput[pair_times] = sum(lst_throughput) / len(lst_throughput)
        # Calculate the average end-to-end delay
        average_delay[pair_times] = sum(lst_delay) / len(lst_delay)
        # Calculate the average energy
        average_energy[pair_times] = sum(lst_energy) / len(lst_energy)
        # Calculate the average packet delivery ratio
        average_pdr[pair_times] = sum(lst_pdr) / len(lst_pdr)

    # Finally print all throughput and end-to-end delay
    print " "
    print "/*************** Result *******************/"
    avg_throughput = "Throughput = ["
    avg_delay = "Delay = ["
    avg_energy = "Energy = ["
    avg_pdr = "PDR = ["
    for pair_times in range(0, pairs):
        avg_throughput += str.format("{0:.4f}", average_throughput[pair_times])
        avg_throughput += ", ";
    avg_throughput = avg_throughput[:-2]
    avg_throughput += "];"
    print avg_throughput
    for pair_times in range(0, pairs):
        avg_delay += str.format("{0:.4f}", average_delay[pair_times])
        avg_delay += ", "
    avg_delay = avg_delay[:-2]
    avg_delay += "];" 
    print avg_delay
    for pair_times in range(0, pairs):
        avg_energy += str.format("{0:.4f}", average_energy[pair_times])
        avg_energy += ", "
    avg_energy = avg_energy[:-2]
    avg_energy += "];"
    print avg_energy
    for pair_times in range(0, pairs):
        avg_pdr += str.format("{0:.4f}", average_pdr[pair_times])
        avg_pdr += ", "
    avg_pdr = avg_pdr[:-2]
    avg_pdr += "];"
    print avg_pdr
    print "/*************** Result *******************/"
   



###################################################################################
# Command: 
#                project.py runtimes pairs BO SO moveflag
# Parameters:
#                runtimes: number of times for running in order to calculate
#                          the average
#                pairs:    number of pairs, up to 10
#                BO:       For Beacon interval
#                SO:       For Superframe interval
#                moveflag: Whether support motion
#                          0: no moving
#                          1: moving
#
###################################################################################
total = len(sys.argv)
cmdargs = str(sys.argv)
print "Command Args: ", cmdargs
# run times
runtimes = int(sys.argv[1])
if (runtimes > 50 or runtimes < 0):
    runtimes = 50
# Pairs
pairs = int(sys.argv[2])
if (pairs > 10 or pairs < 0):
    pairs = 10
# BO and SO
BO = int(sys.argv[3])
SO = int(sys.argv[4])
if (BO > 15 or BO < 0):
    BO = 3
if (SO > 15 or SO < 0):
    SO = 3
# move flag
moveflag = int(sys.argv[5])
# Run ...
main(runtimes, pairs, BO, SO, moveflag)



