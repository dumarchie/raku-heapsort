unit module Heapsort;

my class State {
    has @!a;        # the array of values to sort
    has $!end;      # the last position in the heap region
    has &!preorder; # should be a "strict preorder"

    submethod BUILD(:@a, :&!preorder) {
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
    method sift-down($i --> Nil) {
        my @path := self.descend($i, &!preorder);
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

    # Return an Array whose elements are bound to nodes on a
    # path down from position $i. At every step, choose the
    # right child if and only if preorder(left, right) is true.
    method descend($i, &preorder) {
        my @path;
        my int $elems;

        my $j = $i;
        @path[$elems++] := @!a.AT-POS($j); # root node

        my $child;                         # position of left child
        while ($child := pos-left-child $j) < $!end {
            my \left  = @!a.AT-POS($child);
            my \right = @!a.AT-POS($child + 1);
            if preorder(left, right) {
                $j = $child + 1;
                @path[$elems++] := right;
            }
            else {
                $j = $child;
                @path[$elems++] := left;
            }
        }
        # at the deepest level there may be only one child
        if $child == $!end {
            my \leaf = @!a.AT-POS($child);
            @path[$elems] := leaf;
        }
        @path;
    }
}

# The main routine:
proto sub heapsort(|) is export {*}
multi sub heapsort(@a) {
    State.new(:@a, :preorder(* cmp * == Less)).sort;
}
multi sub heapsort(&infix:<cmp>, @a) {
    State.new(:@a, :preorder(* cmp * == Less)).sort;
}

# Utility routines
sub swap($a is rw, $b is rw --> Nil) {
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
