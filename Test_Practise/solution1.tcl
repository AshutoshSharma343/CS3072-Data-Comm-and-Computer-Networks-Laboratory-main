#Create a simulator object
set ns [new Simulator]

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


$n1 label "Source"
$n2 label "Router"
$n3 label "Destination"

#Create links between the nodes
# $ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Kb 100ms DropTail
$ns duplex-link $n2 $n3 5Mb 200ms DropTail

#Set Queue Size of link (n1-n3) to 10
$ns queue-limit $n1 $n3 10

#Setup a TCP connection at node 1
set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1

#Setup a FTP over TCP connection at node 1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1



#Setup a TCP connection at node 3
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink

$ns connect $tcp1 $sink

$tcp1 set fid_ 2


