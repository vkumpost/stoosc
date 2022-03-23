import CurveFit
using Printf
using stoosc
rc("font", family="arial")

# Maximal considered input intensity
I_max = 0.3

## Deterministic Arnold tongue
filename = joinpath("arnold_tongues", "model01", "ode.csv")
arnold_tongue = load_data(filename)
entrainment_area_ode = estimate_entrainment_area(arnold_tongue, I_max)
println("ode entrainment area = $(entrainment_area_ode)")
fig2, ax2 = subplots(figsize=(2.5, 2.25))
plot_arnold_tongue(arnold_tongue, I_max, ax=ax2)
ax2.set_title("Deterministic")
fig2.tight_layout()
filename = joinpath("arnold_tongues", "model01", "arnold_deterministic.svg")
save_figure(fig2, filename)

## Arnold tongue for a stochastic model with many oscillators
filename = joinpath("arnold_tongues", "model01", "sde_n=1000_σ=0.005.csv")
arnold_tongue = load_data(filename)
entrainment_area = estimate_entrainment_area(arnold_tongue, I_max)
println("entrainment area = $(entrainment_area)")
fig2, ax2 = subplots(figsize=(2.5, 2.25))
plot_arnold_tongue(arnold_tongue, I_max, ax=ax2)
ax2.set_title("n = 1000, σ = 0.005")
fig2.tight_layout()
filename = joinpath("arnold_tongues", "model01", "arnold_many_oscillators.svg")
save_figure(fig2, filename)

## Arnold tongue for a stochastic model with few oscillators
filename = joinpath("arnold_tongues", "model01", "sde_n=10_σ=0.005.csv")
arnold_tongue = load_data(filename)
entrainment_area = estimate_entrainment_area(arnold_tongue, I_max)
println("entrainment area = $(entrainment_area)")
fig2, ax2 = subplots(figsize=(2.5, 2.25))
plot_arnold_tongue(arnold_tongue, I_max, ax=ax2)
ax2.set_title("n = 10, σ = 0.005")
fig2.tight_layout()
filename = joinpath("arnold_tongues", "model01", "arnold_few_oscillators.svg")
save_figure(fig2, filename)

## Increasing noise for constant population size
fig, ax = subplots(figsize=(7, 3))
ax.plot(log10.([0.001, 0.03]), [entrainment_area_ode, entrainment_area_ode], "--",
    color="black", label="Deterministic")

# Save the values for the maximal entrainment area
maximum_entrainment_area = Dict(
    "n" => Float64[],
    "σ" => Float64[],
    "entrainment_area" => Float64[]
)

x = [0.001, 0.002, 0.003, 0.005, 0.01, 0.02, 0.03]  # noise intensitiess
for n = [1000, 100, 10, 1]  # number of oscillators
    # for each population size

    y = Float64[]  # entrainment area

    for σ = x  
        # for each noise value

        # Load the arnold tongue for given n and σ
        filename = joinpath("arnold_tongues", "model01", "sde_n=$(n)_σ=$(σ).csv")
        arnold_tongue = load_data(filename)
        
        # Save arnold tongues for the individual points in the figure
        fig2, ax2 = subplots(figsize=(2.5, 2.25))
        plot_arnold_tongue(arnold_tongue, I_max, ax=ax2)
        ax2.set_title("n = $(n); σ = $(σ)")
        fig2.tight_layout()
        filename = joinpath("arnold_tongues", "model01", "sde_n_$(n)_σ_$(σ).svg")
        save_figure(fig2, filename)

        # Calculate and save the entrainment area
        entrainment_area = estimate_entrainment_area(arnold_tongue, I_max)
        push!(y, entrainment_area)

    end

    # Plot entrainment area versus noise intensity
    x_log = log10.(x)
    f_fit = CurveFit.curve_fit(CurveFit.Polynomial, x_log, y, 2)
    h = ax.plot(x_log, y, "o", label="n = $n")

    # Fit a polynomial for a smooth curve interpolation and plot it
    x_new = range(x_log[1], x_log[end], length=100)
    y_new = f_fit.(x_new)
    ax.plot(x_new, y_new, "-", color=h[1].get_color())

    # Find point of maximal entrainment area and save it into a dictionary
    index = argmax(y_new)
    push!(maximum_entrainment_area["σ"], x_new[index])
    push!(maximum_entrainment_area["n"], n)
    push!(maximum_entrainment_area["entrainment_area"], y_new[index])
    println("Maximum for n = $n is EA = $(y_new[index]) at σ ≈ $(10^x_new[index])")

end

# Set labels for the figure
ax.set_xlabel("log\$_{10}\$(Noise intensity)")
ax.set_ylabel("Entrainment area")
ax.set_title("Entrainment area for constant number of oscillators (n)")
ax.legend(edgecolor="black", framealpha=1.0, loc="best", ncol=1)
fig.tight_layout()

# Save the main figure
filename = joinpath("arnold_tongues", "model01", "overview_n.svg")
save_figure(fig, filename)

