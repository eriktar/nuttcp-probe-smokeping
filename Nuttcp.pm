package Smokeping::probes::Nuttcp;

=head1 301 Moved Permanently
This is a Smokeping probe module. Please use the command 
C<smokeping -man Smokeping::probes::Nuttcp>
to view the documentation or the command
C<smokeping -makepod Smokeping::probes::Nuttcp>
to generate the POD document.

=cut

use strict;
use base qw(Smokeping::probes::basefork); 
# or, alternatively
# use base qw(Smokeping::probes::base);
use Carp;
my $DEFAULTBIN = "/usr/local/bin/nuttcp";

sub pod_hash {
    return {
        name => "Smokeping::probes::nuttcp - a nuttcp probe for SmokePing",
        overview => "Uses nuttcp to measure throughput.",
        description => "See nuttcp -h for details of the options below)",
        authors => <<'DOC',
 Erik Taraldsen <eriktar [AT] gmail.com>
DOC
        notes => <<DOC,
Leans heavely on extraargs to do anything usefull
DOC
        see_also => "nuttcp -h L<http://nuttcp.net/nuttcp/beta/>",
    }
}

sub new($$$)
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);

    # no need for this if we run as a cgi
    unless ( $ENV{SERVER_SOFTWARE} ) {
    	# if you have to test the program output
	# or something like that, do it here
	# and bail out if necessary
    };

    return $self;
}

# From Adrian Popa <adrian_gh.popa@telekom.ro> on the mailinglist
sub ProbeUnit($){
    my $self = shift;
    #TODO: We need to know if we are measuring bps or seconds - depending on measurement (or maybe on probe name).
    return "bps";
}


# This is where you should declare your probe-specific variables.
# The example shows the common case of checking the availability of
# the specified binary.

sub probevars {
    my $class = shift;
    my $h = $class->SUPER::probevars;
    delete $h->{timeout};
    return $class->_makevars($h, {
	binary => {
	    _doc => "The location of your nuttcp binary.",
	    _default => $DEFAULTBIN,
	    _sub => sub {
		my $val = shift;
		return "ERROR: nuttcp 'binary' $val does not point to an executable"
		    unless -f $val and -x _;
		return undef;
	    },
	},
			     });
}


# Here's the place for target-specific variables

sub targetvars {
    my $class = shift;
    return $class->_makevars($class->SUPER::targetvars, {
	#weight => { _doc => "The weight of the pingpong ball in grams",
	#	       _example => 15
	#},
	timeout => {
	    _doc => qq{If test takes longer than this, we expect it failed. NB must be larger than duration.},
	    _re => '\d+',
	    _example => 20,
	    _default => 20,
	},
        duration => {
            _doc => qq{The "-T" nuttcp.  Test duration in seconds.},
            _re => '\d+',
            _example => 20,
            _default => 10,
        },
	host => {
	    _doc => qq{Server to test speed to},
	    _re => '.+',
	    _example => "nuttcp.example.com",
	    _default => "speedmonster.telenor.net",
	},
	extraargs => {
	    _doc => qq{ Anything else from nuttcp you would like to throw at it goes here.},
	    _example => "-r -F",
	    _default => "-t",
		
	},
	
			     });
}

sub ProbeDesc($){
    my $self = shift;
    return "nuttcp throughput";
}

# this is where the actual stuff happens
# you can access the probe-specific variables
# via the $self->{properties} hash and the
# target-specific variables via $target->{vars}

# If you based your class on 'Smokeping::probes::base',
# you'd have to provide a "ping" method instead
# of "pingone"

sub pingone ($){
    my $self = shift;
    my $target = shift;

    my $binary = $self->{properties}{binary};
    # my $weight = $target->{vars}{weight}
    my $host    = $target->{vars}{host};
    my $timeout = $target->{vars}{timeout};
    my $duration = $target->{vars}{duration};
    my $extra   = $target->{vars}{extraargs};
    my $count   = $self->pings($target); # the number of pings for this targets

    # ping one target

    # execute a command and parse its output
    # you should return a sorted array of the measured latency times
    # it could go something like this:
#    my $cmd = "$binary -T $count $extra -fparse -i1 $host";
    my $cmd = "$binary -T $duration $extra -fparse -i1 $host";

    my @times;
    $self->do_debug("Executing $cmd"); 
#    for (1..1) {
    for (1..$count) {
	open(P, "$cmd 2>&1 |") or croak("fork: $!");
	while (<P>) {
	    $self->do_debug("Got output $_");
#megabytes=1.5000 real_sec=1.00 rate_Mbps=12.5817 retrans=0
#	    /rate_Mbps=(\d+\.\d+)\s+retrans/ and push @times, $1;
#megabytes=23.6506 real_seconds=10.37 rate_Mbps=19.1316 tx_cpu=0 rx_cpu=4 retrans=0 rtt_ms=19.31
	    /rate_Mbps=(\d+\.\d+)\s+tx_cpu/ and push @times, $1;
	}
	close P;
    }

    $self->do_debug("All times to update: '@times'");
    return @times;
}


1;
