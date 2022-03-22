"""
`r2_score(x, y)`

Calculate the coefficient of determination as described by Nash and Sutcliffe
(https://doi.org/10.1016/0022-1694(70)90255-6).

**Arguments**
- `x`: Array of target values (data set).
- `y`: Array of predicted (fitted, modeled) values.

**Returns**
- `R2`: The coefficient of determination.
"""
function r2_score(x, y)
    μ = mean(x)
    SSres = sum((x .- y).^2)
    SStot = sum((x .- μ).^2)
    R2 = 1 - SSres/SStot
    return R2
end


"""
`ptp(x; kwargs...)`

Return the peak-to-peak range (maximum - minimum).

**Arguments**
- `x`: Array of values.

**Keyword Arguments**
- Passed to `maximum`/`minimum` functions. See their documentation.

**Returns**
- Peak-to-peak range.
"""
function ptp(x; kwargs...)
    return maximum(x; kwargs...) - minimum(x; kwargs...)
end
