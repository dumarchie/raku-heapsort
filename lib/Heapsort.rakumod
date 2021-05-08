unit module Heapsort;

sub heapsort(@a) is export {
    heapify @a;

    # The following loop maintains the invariant that @a[0..$end] is a heap
    # and every value beyond @a[$end] is greater than everything before it
    # so @a[$end..@a.end] is in sorted order
    my $end = @a.elems - 1;
    while $end > 0 {
        # @a[0] is the root of the heap and contains its max value;
        # the swap moves it in front of the sorted values
        swap @a[$end], @a[0];
        $end--;                # decrement the size of the heap
        sift-down @a, 0, $end; # restore the max-heap property
    }

    # Return the sorted array
    @a;
}

# Put the values stored in @a in max-heap order
sub heapify(@a) {
    # $start is assigned the position of the last internal node
    my $end   = @a.elems - 1;
    my $start = pos-parent $end;

    while $start >= 0 {
        # sift down the value at position $start
        # so that all values below are in heap order
        sift-down @a, $start, $end;

        # continue with the preceding internal node
        $start--;
    }
}

# Search leaf by iteratively following the edge to the child with max value
sub search-leaf(@a, $i, $end) {
    my $j = $i;
    my $child;
    while ($child = pos-right-child $j) <= $end {
        # determine which child has the max value
        if @a[$child] cmp @a[$child - 1] === More {
            $j = $child;     # right child
        }
        else {
            $j = $child - 1; # left child
        }
    }
    # at the deepest level there may be only one child
    --$child <= $end ?? $child !! $j;
}

# Repair the max-heap rooted at position $i,
# assuming the child heaps are valid
sub sift-down(@a, $i, $end) {
    my $j = search-leaf @a, $i, $end;
    while @a[$i] cmp @a[$j] === More {
        $j = pos-parent $j;
    }

    my $x  = @a[$j];
    @a[$j] = @a[$i];
    while $j > $i {
        $j = pos-parent $j;
        swap $x, @a[$j];
    }
}

# Utility routines
sub swap($a is rw, $b is rw) {
    my $value = $a;
    $a = $b;
    $b = $value;
}

sub pos-parent($pos) {
    ($pos - 1) div 2;
}

sub pos-right-child($pos) {
    ($pos * 2) + 2;
}
