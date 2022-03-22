"""
`binary_boundary_search(fun, x_range, err)`

Find a boundary value `X` at which `fun(X)` changes its value from `0` to `1`.
That is, `fun(x) = 0` for all `x < X` and `fun(x) = 1` for all `x > X`.

**Arguments**
- `fun`: Function that returns `0` if `x < X` and `1` if `x > X`.
- `x_range`: Search range as `[x_min, x_max]`.
- `err`: Maximal deviation of the result from the real value.

**Returns**
- `X`: Boundary value, at which `fun(x)` changes from `0` to `1`.
"""
function binary_boundary_search(fun, x_range, err)

    x1 = x_range[1]
    x2 = x_range[2]

    y1 = fun(x1)
    if y1 == 1
        return x1
    end

    y2 = fun(x2)
    if y2 == 0
        return x2
    end

    while abs(x1 - x2) > 2err

        t0 = (x1 + x2) / 2
        x0 = fun(t0)

        if x0 == y1
            y1 = x0
            x1 = t0
        else
            y2 = x0
            x2 = t0
        end

    end

    X = (x1 + x2) / 2
    return X

end
