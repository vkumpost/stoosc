using stoosc
rc("font", family="arial")

MODEL = "model02b"  # model01, model02, model02b

if MODEL == "model01"
    I_strings = ["0.1", "0.25", "0.3"]
    σ_strings = ["0.003", "0.01", "0.03"]
else
    I_strings = ["3.0", "3.5", "5.0"]
    σ_strings = ["0.01", "0.08", "0.2"]
end


fig, axarr = subplots(3, 3, figsize=(6.5, 4.5))
for (i, I_string) in enumerate(I_strings)
    for (j, σ_string) in enumerate(σ_strings)
        println("I = $(I_string), σ = $(σ_string); ")
        phase_shift_arr = []
        t = nothing
        for r = 1:10  # 10
            filename = joinpath("prcs", MODEL, "sde_I=$(I_string)_σ=$(σ_string)_r=$(r).csv")
            df = load_data(filename)
            push!(phase_shift_arr, df[:, "phase_shift"])
            t = df[:, "time"]
        end
        
        phase_shift = [cmean([2π*x[i] for x in phase_shift_arr])/2π for i in 1:length(phase_shift_arr[1])]
        phase_shift_std = [cstd([2π*x[i] for x in phase_shift_arr])/2π for i in 1:length(phase_shift_arr[1])]
        axarr[i, j].errorbar(t, phase_shift,
            yerr=phase_shift_std, fmt=".", color="black")

        # Draw a grid
        grid_color = fill(0.8, 3)
        axarr[i, j].hlines(0.0, 0, 1, color=grid_color, zorder=-1000)
        axarr[i, j].vlines(0.5, -0.5, 0.5, color=grid_color, zorder=-1000)
        axarr[i, j].set_xlim(0, 1)
        axarr[i, j].set_xticks(0:1.0:1)
        axarr[i, j].set_ylim(-0.5, 0.5)
        axarr[i, j].set_yticks(-0.5:1.0:0.5)
        plot_events([0 0.5], ax=axarr[i, j], ylims=[-0.5, 0.5], zorder=-2000)
        axarr[i, j].set_title("I = $(I_string), σ = $(σ_string)", pad=0.1)
        axarr[i, j].set_xlabel("Pulse time", labelpad=0.0)
        axarr[i, j].set_ylabel("Phase shift", labelpad=0.0)
    end
end

fig.tight_layout(pad=0)
save_figure(fig, "prcs", MODEL, "PRC.svg")
