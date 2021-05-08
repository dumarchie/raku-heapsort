unit module Heapsort;

my class State {
    has @!a;   # the array of values to sort
    has $!end; # the last position in the heap

    submethod BUILD(:@a) {
        @!a  := @a;
        $!end = @a.elems - 1;

        # Put the values of @a in max-heap order,
        # working up from the last internal node
        my $i = pos-parent $!end;
        while $i >= 0 {
            # sift down the value at position $i
            # so that all values below are in heap order
            self.sift-down($i);

            # continue with the preceding internal node
            $i--;
        }
    }

    method sort() {
        # The following loop maintains the invariant that @!a[0..$!end] is a
        # heap and every value beyond @!a[$!end] is greater than every value
        # before it, so @!a[$!end..@!a.end] is in sorted order
        while $!end > 0 {
            # @!a[0] is the root of the heap and contains its max value;
            # the swap moves it in front of the sorted values
            swap @!a[$!end], @!a[0];
            $!end--;           # decrement the size of the heap
            self.sift-down(0); # restore the max-heap property
        }

        # Return the sorted array
        @!a;
    }

    # Repair the max-heap rooted at position $i,
    # assuming the child heaps are valid
    method sift-down($i) {
        my $j = self.search-leaf($i);
        while @!a[$i] cmp @!a[$j] === More {
            $j = pos-parent $j;
        }

        my $x   = @!a[$j];
        @!a[$j] = @!a[$i];
        while $j > $i {
            $j = pos-parent $j;
            swap $x, @!a[$j];
        }
    }

    # Iteratively follow the edge to the child with the max value
    method search-leaf($i) {
        my $j = $i;
        my $child;
        while ($child = pos-right-child $j) <= $!end {
            # determine which child has the max value
            if @!a[$child] cmp @!a[$child - 1] === More {
                $j = $child;     # right child
            }
            else {
                $j = $child - 1; # left child
            }
        }
        # at the deepest level there may be only one child
        --$child <= $!end ?? $child !! $j;
    }
}

# The main routine
sub heapsort(@a) is export {
    State.new(:@a).sort;
}

# Utility routines
sub swap($a is rw, $b is rw) {
    my $value = $a;
    $a = $b;
    $b = $value;
}

sub pos-parent(int $pos) {
    ($pos - 1) div 2;
}

sub pos-right-child(int $pos) {
    ($pos * 2) + 2;
}
