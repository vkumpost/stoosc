"""
`kfr(R, A)`

Kim-Forger activator-repressor inhibition for K = 0.
"""
kfr(R, A) = R < A ? 1 - R / A : 0.0


"""
`kfr(R, A, K)`

Kim-Forger activator-repressor inhibition.
"""
kfr(R, A, K) = (A - R - K + sqrt((A - R - K)^2 + 4*A*K)) / (2*A)


"""
`create_events(X)`

Create event matrix from specifications `X` defined as `X = [(:LL, 2*24),
(:LD, 5, 12, 12), (:DD, 5*24), (:LL, 5*24)]`
"""
function create_events(X)

    # Time counter
    current_time = 0.0

    # Initialize matrix of empty events
    events = Matrix{Float64}(undef, 0, 2)

    for x in X

        # Get code of the event
        code = Symbol(x[1])

        if code == :LD  # light-dark period

            # Iterate days
            for _ = 1:x[2]

                if !isempty(events) && events[end, 2] == current_time
                    # Extend an already existing ligt period
                    events[end, 2] = current_time + x[3]
                else
                    # Add a new light-dark cycle
                    events = [events; [current_time current_time + x[3]]]
                end

                # Increment the time counter by the duration of the added day
                current_time = current_time + x[3] + x[4]

            end

        elseif code == :DD  # constant darkness

            # Increment the time counter by the duration of the dark period
            duration = x[2]
            current_time += duration

        elseif code == :LL  # constant light

            if !isempty(events) && events[end, 2] == current_time
                # Extend an already existing ligt period
                events[end, 2] = current_time + x[2]
            else
                # Add a new light period
                events = [events; [current_time current_time + x[2]]]
            end

            # Increment the time counter the duration of the light period
            current_time += x[2]

        else  # unknown code
            error("Unknown code!")
        end
    end

    return events

end


"""
`plot_events(events; ax=gca(), ylims=[], color="#ffbfbfff", zorder=0)`

Plot events.
"""
function plot_events(events; ax=gca(), ylims=[], color="#ffbfbfff", zorder=0)

    if isempty(ylims)
        # Get ylims based on the plotted lines of the Axes

        lines = ax.get_lines()
        if isempty(lines)
            # If there are no lines, default ylims = [0, 1]
            B = 0.0
            T = 1.0
        else
            # If there are lines, ylims = [min(lines), max(lines)]
            B = Inf
            T = -Inf
            for line in lines
                y = line.get_ydata()
                B = min(B, minimum(y))
                T = max(T, maximum(y))
            end
        end
    else
        B = ylims[1]
        T = ylims[2]
    end

    n = size(events, 1)
    for i = 1:n
        # Print a box for each event
        L = events[i, 1]
        R = events[i, 2]
        ax.fill_between([L, R], [B, B], [T, T], linewidth=0.0, color=color,
            zorder=zorder)
    end

    return ax

end


"""
`estimate_period(t, x; kwargs...)`

Estimate period of a signal based on its autocorrelation function.

**Argument**
- `t`: Time vector.
- `x`: Data vector.

**Keyword Arguments**
- `n_lags`: Number of lags used for autocorrelation. Default is 1000.
- `show_plots`: Visualize the result. Default is false.

**Returns**
- `period`: Estimated period (the position of the highest).
- `peak`: Height of the highest peak.
"""
function estimate_period(t, x; n_lags=1000, show_plots=false)

    # If x is constat, return NaNs
    if all(x[1] .== x)
        return (NaN, NaN)
    end

    # Normalize input
    x = zscore(x)

    # Calculate autocorrelation
    n = min(n_lags, length(x))  # number of lags to calculate
    R = autocor(x, 0:(n-1))  # autocorrelation function

    # Find peaks of the autocorrelation function
    pr = findpeaks(R, (0:(n-1)) .* mean(diff(t)), sortstr="descend")

    # If there are no peaks, return NaNs
    if length(pr) == 0
        return (NaN, NaN)
    end

    # Get the highest peaks (peak height and location = period)
    peak = peakheights(pr)[1]
    period = peaklocations(pr)[1]

    # Visualize the results
    if show_plots
        fig, axs = subplots(2)
        axs[1].plot(t, x, color="black")
        axs[1].set_title("Time Series")
        axs[2].plot((0:(n-1)) .* mean(diff(t)), R, color="black")
        axs[2].plot([period, period], [0, peak], color="red")
        axs[2].set_title("peak = $(round(peak, digits=2)), " *
            "period = $(round(period, digits=2))")
        fig.tight_layout()
    end

    return (period, peak)

end
