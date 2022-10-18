using OscillatorPopulation
using PyPlot
rc("font", family="arial")

## Kim-Forger model ===========================================================
fig, ax_array = subplots(3, 3, figsize=(6.25, 4.25))

for (i, I) = enumerate([0.03, 0.05, 0.08])
    
    for (j, σ) = enumerate([0.003, 0.01, 0.03])

        pulse_time = nothing
        phase_shift_array = []
        for i = 1:10
            df = load_data("./outputs/phase_response_curves/kim_forger/I=$(I)_σ=$(σ)_r=$(i).csv")
            pulse_time = df[:, "pulse_time"]
            push!(phase_shift_array, df[:, "phase_shift"])
        end
        
        ax = ax_array[i, j]
        
        phase_shift = [cmean([x[i] for x in phase_shift_array]) for i in 1:length(phase_shift_array[1])]
        phase_shift[phase_shift .> 0.5] .-= 1  # map [0, 1] to [-0.5, 0.5]
        phase_shift_error = [cstd([x[i] for x in phase_shift_array]) for i in 1:length(phase_shift_array[1])]
        
        ax.errorbar(pulse_time, phase_shift, yerr=phase_shift_error, fmt=".", color="black")
        
        # Draw a grid
        grid_color = fill(0.8, 3)
        ax.hlines(0.0, 0, 1, color=grid_color, zorder=-1000)
        ax.vlines(0.5, -0.5, 0.5, color=grid_color, zorder=-1000)
        ax.set_xlim(0, 1)
        ax.set_xticks(0:1.0:1)
        ax.set_ylim(-0.5, 0.5)
        ax.set_yticks(-0.5:1.0:0.5)
        plot_events([0 0.5], ax=ax, ylims=[-0.5, 0.5], zorder=-2000)
        ax.set_title("I = $(I), σ = $(σ)", pad=0.1, loc="left")
        ax.set_xlabel("Pulse time", labelpad=-10.0)
        ax.set_ylabel("Phase shift", labelpad=-20.0)
        
        
    end
    
end

fig.tight_layout(pad=0.3)
save_figure(fig, "./figures/phase_response_curves/kim_forger.svg")

## Limit cycle Van der Pol model ==============================================
using OscillatorPopulation
using PyPlot
rc("font", family="arial")

fig, ax_array = subplots(3, 3, figsize=(6.25, 4.25))


for (i, I) = enumerate([0.4, 0.45, 0.65])
    
    for (j, σ) = enumerate([0.004, 0.03, 0.07])

        pulse_time = nothing
        phase_shift_array = []
        for i = 1:10
            df = load_data("./outputs/phase_response_curves/van_der_pol_limit_cycle/I=$(I)_σ=$(σ)_r=$(i).csv")
            pulse_time = df[:, "pulse_time"]
            push!(phase_shift_array, df[:, "phase_shift"])
        end
        
        ax = ax_array[i, j]
        
        phase_shift = [cmean([x[i] for x in phase_shift_array]) for i in 1:length(phase_shift_array[1])]
        phase_shift[phase_shift .> 0.5] .-= 1  # map [0, 1] to [-0.5, 0.5]
        phase_shift_error = [cstd([x[i] for x in phase_shift_array]) for i in 1:length(phase_shift_array[1])]
        
        ax.errorbar(pulse_time, phase_shift, yerr=phase_shift_error, fmt=".", color="black")
        
        # Draw a grid
        grid_color = fill(0.8, 3)
        ax.hlines(0.0, 0, 1, color=grid_color, zorder=-1000)
        ax.vlines(0.5, -0.5, 0.5, color=grid_color, zorder=-1000)
        ax.set_xlim(0, 1)
        ax.set_xticks(0:1.0:1)
        ax.set_ylim(-0.5, 0.5)
        ax.set_yticks(-0.5:1.0:0.5)
        plot_events([0 0.5], ax=ax, ylims=[-0.5, 0.5], zorder=-2000)
        ax.set_title("I = $(I), σ = $(σ)", pad=0.1)
        ax.set_xlabel("Pulse time", labelpad=-10.0)
        ax.set_ylabel("Phase shift", labelpad=-20.0)
        
    end

end

fig.tight_layout(pad=0.3)
save_figure(fig, "./figures/phase_response_curves/van_der_pol_limit_cycle.svg")

