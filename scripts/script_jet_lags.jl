using stoosc
rc("font", family="arial")

function perform_simulation!(params)

    T = 1.0
    jet_lag = params["jet_lag"]
    trajectories = params["trajectories"]
    model_name = params["model_name"]
    problem_type = params["problem_type"]
    parameter_names = params["parameter_names"]
    parameter_values = params["parameter_values"]
    i_variable = params["i_variable"]

    model = load_model(model_name, problem_type)

    model = set_solver(model; saveat=0.01, maxiters=1e10)
    model = set_parameter_value(model, parameter_names, parameter_values)

    outfun = sol -> hcat(sol[i_variable, :])
    model = set_output(model, outfun)

    if jet_lag == "double day"
        events = create_events(
            [(:LD, 200, T/2, T/2), (:LD, 1, T, 0.5T), (:LD, 21, T/2, T/2)])
    elseif jet_lag == "double night"
        events = create_events(
            [(:LD, 200, T/2, T/2), (:LD, 1, 0.5T, T), (:LD, 21, T/2, T/2)])
    else
        throw("Unknown jet lag type")
    end

    tend = events[end] + T/2
    model = set_timespan(model, (0.0, tend))
    model = set_input(model, events)
    solution_arr = stoosc.PopulationSolution[]

    solution = simulate_population(model, trajectories, show_progress=true,
        save_trajectories=false)
    push!(solution_arr, solution)

    params["solution"] = solution

end


# Peak analysis ==============================================================
function analyze_peaks!(params)

    solution = params["solution"]
    T = 1.0
    show_plots = params["show_plots"]
    # saveplots = params["saveplots"]
    filename = params["filename"]
    period_offset = params["period_offset"]
        
    pr = findpeaks(solution.mean[:, 1], solution.time)
    peak_heights = peakheights(pr)
    peak_prominences = peakprominences(pr)
    peak_locations = peaklocations(pr)

    events = solution.events

    results = Dict(
        "pre_locs" => fill(NaN, 20),
        "pre_pks" => fill(NaN, 20),
        "pre_phases" => fill(NaN, 20),
        "post_locs" => fill(NaN, 20),
        "post_pks" => fill(NaN, 20),
        "post_phases" => fill(NaN, 20)
    )
        
    pre_counter = 0
    post_counter = 0

    for ievent = 2:size(events, 1)-1

        period_start = events[ievent, 1]
        period_end = events[ievent+1, 1]
        idx = (period_start + period_offset) .< peak_locations .<= (period_end + period_offset)
        if any(idx)

            idx_idx = argmax(peak_prominences[idx])
            peak_location = peak_locations[idx][idx_idx]
            peak_height = peak_heights[idx][idx_idx]  # peak_heights
            peak_phase = peak_location - period_start

            # if ievent > 30 && ievent <= 50
            if ievent > 180 && ievent <= 200
                pre_counter += 1
                results["pre_locs"][pre_counter] = peak_location
                results["pre_pks"][pre_counter] = peak_height
                results["pre_phases"][pre_counter] = peak_phase / T
            end

            # if ievent > 51 && ievent <= 71
            if ievent > 201 && ievent <= 221
                post_counter += 1
                results["post_locs"][post_counter] = peak_location
                results["post_pks"][post_counter] = peak_height
                results["post_phases"][post_counter] = peak_phase / T
            end

        end

    end

    if show_plots #|| saveplots
        fig, ax_arr = subplots(2, 1, figsize=(8, 2))

        ax = ax_arr[1]
        x = solution.mean[:, 1]
        t = solution.time
        idx = events[end]/2 .< t .< events[end]
        ax.plot(t, x, color="black")
        plot_events(solution.events, ax=ax)
        ax.plot(results["pre_locs"], results["pre_pks"], "o", color="blue")
        ax.plot(results["post_locs"], results["post_pks"], "o", color="red")
        ax.set_xlim(events[end]/2, events[end])
        ax.set_ylim(minimum(x[idx]), maximum(x[idx]))
        ax.set_title(filename[1:end-4])
        ax.set_xlabel("Time (au)")
        ax.set_ylabel("Conc. (au)")
        fig.tight_layout(pad=0.1)

        ax = ax_arr[2]
        ax.plot(mean(results["pre_phases"]) .- results["post_phases"])

        # if saveplots
        #     fullfilename = joinpath("hpc05", filename[1:end-4] * ".svg")
        #     savefigure(fig, fullfilename)    
        # end
    end

    params["peak_analysis"] = results

end

# Save the peak analysis =====================================================
function save_peak_analysis(params)

    peak_analysis = params["peak_analysis"]
    filename = params["filename"]

    df = DataFrame(peak_analysis)
    save_data(df, filename)

end

params = Dict{String, Any}(
    "show_plots" => true,  # visual control
    "model_name" => "model02",  # model01 or model02
    "problem_type" => "sde",  # ode or sde
    "i_variable" => 1,  # model variable to use to estimate jet lag
    "jet_lag" => "double day",
    "period_offset" => -0.25,  # window shift to search for peak
    "parameter_names" => ["I", "σ"],  # parameter names
    "parameter_values" => [0.5, 0.1],  # parameter values
    "trajectories" => 1000,  # number of oscillators in population
    "filename" => "test_jet_lag.csv"  # save here the jet lag results
)

perform_simulation!(params)
analyze_peaks!(params)
save_peak_analysis(params)
