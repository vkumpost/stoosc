using stoosc
rc("font", family="arial")

## Plot square
fig, ax = subplots(figsize=(1, 0.5))
t = [0.5, 1, 1, 2, 2, 3, 3, 4, 4, 4.5]
x = [0, 0, 1, 1, 0, 0, 1, 1, 0, 0]
ax.plot(t, x, color="black", linewidth=2)
ax.set_axis_off()
fig.tight_layout(pad=0)
save_figure(fig, "figure01", "square.svg")

## Plot sine
fig, ax = subplots(figsize=(1, 0.5))
t = 0:0.01:4π
x = -cos.(t)
ax.plot(t, x, color="black", linewidth=2)
ax.set_axis_off()
fig.tight_layout(pad=0)
save_figure(fig, "figure01","sine.svg")

## Load model and set up its parameters
model = load_model("model01", "sde")
model = set_timespan(model, (0.0, 25.0))
events = create_events([(:LD, 25, 0.5, 0.5)])
model = set_input(model, events)
model = set_parameter_value(model, "I", 0.05)
model = set_parameter_value(model, "σ", 0.01)

## Plot time series for different population sizes
fig, ax_arr = subplots(3, figsize=(5, 4))

min_x = 0.07
max_x = 0.12
events_memory = nothing
for (i, n) = enumerate([1, 10, 100])
    global events_memory, max_x, min_x
    local events, x, t
    solution = simulate_population(model, n, save_trajectories=true, show_progress=true)
    solution = select_time(solution, mintime=19)
    t = solution.time
    x = solution.mean[:, 3]
    U = solution.trajectories[:, 3, :]
    events = solution.events
    for j = 1:n
        if i == 2
            ax_arr[i].plot(t, U[:, j], color="gray", alpha=0.5)
        elseif i == 3
            ax_arr[i].plot(t, U[:, j], color="gray", alpha=0.1)
        end
    end
    ax_arr[i].plot(t, x, color="black")

    if minimum(x) < min_x
        min_x = minimum(U)
    end

    if maximum(x) > max_x
        max_x = maximum(U)
    end

    if isnothing(events_memory)
        events_memory = events
    end

end

for (i, n) = enumerate([1, 10, 100])
    ax_arr[i].set_title("n = $(n)", pad=0)
    ax_arr[i].set_xlabel("Time (a.u.)", labelpad=0)
    ax_arr[i].set_ylabel("Z (a.u.)", labelpad=0)
    ax_arr[i].set_ylim(min_x, max_x)
    ax_arr[i].set_xlim(0, 6)
    ax_arr[i].set_yticks([0.07, 0.12])
    plot_events(events_memory, ax=ax_arr[i], ylims=[min_x, max_x])
    if i == 1
        ax_arr[i].legend(["Single-cell trajectories", "Population-level mean"],
        edgecolor="black", framealpha=1.0, ncol=1, loc=2)
    end
end
fig.tight_layout()

save_figure(fig, "figure01", "population_size.svg")
