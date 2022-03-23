using stoosc
rc("font", family="arial")


function params_prc_create_model!(params)

    println("Simulating reference ...")

    # Get input parameters
    parameter_names = params["parameter_names"]
    parameter_values = params["parameter_values"]
    trajectories = params["trajectories"]
    T = 1.0  # the model should have free running period 1
    n_pulses = params["n_pulses"]
    show_plots = params["show_plots"]
    model_name = params["model_name"]
    problem_type = params["problem_type"]
    i_variable = params["i_variable"]

    tend = 45.0  # final simulation time
    toffset = 25.0  # offset to remove the effect of initial conditions

    # Create a model
    model = load_model(model_name, problem_type)
    model = set_timespan(model, (0.0, tend))
    model = set_solver(model; saveat=0.01, maxiters=1e10)
    model = set_parameter_value(model, parameter_names, parameter_values)
    outfun = sol -> hcat(sol[i_variable, :])
    model = set_output(model, outfun)

    # Generate LD cycle for the whole tspan
    events = create_events([(:LD, tend/T + 1, T/2, T/2)])

    # Keep only 10 LD cycles after timepoint toffset
    idx = events[:, 1] .> toffset
    idx_first_event = findall(idx)[1]  # first event after toffset
    time_first_events = events[idx_first_event, 1]
    idx_last_event = idx_first_event + 9
    events = events[1:idx_last_event, :]  # remove tailing events to create DD

    # Add events to the model and run the simulation
    model = set_input(model, events)
    solution = simulate_population(model, trajectories, save_trajectories=false,
        show_progress=true)

    if show_plots
        _, ax = subplots(figsize=(6, 3))
        plot_solution(solution, ax=ax)
    end

    # Select solution from the first event after time toffset
    solution_selection = select_time(solution, mintime=time_first_events)
    events_selection = solution_selection.events
    
    # Find peaks in the selected solution
    t = solution_selection.time
    x = solution_selection.mean[:, 1]
    pr = findpeaks(x, t, npeaks=15, sortstr="descend", sortref="prominence")
    pr = sort(pr, ref="location")
    pks = peakheights(pr)
    locs = peaklocations(pr)
    
    # Calculate entrainment phase, free-running period, and pulse starts
    C0 = mean(locs[1:10] .- events_selection[:, 1])  # entrainment phase
    FRP = locs[13] - locs[12]  # free-running period
    # reference_location = locs[15]  # reference peak
    pulse_starts = range(locs[12] - C0, locs[13] - C0, length=n_pulses)
    reference_time = pulse_starts[end] + T

    idx = t .> reference_time
    xarr = [x[idx]]
    tarr = [t[idx]]

    # Plot the calculated properties for visual verification
    if show_plots
        _, ax = subplots(figsize=(6, 3))
        ax.plot(t, x, color="black")
        ax.plot(locs[1:10], pks[1:10], "o", color="blue")
        ax.plot(locs[12:13], pks[12:13], "o", color="red")
        for pulse_start in pulse_starts
            ax.vlines(pulse_start, minimum(x), maximum(x), color="blue")
        end
        ax.plot(tarr[1], xarr[1], color="green")
        ax.vlines(reference_time, minimum(x), maximum(x), color="green")
        plot_events(events_selection, ax=ax)
    end

    # Save important variables
    params["model"] = model
    params["events"] = events
    params["time_first_events"] = time_first_events
    params["entrainment_phase"] = C0
    params["free_running_period"] = FRP
    params["reference_time"] = reference_time
    params["pulse_starts"] = time_first_events .+ pulse_starts
    params["xarr"] = xarr
    params["tarr"] = tarr

end


function params_prc_estimate_pulse_responses!(params)

    println("Simulating pulse responses ...")

    T = 1.0  # params["ode_free_running_period"]
    pulse_legth = T / 2
    pulse_starts = params["pulse_starts"]
    events = params["events"]
    model = params["model"]
    time_first_events = params["time_first_events"]
    xarr = params["xarr"]
    tarr = params["tarr"]
    reference_time = params["reference_time"]
    trajectories = params["trajectories"]
    n_pulses = params["n_pulses"]
    show_plots = params["show_plots"]

    if show_plots
        _, axarr = subplots(n_pulses, figsize=(6, 4))
    end

    progressmeter = ProgressMeter.Progress(n_pulses; barlen=20)
    for i in 1:n_pulses

        pulse_start = pulse_starts[i]
        PRC_events = vcat(events, [pulse_start pulse_start + pulse_legth])
        PRC_model = set_input(model, PRC_events)

        success = false
        counter = 0
        solution = stoosc.PopulationSolution()
        while !success
            try
                solution = simulate_population(PRC_model, trajectories,
                    save_trajectories=false, show_progress=false)
                success = true
            catch err
                counter += 1
                if counter == 5
                    rethrow(err)
                else
                    @warn "[$counter] Simulation threw an error: $err"
                end
            end
            
        end
        
        
        # Select solution from the first event after time toffset
        solution_selection = select_time(solution, mintime=time_first_events)
        events_selection = solution_selection.events

        # Find peaks in the selected solution
        t = solution_selection.time
        x = solution_selection.mean[:, 1]

        idx = t .> reference_time
        push!(xarr, x[idx])
        push!(tarr, t[idx])

        ProgressMeter.next!(progressmeter)

        # Plot the calculated properties for visual verification        
        if show_plots
            axarr[i].plot(t, x, color="black")
            plot_events(events_selection, ax=axarr[i])
            axarr[i].plot(tarr[end], xarr[end], color="green")
            axarr[i].axis("off")
        end


    end

end


function params_prc_estimate_prc!(params)

    show_plots = params["show_plots"]
    tarr = params["tarr"]
    xarr = params["xarr"]
    free_running_period = 1.0
    pulse_starts = (params["pulse_starts"] .- params["pulse_starts"][1]) ./ free_running_period
    PRC = Float64[]
    
    n = length(tarr)
    tref = tarr[1]
    xref = xarr[1]
    Ts = mean(diff(tref))
    for i = 2:n

        R = crosscor(xarr[i], xref, ((1-length(tref)):(length(tref)-1)))
        lags = ((1-length(tref)):(length(tref)-1)).*Ts
        pr = findpeaks(R, lags)
        locs = peaklocations(pr)
        pks = peakheights(pr)
        idx = argmin(abs.(locs))
        pk = pks[idx]
        loc = locs[idx]
        push!(PRC, loc ./ free_running_period)

    end

    params["PRC"] = DataFrame([pulse_starts, PRC],
        ["time", "phase_shift"])

    if show_plots
        fig, ax = subplots()
        df = params["PRC"]
        ax.scatter(df[:, "time"], df[:, "phase_shift"])
    end

end


function params_prc_save_prc(params)

    PRC = params["PRC"]
    filename = params["filename"]
    save_data(PRC, filename)

end


params = Dict{String, Any}(
    "parameter_names" => ["d", "B", "τ", "I", "σ"],  # parameter names
    "parameter_values" => [-0.1, 1, 6.2, 3.5, 0.01],  # parameter values
    "trajectories" => 1000,  # number of oscillators in the population
    "n_pulses" => 30,  # number of pulses
    "model_name" => "model02",  # model01 or model02
    "problem_type" => "sde",  # ode or sde
    "i_variable" => 1,  # variable to estimate PRC
    "filename" => "test_prc.csv",  # save the PRC here
    "show_plots" => true  # visual control
)

params_prc_create_model!(params)
params_prc_estimate_pulse_responses!(params)
params_prc_estimate_prc!(params)
params_prc_save_prc(params)
