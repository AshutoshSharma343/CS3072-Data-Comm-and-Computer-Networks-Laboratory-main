#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
global ns nf
$ns flush-trace
#Close the NAM trace file
close $nf
#Execute NAM on the trace file
exec nam out.nam &
exit 0
}

#Create four nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#Create links between the nodes
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n5 $n2 1Mb 10ms DropTail
$ns duplex-link $n3 $n2 1Mb 10ms DropTail
$ns duplex-link $n4 $n2 1Mb 10ms DropTail

#Set Queue Size of link (n2-n4) to 10
$ns queue-limit $n2 $n4 100

#Give node position (for NAM)
$ns duplex-link-op $n1 $n2 orient right-down
$ns duplex-link-op $n5 $n2 orient right
$ns duplex-link-op $n3 $n2 orient right-up
$ns duplex-link-op $n2 $n4 orient right

#Monitor the queue for the link between node 2 and node 4
$ns duplex-link-op $n2 $n4 queuePos 0.5

#Create a UDP agent and attach it to node n5
set udp5 [new Agent/UDP]
$udp5 set class_ 1
$ns attach-agent $n5 $udp5

# Create a CBR traffic source and attach it to udp5
set cbr5 [new Application/Traffic/CBR]
$cbr5 set packetSize_ 500
$cbr5 set interval_ 0.005
$cbr5 attach-agent $udp5

#Setup a TCP connection at node 1
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $n1 $tcp1
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp1 $sink
$tcp1 set fid_ 2


#Setup a FTP over TCP connection at node 3
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP
#Setup a TCP connection at node 3
set tcp3 [new Agent/TCP]
$tcp3 set class_ 3
$ns attach-agent $n3 $tcp3
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp3 $sink
$tcp3 set fid_ 3

#  $ftp set packetSize_ 1000
#  $ftp set interval_ 0.01
#  $ftp set random_ false
#  $ftp set maxpkts_ 1000
#  $ftp set fid_ 1

# $cbr set packetSize_ 1000
# $cbr set interval_ 0.01
# $cbr set random_ false
# $cbr set maxpkts_ 1000
# $cbr set fid_ 0


#Setup a FTP over TCP connection at node 3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ftp3 set type_ FTP
#Create a Null agent (a traffic sink) and attach it to node n4
set null0 [new Agent/Null]
$ns attach-agent $n4 $null0
#Connect the traffic sources with the traffic sink
$ns connect $udp5 $null0

#Schedule events for the CBR agents and FTP agents
$ns at 0.1 "$cbr5 start"
$ns at 1.0 "$ftp1 start"
$ns at 2.0 "$ftp3 start"
$ns at 3.0 "$ftp3 stop"
$ns at 4.0 "$ftp1 stop"
$ns at 5.0 "$cbr5 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"
#Run the simulation
$ns run