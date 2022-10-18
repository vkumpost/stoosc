using OscillatorPopulation
using DifferentialEquations

## Kim-Forger model ===========================================================
## ODE reference --------------------------------------------------------------
model = load_model("kim-forger", "ode")
set_timespan!(model, 100.0)
set_solver!(model, saveat=0.01)
set_parameter!(model, ["A", "τ"], [0.1, 3.66])
simulation_function = create_simulation_function(
    ["phase_coherence", "mean_phase", "phase_coherence_population", "collective_phase"],
    transient=0.5
)

println("Etimating Arnold tongue for ODE")
df = scan_arnold(model, simulation_function;
    input_amplitudes=range(0.0, 0.08, length=101),
    input_periods=range(0.75, 1.25, length=101),
    input_duty_cycles=[0.5],
    input_parameter="I",
    show_progress=true
);

save_data(df, "./outputs/arnold_tongues/kim_forger/arnold_tongue_ode.csv")

## Stochastic model -----------------------------------------------------------
model = load_model("kim-forger", "sde")
set_timespan!(model, 100.0)
set_solver!(model, saveat=0.01)
set_parameter!(model, ["A", "τ"], [0.1, 3.66])

model_jump = load_model("kim-forger", "jump")
set_timespan!(model_jump, 100.0)
set_solver!(model_jump, saveat=0.01)
set_parameter!(model_jump, ["A", "τ"], [0.1, 3.66])

simulation_function = create_simulation_function(
    ["phase_coherence", "mean_phase", "phase_coherence_population", "collective_phase"],
    transient=0.5,
    trajectories=1000,
    subpopulations=[1, 10, 100]
)

for σ = [0.001, 0.002, 0.003, 0.005, 0.01, 0.02, 0.03, 0.05, 0.0316]

    local df

    println("Etimating Arnold tongue for σ=$(σ)")

    Ω = 1/σ^2
    if Ω < 1000
        println("   use JUMP model.")
        model_simulation = deepcopy(model_jump)
        set_parameter!(model_simulation, ["Ω"], [Ω])
    else
        println("   use SDE model.")
        model_simulation = deepcopy(model)
        set_parameter!(model_simulation, ["σ"], [σ])
    end

    df = scan_arnold(model_simulation, simulation_function;
        input_amplitudes=range(0.0, 0.08, length=101),
        input_periods=range(0.75, 1.25, length=101),
        input_duty_cycles=[0.5],
        input_parameter="I",
        show_progress=true
    )

    save_data(df, "./outputs/arnold_tongues/kim_forger/arnold_tongue_σ=$(σ).csv")

end

# Constant volume -------------------------------------------------------------
for Ω0 = [10_000, 20_000, 100_000, 600_000]
    
    for n = [1, 2, 3, 6, 10, 20, 30, 60, 100, 200, 300, 600, 1_000] 
    
        local df, simulation_function

        Ω = round(Int, Ω0/n)
        println("Etimating Arnold tongue for n=$(n) and Ω=$(Ω)")

        if Ω < 1000
            println("   use JUMP model.")
            model_simulation = deepcopy(model_jump)
            set_parameter!(model_simulation, ["Ω"], [Ω])
        else
            println("   use SDE model.")
            model_simulation = deepcopy(model)
            σ = 1/sqrt(Ω)
            set_parameter!(model_simulation, ["σ"], [σ])
        end

        simulation_function = create_simulation_function(
            ["phase_coherence", "mean_phase", "phase_coherence_population", "collective_phase"],
            transient=0.5,
            trajectories=n
        )

        df = scan_arnold(model_simulation, simulation_function;
            input_amplitudes=range(0.0, 0.08, length=101),
            input_periods=range(0.75, 1.25, length=101),
            input_duty_cycles=[0.5],
            input_parameter="I",
            show_progress=true,
            catch_errors=false
        )

        save_data(df, "./outputs/arnold_tongues/kim_forger_constant_volume/arnold_tongue_n=$(n)_Ω=$(Ω).csv")

    end

end

## Limit cycle Van der Pol model ==============================================
## ODE reference --------------------------------------------------------------
model = load_model("van-der-pol", "ode")
set_parameter!(model, ["d", "B", "I", "τ"], [2, 10, 0, 7.63])

set_timespan!(model, 100.0)
set_solver!(model, saveat=0.01)

simulation_function = create_simulation_function(
    ["phase_coherence", "mean_phase", "phase_coherence_population", "collective_phase"],
    transient=0.5
)

println("Etimating Arnold tongue for ODE")
df = scan_arnold(model, simulation_function;
    input_amplitudes=range(0.0, 0.4, length=101),
    input_periods=range(0.75, 1.25, length=101),
    input_duty_cycles=[0.5],
    input_parameter="I",
    show_progress=true
)
save_data(df, "./outputs/arnold_tongues/van_der_pol_limit_cycle/arnold_tongue_ode.csv")

## Stochastic model -----------------------------------------------------------
model = load_model("van-der-pol", "sde")
set_parameter!(model, ["d", "B", "I", "τ", "σ"], [2, 10, 0, 7.63, 0.1])

set_timespan!(model, 100.0)
set_solver!(model, EM(), dt=0.001, saveat=0.01)

simulation_function = create_simulation_function(
    ["phase_coherence", "mean_phase", "phase_coherence_population", "collective_phase"],
    transient=0.5,
    trajectories=1000,
    subpopulations=[1, 10, 100]
)

