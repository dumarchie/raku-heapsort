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
        my @path := self.bounce-path($i);
        my $root := @path[0];

        my $value   = $root;     # the value to sift down
        my int $end = @path.end; # the new position of the value in the path
        my $succ := @path[$end];
        while &!preorder($succ, $value) {
            $end--;
            $succ := @path[$end];
        }

        # shift values on the path
        my int $pos;
        while $pos < $end {
            $succ := @path[++$pos];
            $root  = $succ; # copy value
            $root := $succ; # rebind
        }

        # assign the value to the new position
        $succ = $value;
    }

    # The bounce path is an Array whose elements are bound to nodes on the path
    # from position $i to a leaf where at each level the child with the highest
    # priority is chosen.
    method bounce-path($i) is raw {
        my @path;
        my int $depth;

        my $j = $i;
        @path[$depth++] := @!a[$j]; # root node

        my $child;                  # position of left child
        my ($left, $right);         # child nodes
        while ($child := pos-left-child $j) < $!end {
            $left  := @!a[$child];
            $right := @!a[$child + 1];
            if &!preorder($left, $right) {
                $j = $child + 1;
                @path[$depth++] := $right;
            }
            else {
                $j = $child;
                @path[$depth++] := $left;
            }
        }
        # at the deepest level there may be only one child
        @path[$depth] := @!a[$child] if $child == $!end;
        @path;
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

sub pos-left-child(int $pos) {
    ($pos * 2) + 1;
}
