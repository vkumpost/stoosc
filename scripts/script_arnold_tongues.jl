using stoosc
rc("font", family="arial")


function params_estimate_arnold_tongue!(params)

    # Extract function parameters
    trajectories = params["trajectories"]
    parameter_names = params["parameter_names"]
    parameter_values = params["parameter_values"]
    n_samples = params["n_samples"]
    model_name = params["model_name"]
    I_max = params["I_max"]
    problem_type = params["problem_type"]
    i_variable = params["i_variable"]
    period_range = params["period_range"]
    filename = params["filename"]

    # Create a model
    model = load_model(model_name, problem_type)
    model = set_solver(model, saveat=0.01, maxiters=1e10)
    model = set_timespan(model, (0.0, 200.0))
    outfun = sol -> hcat(sol[i_variable, :])
    model = set_output(model, outfun)
    model = set_parameter_value(model, parameter_names, parameter_values)

    # Set periods and amplitudes to scan
    periods = range(period_range[1], period_range[2], length=n_samples)
    # periods = range(0.8, 1.2, length=n_samples)
    amplitudes = [0.0, I_max]

    # Estimate arnold tongue
    arnold_tongue = estimate_binary_arnold_tongue(model, periods, amplitudes;
        trajectories=trajectories, i_solution=1, n_lags=1000,
        input_parameter_name="I", min_time=nothing, max_time=nothing,
        show_progress=true, period_error=0.02, boundary_error=I_max/n_samples,
        maximal_error_attempts=5)

    # Save the estimated arnold tongue into the params dictionary
    params["arnold_tongue"] = arnold_tongue

    # Save the estimated arnold tongue into a file
    if !isnothing(filename)
        save_data(arnold_tongue, filename)
    end

end

params = Dict(
    "trajectories" => 10,  # number of trajectories to calculate population mean
    "parameter_names" => ["σ"],  # parameter names
    "parameter_values" => [0.005],  # parameter values
    "n_samples" => 100,  # number of samples in the period range
    "period_range" => [0.75, 1.25],  # period range (min, max)
    "model_name" => "model01",  # model name (model01, model02)
    "I_max" => 0.3,  # maximal input amplitude to estimate
    "problem_type" => "sde",  # "ode", "sde", or "jump"
    "i_variable" => 3,  # varialbe to use to estimate entrainment
    "filename" => "test_arnold_tongue.csv",  # save the result in this file
)
params_estimate_arnold_tongue!(params)
