using OscillatorPopulation
using Statistics
using PyPlot
rc("font", family="arial")


fig, ax_arr = subplots(2, 2, figsize=(7, 5))


df = load_data("./outputs/arnold_tongues/kim_forger/arnold_tongue_σ=0.0316.csv")
ax = ax_arr[1, 1]
plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name="phase_coherence",
    color_limits=[0, 1],
    show_colorbar=true,
    colorbar_label="Phase coherence",
    figure_title="Langevin",
    ax=ax
)
ax.set_yticks([0, 0.04, 0.08])
ax.set_xticks([0.75, 1.00, 1.25])

ax = ax_arr[2, 1]
plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name="phase_coherence_population",
    color_limits=[0, 1],
    show_colorbar=true,
    colorbar_label="Population phase coherence",
    figure_title="Langevin",
    ax=ax
)
ax.set_yticks([0, 0.04, 0.08])
ax.set_xticks([0.75, 1.00, 1.25])

df = load_data("./outputs/arnold_tongues/kim_forger_constant_volume/arnold_tongue_n=100_Ω=1000.csv")
ax = ax_arr[1, 2]
plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name="phase_coherence",
    color_limits=[0, 1],
    show_colorbar=true,
    colorbar_label="Phase coherence",
    figure_title="Gillespie",
    ax=ax
)
ax.set_yticks([0, 0.04, 0.08])
ax.set_xticks([0.75, 1.00, 1.25])

ax = ax_arr[2, 2]
plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name="phase_coherence_population",
    color_limits=[0, 1],
    show_colorbar=true,
    colorbar_label="Population population phase",
    figure_title="Gillespie",
    ax=ax
)
ax.set_yticks([0, 0.04, 0.08])
ax.set_xticks([0.75, 1.00, 1.25])

fig.tight_layout(pad=0.3)
fig.show()

save_figure(fig, "./figures/sde_vs_jump_arnold_tongues.svg")
