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

    my int $begin;
    method sort() {
        my $root := @!a.AT-POS($begin);

        my $value; # to move from the heap to the sorted region
        while $!end > 0 {
            # make the last leaf of the heap the head of the sorted region
            my $head := @!a[$!end--];

            # swap the values of the head and the root
            $value = $root;
            $root  = $head;
            $head  = $value;

            # repair the heap
            self.sift-down($begin);
        }

        # Return the sorted array
        @!a;
    }

    # Repair the heap rooted at position $i,
    # assuming the child heaps are valid
    method sift-down($i --> Nil) {
        my @path := self.descend(&!preorder, $i);
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
    # path down from position $start. At every step, choose the
    # right child if and only if preorder(left, right) is true.
    method descend(&preorder, $start = 0) {
        my @path;
        my int $elems;

        # .AT-POS may be faster if $start is a native int
        @path[$elems++] := @!a.AT-POS($start);

        my $child := pos-left-child $start;
        while $child < $!end {
            my \left  = @!a[$child];
            my \right = @!a[$child + 1];
            if preorder(left, right) {
                @path[$elems++] := right;
                $child := pos-left-child $child + 1;
            }
            else {
                @path[$elems++] := left;
                $child := pos-left-child $child;
            }
        }

        # at the deepest level there may be only one child
        if $child == $!end {
            @path[$elems] := @!a[$child];
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
sub pos-parent(int $pos) {
    ($pos - 1) div 2;
}

sub pos-left-child(int $pos) {
    ($pos * 2) + 1;
}
