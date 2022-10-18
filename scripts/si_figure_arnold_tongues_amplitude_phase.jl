using OscillatorPopulation
using Statistics
using PyPlot
rc("font", family="arial")

property_name = "phase_coherence"
color_limits=[0.0, 1.0]

## PANEL A ===
df = load_data("./outputs/arnold_tongues/amplitude_phase/arnold_tongue_ode.csv")

fig, ax = subplots(figsize=(4, 3))

plot_arnold(df, "tongue";
    fixed_value=0.5,
    property_name=property_name,
    color_limits=color_limits,
    show_colorbar=true,
    ax=ax
)
ax.set_title("Deterministic", pad=0, loc="left")
ax.set_yticks([0, 1.0, 2.0, 3.0])
ax.set_xticks([0.75, 1.00, 1.25])

phase_coherence_ode = mean(df[:, property_name])

## ==
σ_array = [0.05, 0.1, 0.2, 0.3, 0.5, 1.0, 2.0]  # 0.01, 0.02, 
n_array = [1, 10, 100, 1000]
phase_coherence_matrix = Matrix{Float64}(undef, length(σ_array), length(n_array))
for (iσ, σ) = enumerate(σ_array)

    df = load_data("./outputs/arnold_tongues/amplitude_phase/arnold_tongue_σ=$(σ).csv")
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
        save_figure(fig, "./figures/arnold_tongues/amplitude_phase/arnold_tongue_n=$(n)_σ=$(σ).svg")
        close(fig)

        phase_coherence = df[:, column_string]

        phase_coherence_matrix[iσ, in] = mean(phase_coherence)

    end

end

## ==
fig, ax = subplots(figsize=(6.75, 2.3))
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
ax.set_title("Amplitude-phase model", pad=0, loc="left")
ax.set_xlabel("log\$_{10}\$(Noise intensity)", labelpad=0)
ax.set_ylabel("Average phase coherence", labelpad=0)
fig.tight_layout(pad=0.1)
save_figure(fig, "./figures/arnold_tongues/amplitude_phase.svg")
