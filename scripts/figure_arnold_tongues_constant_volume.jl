using OscillatorPopulation
using Statistics
using PyPlot
rc("font", family="arial")

property_name = "phase_coherence"
color_limits=[0.0, 1.0]

df = load_data("./outputs/arnold_tongues/kim_forger/arnold_tongue_ode.csv")

phase_coherence = df[:, property_name]
phase_coherence_ode = mean(phase_coherence)

Ω0_array = [10_000, 20_000, 100_000, 600_000]
n_array = [1, 2, 3, 6, 10, 20, 30, 60, 100, 200, 300, 600, 1_000]
phase_coherence_matrix = Matrix{Float64}(undef, length(n_array), length(Ω0_array))
for (iΩ0, Ω0) = enumerate(Ω0_array)
    for (in, n) = enumerate(n_array)
        
        Ω = round(Int, Ω0/n)
        df = load_data("./outputs/arnold_tongues/kim_forger_constant_volume/arnold_tongue_n=$(n)_Ω=$(Ω).csv")

        fig, ax = subplots(figsize=(2.5, 2.25))
        plot_arnold(df, "tongue";
            fixed_value=0.5,
            property_name=property_name,
            color_limits=[0.0, 1.0],
            show_colorbar=false,
            # colorbar_label="input period / oscillator period",
            ax=ax
        )
        ax.set_title("n=$(n), Ω=$(Ω)", pad=0, loc="left")
        fig.tight_layout()
        save_figure(fig, "./figures/arnold_tongues/kim_forger_constant_volume/arnold_tongue_n=$(n)_Ω=$(Ω).svg")
        close(fig)

        phase_coherence = df[:, property_name]

        phase_coherence_matrix[in, iΩ0] = mean(phase_coherence)
        

    end

end

## ==
fig, ax = subplots(figsize=(6.5, 2))
n_array_log = log10.(n_array) 

ax.plot([minimum(n_array_log),  maximum(n_array_log[end])], [phase_coherence_ode, phase_coherence_ode], "--", color="black", label="Deterministic")

polynomial_order = 2

symbol_array = ["o", "v", "^", "s"]
for (i, Ω0) = enumerate(Ω0_array)
    p = fit_curve(polynomial, n_array_log, phase_coherence_matrix[:, i], fill(1.0, polynomial_order + 1))
    tt = range(minimum(n_array_log), maximum(n_array_log[end]), length=100)
    xx = polynomial(tt, p)

    h = ax.plot(n_array_log, phase_coherence_matrix[:, i], symbol_array[i], label="Ω = $Ω0")  #  maximum(n_array_log[end])
    ax.plot(tt, xx, "-", color=h[1].get_color())
end

ax.set_xlim([n_array_log[1] - 0.03, n_array_log[end] + 0.05])
# ax.set_ylim([0, 1])
ax.legend(edgecolor="black", framealpha=1.0, ncol=3)
ax.set_title("Phase coherence for constant volume", pad=0, loc="left")
ax.set_xlabel("Population size (number of oscillators)", labelpad=0)
ax.set_ylabel("Average phase coherence", labelpad=0)
ax.set_xticks(n_array_log)
ax.set_xticklabels(n_array)
fig.tight_layout(pad=0.3)
save_figure(fig, "./figures/arnold_tongues/kim_forger_constant_volume.svg")
fig.show()