for σ = [0.005, 0.01, 0.02, 0.03, 0.05, 0.1, 0.2, 0.3, 0.5]

    local df

    println("Etimating Arnold tongue for σ=$(σ)")

    set_parameter!(model, ["σ"], [σ])

    df = scan_arnold(model, simulation_function;
        input_amplitudes=range(0.0, 0.4, length=11),
        input_periods=range(0.75, 1.25, length=11),
        input_duty_cycles=[0.5],
        input_parameter="I",
        show_progress=true
    )

    save_data(df, "./outputs/arnold_tongues/van_der_pol_limit_cycle/arnold_tongue_σ=$(σ).csv")

end

## Noise-induced Van der Pol model ============================================
## ODE reference --------------------------------------------------------------
model = load_model("van-der-pol", "ode")
set_parameter!(model, ["d", "B", "I", "τ"], [-0.1, 1, 0, 6.2])

set_solver!(model, saveat=0.01)
set_timespan!(model, 100.0)

println("Etimating Arnold tongue for ODE")
df = scan_arnold(model, simulation_function;
    input_amplitudes=range(0.0, 0.4, length=101),
    input_periods=range(0.75, 1.25, length=101),
    input_duty_cycles=[0.5],
    input_parameter="I",
    show_progress=true
)

save_data(df, "./outputs/arnold_tongues/van_der_pol_noise_induced/arnold_tongue_ode.csv")

## Stochastic model -----------------------------------------------------------
model = load_model("van-der-pol", "sde")
set_parameter!(model, ["d", "B", "I", "τ", "σ"], [-0.1, 1, 0, 6.2, 0.2])

set_timespan!(model, 100.0)
set_solver!(model, EM(), dt=0.001, saveat=0.01)

for σ = [0.005, 0.01, 0.02, 0.03, 0.05, 0.1, 0.2, 0.3, 0.5]

    local df

    println("Etimating Arnold tongue for σ=$(σ)")

    set_parameter!(model, ["σ"], [σ])

    df = scan_arnold(model, simulation_function;
        input_amplitudes=range(0.0, 0.4, length=11),
        input_periods=range(0.75, 1.25, length=11),
        input_duty_cycles=[0.5],
        input_parameter="I",
        show_progress=true
    )

    save_data(df, "./outputs/arnold_tongues/van_der_pol_noise_induced/arnold_tongue_σ=$(σ).csv")

end

## Amplitude-phase model ======================================================
## ODE reference --------------------------------------------------------------
model = load_model("amplitude-phase", "ode")
set_parameter!(model, ["λ", "A", "T", "I"], [1.0, 1.0, 1.0, 0.0])

set_timespan!(model, 100.0)
set_solver!(model, saveat=0.01)

simulation_function = create_simulation_function(
    ["phase_coherence", "mean_phase", "phase_coherence_population", "collective_phase"],
    transient=0.5
)

println("Etimating Arnold tongue for ODE")
df = scan_arnold(model, simulation_function;
    input_amplitudes=range(0.0, 3.0, length=101),
    input_periods=range(0.75, 1.25, length=101),
    input_duty_cycles=[0.5],
    input_parameter="I",
    show_progress=true
)
save_data(df, "./outputs/arnold_tongues/amplitude_phase/arnold_tongue_ode.csv")

# SDE model -------------------------------------------------------------------
model = load_model("amplitude-phase", "sde")
set_parameter!(model, ["λ", "A", "T", "I"], [1.0, 1.0, 1.0, 0.0])

set_timespan!(model, 100.0)
set_solver!(model, EM(), dt=0.001, saveat=0.01)

simulation_function = create_simulation_function(
    ["phase_coherence", "mean_phase", "phase_coherence_population", "collective_phase"],
    transient=0.5,
    trajectories=1000,
    subpopulations=[1, 10, 100]
)

for σ = [0.01, 0.02, 0.03, 0.05, 0.1, 0.2, 0.3, 0.5, 1.0, 2.0]

    local df

    println("Etimating Arnold tongue for σ=$(σ)")

    set_parameter!(model, ["σ"], [σ])

    df = scan_arnold(model, simulation_function;
        input_amplitudes=range(0.0, 3.0, length=101),
        input_periods=range(0.75, 1.25, length=101),
        input_duty_cycles=[0.5],
        input_parameter="I",
        show_progress=true
    )

    save_data(df, "./outputs/arnold_tongues/amplitude_phase/arnold_tongue_σ=$(σ).csv")

end

## Heterogeneous population ===================================================
model = load_model("kim-forger", "ode")
set_timespan!(model, 100.0)
set_solver!(model, saveat=0.01)
set_parameter!(model, ["A", "τ"], [0.1, 3.66])
simulation_function = create_simulation_function(
    ["phase_coherence", "mean_phase", "phase_coherence_population", "collective_phase", "winding_number"],
    transient=0.5
)

for σ = [0.001, 0.002, 0.003, 0.005, 0.01, 0.02, 0.03, 0.05, 0.1, 0.2, 0.3, 0.5, 1.0]

    local simulation_function, df

    parameter_values = generate_random_values(0.1, σ, 1000; lower=0, seed=833)

    simulation_function = create_simulation_function(
        ["phase_coherence", "mean_phase", "phase_coherence_population", "collective_phase", "winding_number"],
        transient=0.5,
        trajectories=1000,
        parameters=(["A"], parameter_values)
    )

    println("Etimating Arnold tongue for ODE with varying parameters (σ = $(σ))")
    df = scan_arnold(model, simulation_function;
        input_amplitudes=range(0.0, 0.08, length=101),
        input_periods=range(0.75, 1.25, length=101),
        input_duty_cycles=[0.5],
        input_parameter="I",
        show_progress=true
    );

    save_data(df, "./outputs/arnold_tongues/heterogeneity/arnold_tongue_ode_σ=$(σ).csv")

end
