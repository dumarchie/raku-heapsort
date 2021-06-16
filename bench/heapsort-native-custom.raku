use lib 'lib';
use Heapsort;

my $n = 2**18;
my @times;
for ^4 {
    my int @array = (^$n).pick(*);
    my $start  = now;
    heapsort * <=> *, @array;

    # check result
    die "Incorrect result" if @array.tail != $n - 1;

    my $time = now - $start;
    printf "custom heapsort array[int] with %d elems:\t%1.3fs\n", $n, $time;

    push @times, $time;
}

printf "Average of last 3 sorts:\t%1.3fs\n", sum(@times[1..3]) / 3;
