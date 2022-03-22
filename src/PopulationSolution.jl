"""
`PopulationSolution`

Solution for a population of solutions.

**Fields**
- `time`: Time vector (time steps).
- `mean`: Population mean over individual trajectories (time steps x variables).
- `trajectories`: Individual trajectories (time steps x variables x trajectories).
- `success`: True, if the integration was successful.

**Functions**
- `plot_solution`
- `select_time`
"""
struct PopulationSolution

    time::Vector
    mean::Matrix
    trajectories::Array
    events::Matrix
    success::Bool

    """
    Constructor if all fields are known.
    """
    function PopulationSolution(time::Vector, mean::Matrix, trajectories::Array, events::Matrix, success::Bool)
        new(time, mean, trajectories, events, success)
    end

    """
    Constructor if only mean is known but not the individual trajectories.
    """
    function PopulationSolution(time::Vector, mean::Matrix, events::Matrix, success::Bool)
        trajectories = Array{Float64, 3}(undef, 0, 0, 0)
        new(time, mean, trajectories, events, success)
    end

    """
    Constructor without parameters creates a solution for a failed simulation.
    """
    function PopulationSolution()
        empty_time = Vector{Float64}(undef, 0)
        empty_mean = Matrix{Float64}(undef, 0, 0)
        empty_trajectories = Array{Float64, 3}(undef, 0, 0, 0)
        empty_events = Matrix{Float64}(undef, 0, 2)
        new(empty_time, empty_mean, empty_trajectories, empty_events, false)
    end

end


"""
`plot_solution(solution::PopulationSolution; ax=gca())`

Plot a solution.

**Arguments**
- `solution`: PopulationSolution.

**Keyword Arguments**
- `ax`: Axes.
"""
function plot_solution(solution::PopulationSolution; ax=gca())


    ax.plot(solution.time, solution.mean, color="black")
    plot_events(solution.events, ax=ax)

    return ax

end


"""
`select_time`

Select a specific time from a solution.

**Arguments**
- `solution`: `PopulationSolution`.

**Keyword Arguments**
- `removeoffset`: If `true`, the first time point is set to 0.
- `offset`: Set offset (the first time point).
- `mintime`: Minimal time (inclusive).
- `maxtime`: Minimal time (exclusive).
"""
function select_time(solution::PopulationSolution; removeoffset=true, kwargs...)

    t = solution.time
    m = solution.mean
    U = solution.trajectories
    events = solution.events
    success = solution.success

    if (:mintime in keys(kwargs))
        
        # Remove samples before `mintime`
        mintime = kwargs[:mintime]
        indices = t .>= mintime
        t = t[indices]
        m = m[indices, :]
        if !isempty(U)
            U = U[indices, :, :]
        end

        # Remove events before `mintime`
        newevents = Matrix{Float64}(undef, 0, 2)
        for i = 1:size(events, 1)
            if events[i, 2] >= mintime
                if events[i, 1] >= mintime
                    newevents = vcat(newevents, events[i, :]')
                else
                    newevents = vcat(newevents, [t[1] events[i, 2]])
                end
            end 
        end
        events = newevents

    end

    if (:maxtime in keys(kwargs))

        # Remove samples after `maxtime`
        maxtime = kwargs[:maxtime]
        indices = t .< maxtime
        t = t[indices]
        m = m[indices, :]
        if !isempty(U)
            U = U[indices, :, :]
        end

        # Remove events after `maxtime`
        newevents = Matrix{Float64}(undef, 0, 2)
        for i = 1:size(events, 1)
            if events[i, 1] < maxtime
                if events[i, 2] < maxtime
                    newevents = vcat(newevents, events[i, :]')
                else
                    newevents = vcat(newevents, [events[i, 1] t[end]])
                end
            end 
        end
        events = newevents
    end

    if removeoffset
        # Set first timepoint to zero
        events .-= t[1]
        t .-= t[1]
    end

    if :offset in keys(kwargs)
        # Set first timepoint to offset
        offset = kwargs[:offset]
        events .+= offset .- t[1]
        t .+= offset .- t[1]
    end

    return PopulationSolution(t, m, U, events, success)

end
