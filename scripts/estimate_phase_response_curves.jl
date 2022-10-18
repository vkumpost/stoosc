using OscillatorPopulation
using DifferentialEquations

## Kim-Forger model ===========================================================
model = load_model("kim-forger", "sde")
set_timespan!(model, 100.0)
set_solver!(model, saveat=0.01)
set_parameter!(model, ["A", "τ"], [0.1, 3.66])

for σ = [0.003, 0.01, 0.03]

    for I = [0.03, 0.05, 0.08]
    
        set_parameter!(model, ["σ", "I"], [σ, I])
        for i = 1:10

            println("Working on I=$(I) σ=$(σ) r=$(i)")

            prc = estimate_prc(model,
                trajectories=1000,
                n_pulses=30,
                frp=1,
                show_plots=false
            )

            save_data(prc, "./outputs/phase_response_curves/kim_forger/I=$(I)_σ=$(σ)_r=$(i).csv")

        end
        
    end

end

## Limit cycle Van der Pol model ==============================================
model = load_model("van-der-pol", "sde")
set_timespan!(model, 100.0)
set_solver!(model, EM(), dt=0.001, saveat=0.01)
set_parameter!(model, ["B", "d", "τ"], [10.0, 2.0, 7.63])

for σ = [0.004, 0.03, 0.07]

    for I = [0.4, 0.45, 0.65]
    
        set_parameter!(model, ["σ", "I"], [σ, I])
        for i = 1:10

            println("Working on I=$(I) σ=$(σ) r=$(i)")

            prc = estimate_prc(model,
                trajectories=1000,
                n_pulses=30,
                frp=1,
                show_plots=false
            )

            save_data(prc, "./outputs/phase_response_curves/van_der_pol_limit_cycle/I=$(I)_σ=$(σ)_r=$(i).csv")

        end
        
    end

end

## Noise-induced Van der Pol model ============================================
model = load_model("van-der-pol", "sde")
set_timespan!(model, 100.0)
set_solver!(model, EM(), dt=0.001, saveat=0.01)
set_parameter!(model, ["B", "d", "τ"], [1.0, -0.1, 6.2])

for σ = [0.004, 0.03, 0.07]

    for I = [0.4, 0.45, 0.65]
    
        set_parameter!(model, ["σ", "I"], [σ, I])
        for i = 1:10

            println("Working on I=$(I) σ=$(σ) r=$(i)")

            prc = estimate_prc(model,
                trajectories=1000,
                n_pulses=30,
                frp=1,
                show_plots=false
            )

            save_data(prc, "./outputs/phase_response_curves/van_der_pol_noise_induced/I=$(I)_σ=$(σ)_r=$(i).csv")
        end
        
    end

end

## Amplitude-phase model ======================================================
model = load_model("amplitude-phase", "sde")
set_timespan!(model, 100.0)
set_solver!(model, EM(), dt=0.001, saveat=0.01)
set_parameter!(model, ["λ", "A", "T"], [1.0, 1.0, 1.0])

for σ = [0.25, 0.4, 0.7]

    for I = [1.5, 3.0, 6.0]
    
        set_parameter!(model, ["σ", "I"], [σ, I])
        for i = 1:10

            println("Working on I=$(I) σ=$(σ) r=$(i)")

            prc = estimate_prc(model,
                trajectories=1000,
                n_pulses=30,
                frp=1,
                show_plots=false
            )

            save_data(prc, "./outputs/phase_response_curves/amplitude_phase/I=$(I)_σ=$(σ)_r=$(i).csv")
        end
        
    end

end
