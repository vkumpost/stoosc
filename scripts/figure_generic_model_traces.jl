using OscillatorPopulation
using PyPlot
rc("font", family="arial")

seed = 149
σ = 0.1
σa = 0.5

# Dictionary to store all the numerical solutions
solutions = Dict()

# Amplitude-phase oscillator without noise
model = load_model("amplitude-phase", "ode")
set_parameter!(model, ["λ", "A", "T", "I"], [1.0, 1.0, 1.0, 0])
set_initial_conditions!(model, [0, 1])
set_timespan!(model, (0.0, 10.0))
solution = simulate_population(model)
solutions["amplitude_phase_ode"] = Dict(
    "t" => solution.time,
    "x" => solution.mean[:, 1]
)

# Amplitude-phase oscillator with noise
model = load_model("amplitude-phase", "sde")
set_parameter!(model, ["λ", "A", "T", "I", "σ"], [1.0, 1.0, 1.0, 0, σa])
set_initial_conditions!(model, [0, 1])
set_timespan!(model, (0.0, 10.0))
solution = simulate_population(model; seed=seed)
solutions["amplitude_phase_sde"] = Dict(
    "t" => solution.time,
    "x" => solution.mean[:, 1]
)

# Limit cycle oscillator without noise
model = load_model("van-der-pol", "ode")
set_parameter!(model, ["B", "d", "τ", "I"], [10, 2, 7.63, 0])
set_initial_conditions!(model, [0, 1])
set_timespan!(model, (0.0, 10.0))
solution = simulate_population(model)
solutions["limit_cycle_ode"] = Dict(
    "t" => solution.time,
    "x" => solution.mean[:, 1]
)

# Noise-induced oscillator without noise
set_parameter!(model, ["B", "d", "τ", "I"], [1, -0.1, 6.2, 0])
solution = simulate_population(model)
solutions["noise_induced_ode"] = Dict(
    "t" => solution.time,
    "x" => solution.mean[:, 1]
)

# Limit cycle oscillator with noise
model = load_model("van-der-pol", "sde")
set_parameter!(model, ["B", "d", "τ", "I", "σ"], [10, 2, 7.63, 0, σ])
set_initial_conditions!(model, [0, 1])
set_timespan!(model, (0.0, 10.0))
solution = simulate_population(model; seed=seed)
solutions["limit_cycle_sde"] = Dict(
    "t" => solution.time,
    "x" => solution.mean[:, 1]
)

# Noise-induced with noise
set_parameter!(model, ["B", "d", "τ", "I",  "σ"], [1, -0.1, 6.2, 0, σ])
solution = simulate_population(model; seed=seed)
t = solution.time
x = solution.mean[:, 1]
solutions["noise_induced_sde"] = Dict(
    "t" => solution.time,
    "x" => solution.mean[:, 1]
)

## ==
fig, ax_arr = subplots(1, 2, figsize=(7, 1.5))

ax_arr[1].plot(solutions["limit_cycle_ode"]["t"], solutions["limit_cycle_ode"]["x"], color="black")
ax_arr[1].plot(solutions["limit_cycle_sde"]["t"], solutions["limit_cycle_sde"]["x"], color="blue")
ax_arr[1].set_title("Limit cycle oscillator", loc="left", pad=0)

ax_arr[2].plot(solutions["noise_induced_ode"]["t"], solutions["noise_induced_ode"]["x"], color="black")
ax_arr[2].plot(solutions["noise_induced_sde"]["t"], solutions["noise_induced_sde"]["x"], color="blue")
ax_arr[2].set_title("Noise-induced oscillator", loc="left", pad=0)

for i = 1:2
    ax_arr[i].set_xlabel("Time", labelpad=0)
    ax_arr[i].set_ylabel("X",  labelpad=0)
    ax_arr[i].set_xlim(0, 6)
    ax_arr[i].legend(["σ = 0", "σ = $(σ)"], edgecolor="black", framealpha=1.0, loc="best", ncol=2)
end

fig.tight_layout(pad=0.3)
# Save the figure
save_figure(fig, "./figures/van_der_pol_traces.svg")

## ==
fig, ax_arr = subplots(3, figsize=(7, 4))

ax_arr[1].plot(solutions["amplitude_phase_ode"]["t"], solutions["amplitude_phase_ode"]["x"], color="black")
ax_arr[1].plot(solutions["amplitude_phase_sde"]["t"], solutions["amplitude_phase_sde"]["x"], color="blue")
ax_arr[1].set_title("Limit cycle oscillator (Amplitude-phase)", loc="left", pad=0)

ax_arr[2].plot(solutions["limit_cycle_ode"]["t"], solutions["limit_cycle_ode"]["x"], color="black")
ax_arr[2].plot(solutions["limit_cycle_sde"]["t"], solutions["limit_cycle_sde"]["x"], color="blue")
ax_arr[2].set_title("Limit cycle oscillator (Van der Pol)", loc="left", pad=0)

ax_arr[3].plot(solutions["noise_induced_ode"]["t"], solutions["noise_induced_ode"]["x"], color="black")
ax_arr[3].plot(solutions["noise_induced_sde"]["t"], solutions["noise_induced_sde"]["x"], color="blue")
ax_arr[3].set_title("Noise-induced oscillator", loc="left", pad=0)

for i = 1:3
    ax_arr[i].set_xlabel("Time", labelpad=0)
    ax_arr[i].set_ylabel("X",  labelpad=0)
    ax_arr[i].set_xlim(0, 10)
    if i == 1
        ax_arr[i].legend(["σ = 0.0", "σ = $(σa)"], edgecolor="black", framealpha=1.0, loc="best", ncol=2)
    else
        ax_arr[i].legend(["σ = 0.0", "σ = $(σ)"], edgecolor="black", framealpha=1.0, loc="best", ncol=2)
    end
end

fig.tight_layout(pad=0.3)
# Save the figure
save_figure(fig, "./figures/generic_model_traces.svg")
