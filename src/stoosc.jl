module stoosc

    using Reexport

    include("FindPeaks/FindPeaks.jl")
    include("MiscFunctions/MiscFunctions.jl")
    
    @reexport begin
        
        # Unregistered packages
        using .FindPeaks
        using .MiscFunctions

        # Registered packages
        using DataFrames
        using DifferentialEquations
        using PyPlot
        using Statistics
        using StatsBase

        # import CurveFit
        import CSV  # https://github.com/JuliaData/CSV.jl/issues/981
        import ProgressMeter

    end

    export estimate_entrainment_area, plot_arnold_tongue
    include("arnold_tongue.jl")

    export save_data, load_data, save_figure
    include("input_output.jl")

    export load_model
    include("load_model.jl")

    export kfr, create_events, plot_events, estimate_period
    include("miscellaneous.jl")

    export set_initial_conditions, set_timespan, set_output, create_model,
    set_solver, get_parameter_index, get_parameter_value, set_parameter_value,
    set_input, simulate_population, scan, estimate_binary_arnold_tongue
    include("Model.jl")

    export plot_solution, select_time
    include("PopulationSolution.jl")

end  # module
