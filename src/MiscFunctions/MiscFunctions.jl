"""
`MiscFunctions`

Miscellaneous functions.

**Functions**
- `binary_boundary_search`: Use binary search to find a boundary value.
- `cmean`: Compute circular mean of an array.
- `cstd`: Compute circular standard deviation of an array.
- `find_all_combinations`: Find all combinations of values.
- `find_closest`: Find the position of the closest value in an array.
- `r2_score`: Calculate the coefficient of determination.
- `ptp`: Peak-to-peak range (maximum - minimum).
- `smooth`: Smooth a vector using a moving average filter.
"""
module MiscFunctions

using Statistics

export binary_boundary_search
export cmean, cstd
export find_all_combinations
export find_closest
export r2_score, ptp
export smooth

include("binary_search.jl")
include("circular_statistics.jl")
include("find_all_combinations.jl")
include("find_closest.jl")
include("metrics.jl")
include("smooth.jl")

end  # module