## Plot maximal entrainment area and corresponding noise intenisty for each n 
fig, ax_arr = subplots(1, 2, figsize=(7, 3))
n = log10.(maximum_entrainment_area["n"])
σ = maximum_entrainment_area["σ"]
entrainment_area = maximum_entrainment_area["entrainment_area"]

ax_arr[1].plot(n, σ, "o", color="black")
ax_arr[1].set_xlabel("log\$_{10}\$(Number of oscillators, n)")
ax_arr[1].set_ylabel("log\$_{10}\$(Noise intensity, σ)")
ax_arr[1].set_title("Noise intensity for maximal entrainment area")

ax_arr[2].plot(n, entrainment_area, "o", color="black")
ax_arr[2].set_xlabel("log\$_{10}\$(Number of oscillators, n)")
ax_arr[2].set_ylabel("Entrainment area")
ax_arr[2].set_title("Maximal entrainment area")

fig.tight_layout()
save_figure(fig, "arnold_tongues", "model01", "maximal_entrainment_n.svg")

## Increasing number of oscillators for constant system volume
fig, ax = subplots(figsize=(7, 3))
ax.plot(log10.([1, 1000]), [entrainment_area_ode, entrainment_area_ode], "--",
    color="black", label="Deterministic")

# Save the values for the maximal entrainment area
maximum_entrainment_area = Dict(
    "V" => Float64[],
    "n" => Float64[],
    "entrainment_area" => Float64[]
)

n_arr = [1, 4, 10, 40, 100, 400, 1_000]
for i = [10, 1, 0.4, 0.2, 0.1]
    Ω_arr = convert.(Int, [1_000_000, 250_000, 100_000, 25_000, 10_000, 2_500, 1_000] .* i)
    y = Float64[]
    x = n_arr
    for (n, Ω) = zip(n_arr, Ω_arr)

        filename = joinpath("arnold_tongues", "model01", "sde_n=$(n)_Ω=$(Ω).csv")
        arnold_tongue = load_data(filename)

        # Save arnold tongues for the individual points in the figure
        fig2, ax2 = subplots(figsize=(2.5, 2.25))
        plot_arnold_tongue(arnold_tongue, I_max, ax=ax2)
        ax2.set_title("n = $(n); Ω = $(Ω)")
        fig2.tight_layout()
        filename = joinpath("arnold_tongues", "model01", "sde_n_$(n)_Ω_$(Ω).svg")
        save_figure(fig2, filename)
        
        entrainment_area = estimate_entrainment_area(arnold_tongue, I_max)
        push!(y, entrainment_area)
        
    end
    x_log = log10.(x)
    f_fit = CurveFit.curve_fit(CurveFit.Polynomial, x_log, y, 3)
    x_new = range(x_log[1], x_log[end], length=100)
    y_new = f_fit.(x_new)

    index = argmax(y_new)
    push!(maximum_entrainment_area["V"], Ω_arr[1])
    push!(maximum_entrainment_area["n"], x_new[index])
    push!(maximum_entrainment_area["entrainment_area"], y_new[index])
    println("Maximum for i = $i is EA = $(y_new[index]) at n ≈ $(10^x_new[index])")

    plot_label = @sprintf("V = %.0e", Ω_arr[1])
    h = ax.plot(x_log, y, "o", label=plot_label)
    ax.plot(x_new, y_new, "-", color=h[1].get_color())

end

# Set labels for the figure
ax.set_xlabel("Number of oscillators")
ax.set_xticks(log10.(n_arr))
ax.set_xticklabels(n_arr)
ax.set_ylabel("Entrainment area")
ax.set_title("Entrainment area for constant total volume (V)")
ax.legend(edgecolor="black", framealpha=1.0, loc="lower left", ncol=3)
fig.tight_layout()

filename = joinpath("arnold_tongues", "overview_V.svg")
save_figure(fig, filename)

## Plot maximal entrainment area and corresponding noise intenisty for each n 
fig, ax_arr = subplots(1, 2, figsize=(7, 3))
V = log10.(maximum_entrainment_area["V"])[2:end]
n = maximum_entrainment_area["n"][2:end]
entrainment_area = maximum_entrainment_area["entrainment_area"][2:end]

ax_arr[1].plot(V, n, "o", color="black")
ax_arr[1].set_xlabel("log\$_{10}\$(Total volume, V)")
ax_arr[1].set_ylabel("log\$_{10}\$(Number of oscillators, n)")
ax_arr[1].set_title("Total volume for maximal entrainment area")

ax_arr[2].plot(V, entrainment_area, "o", color="black")
ax_arr[2].set_xlabel("log\$_{10}\$(Total volume, V)")
ax_arr[2].set_ylabel("Entrainment area")
ax_arr[2].set_title("Maximal entrainment area")

fig.tight_layout()
save_figure(fig, "arnold_tongues", "model01", "maximal_entrainment_V.svg")
