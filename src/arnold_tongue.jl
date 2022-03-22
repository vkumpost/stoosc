"""
`estimate_entrainment_area(arnold_tongue, I_max)`

Estimate entrainment area of the Arnold tongue.

**Arguments**
- `arnold_tongue`: A DataFrame representing an Arnold tongue. The DataFrame has
    two columns names `amplitudes` and `periods`. Periods indicate a position
    at x-axis and amplitudes indices a maximal height at y-axis at which was the
    system entrained.
- `I_max`: Maximal input period that was considered for the Arnold tongue.
"""
function estimate_entrainment_area(arnold_tongue, I_max)
    amplitudes = arnold_tongue[:, "amplitudes"]
    entrainment_area = 1 - mean(amplitudes ./ I_max)
    return entrainment_area
end


"""
`plot_arnold_tongue(arnold_tongue, I_max; ax=gca())`

Plot the Arnold tongue.

**Arguments**
- `arnold_tongue`: A DataFrame representing an Arnold tongue. The DataFrame has
    two columns names `amplitudes` and `periods`. Periods indicate a position
    at x-axis and amplitudes indices a maximal height at y-axis at which was the
    system entrained.
- `I_max`: Maximal input period that was considered for the Arnold tongue.

**Keyword Arguments**
- `ax`: PyPlot axes.
"""
function plot_arnold_tongue(arnold_tongue, I_max; ax=gca())
    periods = arnold_tongue[:, "periods"]
    amplitudes = arnold_tongue[:, "amplitudes"]
    n = length(amplitudes)
    arnold_tongue_matrix = fill(0.0, n, n)

    for i_period = 1:n
        for i_amplitude = 1:n
            amplitude = amplitudes[i_period]
            entrained = (I_max * (i_amplitude/n) ) < amplitude
            arnold_tongue_matrix[i_amplitude, i_period] = entrained
        end
    end
    amplitude_ticks = range(0, I_max, length=n)
    ax.pcolor(periods, amplitude_ticks, arnold_tongue_matrix, rasterized=true)
    ax.set_xticks(range(minimum(periods), maximum(periods), length=3))
    ax.set_yticks(range(minimum(amplitude_ticks), maximum(amplitude_ticks),
        length=4))
    ax.set_xlabel("Input period")
    ax.set_ylabel("Input amplitude")
    ax.set_title("Arnold tongue")

    return ax
end
