"""
`Model`

A struct representing a model.

**Fields**
- `variable_names`: Variable names (e.g. `["X", "Y", "Z"]`).
- `parameter_names`: Parameter names (e.g. `["v", "d1", "d2"]`).
- `problem`: `ODEProblem` or `SDEProblem` or `JumpProblem`.
- `solver_algorithm`: Solver used to solve the `problem`` (e.g. `SOSRI()`).
- `solver_parameters`: Parameters passed to the solver (e,g, `(saveat=0.1,)`)
- `input`: Input to the model representedas a tuple with two elements. The first
    element is a matrix representing the input events and the second element is
    a string that specifies, which parameter is manipulated by the events.
- `output`: Function that transforms `DifferentialEqualtions` solution
    into a matrix. Rows are time steps and columns are variables.

**Functions**
- `set_initial_conditions`
- `set_timespan`
- `create_model`
- `set_solver`
- `get_parameter_index`
- `get_parameter_value`
- `set_parameter_value`
- `set_input`
- `simulate_population`
"""
struct Model
    variable_names::Vector{String}
    parameter_names::Vector{String}
    problem::Union{ODEProblem, SDEProblem, JumpProblem}
    solver_algorithm::Any
    solver_parameters::NamedTuple
    input::Tuple{Matrix{Float64}, String}
    output::Function
end


"""
`_set_model_property(model::Model; kwargs...)`

Create a new copy of `model` with replaced fields as specified by the keyword
    arguments.
"""
function _set_model_property(model::Model; kwargs...)

    # Iterate all possible fields of Model struct
    fields = []
    for field in fieldnames(Model)

        # If the field is in kwargs, use it, otherwise use the original value
        if field in keys(kwargs)
            push!(fields, deepcopy(kwargs[field]))
        else
            push!(fields, deepcopy(getproperty(model, field)))
        end

    end

    # Create a model with new fields
    return Model(fields...)

end


function _get_problem_property(problem, property_name)

    # Property name must be a symbol
    property_name = Symbol(property_name)

    # For JumpProblem access problem.prob, otherwise problem directly
    if problem isa JumpProblem
        property = getproperty(problem.prob, property_name)
    else
        property = getproperty(problem, property_name)
    end

    # Return the found property
    return property

end


function _get_problem_property(model::Model, property_name)

    return _get_problem_property(model.problem, property_name)

end


function _set_problem_property(model::Model; kwargs...)

    # Remake problem with the new properties
    new_problem = remake(model.problem; kwargs...)

    # Replace the problem in the model
    new_model = _set_model_property(model, problem=new_problem)
    
    return new_model
end


"""
`set_initial_conditions(model::Model, u0)`

Set initial conditions for a model.
"""
function set_initial_conditions(model::Model, u0)
    return _set_problem_property(model; u0=u0)
end


"""
`set_timespan(model::Model, tspan)`

Set timespan for a model.
"""
function set_timespan(model::Model, tspan)
    return _set_problem_property(model; tspan=tspan)
end


function set_output(model::Model, output)
    return _set_model_property(model; output=output)
end


