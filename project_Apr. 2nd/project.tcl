# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel  ;# channel type
set val(prop)           Propagation/TwoRayGround ;# radio-propagation model
set val(ant)            Antenna/OmniAntenna      ;# Antenna type
set val(ll)             LL                       ;# Link layer type
set val(ifq)            Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)         50                       ;# max packet in ifq
set val(netif)          Phy/WirelessPhy/802_15_4 ;# network interface type
set val(mac)            Mac/802_15_4             ;# MAC type
set val(rp)             AODV                     ;# AODV routing protocol 
set val(nn)             12   			 ;# Number of nodes
set val(pair)		1			 ;# Number of pairs
set val(fch)		1			 ;# Seed for random
set val(rtscts)		0			 ;# RTS/CTS enable/disable
set val(pktsize)	80			 ;# Packet size
set val(energymodel)    EnergyModel
set val(SO)             3			 ;#SuperframeOrder
set val(BO)             3 			 ;#BeaconOrder
set val(STPANCOO)       1                        ;#StartTime Coordinator  
set val(STDevice)       2                        ;#StartTime Device
set val(IntervalDevice) 0.2                      ;#Interval for start device           

set val(trfile)		project.tr	         ;# Trace file name          
set val(nam)		project.nam

set val(stop)		100


set X_Coordinate	{
			 180 85 10 80 10 280 320 380 470 500 70 490 220 280 580 10 230 450 660 650
			}
set Y_Coordinate	{
			 300 220 160 420 250 200 320 400 250 500 70 400 430 90 30 500 600 650 300 600
			}	


# Read command line: ns hw1.tcl -pair 20 -fch seed -rtscts 0 -packetsize 500
proc getCmdArgu {argc argv} {
        global val
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
                set name [string range $arg 1 end]
                set val($name) [lindex $argv [expr $i+1]]
                #puts "name is $name"
                #puts "data is [lindex $argv [expr $i + 1]]"
        }
}
getCmdArgu $argc $argv


# Configure seed
global defaultRNG
$defaultRNG seed $val(fch)

# Configure ns simulator and trace
set ns			[new Simulator]
set tracefd		[open $val(trfile) w]
$ns trace-all		$tracefd

if {"$val(nam)" == "project.nam"} {
    set namtrace [open ./$val(nam) w]
    $ns namtrace-all-wireless $namtrace 700 700
}

$ns puts-nam-traceall {# nam4exe  #}


set topo		[new Topography]
$topo load_flatgrid 700 700

create-god $val(nn)

# Configure nodes
$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -channelType $val(chan) \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace ON \
                -movementTrace OFF \
                -energyModel $val(energymodel) \
                -initialEnergy 100 \
                -rxPower 0.165 \
                -txPower 0.1485 \
                -idlePower 0.1085 \
                -sleepPower 0.001 




# Create mobile nodes
for {set i 0} {$i < $val(nn) } {incr i} {
    set node_($i) [$ns node]
    # Disable random motion
    $node_($i) random-motion 0
    # Layout of nodes
    $node_($i) set X_ [lindex $X_Coordinate [expr $i]]
    $node_($i) set Y_ [lindex $Y_Coordinate [expr $i]]
    $node_($i) set Z_ 0.0
  
}
$ns at 0.0	        "$node_(0) NodeLabel \"PAN Coor\""
$ns at $val(STPANCOO)	"$node_(0) sscs startPANCoord 1 $val(BO) $val(SO)"	;# startCTPANCoord <txBeacon=1> <BO=3> <SO=3>

#$ns at 5.0 "$node_(0) sscs startCTDevice 1 1 1 3 3"
for {set i 1} {$i < $val(nn)} {incr i} {
    $ns at [expr $val(STDevice) + $val(IntervalDevice)*$i] "$node_($i) sscs startDevice 1 1 1 $val(BO) $val(SO)"               ;# startCTDevice <isFFD=1> <assoPermit=1> <txBeacon=0> <BO=3> <SO=3>
}




#set nums {4 0 2 5 1 6 3 8 7 9}

#randomNumber
set rmax $val(nn)
set nums {}

for {set i 0} {$i<$rmax} {incr i} {lappend nums $i}
#shuffle1
      set n [llength $nums]
      for { set i 0 } { $i < $n } { incr i } {
          set j [expr {int(rand()*$n)}]
          set temp [lindex $nums $j]
          set nums [lreplace $nums $j $j [lindex $nums $i]]
          set nums [lreplace $nums $i $i $temp]
      }







for {set i 0} {$i < $val(pair)} {incr i} {
    puts "source: [lindex $nums [expr ($i*2)]]"
    set udp_($i) [new Agent/UDP]
    $ns attach-agent $node_([lindex $nums [expr ($i*2)]]) $udp_($i)
    #$ns attach-agent $node_(1) $udp_($i)

    puts "destination: [lindex $nums [expr ($i*2+1)]]"
    set sink_($i) [new Agent/Null]
    $ns attach-agent $node_([lindex $nums [expr ($i*2+1)]]) $sink_($i)
    #$ns attach-agent $node_(2) $sink_($i)

    set exp_($i) [new Application/Traffic/Exponential]
    $exp_($i) attach-agent $udp_($i)
    $exp_($i) set burst_time_ 5000ms
    $exp_($i) set idle_time_ 500ms	;# idle_time + pkt_tx_time = interval
    $exp_($i) set packet_size_   $val(pktsize)
    $exp_($i) set rate_ 3600

    $ns connect $udp_($i) $sink_($i)

    $ns at 10.0 "$exp_($i) start"
    $ns at $val(stop) "$exp_($i) stop"
}


# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns initial_node_pos $node_($i) 20
    $ns at $val(stop) "$node_($i) reset";
}


$ns at [expr $val(stop) + 0.1] "stop"
$ns at [expr $val(stop) + 0.2] "puts \"NS EXITING...\" ; $ns halt"
proc stop {} {
    global ns tracefd
    $ns flush-trace
    close $tracefd
    #exec nam project.nam &
}


puts "Starting Simulation..."
$ns run



