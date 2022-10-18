using OscillatorPopulation
using Statistics
using PyPlot
rc("font", family="arial")

## Kim-Forger model ===========================================================
I_array = [0.005, 0.015, 0.03]
σ_array = [0.001, 0.008, 0.015, 0.03]
color_array = ["gray", "black", "red", "blue"]

for I = I_array
    fig, ax = subplots(figsize=(6, 2.0))
    for (i, σ) = enumerate(σ_array)
        df = load_data("./outputs/jet_lags/kim_forger/I=$(I)_σ=$(σ).csv")

        t = df[:, 1]
        X = Matrix(df[:, 2:end])
        n = size(X, 1)
        x = fill(NaN, n)
        x_std = fill(NaN, n)
        for ix in 1:n
            x[ix] = -mean(X[ix, .!isnan.(X[ix, :])])
            x_std[ix] = std(X[ix, .!isnan.(X[ix, :])])
        end

        ax.errorbar(
            t,
            x,
            yerr=x_std,
            fmt="o",
            color=color_array[i],
            label="σ = $(σ)"
        )

    end

    ax.plot([-100, 100], [0, 0], "--", color="black")
    ax.plot([0, 0], [-100, 100], "--", color="black")
    ax.set_xlim(-5.5, 20.5)
    ax.set_ylim(-0.1, 0.5)
    ax.set_xlabel("Days", labelpad=0)
    ax.set_ylabel("Phase difference (days)", labelpad=0)
    ax.set_title("Reentrainment after jet lag (I=$(I))", pad=0, loc="left")
    ax.legend(edgecolor="black", framealpha=1.0, ncol=1, loc=2)
    fig.tight_layout(pad=0.1)
    fig.show()
    save_figure(fig, "./figures/jet_lags/kim_forger_I=$(I).svg")

end


## Van der Pol limit cycle model ==============================================
I_array = [0.05]
σ_array = [0.001, 0.06, 0.1]
color_array = ["black", "red", "blue"]

for I = I_array
    fig, ax = subplots(figsize=(6, 2.0))
    for (i, σ) = enumerate(σ_array)
        df = load_data("./outputs/jet_lags/van_der_pol_limit_cycle/I=$(I)_σ=$(σ).csv")

        t = df[:, 1]
        X = Matrix(df[:, 2:end])
        n = size(X, 1)
        x = fill(NaN, n)
        x_std = fill(NaN, n)
        for ix in 1:n
            x[ix] = -mean(X[ix, .!isnan.(X[ix, :])])
            x_std[ix] = std(X[ix, .!isnan.(X[ix, :])])
        end

        ax.errorbar(
            t,
            x,
            yerr=x_std,
            fmt="o",
            color=color_array[i],
            label="σ = $(σ)"
        )

    end

    ax.plot([-100, 100], [0, 0], "--", color="black")
    ax.plot([0, 0], [-100, 100], "--", color="black")
    ax.set_xlim(-5.5, 20.5)
    ax.set_ylim(-0.1, 0.5)
    ax.set_xlabel("Days", labelpad=0)
    ax.set_ylabel("Phase difference (days)", labelpad=0)
    ax.set_title("Relaxation limit cycle oscillator (Van der Pol, I=$(I))", pad=0, loc="left")
    ax.legend(edgecolor="black", framealpha=1.0, ncol=1, loc=2)
    fig.tight_layout(pad=0.1)
    fig.show()
    save_figure(fig, "./figures/jet_lags/van_der_pol_limit_cycle.svg")

end

## Van der Pol noise-induced ==================================================
I_array = [0.05]
σ_array = [0.001, 0.06, 0.1]
color_array = ["black", "red", "blue"]

for I = I_array
    fig, ax = subplots(figsize=(6, 2))
    for (i, σ) = enumerate(σ_array)
        df = load_data("./outputs/jet_lags/van_der_pol_noise_induced/I=$(I)_σ=$(σ).csv")

        t = df[:, 1]
        X = Matrix(df[:, 2:end])
        n = size(X, 1)
        x = fill(NaN, n)
        x_std = fill(NaN, n)
        for ix in 1:n
            x[ix] = -mean(X[ix, .!isnan.(X[ix, :])])
            x_std[ix] = std(X[ix, .!isnan.(X[ix, :])])
        end

        ax.errorbar(
            t,
            x,
            yerr=x_std,
            fmt="o",
            color=color_array[i],
            label="σ = $(σ)"
        )

    end

    ax.plot([-100, 100], [0, 0], "--", color="black")
    ax.plot([0, 0], [-100, 100], "--", color="black")
    ax.set_xlim(-5.5, 20.5)
    ax.set_ylim(-0.1, 0.5)
    ax.set_xlabel("Days", labelpad=0)
    ax.set_ylabel("Phase difference (days)", labelpad=0)
    ax.set_title("Noise-induced oscillator (Van der Pol, I=$(I))", pad=0, loc="left")
    ax.legend(edgecolor="black", framealpha=1.0, ncol=1, loc=2)
    fig.tight_layout(pad=0.1)
    fig.show()
    save_figure(fig, "./figures/jet_lags/van_der_pol_noise_induced.svg")

end

## Amplitude-phase model ======================================================
I_array = [0.3]
σ_array = [0.25, 0.4, 0.7]
color_array = ["black", "red", "blue"]

for I = I_array
    fig, ax = subplots(figsize=(6, 2))
    for (i, σ) = enumerate(σ_array)
        df = load_data("./outputs/jet_lags/amplitude_phase/I=$(I)_σ=$(σ).csv")

        t = df[:, 1]
        X = Matrix(df[:, 2:end])
        n = size(X, 1)
        x = fill(NaN, n)
        x_std = fill(NaN, n)
        for ix in 1:n
            x[ix] = -mean(X[ix, .!isnan.(X[ix, :])])
            # x[ix] = mod(x[ix], 1)
            if x[ix] < -0.1
                x[ix] += 1
            end
    
            x_std[ix] = std(X[ix, .!isnan.(X[ix, :])])
        end

        ax.errorbar(
            t,
            x,
            yerr=x_std,
            fmt="o",
            color=color_array[i],
            label="σ = $(σ)"
        )

    end

    ax.plot([-100, 100], [0, 0], "--", color="black")
    ax.plot([0, 0], [-100, 100], "--", color="black")
    ax.set_xlim(-5.5, 20.5)
    ax.set_ylim(-0.05, 0.45)
    # ax.set_ylim(-1, 1)
    ax.set_xlabel("Days", labelpad=0)
    ax.set_ylabel("Phase difference (days)", labelpad=0)
    ax.set_title("Sinusoidal limit cycle oscillator (Amplitude-phase, I=$(I))", pad=0, loc="left")
    ax.legend(edgecolor="black", framealpha=1.0, ncol=1, loc=2)
    fig.tight_layout(pad=0.1)
    fig.show()
    save_figure(fig, "./figures/jet_lags/amplitude_phase.svg")

end
