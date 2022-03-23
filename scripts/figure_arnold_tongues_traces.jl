using stoosc
rc("font", family="arial")

## Gemeral settings
params = Dict(
    "I_max" => 0.3,
    "forcing_period_arr" => [0.85, 1.0, 1.15],
    "forcing_amplitude" => 0.1,
    "output_figure_folder" => "arnold_tongues_traces"
)

## Arnold tongues
function params_plot_arnold_tongue(params, problem_type; n=nothing, σ=nothing)

    I_max = params["I_max"]
    forcing_period_arr = params["forcing_period_arr"] 
    forcing_amplitude = params["forcing_amplitude"]
    output_figure_folder = params["output_figure_folder"]

    if problem_type == "ode"
        filename = "ode.csv"
    elseif problem_type == "sde"
        filename = "sde_n=$(n)_σ=$(σ).csv"
    end

    arnold_tongue = load_data("arnold_tongues", "model01", filename)
    entrainment_area_ode = estimate_entrainment_area(arnold_tongue, I_max)
    println("entrainment area = $(entrainment_area_ode)")
    
    fig, ax = subplots(figsize=(2.5, 2.25))
    plot_arnold_tongue(arnold_tongue, I_max, ax=ax)

    ax.plot(
        forcing_period_arr,
        fill(forcing_amplitude, length(forcing_period_arr)),
        "o",
        color="red"
    )

    ax.set_title(replace(filename, "_" => ", ", ".csv" => ""))
    fig.tight_layout()

    if !isnothing(output_figure_folder)
        figure_filename = "arnold_" * replace(filename, ".csv" => ".svg")
        save_figure(fig, output_figure_folder, figure_filename)
    end

end

params_plot_arnold_tongue(params, "ode")
params_plot_arnold_tongue(params, "sde"; n=10, σ=0.005)
params_plot_arnold_tongue(params, "sde"; n=1000, σ=0.005)

## Time traces
function params_plot_time_traces(params, problem_type; n=nothing, σ=nothing)

    forcing_amplitude = params["forcing_amplitude"]
    forcing_period_arr = params["forcing_period_arr"]
    output_figure_folder = params["output_figure_folder"]
    
    model_name = "model01"
    i_variable = 3

    if problem_type == "ode"
        parameter_names = ["A", "τ", "I"]
        parameter_values = [0.1, 3.66, forcing_amplitude]
        trajectories = 1
        figure_filename = "time_ode.svg"
    elseif problem_type == "sde"
        parameter_names = ["A", "τ", "I", "σ"]
        parameter_values = [0.1, 3.66, forcing_amplitude, σ]
        trajectories = n
        figure_filename = "time_sde_n=$(n)_σ=$(σ).svg"
    end
    
    model = load_model(model_name, problem_type)
    model = set_solver(model, saveat=0.01)
    model = set_timespan(model, (0.0, 200.0))
    outfun = sol -> hcat(sol[i_variable, :])
    model = set_output(model, outfun)
    model = set_parameter_value(model, parameter_names, parameter_values)

    fig, ax_arr = subplots(length(forcing_period_arr), figsize=(7, 5))
    for (i, forcing_period) = enumerate(forcing_period_arr)
        end_time = model.problem.tspan[end]
        nevents = end_time / forcing_period + 1
        events = create_events([(:DD, forcing_period*0.5),
            (:LD, nevents, forcing_period*0.5, forcing_period*0.5)])
        model = set_input(model, events, "I")

        solution = simulate_population(model, trajectories; save_trajectories=false,
            show_progress=true)

        solution = select_time(solution, mintime=end_time-10)
        t = solution.time
        m = solution.mean[:, 1]

        ax_arr[i].plot(t, m, color="black")
        plot_events(solution.events, ax=ax_arr[i])
        ax_arr[i].set_xlabel("Time")
        ax_arr[i].set_ylabel("Z")
        if problem_type == "ode"
            ax_arr[i].set_title("ode, I = $(forcing_amplitude), \
            T = $forcing_period", loc="left")
        elseif problem_type == "sde"
            ax_arr[i].set_title("sde, n = $(n), I = $(forcing_amplitude), \
            σ = $(σ), T = $forcing_period", loc="left")
        end
        ax_arr[i].set_xlim(0, 10)
        ax_arr[i].set_ylim(minimum(m), maximum(m))
    end

    fig.tight_layout()

    if !isnothing(output_figure_folder)
        save_figure(fig, output_figure_folder, figure_filename)
    end

end

params_plot_time_traces(params, "ode")
params_plot_time_traces(params, "sde", n=10, σ=0.005)
params_plot_time_traces(params, "sde", n=1000, σ=0.005)
