#Parameters: Number of pairs; Packet Size; Interval; RTSThreshold

#Basic Configurations
set val(chan)           Channel/WirelessChannel;
set val(prop)           Propagation/TwoRayGround;
set val(netif)          Phy/WirelessPhy;
set val(mac)            Mac/802_11;
set val(ifq)            Queue/DropTail/PriQueue;
set val(ll)             LL;
set val(ant)            Antenna/OmniAntenna;
set val(ifqlen)         50;
set val(nn)             49;
set val(rp)             AODV;
set val(x)		490
set val(y)		490
set pairs               [expr ([lindex $argv 0]+1)]

Mac/802_11 set RTSThreshold_ [lindex $argv 3]; #Setting the RTS threshold 0/3000
Mac/802_11 set dataRate_ 2Mb; #Setting MAC DataRate 2Mb

set ns		[new Simulator]

set tracefd     [open hwk1.tr w]
$ns trace-all   $tracefd
#set namtracefd    [open hwk1.nam w]
#$ns namtrace-all-wireless $namtracefd $val(x) $val(y)

set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

$ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace OFF \
		-macTrace OFF \
		-movementTrace OFF \
		-channelType $val(chan)
		#-channel [new $val(chan)]

#Create nodes&set their location
for {set i 0} {$i < $val(nn)} {incr i} {
	set node_($i) [$ns node]
	$node_($i) random-motion 0
	$node_($i) set X_ [expr (($i%7) * 70.0)]
	$node_($i) set Y_ [expr (($i/7) * 70.0)]
	$node_($i) set Z_ 0.0
	$ns initial_node_pos $node_($i) 20 
}

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

#for {set i 0} {$i < $rmax} {incr i} {
#	puts [lindex $nums $i]
#}

for {set i 1} {$i < $pairs} {incr i} {
	#if {([lindex $nums [expr (($i-1)*2)]] == 1)&&([lindex $nums [expr (($i-1)*2+1)]] == 46)} {incr i}
	set udp($i) [new Agent/UDP]
	set null($i) [new Agent/Null]
	$ns attach-agent $node_([lindex $nums [expr (($i-1)*2)]]) $udp($i)
	$ns attach-agent $node_([lindex $nums [expr (($i-1)*2+1)]]) $null($i)
	$ns connect $udp($i) $null($i)
	set cbr($i) [new Application/Traffic/CBR]
	$cbr($i) attach-agent $udp($i)
	$cbr($i) set packet_size_ [lindex $argv 1]
	$cbr($i) set interval_  [lindex $argv 2]
}
        

for {set i 1} {$i < $pairs} {incr i} {
$ns at 5.0 "$cbr($i) start" 
$ns at 25.0 "$cbr($i) stop"
}
$ns at 25.01 "stop"
$ns at 25.02 "puts \"NS EXITING...\" ; $ns halt"

proc stop {} {
    global ns tracefd namtracefd
    $ns flush-trace
    close $tracefd
#    close $namtracefd
#    puts "running nam..."
#    exec nam wireless-udp.nam &
    exit 0
}

$ns run


