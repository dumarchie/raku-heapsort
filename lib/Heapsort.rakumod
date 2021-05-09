unit module Heapsort;

my class State {
    has @!a;        # the array of values to sort
    has $!end;      # the last position in the heap region
    has &!preorder; # must be a "strict preorder"

    submethod BUILD(:@a, :&!preorder) {
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
        # max-heap and every value beyond @!a[$!end] is in sorted order.
        while $!end > 0 {
            # @!a[0] is the root of the heap; the swap moves its value in
            # front of the sorted values; decrementing the size of the heap
            # makes this value the head of the sorted region
            swap @!a[$!end], @!a[0];
            $!end--;

            # now repair the heap
            self.sift-down(0);
        }

        # Return the sorted array
        @!a;
    }

    # Repair the heap rooted at position $i,
    # assuming the child heaps are valid
    method sift-down($i) {
        my $j = self.search-leaf($i);
        while &!preorder(@!a[$j], @!a[$i]) {
            $j = pos-parent $j;
        }

        my $x   = @!a[$j];
        @!a[$j] = @!a[$i];
        while $j > $i {
            $j = pos-parent $j;
            swap $x, @!a[$j];
        }
    }

    # Locate an external node,
    # iteratively following the edge to the child with the highest priority
    method search-leaf($i) {
        my $j = $i;
        my $child;
        while ($child = pos-right-child $j) <= $!end {
            if &!preorder(@!a[$child - 1], @!a[$child]) {
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

# The default preorder relation:
sub preorder(\a, \b) is pure {
    a cmp b === Less
}

# The main routine:
proto sub heapsort(|) is export {*}
multi sub heapsort(@a) {
    State.new(:@a, :&preorder).sort;
}
multi sub heapsort(&preorder, @a) {
    # TODO: check that &preorder is a "strict preorder"
    # by comparing @a[0] to itself (if @a is not empty)
    State.new(:@a, :&preorder).sort;
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
