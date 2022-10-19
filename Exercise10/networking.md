### Calculation of Network IP, Number of hosts, Range of IP addresses and Broadcast IP from a given Subnet 193.16.20.35/29.**

*Calculating Network IP*
     193.16.20.35 => 11000001.00010000.00010100.00100011
     29 => 11111111.11111111.11111111.11111000

     193.16.20.35 => 11000001.00010000.00010100.00100011
     29           => 11111111.11111111.11111111.11111000
                     --------- logical AND -------------
                     11000001.00010000.00010100.00100000

     11000001.00010000.00010100.00100000 => 193.16.20.32
The Network IP of 193.16.20.35/29 is 193.16.20.32

*Number of hosts*
Formula for number of hosts: 2^(32 - subnet) - 2
in our case: 2^(32 - 29) - 2 = 2^3 - 2 = 8 - 2 = 6

The number of hosts that can be asigned IP's on the network is 6.

*Calculating Broadcast IP*
     11111111.11111111.11111111.11111000 => 00000000.00000000.00000000.00000111
     193.16.20.35     => 11000001.00010000.00010100.00100011
     New subnet value => 00000000.00000000.00000000.00000111
                         ----------- logical OR ------------
                         11000001.00010000.00010100.00100111
     11000001.00010000.00010100.00100111 => 193.16.20.39
Therefore the Broadcast IP of 193.16.20.35/29 is 193.16.20.39

*Calculating Range of IP addresses*
The range of IP addresses that can be assigned to hosts lie in between the value of the Network IP and the Broadcast IP

     193.16.20.33
     193.16.20.34
     193.16.20.35
     193.16.20.36
     193.16.20.37
     193.16.20.38
