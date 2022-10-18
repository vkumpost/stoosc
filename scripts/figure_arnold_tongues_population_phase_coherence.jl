using OscillatorPopulation
using Statistics
using PyPlot
rc("font", family="arial")

property_name = "phase_coherence_population"
color_limits=[0.0, 1.0]

## ==
σ_array = [0.001, 0.002, 0.003, 0.005, 0.01, 0.02, 0.03, 0.05]
n_array = [1000]
phase_coherence_matrix = Matrix{Float64}(undef, length(σ_array), length(n_array))
for (iσ, σ) = enumerate(σ_array)

    df = load_data("./outputs/arnold_tongues/kim_forger/arnold_tongue_σ=$(σ).csv")
    for (in, n) = enumerate(n_array)

        if n < 1000
            # column_string = "phase_coherence_n$(n)"
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
        save_figure(fig, "./figures/arnold_tongues/population_phase_coherence/arnold_tongue_n=$(n)_σ=$(σ).svg")
        close(fig)

        phase_coherence = df[:, column_string]
        # phase_coherence = 1/mean(abs.(df[:, column_string] .- 1))

        phase_coherence_matrix[iσ, in] = mean(phase_coherence)
        # phase_coherence_matrix[iσ, in] = sum(phase_coherence .> 0.98) / length(phase_coherence)

    end

end

## ==
fig, ax = subplots(figsize=(6.5, 2))
σ_array_log = log10.(σ_array)

polynomial_order = 1

for (i, n) = enumerate(n_array)
    p = fit_curve(polynomial, σ_array_log, phase_coherence_matrix[:, i], fill(1.0, polynomial_order + 1))
    tt = range(minimum(σ_array_log), maximum(σ_array_log[end]), length=100)
    xx = polynomial(tt, p)

    h = ax.plot(σ_array_log, phase_coherence_matrix[:, i], "o", color="black")
    ax.plot(tt, xx, "-", color=h[1].get_color())
end

ax.set_xlim([σ_array_log[1] - 0.03, σ_array_log[end] + 0.05])
# ax.legend(edgecolor="black", framealpha=1.0, ncol=2)
ax.set_title("Population phase coherence", pad=0, loc="left")
ax.set_xlabel("log\$_{10}\$(Noise intensity)", labelpad=0)
ax.set_ylabel("Average phase coherence", labelpad=0)
fig.tight_layout(pad=0.1)
save_figure(fig, "./figures/arnold_tongues/population_phase_coherence.svg")
fig.show()
