# nuttcp-probe-smokeping
[Nuttcp](http://nuttcp.net/nuttcp/beta/) IP performance probe for [smokeping](https://oss.oetiker.ch/smokeping/).  Can be used for simple bandwith measurements, or use different charateristics to simulate different types of IP traffic.  Such as RTP media for SIP, performance within different QoS classes etc.

When seting up the tests, do some calcultaions so you are fairly confident that they do not overlap.  If you do to many tests and to large "pings", the tests may overlap each other and create unpredicteble results.

## Install
The Nuttcp.pm module needs to be copied to your smokeping catalog.  Ubuntu has it per default here: /usr/share/perl5/Smokeping/probes/.  The nuttcp binary distribiuted with the packet handler is typicaly old'ish.  I recomend downloading and compiling the latest version by hand.  Different distributions has different styles of config files for smoekping.  Fedora uses a single config file, ubuntu uses a file per section.  Modify and insert the targets and probes as needed on your system.

### Target
```
+Througput
title = Throughput
menu  = Throughput

++TX_DEF
title = Transmit default class
menu  = Transmit default class
probe = Nuttcp
host  = nuttcp.example.com
extraargs = -t -p 5102

++RX_DEF
title = Recive default class
menu  = Recive default class
probe = Nuttcp
host  = nuttcp.example.com
extraargs = -r -F -p 5101
```


### Probes

```
+ Nuttcp
binary = /usr/local/bin/nuttcp  # Or different path if you don't compile your own nuttcp
pings  = 3  # Ping is a 10 second test, so this is 3 tests of 10 seconds
step   = 300 
forks  = 1 # Be very sure of what you are testing if you set this to something other than 1.
```


