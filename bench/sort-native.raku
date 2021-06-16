my $n = 2**18;
my @times;
for ^4 {
    my int @array = (^$n).pick(*);
    my $start  = now;
    my @sorted = sort @array;

    # check result
    die "Incorrect result" if @sorted.tail != $n - 1;

    my $time = now - $start;
    printf "sort array[int] with %d elems:\t%1.3fs\n", $n, $time;

    push @times, $time;
}

printf "Average of last 3 sorts:\t%1.3fs\n", sum(@times[1..3]) / 3;
