using stoosc
rc("font", family="arial")


function params_create_model!(params)

    parameter_names = params["parameter_names"]  # Ω must be last!
    parameter_values = params["parameter_values"]
    problem_type = params["problem_type"]
    model_name = params["model_name"]

    # Set up an SDE model
    model = load_model(model_name, problem_type)
    model = set_solver(model, saveat=0.01)
    model = set_timespan(model, (0.0, 200.0))
    model = set_parameter_value(model, parameter_names, parameter_values)
    if problem_type == "jump"
        outfun = sol -> hcat(sol[2, :], sol[3, :]) ./ parameter_values[end]
    else
        outfun = sol -> hcat(sol[2, :], sol[3, :])  # save only Y and Z
    end
    model = set_output(model, outfun)

    # Add events
    events = create_events([(:LD, 200 + 1, 0.5, 0.5)])
    model = set_input(model, events)
    
    params["model"] = model

end

function params_simulate_model!(params)

    model = params["model"]
    trajectories = params["trajectories"]

    solution = simulate_population(model, trajectories, show_progress=true)
    solution = select_time(solution, mintime=100.0)
    t = solution.time
    Y = reshape(solution.trajectories[:, 1, :],
        length(solution.trajectories[:, 1, 1])*trajectories, 1)[:, 1]
    Z = reshape(solution.trajectories[:, 2, :],
        length(solution.trajectories[:, 2, 1])*trajectories, 1)[:, 1]
    
    params["t"] = t
    params["Y"] = Y
    params["Z"] = Z

end

function params_create_figure(params)

    t = params["t"]
    Y = params["Y"]
    Z = params["Z"]
    plot_range = params["plot_range"]
    filename = params["filename"]
    histogram_bins = params["histogram_bins"]
    phase_plane_title = params["phase_plane_title"]
    
    fig, ax = subplots(figsize=(4.5, 2.5))
    ax.plot(t, Z[1:length(t)], color="black")
    ax.set_ylim(plot_range[2][1], plot_range[2][2])
    ax.set_xlim(0, 50)
    ax.set_title("Time series")
    ax.set_xlabel("Time")
    ax.set_ylabel("Z")
    fig.tight_layout(pad=0.1)
    
    if !isnothing(filename)
        time_filename = filename[1:end-4] * "_time" * filename[end-3:end]
        save_figure(fig, "sde_vs_jump", time_filename)
    end

    fig, ax = subplots(figsize=(3, 3))
    h = ax.hist2d(Y, Z, bins=histogram_bins, density=true, range=plot_range,
        rasterized=true)
    if isnothing(phase_plane_title)
        ax.set_title("Phase-plane histogram")
    else
        ax.set_title(phase_plane_title)
    end
    ax.set_xlabel("Y")
    ax.set_ylabel("Z")
    fig.tight_layout(pad=0.1)
    
    if !isnothing(filename)
        save_figure(fig, "sde_vs_jump", filename)
    end

end

params = Dict{String, Any}(
    "trajectories" => 100,
    "model_name" => "model01",
    "parameter_names" => ["I", "Ω"],
    "parameter_values" => [0, 1/0.01^2],
    "problem_type" => "jump",  # sde or jump
    "histogram_bins" => 25, # 25,
    "plot_range" => [[0.04, 0.16], [0.06, 0.14]],
    "histogram_bins" => 25,
    "filename" => "jump_σ=0.01_I=0.svg",
    "phase_plane_title" => "Gillespie, σ = 0.01, I = 0"
)

params_create_model!(params)
params_simulate_model!(params)
params_create_figure(params)

params["parameter_values"] = [0.3, 1/0.01^2]
params["filename"] = "jump_σ=0.01_I=0.3.svg"
params["phase_plane_title"] = "Gillespie, σ = 0.01, I = 0.3"

params_create_model!(params)
params_simulate_model!(params)
params_create_figure(params)

params["problem_type"] = "sde"
params["parameter_names"] = ["I", "σ"]
params["parameter_values"] = [0, 0.01]
params["filename"] = "sde_σ=0.01_I=0.svg"
params["phase_plane_title"] = "SDE model, σ = 0.01, I = 0"

params_create_model!(params)
params_simulate_model!(params)
params_create_figure(params)

params["parameter_values"] = [0.2, 0.01]
params["filename"] = "sde_σ=0.01_I=0.3.svg"
params["phase_plane_title"] = "SDE model, σ = 0.01, I = 0.3"

params_create_model!(params)
params_simulate_model!(params)
params_create_figure(params)
