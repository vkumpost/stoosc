using OscillatorPopulation
using PyPlot
rc("font", family="arial")

# Load model and set paraemters (except for A that will be scanned)
model = load_model("kim-forger", "ode")
set_parameter!(model, ["τ", "I"], [1.0, 0.0])
set_solver!(model, reltol=1e-12, abstol=1e-12)

# A summary function that performs a numerical simulation and estimates the 
# parameters of the solution
summary_function = function (model=nothing)

    # If the model is not passed, return the names of the parameters
    if isnothing(model)
        return ["p2p", "rms"]
    end

    # Set up the solver and simulate the model
    set_timespan!(model, (0.0, 1000.0))
    set_solver!(model, saveat=200.0:0.1:1000.0)
    solution = simulate_population(model)

    # If the simulation is successful, calculate the parameters, otherwise
    # return NaNs
    if solution.success
        x = solution.mean[:, 3]
        xmax = maximum(x)
        xmin = minimum(x)
        p2p = xmax - xmin
        rms = sqrt(mean(x.^2))
    else
        p2p = NaN
        rms = NaN
    end

    return [p2p, rms]

end

# Specify the name of the parameter and the values to scan over
parameters = [("A", 10 .^ range(-3.0, 0.0; length=100))]

# Perform the parameter scan
df = scan(model, parameters, summary_function; show_progress=true)

# Create a figure and save it
A_log = log10.(df[:, "A"])
p2p = df[:, "p2p"]
ylim = [minimum(p2p) - 0.001, maximum(p2p) + 0.001]

fig, ax = subplots(figsize=(7, 2.25))
ax.plot(A_log, p2p, color="black", label="Peak-to-peak amplitude")
ax.plot([-1, -1], ylim, label="Used value of A", color="red")
ax.plot([log10(0.125), log10(0.125)], ylim, label="Analytical bifurcation", color="blue")
ax.legend(edgecolor=:black, framealpha=1.0)
ax.set_xlim(-3, 0)
ax.set_ylim(ylim)
ax.set_xlabel("log\$_{10}\$(A)", labelpad=0)
ax.set_ylabel("Peak-to-peak amplitude", labelpad=0)
ax.set_title("Parameter scan for A", pad=0, loc="left")
fig.tight_layout(pad=0.3)
save_figure(fig, "./figures/parameter_scan.svg")
