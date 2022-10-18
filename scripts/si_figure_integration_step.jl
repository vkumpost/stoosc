
using OscillatorPopulation
using PyPlot
rc("font", family="arial")

# Model and its parameters
model_name = "kim-forger"
parameter_names = ["A", "τ", "I"]
parameter_values = [0.1, 3.66, 0.08]

# 3 days in DD to see the effect of the intital conditions and then LD cycle
events = create_events([(:DD, 3), (:LD, 3, 0.5, 0.5)])

# Set up ODE model
ode_model = load_model(model_name, "ode")
set_parameter!(ode_model, parameter_names, parameter_values)
set_initial_conditions!(ode_model, [0.0, 0.0, 0.1])
set_timespan!(ode_model, (0.0, 6.0))
set_input!(ode_model, events)

# Simulate ODE model
ode_solution = simulate_population(ode_model)
t_ode = ode_solution.time
x_ode = ode_solution.mean[:, 3]

# Set up SDE model
sde_model = load_model(model_name, "sde")
set_parameter!(sde_model, parameter_names, parameter_values)
set_parameter!(sde_model, "σ", 0)
set_initial_conditions!(sde_model, [0.0, 0.0, 0.1])
set_input!(sde_model, events)
set_timespan!(sde_model, (0.0, 6.0))

# Simulate SDE model and create a figure for varying integration step dt
fig, ax_arr = subplots(3, 1, figsize=(7, 4.5))
for (i, dt) = enumerate([0.1, 0.01, 0.001])
    
    set_solver!(sde_model, dt=dt)
    sde_solution = simulate_population(sde_model)
    t = sde_solution.time
    x = sde_solution.mean[:, 3]
    
    ax_arr[i].plot(t_ode, x_ode, color="black", label="ODE")
    ax_arr[i].plot(t, x, color="blue", label="SDE (σ = 0)")
    plot_events(events, ylims=[0.04, 0.16], ax=ax_arr[i])
    ax_arr[i].set_ylim(0.04, 0.16)
    ax_arr[i].set_xlabel("Time", labelpad=0)
    ax_arr[i].set_ylabel("Amplitude", labelpad=0)
    ax_arr[i].set_title("dt = $dt", pad=0, loc="left")
    ax_arr[i].legend(ncol=2, edgecolor="black", framealpha=1.0)
    ax_arr[i].set_xlim(0, 6)
end
fig.tight_layout(pad=0)
fig.show()

# Save the figure
save_figure(fig, "./figures/integration_step.svg")
