"""
`cmean(x)`

Compute circular mean of an array.

**Arguments**
- `x`: Array of angles in radians.

**Returns**
- `m`: Circular mean of `x`.
"""
function cmean(x)
    S = mean(sin.(x))
    C = mean(cos.(x))
    m = atan(S, C)
    return m
end


"""
`cstd(x)`

Compute circular standard deviation of an array.

**Arguments**
- `x`: Array of angles in radians.

**Returns**
- `sd`: Circular standard deviation of `x`.
"""
function cstd(x)
    S = mean(sin.(x))
    C = mean(cos.(x))
    R = sqrt(S^2 + C^2)
    x = -2*log(R)
    if x < 0
        @warn "Negative value $x set to 0!"
        x = 0
    end
    sd = sqrt(x)
    return sd
end
