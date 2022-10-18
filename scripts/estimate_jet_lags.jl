using DifferentialEquations
using DataFrames
using OscillatorPopulation
using Statistics
using PyPlot
rc("font", family="arial")


function params_create_events!(params)

    forcing_period = params["forcing_period"]
    jetlag_light = params["jetlag_light"]
    jetlag_total = params["jetlag_total"]
    show_debug_plots = params["show_debug_plots"]

    events = create_events_cycle(75, forcing_period)
    events_end = events[end, 2] + 0.5 * forcing_period
    index_events_before_jetlag_end = size(events, 1)
    index_events_after_jetlag_start = index_events_before_jetlag_end + 2

    events = vcat(
        events,
        [0.0 jetlag_light] .+ events_end,
        events .+ events_end .+ jetlag_total
    )

    if show_debug_plots
        _, ax = subplots()
        plot_events(events, ax=ax)
    end

    params["events"] = events
    params["index_events_before_jetlag_end"] = index_events_before_jetlag_end
    params["index_events_after_jetlag_start"] = index_events_after_jetlag_start

end

function params_simulate_model!(params)

    I = params["I"]
    σ = params["σ"]
    events = params["events"]
    show_debug_plots = params["show_debug_plots"]
    model_name = params["model_name"]
    default_parameters = params["default_parameters"]

    # Build model
    model = load_model(model_name, "sde")
    set_timespan!(model, 125.0)
    set_parameter!(model, default_parameters[1], default_parameters[2])
    set_parameter!(model, ["I", "σ"], [I, σ])
    set_input!(model, events)

    set_solver!(model, EM(); dt=0.001, saveat=0.01)

    # Simulate model
    solution = simulate_population(model, 1000, show_progress=true)

    if show_debug_plots
        _, ax = subplots()
        plot_solution(solution, ax=ax)
    end

    params["model"] = model
    params["solution"] = solution

end

function params_estimate_phase!(params)

    solution = params["solution"]
    index_events_before_jetlag_end = params["index_events_before_jetlag_end"]
    index_events_after_jetlag_start = params["index_events_after_jetlag_start"]
    n_periods_before_jetlag = params["n_periods_before_jetlag"]
    n_periods_after_jetlag = params["n_periods_after_jetlag"]
    show_debug_plots = params["show_debug_plots"]

    t = solution.time
    x = solution.mean[:, 1]
    U = solution.trajectories[:, 1, :]
    events = solution.events
    phase_array = estimate_phase_array(t, x, events; method="peak_height", smooth_span=10)
    phase_matrix = estimate_phase_array(t, U, events; method="peak_height", smooth_span=10)

    # Weird indexing: estimate_phase_array discards the first event
    index_before_jetlag = (index_events_before_jetlag_end-n_periods_before_jetlag):(index_events_before_jetlag_end-1)
    index_after_jetlag = (index_events_after_jetlag_start-1):(index_events_after_jetlag_start+n_periods_after_jetlag-2)

    phase_array_before_jetlag = phase_array[index_before_jetlag]
    phase_matrix_before_jetlag = phase_matrix[index_before_jetlag, :]
    phase_array_after_jetlag = phase_array[index_after_jetlag]
    phase_matrix_after_jetlag = phase_matrix[index_after_jetlag, :]

    # Check that indexing fits
    if show_debug_plots
        _, ax = subplots()
        ax.plot(1:length(phase_array), phase_array, "ko", label="Mean phase")
        ax.plot(index_before_jetlag, phase_array_before_jetlag, "bo", label="Before jetlag")
        ax.plot(index_after_jetlag, phase_array_after_jetlag, "ro", label="After jetlag")
        ax.legend()
    end

    params["phase_array_before_jetlag"] = phase_array_before_jetlag
    params["phase_matrix_before_jetlag"] = phase_matrix_before_jetlag
    params["phase_array_after_jetlag"] = phase_array_after_jetlag
    params["phase_matrix_after_jetlag"] = phase_matrix_after_jetlag

end