"""
`create_model`

Create a model based on the `DifferentialEqualtions` problem.

**Arguments**
- `variable_names`: Variable names (e.g. `["X", "Y", "Z"]`).
- `parameter_names`: Parameter names (e.g. `["v", "d1", "d2"]`).
- `problem`: `ODEProblem` or `SDEProblem` or `JumpProblem`.

**Returns**
- `model`: Model represented as a `Model` struct.
"""
function create_model(variable_names, parameter_names, problem)

    # Check that variable names match the length of the initial state
    u0 = _get_problem_property(problem, "u0")
    if length(variable_names) != length(u0)
        error("Incorrect number of variable names!")
    end

    # Check that parameter names match the length of the parameter vector
    p = _get_problem_property(problem, "p")
    if length(parameter_names) != length(p)
        error("Incorrect number of parameter names!")
    end

    # Set up a default algorithm based on the problem type
    if problem isa ODEProblem
        solver_algorithm = Tsit5()
    elseif problem isa SDEProblem
        solver_algorithm = SOSRI()
    elseif problem isa JumpProblem
        solver_algorithm = SSAStepper()
    else
        error("Unknown problem type!")
    end

    # Set up the other default parameters the do not depend on the problem type
    solver_parameters = (saveat=0.1,)
    input = (Matrix{Float64}(undef, 0, 0), "")
    output = sol -> Matrix(sol[:, :]')

    # Create the Model struct
    model = Model(
        variable_names,
        parameter_names,
        problem,
        solver_algorithm,
        solver_parameters,
        input,
        output
    )

    return model
    
end


"""
`set_solver(model::Model, algorithm=nothing; merge_kwargs=true, kwargs...)`

Set solver algorithm and its properties.

**Arguments**
- `model`: Model.

**Optional Arguments**
- `algorithm`: Solver algorithm (e.g. `Tsit5()` or `SOSRI()`).

**Keyword Arguments**
- `merge_kwargs`: If `false`, the original arguments are deleted.
- `kwargs...`: Solver parameters.

**Returns**
- `new_model`: Model with updated solver algorithm and parameters.
"""
function set_solver(model::Model, algorithm=nothing; merge_kwargs=true, kwargs...)
 
    if :callback in keys(kwargs)
        error("Callback is reserved for the input function!")
    end

    if isnothing(algorithm)
        # If the algorithm was not specified, use to original one
        solver_algorithm = model.solver_algorithm
    else
        # If the algorithm was specified, use the new one
        solver_algorithm = algorithm
    end

    if length(kwargs) > 0
        # If any kwargs were passed, add them to the solver_parameters

        if merge_kwargs
            # Merge kwargs with the existing parameters
            solver_parameters = merge(model.solver_parameters, NamedTuple(kwargs))
        else
            # Replace the old parameters with the new ones
            if :callback in keys(model.solver_parameters)
                # Preserve callback
                callback = model.solver_parameters[:callback]
                solver_parameters = merge(NamedTuple(kwargs), (callback=callback,))
            else
                solver_parameters = NamedTuple(kwargs)
            end
        end

    else
        # If no kwargs were passed, just copy the original ones
        solver_parameters = model.solver_parameters

    end

    # Build a new model
    new_model = _set_model_property(model; solver_algorithm=solver_algorithm,
        solver_parameters=solver_parameters)

    return new_model

end


"""
Set callback to the solver parameters.
"""
function _set_callback(model::Model, callback)

    # Merge callback with existing solver parameters
    solver_parameters = merge(model.solver_parameters, (callback=callback,))

    # Build a new model
    new_model = _set_model_property(model; solver_parameters=solver_parameters)

    return new_model

end


"""
`get_parameter_index(model::Model, parameter_name::String)`

Find index of the specified parameter.

**Arguments**
- `model`: Model.
- `parameter_name`: Name of the parameter.

**Returns**
- `index`: Index indicating the position of the parameter.
"""
function get_parameter_index(model::Model, parameter_name::String)

    parameter_names = model.parameter_names
    index = findfirst(parameter_names .== parameter_name)
    if isnothing(index)
        error("Parameter '$(parameter_name)' is not in the model!")
    end
    return index

end


"""
`get_parameter_value(model::Model, parameter_name::String)`

Get a parameter value.

**Arguments**
- `model`: Model.
- `parameter_name`: Name of the parameter.

**Returns**
- `parameter_value`: Value of the parameter.
"""
function get_parameter_value(model::Model, parameter_name::String)
    
    index = get_parameter_index(model, parameter_name)
    parameter_values = _get_problem_property(model, "p")
    return parameter_values[index]

end


"""
`set_parameter_value(model::Model, name::String, value::Number)`

Set a parameter value.

**Arguments**
- `model`: Model.
- `name`: Name of the parameter. Can also be in the form of "d1=d2=d3", which
    sets all parameters d1, d2, and d3 to the same value.
- `value`: New value for the parameter.

**Returns**
- `new_model`: Copy of `model` with updated parameter value.
"""
function set_parameter_value(model::Model, name::String, value::Number)

    # Get array of parameter values
    parameter_values = _get_problem_property(model, "p")

    if occursin("=", name)
        # If "=" occurs in `name`, split the string into individual parameters
        name_array = String.(split(name, "="))
        for name_split in name_array
            # Set each parameter to `value`
            index = get_parameter_index(model, name_split)
            parameter_values[index] = value
        end
    else
        # Set the desired parameter to `value`
        index = get_parameter_index(model, name)
        parameter_values[index] = value
    end

    # Rebuild the model with the new parameter value
    new_model = _set_problem_property(model, p=parameter_values)
    return new_model

end


"""
`model::Model, name_array::Array, value_array::Array`

Set parameter values.

**Arguments**
- `model`: Model.
- `name_array`: Parameter names. Can also be in the form of "d1=d2=d3", which
    sets all parameters d1, d2, and d3 to the same value.
- `value_array`: New values for the parameters.

**Returns**
- `new_model`: Copy of `model` with updated parameter values.
"""
function set_parameter_value(model::Model, name_array::Array, value_array::Array)

    # The input arrays must have the same length
    if length(name_array) != length(value_array)
        error("The array of parameter names and values must have the same length!")
    end

    # Set the parameters
    new_model = deepcopy(model)
    for (name, value) in zip(name_array, value_array)
        new_model = set_parameter_value(new_model, name, value)
    end

    return new_model

end


"""
`_create_callback(events::Matrix, i)`

Generate `PresetTimeCallback` from `events` modyfing `i`-th parameter.
"""
function _create_callback(events::Matrix, i)

    p = NaN  # holds the original value of the parameter

    # Initialization at the beginning of the integration
    initialize = function (c, u, t, integrator)

        # Protect the original parameters from overwriting
        integrator.p = copy(integrator.p) 

        # Save the default parameter
        p = integrator.p[i]

        # Set the parameter to 0
        integrator.p[i] = 0.0

    end

    # Set the parameter to its default value at the beginning of the event
    tstops_on = events[:, 1]
    affect_on! = (integrator) -> integrator.p[i] = p
    callback_on = PresetTimeCallback(tstops_on, affect_on!,
        save_positions=(false, false), initialize=initialize)

    # Set the parameter to zero at the end of the event
    tstops_off = events[:, 2]
    affect_off! = (integrator) -> integrator.p[i] = 0.0
    callback_off = PresetTimeCallback(tstops_off, affect_off!,
        save_positions=(false, false))

    return CallbackSet(callback_on, callback_off)

end


"""
`_events_to_function(events::Matrix)`

Convert `events` to a function.
"""
function _events_to_function(events::Matrix)
    N = size(events, 1)
    function fun(t)
        for i = 1:N
            if events[i, 1] <= t < events[i, 2]
                return 1.0
            end
        end
        return 0.0
    end
    return fun
end


"""
`_create_discrete_callback(events::Matrix, i)`

Generate `DiscreteCallback` from `events` modyfing `i`-th parameter.
"""
function _create_discrete_callback(events::Matrix, i)

    p = NaN  # holds the original value of the parameter

    # Initialization at the beginning of the integration
    initialize = function (c, u, t, integrator)

        # Protect the original parameters from overwriting
        integrator.p = copy(integrator.p) 

        # Save the default parameter
        p = integrator.p[i]

        # Set the parameter to 0
        integrator.p[i] = 0.0

    end

    # Convert the events to a function
    fun = _events_to_function(events)

    # Call the function at every step of the integration
    affect! = (integrator) -> integrator.p[i] = fun(integrator.t)*p
    condition = (u, t, integrator) -> true
    callback = DiscreteCallback(condition, affect!; initialize=initialize,
        save_positions=(false, false))

    return callback

end


"""
`set_input(model::Model, events::Matrix, parameter_name="I")`

Set input to the model.

**Arguments**
- `model`: Model.
- `events`: Matrix representing the input square function.
- `parameter_name`: Parameter that is being modified by the input.
"""
function set_input(model::Model, events::Matrix, parameter_name="I")

    parameter_index = get_parameter_index(model, parameter_name)

    # Create a callback
    if model.problem isa Union{ODEProblem, SDEProblem}
        # Use PresetTimeCallback for ODE and SDE models
        callback = _create_callback(events, parameter_index)
    elseif model.problem isa JumpProblem
        # Use DiscreteCallback for Jump models
        callback = _create_discrete_callback(events, parameter_index)
    end

    # Build a new model with the specified input
    new_model = _set_callback(model, callback)
    new_model = _set_model_property(new_model, input=(events, parameter_name))

    return new_model

end


"""
`simulate_population(model::Model, trajectories=1; save_trajectories=true,
    show_progress=false)`

Simulate a population.

**Arguments**
- `model`: Model.

**Optional Arguments**
- `trajectories`: Number of trajectories to simulate.

**Keyword Arguments**
- `save_trajectories`: If `false`, only mean is saved.
- `show_progress`: If `true`, show a progress bar in the terminal.
"""
function simulate_population(model::Model, trajectories=1;
    save_trajectories=true, show_progress=false)

    # Make sure that the original model is not modified
    model = deepcopy(model)

    # Prepare variables for PopulationSolution fields
    t = Vector{Float64}(undef, 0)  # time
    m = Matrix{Float64}(undef, 0, 0)  # mean
    U = Array{Float64, 3}(undef, 0, 0, 0)  # trajectories
    events = model.input[1]  # events
    
    # Initialize the porgress meter
    if show_progress
        progress_meter = ProgressMeter.Progress(trajectories; barlen=20)
    end

    # Simulate trajectories
    success_arr = fill(false, trajectories)  # success for individual trajectories
    lk = ReentrantLock()
    Threads.@threads for i = 1:trajectories

        model2 = deepcopy(model)

        # Solve the problem
        sol2 = solve(model2.problem, model2.solver_algorithm; model2.solver_parameters...)

        # Check if the simulation was successful
        if model2.problem isa Union{ODEProblem, SDEProblem}
            success_arr[i] = sol2.retcode == :Success
        elseif model2.problem isa JumpProblem
            success_arr[i] = sol2.retcode == :Default
        else
            error("Unknown model type!")
        end

        # Save the solution if the current simulation was successful
        if success_arr[i]

            lock(lk) do

                # Save time
                if isempty(t)
                    t = sol2.t
                end

                # Map solution to a matrix
                x = model2.output(sol2)

                # Add the trajectory contribution to the mean
                if isempty(m)
                    # Initialize the mean vector
                    m = (x ./ trajectories)
                else
                    # Add solution to the mean vector
                    m .+= (x ./ trajectories)
                end

                # Save the individual trajectory
                if save_trajectories
                    if isempty(U)
                        # Initialize the matrix for individual trajectories
                        nsamples = size(x, 1)
                        nvariables = size(x, 2)
                        U = fill(NaN, nsamples, nvariables, trajectories)
                    end
                    # Add the current trajectory to the trajectory list
                    U[:, :, i] = x
                end

            end

        else
            # Stop the simulation if the current simulation was unsuccessful
            break
        end

        if show_progress
            lock(lk) do
                ProgressMeter.next!(progress_meter)
            end
        end

    end

    # Build the output struct
    success = all(success_arr)
    solution = PopulationSolution(t, m, U, events, success)

    return solution

end


"""
`scan`

Scan parameters of a model.

**Arguments**
- `model`: Model.
- `parameter_names`: Parameter names to scan.
- `parameter_values`: Parameter values for each parameter to scan over.
- `summary_function`: A function that takes in a model, evaluates it, and
    returns some parameters. If the function is called without any arguments,
    it returns the names of the parameters as a vector of strings. For example
    ```
    julia> summary_function(model)
    [1.1, 2.2, 3.3]
    julia> summary_function()
    ["Period", "Amplitude", "Phase"]
    ```

**Keyword Arguments**
- `show_progress`: If `true`, show a progress bar in the terminal.

**Returns**
- `df`: Dataframe with results.
"""
function scan(model::Model, parameter_names, parameter_values,
    summary_function; show_progress=false)

    # Protect the original model from overwriting
    model = deepcopy(model)

    # Find all possible parameter combinations
    parameter_value_combinations = find_all_combinations(parameter_values)
    n = size(parameter_value_combinations, 1)
    
    # Initialize summary matrix
    summary_names = summary_function()
    scan_summary = fill(NaN, n, length(summary_names))

    # Initialize progress bar
    if show_progress
        progressmeter = ProgressMeter.Progress(n; barlen=20)
    end

    # Iterate all parameter value combinations
    lk = ReentrantLock()
    Threads.@threads for i = 1:n

        # Set model parameters
        pmodel = set_parameter_value(model, parameter_names, parameter_value_combinations[i, :])

        # Evaluate the sumary function
        pmodel_summary = summary_function(pmodel)

        # Save the model summary to the overall matrix
        scan_summary[i, :] = pmodel_summary

        # Update progress bar
        if show_progress
            lock(lk) do
                ProgressMeter.next!(progressmeter)
            end
        end

    end

    # Build the output dataframe
    matrix = hcat(parameter_value_combinations, scan_summary)
    names = vcat(parameter_names, summary_names)
    df = DataFrame(matrix, names)

    return df

end


"""
`estimate_binary_arnold_tongue`

Use binary search to estimate arnold tongue for a model.

**Arguments**
- `model`: Model.
- `periods`: A two-element array like `[minimal_period, maximal_period]`.
- `amplitudes`: Input amplitudes to scan.

**Keyword Arguments**
- `trajectories`: Number of trajectories in a population.
- `i_solution`: Number of the state to use to estimate the period.
- `n_lags`: Number of lags used to estimate the autocorrelation functions.
- `input_parameter_name`: Name of the parameter that control the input amplitude.
- `min_time`: Minimal time to consider (to remove the effect of initial conditions).
- `max_time`: Maximal time of the simulation.
- `show_progress`: If true, show a progress bar in the terminal.
- `period_error`: Maximal allowed output period deviation from the input period.
- `boundary_error`: Maximal allowed error to estimate the boundary between the
    entrained and unentrained regions.
- `maximal_error_attempts`: How many attempts should be given to an errored simulation.
"""
function estimate_binary_arnold_tongue(model::Model, periods, amplitudes;
    trajectories=1, i_solution=1, n_lags=1000, input_parameter_name="I",
    min_time=nothing, max_time=nothing, show_progress=false, period_error=0.01,
    boundary_error=0.01, maximal_error_attempts=0)

    # Protect the original model from overwriting
    model = deepcopy(model)

    # Set the maximal time of the simulation
    if !isnothing(max_time)
        model = set_timespan(model, (0.0, max_time))
    end

    # Get minimal and maximal amplitude and the number of periods to scan
    minimal_amplitude = amplitudes[1]
    maximal_amplitude = amplitudes[end]
    n_periods = length(periods)

    # Each element is the minimal amplitude of entrainment for the given period
    entrainment_amplitudes = fill(NaN, n_periods)
    
    # Initialize a progress bar
    if show_progress
        progressmeter = ProgressMeter.Progress(n_periods; barlen=20)
    end

    # Iterate all period-amplitude combinations
    lk = ReentrantLock()
    Threads.@threads for i = 1:n_periods  # Threads.@threads 

        # Set the forcing (input) period
        forcing_period = periods[i]
        
        # Create events for the current forcing period
        if model.problem isa JumpProblem
            end_time = model.problem.prob.tspan[2]
        else
            end_time = model.problem.tspan[2]
        end
        nevents = end_time / forcing_period + 1
        events = create_events([(:DD, forcing_period*0.5),
            (:LD, nevents, forcing_period*0.5, forcing_period*0.5)])
        
        # Set offset (solution before this time is discarted)
        if isnothing(min_time)
            offset = end_time*0.5
        else
            offset = min_time
        end
        
        # pmodel = deepcopy(model)
        pmodel = set_input(model, events, input_parameter_name)
        
        """
        This function will be optimized using the binary boundary search. It
        simulates the model for the given forcing amplitude and returns `true`
        if the model is entrained and `false` if the model is unentrained.
        """
        function fun(forcing_amplitude)
        
            # Set the forcing amplitude and events to the model
            pmodel = set_parameter_value(pmodel, input_parameter_name, forcing_amplitude)

            # Simulate the population
            solution = PopulationSolution()
            success = false
            counter = 0
            while !success
                try
                    # lock(lk) do
                    solution = simulate_population(pmodel, trajectories;
                        save_trajectories=false)
                    # end
                    success = true
                catch err
                    counter += 1
                    if counter >= maximal_error_attempts
                        @warn "[LAST] Simulation threw an error: $err"
                        solution = PopulationSolution()
                        success = true
                    else
                        @warn "[$counter] Simulation threw an error: $err"
                    end
                end 
            end

            # If the simulation was successful, estimate the period
            if solution.success
                
                # Discard the simulation start
                solution = select_time(solution, mintime=offset)
                t = solution.time
                m = solution.mean[:, i_solution]
    
                R_period, _ = estimate_period(t, m; n_lags=n_lags)
                
                return abs(R_period - forcing_period) <= period_error

            else

                return false

            end

        end

        # Perform binary search
        entrainment_amplitudes[i] = binary_boundary_search(fun,
            [minimal_amplitude, maximal_amplitude], boundary_error)

        # Update the progress bar
        if show_progress
            ProgressMeter.next!(progressmeter)
        end

    end

    # Create the output dataframe
    arnold_tongue = DataFrame(periods=periods, amplitudes=entrainment_amplitudes)
    
    return arnold_tongue

end
