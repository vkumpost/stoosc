using OscillatorPopulation
using PyPlot
rc("font", family="arial")

seed = 605

fig, ax_array = subplots(3, 1, figsize=(6.5, 4))


for (i, σ) = enumerate([0.005, 0.01, 0.02])
    model = load_model("kim-forger", "sde")
    set_timespan!(model, 100.0)
    set_solver!(model, saveat=0.01)
    set_parameter!(model, ["A", "τ", "I", "σ"], [0.1, 3.66, 0.02, σ])


    events = create_events_cycle(100, 1.05)
    set_input!(model, events)

    solution = simulate_population(model, 1000, seed=seed, show_progress=true)

    solution = select_time(solution, min_time=87)

    t = solution.time
    x = solution.mean[:, 1]
    U = solution.trajectories[:, 1, :]
    events = solution.events
    phase_array = estimate_phase_array(t, U, events)
    phase_coherence, _ = estimate_order_parameter(phase_array)

    solution = select_time(solution, min_time=events[2, 1], max_time=events[end-1, 1])
    t = solution.time
    x = solution.mean[:, 1]
    events = solution.events

    ax = ax_array[i]

    for i = 1:10
        xx = solution.trajectories[:, 1, i]
        ax.plot(t, xx, color="gray", alpha=0.5)
    end
    ax.plot(t, x, color="black")

    ylims = [0.00, 0.25]
    plot_events(events, ylims=ylims, ax=ax)
    ax.set_xlim(0, 10)
    ax.set_ylim(ylims)
    ax.set_xlabel("Time", labelpad=0)
    ax.set_ylabel("Amplitude", labelpad=0)
    ax.set_title("Population phase coherence = $(round(phase_coherence, digits=2))", pad=0, loc="left")


end



fig.tight_layout(pad=0.3)
fig.show()

save_figure(fig, "./figures/population_phase_coherence.svg")
