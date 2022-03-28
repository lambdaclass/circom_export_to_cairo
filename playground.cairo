#This is a simple cairo program, it executes a binary search and returns 1(TRUE) when the number is found
%builtins output range_check

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import unsigned_div_rem

#array must be sorted
#Returns TRUE if the number is found in the array, or FALSE otherwise
func binary_search{range_check_ptr : felt}(array : felt*, number : felt, length : felt, position : felt) -> (r: felt):
    alloc_locals
    let comp1 : felt = is_le(length + 1, position)
    if comp1 == TRUE:
        return(FALSE)
    else:
        let (mid, _) = unsigned_div_rem(position + length, 2)
        if array[mid] == number:
            return(TRUE)
        end
        let comp2 : felt = is_le(array[mid], number)
        if comp2 == TRUE:
            return binary_search(array, number, length, mid +1)
        else:
            return binary_search(array, number, mid -1, position)
        end
    end
end
	
func main{output_ptr : felt*, range_check_ptr}():

    let (array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 2
    assert array[2] = 3
    assert array[3] = 4
    assert array[4] = 5
    assert array[5] = 6

    let number = 5

    let result : felt = binary_search(array, number, 5, 0)
    serialize_word(result)

    return ()
end