## Noise-induced Van der Pol model ============================================
using OscillatorPopulation
using PyPlot
rc("font", family="arial")

fig, ax_array = subplots(3, 3, figsize=(6.25, 4.25))


for (i, I) = enumerate([0.4, 0.45, 0.65])
    
    for (j, σ) = enumerate([0.004, 0.03, 0.07])

        pulse_time = nothing
        phase_shift_array = []
        for i = 1:10
            df = load_data("./outputs/phase_response_curves/van_der_pol_noise_induced/I=$(I)_σ=$(σ)_r=$(i).csv")
            pulse_time = df[:, "pulse_time"]
            push!(phase_shift_array, df[:, "phase_shift"])
        end
        
        ax = ax_array[i, j]
        
        phase_shift = [cmean([x[i] for x in phase_shift_array]) for i in 1:length(phase_shift_array[1])]
        phase_shift[phase_shift .> 0.5] .-= 1  # map [0, 1] to [-0.5, 0.5]
        phase_shift_error = [cstd([x[i] for x in phase_shift_array]) for i in 1:length(phase_shift_array[1])]
        
        ax.errorbar(pulse_time, phase_shift, yerr=phase_shift_error, fmt=".", color="black")
        
        # Draw a grid
        grid_color = fill(0.8, 3)
        ax.hlines(0.0, 0, 1, color=grid_color, zorder=-1000)
        ax.vlines(0.5, -0.5, 0.5, color=grid_color, zorder=-1000)
        ax.set_xlim(0, 1)
        ax.set_xticks(0:1.0:1)
        ax.set_ylim(-0.5, 0.5)
        ax.set_yticks(-0.5:1.0:0.5)
        plot_events([0 0.5], ax=ax, ylims=[-0.5, 0.5], zorder=-2000)
        ax.set_title("I = $(I), σ = $(σ)", pad=0.1)
        ax.set_xlabel("Pulse time", labelpad=-10.0)
        ax.set_ylabel("Phase shift", labelpad=-20.0)
    

    end

end

fig.tight_layout(pad=0.3)
save_figure(fig, "./figures/phase_response_curves/van_der_pol_noise_induced.svg")

## Amplitude-phase model ======================================================
using OscillatorPopulation
using PyPlot
rc("font", family="arial")

fig, ax_array = subplots(3, 3, figsize=(6.25, 4.25))

for (i, I) = enumerate([1.5, 3.0, 6.0])
    
    for (j, σ) = enumerate([0.25, 0.4, 0.7])

        pulse_time = nothing
        phase_shift_array = []
        for i = 1:10
            df = load_data("./outputs/phase_response_curves/amplitude_phase/I=$(I)_σ=$(σ)_r=$(i).csv")
            pulse_time = df[:, "pulse_time"]
            push!(phase_shift_array, df[:, "phase_shift"])
        end
        
        ax = ax_array[i, j]
        
        phase_shift = [cmean([x[i] for x in phase_shift_array]) for i in 1:length(phase_shift_array[1])]
        phase_shift[phase_shift .> 0.5] .-= 1  # map [0, 1] to [-0.5, 0.5]
        phase_shift_error = [cstd([x[i] for x in phase_shift_array]) for i in 1:length(phase_shift_array[1])]
        
        ax.errorbar(pulse_time, phase_shift, yerr=phase_shift_error, fmt=".", color="black")
        
        # Draw a grid
        grid_color = fill(0.8, 3)
        ax.hlines(0.0, 0, 1, color=grid_color, zorder=-1000)
        ax.vlines(0.5, -0.5, 0.5, color=grid_color, zorder=-1000)
        ax.set_xlim(0, 1)
        ax.set_xticks(0:1.0:1)
        ax.set_ylim(-0.5, 0.5)
        ax.set_yticks(-0.5:1.0:0.5)
        plot_events([0 0.5], ax=ax, ylims=[-0.5, 0.5], zorder=-2000)
        ax.set_title("I = $(I), σ = $(σ)", pad=0.1)
        ax.set_xlabel("Pulse time", labelpad=-10.0)
        ax.set_ylabel("Phase shift", labelpad=-20.0)
    
    end

end

fig.tight_layout(pad=0.3)
save_figure(fig, "./figures/phase_response_curves/amplitude_phase.svg")