function params_plot_jetlag(params; ax=gca())

    phase_array_before_jetlag = params["phase_array_before_jetlag"]
    phase_matrix_before_jetlag = params["phase_matrix_before_jetlag"]
    phase_array_after_jetlag = params["phase_array_after_jetlag"]
    phase_matrix_after_jetlag = params["phase_matrix_after_jetlag"]
    n_periods_before_jetlag = params["n_periods_before_jetlag"]
    n_periods_after_jetlag = params["n_periods_after_jetlag"]
    σ = params["σ"]

    N = length(phase_array_before_jetlag)
    for i = 1:n_periods_before_jetlag
        local x
        x = phase_matrix_before_jetlag[N-(i-1), :]
        m = phase_array_before_jetlag[N-(i-1)]
        ax.plot(x, fill(-i, 1000), "ko", alpha=0.01, rasterized=true)
        ax.plot(m, -i, "ro", zorder=1000)
    end
    for i = 1:n_periods_after_jetlag
        local x
        x = phase_matrix_after_jetlag[i, :]
        m = phase_array_after_jetlag[i]
        ax.plot(x, fill(i, 1000), "ko", alpha=0.01, rasterized=true)
        ax.plot(m, i, "ro", zorder=1000)
    end
    ax.set_xlim(0, 1)
    ax.set_ylim(- (n_periods_before_jetlag+0.5), n_periods_after_jetlag+0.5)

    L = 0
    R = 0.5
    B = - (n_periods_before_jetlag + 0.5)
    T = n_periods_after_jetlag + 0.5
    color="#ffbfbfff"
    zorder=0
    ax.fill_between([L, R], [B, B], [T, T], linewidth=0.0, color=color,
        zorder=zorder)
    L = 0
    R = 1
    B = -0.5
    T = 0.5
    ax.fill_between([L, R], [B, B], [T, T], linewidth=0.0, color="red",
        zorder=zorder)

    ax.set_xlabel("Phase", labelpad=0)
    ax.set_ylabel("Days", labelpad=0)
    ax.set_title("σ = $(σ)", pad=0, loc="left")

end

## Kim-Forger model ===========================================================
params = Dict{String, Any}(
    "model_name" => "kim-forger",
    "default_parameters" => (["A", "τ"], [0.1, 3.66]),
    "I" => 0.03,
    "σ" => 0.01,
    "forcing_period" => 1.0,
    "jetlag_light" => 1.0,
    "jetlag_total" => 1.5,
    "n_periods_before_jetlag" => 5,
    "n_periods_after_jetlag" => 20,
    "show_debug_plots" => false
)

I_array = [0.005, 0.015, 0.03]
σ_array = [0.001, 0.008, 0.015, 0.03]

for I = I_array
    for σ = σ_array
        
        params["I"] = I
        params["σ"] = σ

        params_create_events!(params)
        phase_array_before_jetlag_array = []
        phase_array_after_jetlag_array = []
        
        df = DataFrame(
                "day" => vcat(
                    -params["n_periods_before_jetlag"]:-1,
                    1:params["n_periods_after_jetlag"]
                )
            )

        for j = 1:10
            println("I=$(I)_σ=$(σ)_r=$(j)")
            params_simulate_model!(params)
            params_estimate_phase!(params)

            x1 = params["phase_array_before_jetlag"]
            x2 = params["phase_array_after_jetlag"]

            df[:, "r$(j)"] = vcat(x1, x2) .- cmean(x1)
        end

        save_data(df, "./outputs/jet_lags/kim_forger/I=$(I)_σ=$(σ).csv")

    end
end

## Van der Pol limit cycle ====================================================
params = Dict{String, Any}(
    "model_name" => "van-der-pol",
    "default_parameters" => (["B", "d", "τ"], [10.0, 2.0, 7.63]),
    "I" => 0.03,
    "σ" => 0.01,
    "forcing_period" => 1.0,
    "jetlag_light" => 1.0,
    "jetlag_total" => 1.5,
    "n_periods_before_jetlag" => 5,
    "n_periods_after_jetlag" => 20,
    "show_debug_plots" => false
)

