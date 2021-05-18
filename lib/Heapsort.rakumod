unit module Heapsort;

my class State {
    has @!a;   # the array of values to sort
    has $!end; # the last position in the heap region
    has &!cmp; # should return Order:D

    submethod BUILD(:@a, :&!cmp) {
        @!a  := @a;
        $!end = @a.elems - 1;

        # Put the values of @a in max-heap order,
        # working up from the last internal node
        my int $i = pos-parent $!end;
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
        my int $begin = 0;
        my \root = @!a.AT-POS($begin);
        while $!end > $begin {
            # the swap moves the value at the root in front of the sorted
            # values; decrementing the size of the heap makes this value the
            # head of the sorted region
            swap @!a.AT-POS($!end), root;
            $!end--;

            # now repair the heap
            self.sift-down($begin);
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
        while &!cmp($succ, $value) === Less {
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
    method bounce-path($i) {
        my @path;
        my int $depth;

        my $j = $i;
        @path[$depth++] := @!a.AT-POS($j); # root node

        my $child;                         # position of left child
        my ($left, $right);                # child nodes
        while ($child := pos-left-child $j) < $!end {
            $left  := @!a.AT-POS($child);
            $right := @!a.AT-POS($child + 1);
            if &!cmp($left, $right) === Less {
                $j = $child + 1;
                @path[$depth++] := $right;
            }
            else {
                $j = $child;
                @path[$depth++] := $left;
            }
        }
        # at the deepest level there may be only one child
        @path[$depth] := @!a.AT-POS($child) if $child == $!end;
        @path;
    }
}

# The main routine:
proto sub heapsort(|) is export {*}
multi sub heapsort(@a) {
    heapsort * cmp *, @a;
}
multi sub heapsort(&cmp, @a) {
    # TODO: check that &preorder is a "strict preorder"
    # by comparing @a[0] to itself (if @a is not empty)
    State.new(:@a, :&cmp).sort;
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
