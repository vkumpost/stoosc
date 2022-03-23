using stoosc
rc("font", family="arial")

# Dictionary to store all the numerical solutions
solutions = Dict()

# Limit cycle oscillator without noise
model = load_model("model02", "ode")
model = set_parameter_value(model, ["B", "d", "τ", "I"], [10, 2, 7.63, 0])
model = set_initial_conditions(model, [0, 1])
model = set_timespan(model, (0.0, 6.0))
solution = simulate_population(model)
solutions["limit_cycle_ode"] = Dict(
    "t" => solution.time,
    "x" => solution.mean[:, 1]
)

# Noise-induced oscillator without noise
model = set_parameter_value(model, ["B", "d", "τ", "I"], [1, -0.1, 6.2, 0])
solution = simulate_population(model)
solutions["noise_induced_ode"] = Dict(
    "t" => solution.time,
    "x" => solution.mean[:, 1]
)

# Limit cycle oscillator with noise
model = load_model("model02", "sde")
model = set_parameter_value(model, ["B", "d", "τ", "I", "σ"], [10, 2, 7.63, 0, 0.2])
model = set_initial_conditions(model, [0, 1])
model = set_timespan(model, (0.0, 6.0))
solution = simulate_population(model)
solutions["limit_cycle_sde"] = Dict(
    "t" => solution.time,
    "x" => solution.mean[:, 1]
)

# Noise-induced with noise
model = set_parameter_value(model, ["B", "d", "τ", "I",  "σ"], [1, -0.1, 6.2, 0, 0.2])
solution = simulate_population(model)
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
    ax_arr[i].legend(["σ = 0", "σ = 0.2"], edgecolor="black", framealpha=1.0, loc="best", ncol=2)
end

fig.tight_layout(pad=0.3)
# Save the figure
save_figure(fig, "van_der_pol_traces.svg")
