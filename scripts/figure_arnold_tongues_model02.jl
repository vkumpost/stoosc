import CurveFit
using Printf
using stoosc
rc("font", family="arial")

MODEL = "model02b"  # model02 or model02b

# Maximal considered input intensity
I_max = 3.0

## Deterministic Arnold tongue
filename = joinpath("arnold_tongues", MODEL, "ode.csv")
arnold_tongue = load_data(filename)
entrainment_area_ode = estimate_entrainment_area(arnold_tongue, I_max)
println("ode entrainment area = $(entrainment_area_ode)")
fig2, ax2 = subplots(figsize=(2.5, 2.25))
plot_arnold_tongue(arnold_tongue, I_max, ax=ax2)
ax2.set_title("Deterministic")
fig2.tight_layout()
filename = joinpath("arnold_tongues", MODEL, "arnold_deterministic.svg")
save_figure(fig2, filename)

## Arnold tongue for a stochastic model with many cells
arnold_tongue = load_data("arnold_tongues", MODEL, "sde_n=1000_σ=0.2.csv")
entrainment_area = estimate_entrainment_area(arnold_tongue, I_max)
println("entrainment area = $(entrainment_area)")
fig2, ax2 = subplots(figsize=(2.5, 2.25))
plot_arnold_tongue(arnold_tongue, I_max, ax=ax2)
ax2.set_title("n = 1000, σ = 0.2")
fig2.tight_layout()
filename = joinpath("arnold_tongues", MODEL, "arnold_many_cells.svg")
save_figure(fig2, filename)

## Arnold tongue for a stochastic model with few cells
arnold_tongue = load_data("arnold_tongues", MODEL, "sde_n=10_σ=0.2.csv")
entrainment_area = estimate_entrainment_area(arnold_tongue, I_max)
println("entrainment area = $(entrainment_area)")
fig2, ax2 = subplots(figsize=(2.5, 2.25))
plot_arnold_tongue(arnold_tongue, I_max, ax=ax2)
ax2.set_title("n = 10, σ = 0.2")
fig2.tight_layout()
filename = joinpath("arnold_tongues", MODEL, "arnold_few_cells.svg")
save_figure(fig2, filename)

## Increasing noise for constant population size
fig, ax = subplots(figsize=(7, 3))
ax.plot(log10.([0.01, 1.0]), [entrainment_area_ode, entrainment_area_ode], "--",
    color="black", label="Deterministic")

# Save the values for the maximal entrainment area
maximum_entrainment_area = Dict(
    "n" => Float64[],
    "σ" => Float64[],
    "entrainment_area" => Float64[]
)

x = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1.0]  # noise intensitiess
for n = [1, 10, 100, 1000]  # number of cells
    # for each population size

    y = Float64[]  # entrainment area

    for σ = x  
        # for each noise value

        # Load the arnold tongue for given n and σ
        filename = joinpath("arnold_tongues", MODEL, "sde_n=$(n)_σ=$(σ).csv")
        arnold_tongue = load_data(filename)
        
        # Save arnold tongues for the individual points in the figure
        fig2, ax2 = subplots(figsize=(2.5, 2.25))
        plot_arnold_tongue(arnold_tongue, I_max, ax=ax2)
        ax2.set_title("n = $(n); σ = $(σ)")
        fig2.tight_layout()
        filename = joinpath("arnold_tongues", MODEL, "sde_n_$(n)_σ_$(σ).svg")
        save_figure(fig2, filename)

        # Calculate and save the entrainment area
        entrainment_area = estimate_entrainment_area(arnold_tongue, I_max)
        push!(y, entrainment_area)

    end

    # Plot entrainment area versus noise intensity
    x_log = log10.(x)
    if MODEL == "model02"
        f_fit = CurveFit.curve_fit(CurveFit.Polynomial, x_log, y, 2)
    elseif MODEL == "model02b"
        f_fit = CurveFit.curve_fit(CurveFit.Polynomial, x_log, y, 3)
    end
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
    # ax.plot(x_new[index], y_new[index], "x", markersize=10, color=h[1].get_color())
    println("Maximum for n = $n is at σ ≈ $(10^x_new[index])")

end

# Set labels for the figure
ax.set_xlabel("log\$_{10}\$(Noise intensity)")
ax.set_ylabel("Entrainment area")
ax.set_title("Limit cycle oscillator")
ax.legend(edgecolor="black", framealpha=1.0, loc="best", ncol=2)
fig.tight_layout()

# Save the main figure
filename = joinpath("arnold_tongues", MODEL, "overview_n.svg")
save_figure(fig, filename)

# ## Plot maximal entrainment area and corresponding noise intenisty for each n 
# fig, ax_arr = subplots(1, 2, figsize=(7, 3))
# n = log10.(maximum_entrainment_area["n"])
# σ = maximum_entrainment_area["σ"]
# entrainment_area = maximum_entrainment_area["entrainment_area"]

# ax_arr[1].plot(n, σ, "o", color="black")
# ax_arr[1].set_xlabel("log\$_{10}\$(Number of cells, n)")
# ax_arr[1].set_ylabel("log\$_{10}\$(Noise intensity, σ)")
# ax_arr[1].set_title("Noise intensity for maximal entrainment area")

# ax_arr[2].plot(n, entrainment_area, "o", color="black")
# ax_arr[2].set_xlabel("log\$_{10}\$(Number of cells, n)")
# ax_arr[2].set_ylabel("Entrainment area")
# ax_arr[2].set_title("Maximal entrainment area")

# fig.tight_layout()
# save_figure(fig, "arnold_tongues", MODEL, "maximal_entrainment_n.svg")
