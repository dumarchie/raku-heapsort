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

# Repair the max-heap rooted at position $start,
# assuming the child heaps are valid
sub sift-down(@a, $start, $end) {
    my $root = $start;

    my $child = pos-left-child $root;
    while $child <= $end {
        my $swap = $root;         # keeps track of the child to swap with
        $swap = $child
          if @a[$swap] cmp @a[$child] === Less;

        $swap = $child
          if ++$child <= $end     # there is a right child
          && @a[$swap] cmp @a[$child] === Less;

        if $swap == $root {       # the root contains the max value
            $child = $end + 1;    # make this the last iteration
        }
        else {
            swap @a[$root], @a[$swap];

            # now repair the child heap
            $root = $swap;
            $child = pos-left-child $root;
        }
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

sub pos-left-child($pos) {
    ($pos * 2) + 1;
}
