using OscillatorPopulation
using Statistics
using PyPlot
rc("font", family="arial")

const ProgressMeter = OscillatorPopulation.ProgressMeter

function benchmark(fun)
    
    # Precompile
    _ = @elapsed x = fun()

    time_array = fill(NaN, 100)
    negative_array = fill(NaN, 100)
    for i = 1:100
        time_array[i] = @elapsed x = fun()
        negative_array[i] = sum(x .< 0)
    end

    mean_time = mean(time_array .* 1000)
    std_time = std(time_array .* 1000)
    mean_negative = mean(negative_array)
    std_negative = std(negative_array)

    return mean_time, std_time, mean_negative, std_negative

end

max_time = 100.0
model_langevin = load_model("kim-forger", "sde", noise_type="langevin")
set_timespan!(model_langevin, max_time)

model_gillespie = load_model("kim-forger", "jump")
set_timespan!(model_gillespie, max_time)

Ω_array = 10 .^ (1.0:0.1:3.75)
nΩ = length(Ω_array)
parameters = Dict(
    "mean_time_langevin" => fill(NaN, nΩ),
    "std_time_langevin" => fill(NaN, nΩ),
    "mean_negative_langevin" => fill(NaN, nΩ),
    "std_negative_langevin" => fill(NaN, nΩ),
    "mean_time_gillespie" => fill(NaN, nΩ),
    "std_time_gillespie" => fill(NaN, nΩ),
    "mean_negative_gillespie" => fill(NaN, nΩ),
    "std_negative_gillespie" => fill(NaN, nΩ),
)

progress_meter = ProgressMeter.Progress(nΩ; barlen=20)
for (iΩ, Ω) = enumerate(Ω_array)
    set_parameter!(model_langevin, ["σ", "I"], [1/sqrt(Ω), 0.0])
    fun_langevin = () -> (simulate_model(model_langevin)[1][:, 1])
    mean_time, std_time, mean_negative, std_negative = benchmark(fun_langevin)
    parameters["mean_time_langevin"][iΩ] = mean_time
    parameters["std_time_langevin"][iΩ] = std_time
    parameters["mean_negative_langevin"][iΩ] = mean_negative
    parameters["std_negative_langevin"][iΩ] = std_negative

    set_parameter!(model_gillespie, ["Ω", "I"], [Ω, 0.0])
    fun_gillespie = () -> (simulate_model(model_gillespie)[1][:, 1])
    mean_time, std_time, mean_negative, std_negative = benchmark(fun_gillespie)
    parameters["mean_time_gillespie"][iΩ] = mean_time
    parameters["std_time_gillespie"][iΩ] = std_time
    parameters["mean_negative_gillespie"][iΩ] = mean_negative
    parameters["std_negative_gillespie"][iΩ] = std_negative

    ProgressMeter.next!(progress_meter)
end

## ==
fig, ax_array = subplots(1, 2, figsize=(7, 2.5))

ax_array[1].errorbar(log10.(Ω_array), parameters["mean_time_gillespie"],
    yerr=parameters["std_time_gillespie"], marker=".", color="black", label="Gillespie")  # marker=".", linestyle="", 
ax_array[1].errorbar(log10.(Ω_array), parameters["mean_time_langevin"],
    yerr=parameters["std_time_langevin"], marker=".", color="red", label="Langevin")
ax_array[1].legend(edgecolor="black", framealpha=1.0, ncol=1)
ax_array[1].set_xlabel("log\$_{10}\$(System size parameter Ω)", labelpad=0)
ax_array[1].set_ylabel("Simulation time (ms)", labelpad=0)
ax_array[1].set_title("Simulation time", pad=0, loc="left")

ax_array[2].errorbar(log10.(Ω_array), parameters["mean_negative_gillespie"],
    yerr=parameters["std_negative_gillespie"], marker=".", color="black", label="Gillespie")
ax_array[2].errorbar(log10.(Ω_array), parameters["mean_negative_langevin"],
    yerr=parameters["std_negative_langevin"], marker=".", color="red", label="Langevin")
ax_array[2].legend(edgecolor="black", framealpha=1.0, ncol=1)
ax_array[2].set_xlabel("log\$_{10}\$(System size parameter Ω)", labelpad=0)
ax_array[2].set_ylabel("Negative value count", labelpad=0)
ax_array[2].set_title("Negative concentrations", pad=0, loc="left")

fig.tight_layout(pad=0.5)
fig.show()
save_figure(fig, "figures/sde_vs_jump_benchmark.svg")
