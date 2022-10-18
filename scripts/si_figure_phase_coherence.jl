using OscillatorPopulation
using PyPlot
rc("font", family="arial")

seed = 605

fig, ax_array = subplots(3, 1, figsize=(6.5, 4))

# PC = 1 (ODE)
model = load_model("kim-forger", "ode")
set_timespan!(model, 100.0)
set_solver!(model, saveat=0.01)
set_parameter!(model, ["A", "τ", "I"], [0.1, 3.66, 0.02])


events = create_events_cycle(100, 1.05)
set_input!(model, events)

solution = simulate_population(model, 1, seed=seed, show_progress=true)

solution = select_time(solution, min_time=87)
# plot_solution(solution)

t = solution.time
x = solution.mean[:, 1]
events = solution.events
phase_array = estimate_phase_array(t, x, events)
phase_coherence, _ = estimate_order_parameter(phase_array)

solution = select_time(solution, min_time=events[2, 1], max_time=events[end-1, 1])
t = solution.time
x = solution.mean[:, 1]
events = solution.events

ylims = [minimum(x) - 0.01, maximum(x) + 0.01]

ax = ax_array[1]
ax.plot(t, x, color="black")
plot_events(events, ylims=ylims, ax=ax)
ax.set_xlim(0, 10)
ax.set_ylim(ylims)
ax.set_xlabel("Time", labelpad=0)
ax.set_ylabel("Amplitude", labelpad=0)
ax.set_title("Phase coherence = $(round(phase_coherence, digits=2))", pad=0, loc="left")

## PC = 0.9 (SDE)

model = load_model("kim-forger", "sde")
set_timespan!(model, 100.0)
set_solver!(model, saveat=0.01)
set_parameter!(model, ["A", "τ", "I", "σ"], [0.1, 3.66, 0.02, 0.01])


events = create_events_cycle(100, 1.05)
set_input!(model, events)

solution = simulate_population(model, 1, seed=seed, show_progress=true)

solution = select_time(solution, min_time=87)

t = solution.time
x = solution.mean[:, 1]
events = solution.events
phase_array = estimate_phase_array(t, x, events)
phase_coherence, _ = estimate_order_parameter(phase_array)

solution = select_time(solution, min_time=events[2, 1], max_time=events[end-1, 1])
t = solution.time
x = solution.mean[:, 1]
events = solution.events

ylims = [minimum(x) - 0.01, maximum(x) + 0.01]

ax = ax_array[2]
ax.plot(t, x, color="black")
plot_events(events, ylims=ylims, ax=ax)
ax.set_xlim(0, 10)
ax.set_ylim(ylims)
ax.set_xlabel("Time", labelpad=0)
ax.set_ylabel("Amplitude", labelpad=0)
ax.set_title("Phase coherence = $(round(phase_coherence, digits=2))", pad=0, loc="left")

## PC = 0.9 (ODE)
model = load_model("kim-forger", "ode")
set_timespan!(model, 100.0)
set_solver!(model, saveat=0.01)
set_parameter!(model, ["A", "τ", "I"], [0.1, 3.66, 0.02])


events = create_events_cycle(100, 0.85)
set_input!(model, events)

solution = simulate_population(model, 1, seed=seed, show_progress=true)

solution = select_time(solution, min_time=87)
# plot_solution(solution)

t = solution.time
x = solution.mean[:, 1]
events = solution.events
phase_array = estimate_phase_array(t, x, events)
phase_coherence, _ = estimate_order_parameter(phase_array)

solution = select_time(solution, min_time=events[2, 1], max_time=events[end-1, 1])
t = solution.time
x = solution.mean[:, 1]
events = solution.events

ylims = [minimum(x) - 0.01, maximum(x) + 0.01]

ax = ax_array[3]
ax.plot(t, x, color="black")
plot_events(events, ylims=ylims, ax=ax)
ax.set_xlim(0, 10)
ax.set_ylim(ylims)
ax.set_xlabel("Time", labelpad=0)
ax.set_ylabel("Amplitude", labelpad=0)
ax.set_title("Phase coherence = $(round(phase_coherence, digits=2))", pad=0, loc="left")

fig.tight_layout(pad=0.3)
fig.show()
save_figure(fig, "./figures/phase_coherence.svg")
