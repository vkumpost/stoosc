"""
`smooth(y, span=5)`

Smooth a vector using a moving average filter. Endpoints are handled by
collapsing the length of the filter as showed below.
```
yy[1] = y[1]
yy[2] = (y[1] + y[2] + y[3]) / 3
yy[3] = (y[1] + y[2] + y[3] + y[4] + y[5]) / 5
yy[4] = (y[2] + y[3] + y[4] + y[4] + y[6]) / 5
```

**Arguments**
- `y`: Array of values.

**Optional Arguments**
- `span`: Filter length.

**Returns**
- `yy`: Smoothed array of values.
"""
function smooth(y, span=5)

    halfspan = floor(span/2)
    n = length(y)
    yy = fill(NaN, n)

    for i = 1:n

        ispan = min(i-1, n-i, halfspan)
        ileft = convert(Int, i-ispan)
        iright = convert(Int, i+ispan)

        yy[i] = mean(y[ileft:iright])

    end

    return yy

end