I_array = [0.05]
σ_array = [0.001, 0.06, 0.08, 0.1]  # get sigma from the previous paper

for I = I_array
    for σ = σ_array
        
        params["I"] = I
        params["σ"] = σ

        params_create_events!(params)
        phase_array_before_jetlag_array = []
        phase_array_after_jetlag_array = []
        
        df = DataFrame(
                "day" => vcat(
                    -params["n_periods_before_jetlag"]:-1,
                    1:params["n_periods_after_jetlag"]
                )
            )

        for j = 1:10
            println("I=$(I)_σ=$(σ)_r=$(j)")
            params_simulate_model!(params)
            params_estimate_phase!(params)

            x1 = params["phase_array_before_jetlag"]
            x2 = params["phase_array_after_jetlag"]

            df[:, "r$(j)"] = vcat(x1, x2) .- cmean(x1)
        end

        save_data(df, "./outputs/jet_lags/van_der_pol_limit_cycle/I=$(I)_σ=$(σ).csv")

    end
end


## Van der Pol noise-induced ==================================================
params = Dict{String, Any}(
    "model_name" => "van-der-pol",
    "default_parameters" => (["B", "d", "τ"], [1.0, -0.1, 6.2]),
    "I" => 0.03,
    "σ" => 0.01,
    "forcing_period" => 1.0,
    "jetlag_light" => 1.0,
    "jetlag_total" => 1.5,
    "n_periods_before_jetlag" => 5,
    "n_periods_after_jetlag" => 20,
    "show_debug_plots" => false
)

I_array = [0.05]
σ_array = [0.001, 0.06, 0.08, 0.1]

for I = I_array
    for σ = σ_array
        
        params["I"] = I
        params["σ"] = σ

        params_create_events!(params)
        phase_array_before_jetlag_array = []
        phase_array_after_jetlag_array = []
        
        df = DataFrame(
                "day" => vcat(
                    -params["n_periods_before_jetlag"]:-1,
                    1:params["n_periods_after_jetlag"]
                )
            )

        for j = 1:10
            println("I=$(I)_σ=$(σ)_r=$(j)")
            params_simulate_model!(params)
            params_estimate_phase!(params)

            x1 = params["phase_array_before_jetlag"]
            x2 = params["phase_array_after_jetlag"]

            df[:, "r$(j)"] = vcat(x1, x2) .- cmean(x1)
        end

        save_data(df, "./outputs/jet_lags/van_der_pol_noise_induced/I=$(I)_σ=$(σ).csv")

    end
end

## Amplitude-phase model ======================================================
params = Dict{String, Any}(
    "model_name" => "amplitude-phase",
    "default_parameters" => (["λ", "A", "T", "I"], [1.0, 1.0, 1.0, 0.0]),
    "I" => 3.0,
    "σ" => 0.1,
    "forcing_period" => 1.0,
    "jetlag_light" => 0.9,
    "jetlag_total" => 1.4,
    "n_periods_before_jetlag" => 5,
    "n_periods_after_jetlag" => 20,
    "show_debug_plots" => false
)

I_array = [0.3]
σ_array = [0.4]  #1.0, 0.5, 0.3, 0.2, 0.1, 0.05, 0.03, 0.02, 0.01]

for I = I_array
    for σ = σ_array
        
        params["I"] = I
        params["σ"] = σ

        params_create_events!(params)
        phase_array_before_jetlag_array = []
        phase_array_after_jetlag_array = []
        
        df = DataFrame(
                "day" => vcat(
                    -params["n_periods_before_jetlag"]:-1,
                    1:params["n_periods_after_jetlag"]
                )
            )

        for j = 1:10
            println("I=$(I)_σ=$(σ)_r=$(j)")
            params_simulate_model!(params)
            params_estimate_phase!(params)

            x1 = params["phase_array_before_jetlag"]
            x2 = params["phase_array_after_jetlag"]

            df[:, "r$(j)"] = vcat(x1, x2) .- cmean(x1)
        end

        save_data(df, "./outputs/jet_lags/amplitude_phase/I=$(I)_σ=$(σ).csv")

    end
end
