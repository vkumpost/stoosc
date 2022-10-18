using OscillatorPopulation
using Statistics
using PyPlot
rc("font", family="arial")

property_name = "phase_coherence"
color_limits=[0.0, 1.0]

## ===
df = load_data("./outputs/arnold_tongues/kim_forger/arnold_tongue_ode.csv")
fig, ax_array = subplots(1, 3, figsize=(6.5, 2))

plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name=property_name,
    color_limits=color_limits,
    show_colorbar=false,
    ax=ax_array[1]
)
ax_array[1].set_title("Deterministic", pad=0, loc="left")
ax_array[1].set_yticks([0, 0.04, 0.08])
ax_array[1].set_xticks([0.75, 1.00, 1.25])

phase_coherence_ode = mean(df[:, property_name])
println("ODE PC = $(phase_coherence_ode)")

df = load_data("./outputs/arnold_tongues/kim_forger/arnold_tongue_σ=0.005.csv")
plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name="$(property_name)_n1",
    color_limits=color_limits,
    show_colorbar=false,
    ax=ax_array[2]
)
ax_array[2].set_title("Stochastic (n = 1)", pad=0, loc="left")
ax_array[2].set_yticks([0, 0.04, 0.08])
ax_array[2].set_xticks([0.75, 1.00, 1.25])

phase_coherence_sde_1 = mean(df[:, "$(property_name)_n1"])
println("SDE 1 PC = $(phase_coherence_sde_1)")

plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name="$(property_name)",
    color_limits=color_limits,
    show_colorbar=false,
    ax=ax_array[3]
)
ax_array[3].set_title("Stochastic (n = 1000)", pad=0, loc="left")
ax_array[3].set_yticks([0, 0.04, 0.08])
ax_array[3].set_xticks([0.75, 1.00, 1.25])

phase_coherence_sde_2 = mean(df[:, "$(property_name)"])
println("SDE 1 PC = $(phase_coherence_sde_2)")

fig.tight_layout(pad=0.5)
fig.show()
save_figure(fig, "./figures/arnold_tongues/arnold_tongues_examples.svg")

# For colorbar
fig, ax = subplots(figsize=(6, 2))
plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name="$(property_name)",
    color_limits=color_limits,
    ax=ax
)
fig.tight_layout(pad=0.5)
save_figure(fig, "./figures/arnold_tongues/arnold_tongues_examples_colorbar.svg")

## ==
σ_array = [0.001, 0.002, 0.003, 0.005, 0.01, 0.02, 0.03, 0.05]
n_array = [1, 10, 100, 1000]
phase_coherence_matrix = Matrix{Float64}(undef, 8, 4)
for (iσ, σ) = enumerate(σ_array)

    df = load_data("./outputs/arnold_tongues/kim_forger/arnold_tongue_σ=$(σ).csv")
    for (in, n) = enumerate(n_array)

        if n < 1000
            column_string = "$(property_name)_n$(n)"
        else
            column_string = property_name
        end

        fig, ax = subplots(figsize=(2.5, 2.25))
        plot_arnold(df, "tongue";
            fixed_value=0.5,
            property_name=column_string,
            # property_name="collective_phase",
            # property_name="phase_coherence_population",
            # error_name="phase_coherence",
            color_limits=[0.0, 1.0],
            show_colorbar=false,
            # colorbar_label="input period / oscillator period",
            ax=ax
        )
        ax.set_title("n=$n, σ=$σ", pad=0, loc="left")
        fig.tight_layout()
        save_figure(fig, "./figures/arnold_tongues/kim_forger/arnold_tongue_n=$(n)_σ=$(σ).svg")
        close(fig)

        phase_coherence = df[:, column_string]

        phase_coherence_matrix[iσ, in] = mean(phase_coherence)

    end

end

## ==
fig, ax = subplots(figsize=(6.5, 2))
σ_array_log = log10.(σ_array)
ax.plot([-100, 100], [phase_coherence_ode, phase_coherence_ode], "--", color="black", label="Deterministic")

polynomial_order = 2

symbol_array = ["o", "v", "^", "s"]
for (i, n) = enumerate(n_array)
    p = fit_curve(polynomial, σ_array_log, phase_coherence_matrix[:, i], fill(1.0, polynomial_order + 1))
    tt = range(minimum(σ_array_log), maximum(σ_array_log[end]), length=100)
    xx = polynomial(tt, p)

    h = ax.plot(σ_array_log, phase_coherence_matrix[:, i], symbol_array[i], label="n = $n")
    ax.plot(tt, xx, "-", color=h[1].get_color())
end

ax.set_xlim([σ_array_log[1] - 0.03, σ_array_log[end] + 0.05])
ax.legend(edgecolor="black", framealpha=1.0, ncol=3)
ax.set_title("Phase coherence for constant number of oscillators (n)", pad=0, loc="left")
ax.set_xlabel("log\$_{10}\$(Noise intensity)", labelpad=0)
ax.set_ylabel("Average phase coherence", labelpad=0)
fig.tight_layout(pad=0.1)
save_figure(fig, "./figures/arnold_tongues/kim_forger.svg")
