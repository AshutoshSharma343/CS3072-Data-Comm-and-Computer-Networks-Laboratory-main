#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

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
# Define nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Create links between nodes
$ns duplex-link $n0 $n2 100Mb 10ms DropTail
$ns duplex-link $n1 $n2 100Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 75ms DropTail

#Give node position (for NAM)
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

# Set up TCP Tahoe on connection from n0 to n3
set tcp0 [new Agent/TCP]
$tcp0 set class_ 2
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n3 $sink0
$ns connect $tcp0 $sink0

#Setup a FTP over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP

# Set up TCP Reno on connection from n1 to n3
set tcp1 [new Agent/TCP/Reno]
$ns attach-agent $n1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink1
$ns connect $tcp1 $sink1

# Set up TCP Reno on connection from n1 to n3
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

# Schedule events for the FTP agents
$ns at 0.0 "$ftp0 start"
$ns at 0.5 "$ftp1 start"
$ns at 2.0 "$ftp0 stop"
$ns at 2.5 "$ftp1 stop"

# Call finish after 5 seconds of simulation time
$ns at 5.0 "finish"

# Run the simulation
$ns run
