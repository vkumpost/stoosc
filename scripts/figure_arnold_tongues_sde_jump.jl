using stoosc
rc("font", family="arial")

fig, ax_arr = subplots(2, 2, figsize=(7, 6))

I_max = 0.3

filename = joinpath("arnold_tongues", "model01", "sde_n=100_Ω=1000.csv")
arnold_tongue = load_data(filename)
entrainment_area_ode = estimate_entrainment_area(arnold_tongue, I_max)
println("ode entrainment area = $(entrainment_area_ode)")
plot_arnold_tongue(arnold_tongue, I_max, ax=ax_arr[1, 1])
ax_arr[1, 1].set_title("SDE model; n = 100; Ω = 1000")

filename = joinpath("arnold_tongues", "model01", "sde_n=100_Ω=1000_jump.csv")
arnold_tongue = load_data(filename)
entrainment_area_ode = estimate_entrainment_area(arnold_tongue, I_max)
println("ode entrainment area = $(entrainment_area_ode)")
plot_arnold_tongue(arnold_tongue, I_max, ax=ax_arr[1, 2])
ax_arr[1, 2].set_title("Gillespie method; n = 100; Ω = 1000")

filename = joinpath("arnold_tongues", "model01", "sde_n=1000_Ω=1000.csv")
arnold_tongue = load_data(filename)
entrainment_area_ode = estimate_entrainment_area(arnold_tongue, I_max)
println("ode entrainment area = $(entrainment_area_ode)")
plot_arnold_tongue(arnold_tongue, I_max, ax=ax_arr[2, 1])
ax_arr[2, 1].set_title("SDE model; n = 1000; Ω = 1000")

filename = joinpath("arnold_tongues", "model01", "sde_n=1000_Ω=1000_jump.csv")
arnold_tongue = load_data(filename)
entrainment_area_ode = estimate_entrainment_area(arnold_tongue, I_max)
println("ode entrainment area = $(entrainment_area_ode)")
plot_arnold_tongue(arnold_tongue, I_max, ax=ax_arr[2, 2])
ax_arr[2, 2].set_title("Gillespie method; n = 1000; Ω = 1000")

fig.tight_layout()
save_figure(fig, "arnold_tonuges_sde_jump.svg")
# ax_arr[1, 1].tight_layout()
# filename = joinpath("arnold_tongue", "arnold_deterministic.svg")
# 
# close("all")