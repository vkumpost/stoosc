using stoosc
rc("font", family="arial")

MODEL = "model01"

if MODEL == "model01"
    I = "0.02"  # 0.02, 0.05, 0.1
    σ_string_arr = ["0.001", "0.003", "0.01", "0.03"]
    title_string = "Reentrainment after jet lag (I = $I)"
elseif MODEL == "model02"
    I = "0.5"
    σ_string_arr = ["0.02", "0.1", "0.15", "0.2"]
    title_string = "Limit cycle osillator (I = $I)"
elseif MODEL == "model02b"
    I = "0.5"
    σ_string_arr = ["0.02", "0.1", "0.15", "0.2"]
    title_string = "Noise-induced osillator (I = $I)"
end

phase_diff_mean_arr = []
phase_diff_std_arr = []
pre_phase_diff_mean_arr = []
pre_phase_diff_std_arr = []
for σ_string in σ_string_arr
    global phase_diff_mean_arr, phase_diff_std_arr
    local filename

    xarr = []
    pre_xarr = []

    for i = 1:10
        filename = "sde_I=$(I)_σ=$(σ_string)_r=$(i).csv"
        fullfilename = joinpath("jet_lags", MODEL, filename)
        df = load_data(fullfilename)

        x = (mean(df[:, "pre_phases"]) .- df[:, "post_phases"])
        push!(xarr, x)

        pre_x = (mean(df[:, "pre_phases"]) .- df[:, "pre_phases"])
        push!(pre_xarr, pre_x)
    end

    phase_diff_mean = mean(xarr)
    phase_diff_std = std(xarr)

    push!(phase_diff_mean_arr, phase_diff_mean)
    push!(phase_diff_std_arr, phase_diff_std)

    pre_phase_diff_mean = mean(pre_xarr)
    pre_phase_diff_std = std(pre_xarr)

    push!(pre_phase_diff_mean_arr, pre_phase_diff_mean)
    push!(pre_phase_diff_std_arr, pre_phase_diff_std)

end


colors = ["gray", "black", "red", "blue"]
fig, ax = subplots(figsize=(6.5, 2.5))
pre_max = 5
["σ = 0.03", "σ = 0.01", "σ = 0.003", "σ = 0.001"]
for i = 1:length(σ_string_arr)
    ax.errorbar(-pre_max:-1, pre_phase_diff_mean_arr[i][21-pre_max:end], yerr=pre_phase_diff_std_arr[i][21-pre_max:end], fmt="o", color=colors[i], label="σ = $(σ_string_arr[i])")
    ax.errorbar(1:20, phase_diff_mean_arr[i], yerr=phase_diff_std_arr[i], fmt="o", color=colors[i])
end
ax.legend(edgecolor="black", framealpha=1.0, ncol=1, loc=2)
ax.plot([-pre_max-.5, 20+0.5], [0, 0], color="black", linestyle="--")
ax.plot([0, 0], [-0.1, 0.5], color="black", linestyle="--")
ax.set_xlabel("Days")
ax.set_ylabel("Phase difference (days)")
ax.set_title(title_string, pad=0.1)
ax.set_xlim(-5.5, 20.5)
ax.set_ylim(-0.1, 0.5)
fig.tight_layout()

filename = joinpath("jet_lags", MODEL, "jet_lag_I=$(I).svg")
save_figure(fig, filename)
