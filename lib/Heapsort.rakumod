unit module Heapsort;

my class State {
    has @!a;        # the array of values to sort
    has Int $.end;  # the last position in the heap region
    has &.preorder; # should be a "strict preorder"

    method STORE(@values) {
        @!a  := @values;
        $!end = @!a.elems - 1;

        # Put the @values in heap order,
        # working up from the last internal node
        loop (my int $i = pos-parent $!end; $i >= 0; $i--) {
            self.sift-down($i);
        }
    }

    method heapify(@values, &preorder) {
        my \SELF = self.bless(:&preorder);
        SELF.STORE(@values);
        SELF;
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

    # Repair the heap rooted at position $start,
    # assuming the child heaps are valid
    method sift-down($start --> Nil) {
        my @path := self.descend(&!preorder, $start);
        my $root := @path[0];
        my $value = $root;

        # determine the new position for the value
        my int $new = @path.end;
        while &!preorder($value, @path[$new]) { $new-- }

        # shift values along the path until we've cleared the new position
        my int $pos;
        while $pos < $new {
            my $succ := @path[++$pos];
            $root  = $succ; # copy value
            $root := $succ; # rebind
        }

        # assign the value to the new position
        $root = $value;
    }

    # Return an Array whose elements are bound to nodes on a
    # path down from position $start. At every step, choose the
    # right child if and only if preorder(right, left) is true.
    method descend(&preorder, $start = 0) {
        my @path;
        my int $elems;

        # .AT-POS may be faster if $start is a native int
        @path[$elems++] := @!a.AT-POS($start);

        my $child := pos-left-child $start;
        my \end = self.end;
        while $child < end {
            my \left  = @!a[$child];
            my \right = @!a[$child + 1];
            if preorder(right, left) {
                @path[$elems++] := right;
                $child := pos-left-child $child + 1;
            }
            else {
                @path[$elems++] := left;
                $child := pos-left-child $child;
            }
        }

        # at the deepest level there may be only one child
        if $child == end {
            @path[$elems] := @!a[$child];
        }
        @path;
    }
}

# The main routine:
proto sub heapsort(|) is export {*}
multi sub heapsort(@a) {
    State.heapify(@a, * cmp * == More).sort;
}
multi sub heapsort(&infix:<cmp>, @a) {
    State.heapify(@a, * cmp * == More).sort;
}

# Utility routines
sub pos-parent(int $pos) {
    ($pos - 1) div 2;
}

sub pos-left-child(int $pos) {
    ($pos * 2) + 1;
}
