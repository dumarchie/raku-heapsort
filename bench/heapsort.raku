use NativeCall;

use lib 'lib';
use Heapsort;

my $n = 2**16;
my @times;
for ^4 {
    my @array := CArray[uint16].new: (^$n).pick(*);
    my $start  = now;
    my $result = heapsort @array;

    # ensure the $result is fully reified
    die "Incorrect number of elements in the result"
      if $result.elems != $n;

    my $time = now - $start;
    printf "sort CArray with %d elems:\t%1.3fs\n", $n, $time;

    push @times, $time;
}

printf "Average of last 3 sorts:\t%1.3fs\n", sum(@times[1..3]) / 3;
