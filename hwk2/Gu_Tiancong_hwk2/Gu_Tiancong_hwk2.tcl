

# ==================================================================
# Define options
# ===================================================================
set val(chan)		Channel/WirelessChannel
set val(prop)		Propagation/TwoRayGround
set val(netif)		Phy/WirelessPhy
set val(mac)		Mac/802_11
set val(ifq)		Queue/DropTail/PriQueue
set val(ll)		LL
set val(ant)            Antenna/OmniAntenna
set val(filters)        GradientFilter    ;# old name for twophasepull filter 
                                ;# TPP/OPP/Gear/Rmst/SourceRoute/Log/TagFilter
set val(x)		560	;# X dimension of the topography
set val(y)		560     ;# Y dimension of the topography
set val(ifqlen)		50	;# max packet in ifq
set val(nn)		49	;# number of nodes

set val(stop)		50	;# simulation time
set val(prestop)        19      ;# time to prepare to stop
set val(nsrc)           [expr [lindex $argv 0]]         ;#numbers of sources
set val(tr)		"hw2.tr"	;# trace file
set val(nam)            "hw2.nam"  ;# nam file
set val(adhocRouting)   Directed_Diffusion
set val(energymodel)    EnergyModel
#set opt(traf)		"diffusion-traf.tcl"      ;# traffic file

# ==================================================================

LL set mindelay_		50us    
LL set delay_			30us    ;# delay = 30us
LL set bandwidth_		0	;# not used

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0

# ==================================================================
# Main Program
# =================================================================

#
# Initialize Global Variables
#

set ns_		[new Simulator] 
set topo	[new Topography]

set tracefd	[open $val(tr) w]
$ns_ trace-all $tracefd

set nf [open $val(nam) w]
$ns_ namtrace-all-wireless $nf $val(x) $val(y)

#$ns_ use-newtrace

$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

# log the mobile nodes movements if desired

#if { $opt(lm) == "on" } {
#    log-movement
#}

#global node setting

$ns_ node-config -adhocRouting $val(adhocRouting) \
		 -llType $val(ll) \
		 -macType $val(mac) \
		 -ifqType $val(ifq) \
		 -ifqLen $val(ifqlen) \
		 -antType $val(ant) \
		 -propType $val(prop) \
		 -phyType $val(netif) \
		 -channelType $val(chan) \
		 -topoInstance $topo \
                 -diffusionFilter $val(filters) \
		 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -energyModel $val(energymodel) \
                 -initialEnergy 1000 \
                 -rxPower 0.35 \
                 -txPower 0.66 \
                 -idlePower 0.035 
                  

#  Create the specified number of nodes [$opt(nn)] and "attach" them
#  to the channel. 

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node $i]
	$node_($i) random-motion 0		;# disable random motion
        $god_ new_node $node_($i)
	$node_($i) set X_ [expr (($i%7) * 80.0 + 40.0)]
	$node_($i) set Y_ [expr (($i/7) * 80.0 + 40.0)]
	$node_($i) set Z_ 0.0
	$ns_ initial_node_pos $node_($i) 20     ;# 20 defines the node size in nam, must adjust it according to your scenario
    					       ;# The function must be called after mobility model is defined
}

puts "Loading connection pattern..."

#randomNumber
set rmax 49
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
#The shuffle1 here do generate a random list, even if I do not use seed here.

#Diffusion src application
for {set i 0} {$i < $val(nsrc)} {incr i} {
	set src_($i) [new Application/DiffApp/PingSender/TPP]
	if {[lindex $nums $i] == 24} {
		$ns_ attach-diffapp $node_([lindex $nums 48]) $src_($i)
		puts $tracefd [lindex $nums 48]
		puts "24 is avoided"
		puts [lindex $nums 48]
	} else {                                                             ;#node 24 is the sink
	$ns_ attach-diffapp $node_([lindex $nums $i]) $src_($i)
	puts $tracefd [lindex $nums $i]
	puts [lindex $nums $i]
	}

	$ns_ at 0.4 "$src_($i) publish"
}



#Diffusion sink application No.24 node starts at 1.1s
set snk_(0) [new Application/DiffApp/PingReceiver/TPP]
$ns_ attach-diffapp $node_(24) $snk_(0)
$ns_ at 1.1 "$snk_(0) subscribe"


#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).000000001 "$node_($i) reset";
}
# tell nam the simulation stop time
$ns_ at  $val(stop)	"$ns_ nam-end-wireless $val(stop)"
$ns_ at  $val(stop)     "stop"
$ns_ at  $val(stop).000000001 "puts \"NS EXITING...\" ; $ns_ halt"

puts $tracefd "Directed Diffusion:"
puts $tracefd "M 0.0 nn $val(nn) x $val(x) y $val(y)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"



proc stop {} {
    global ns_ tracefd nf
    $ns_ flush-trace
    close $tracefd
    close $nf
    puts "running nam..."
    #exec nam hw2.nam &
    exit 0
}

puts "Starting Simulation..."
$ns_ run

