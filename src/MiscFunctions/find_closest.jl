"""
`find_closest(value, array)`

Find the position of the closest value in an array.

**Arguments**
- `value`: Number.
- `array`: Array of numbers.

**Returns**
- `index`: Position in `array` that is the closest to `value`.
"""
function find_closest(value, array)
    difference = abs.(array .- value)
    index = argmin(difference)
    return index
end
