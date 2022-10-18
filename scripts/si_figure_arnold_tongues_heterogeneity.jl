using OscillatorPopulation
using Statistics
using PyPlot
rc("font", family="arial")

property_name = "phase_coherence"
color_limits=[0.0, 1.0]

## PANEL A ===
df = load_data("./outputs/arnold_tongues/kim_forger/arnold_tongue_ode.csv")
fig, ax = subplots(figsize=(3, 2))

plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name=property_name,
    color_limits=color_limits,
    show_colorbar=true,
    ax=ax
)
ax.set_title("ODE", pad=0, loc="left")
ax.set_yticks([0, 0.04, 0.08])
ax.set_xticks([0.75, 1.00, 1.25])

phase_coherence_ode = mean(df[:, property_name])

## ==
σ_array = [0.001, 0.002, 0.003, 0.005, 0.01, 0.02, 0.03, 0.05, 0.1, 0.2, 0.3, 0.5, 1.0]
n_array = [1000]
phase_coherence_matrix = Matrix{Float64}(undef, length(σ_array), length(n_array))
for (iσ, σ) = enumerate(σ_array)

    df = load_data("./outputs/arnold_tongues/heterogeneity/arnold_tongue_ode_σ=$(σ).csv")
    for (in, n) = enumerate(n_array)

        column_string = property_name

        fig, ax = subplots(figsize=(2.5, 2.25))
        plot_arnold(df, "tongue";
            fixed_value=0.5,
            property_name=column_string,
            color_limits=[0.0, 1.0],
            show_colorbar=false,
            ax=ax
        )
        ax.set_title("n=$n, σ=$σ", pad=0, loc="left")
        fig.tight_layout()
        save_figure(fig, "./figures/arnold_tongues/heterogeneity/arnold_tongue_n=$(n)_σ=$(σ).svg")
        close(fig)

        phase_coherence = df[:, column_string]

        phase_coherence_matrix[iσ, in] = mean(phase_coherence)

    end

end

## ==
fig, ax = subplots(figsize=(6.5, 2))
σ_array_log = log10.(σ_array)
ax.plot([-100, 100], [phase_coherence_ode, phase_coherence_ode], "--", color="black", label="Deterministic")

polynomial_order = 3

for (i, n) = enumerate(n_array)
    h = ax.plot(σ_array_log, phase_coherence_matrix[:, i], "o", color="black", label="n = $n")
end

ax.set_xlim([σ_array_log[1] - 0.03, σ_array_log[end] + 0.05])
ax.set_title("Phase coherence for a heterogeneous population of 1000 oscillators", pad=0, loc="left")
ax.set_xlabel("log\$_{10}\$(Noise intensity)", labelpad=0)
ax.set_ylabel("Average phase coherence", labelpad=0)
fig.tight_layout(pad=0.1)
save_figure(fig, "./figures/arnold_tongues/heterogeneity.svg")
