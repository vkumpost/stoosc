"""
`load_model(model_name::String, problem_type::String)`

Load a model.
"""
function load_model(model_name::String, problem_type::String)

    if model_name == "model01"
        return _load_model01(problem_type)
    elseif model_name == "model02"
        return _load_model02(problem_type)
    else
        error("Unknown model name!")
    end

end


function _load_model01(problem_type)

    function model!(du, u, p, t)

        # Variables
        X, Y, Z = u
    
        # Parameters
        A, τ, I = p
    
        # Equations
        du[1] = τ*kfr(Z, A) - τ*X + I  # dX
        du[2] = τ*X - τ*Y  # dY
        du[3] = τ*Y - τ*Z  # dZ
    
    end

    function noise!(du, u, p, t)

        # Variables
        X, Y, Z = u

        # Parameters
        A, τ, I, σ = p

        # Equations
        du[1, 1] = σ * sqrt(τ*kfr(Z, A))
        du[1, 2] = σ * -sqrt(τ*X)
        du[1, 3] = σ * sqrt(I)
        du[2, 4] = σ * sqrt(τ*X)
        du[2, 5] = σ * -sqrt(τ*Y)
        du[3, 6] = σ * sqrt(τ*Y)
        du[3, 7] = σ * -sqrt(τ*Z)

    end

    function jumps()

        iX, iY, iZ = 1:3
        iA, iτ, iI, iΩ = 1:10

        rate1(u, p, t) = p[iτ]*p[iΩ]*kfr(u[iZ],  p[iΩ]*p[iA])
        affect1!(integrator) = integrator.u[iX] += 1
        jump1 = ConstantRateJump(rate1, affect1!)
    
        rate2(u, p, t) = p[iτ]*u[iX]
        affect2!(integrator) = integrator.u[iX] -= 1
        jump2 = ConstantRateJump(rate2, affect2!)
    
        rate3(u, p, t) = p[iτ]*u[iX]
        affect3!(integrator) = integrator.u[iY] += 1
        jump3 = ConstantRateJump(rate3, affect3!)
    
        rate4(u, p, t) = p[iτ]*u[iY]
        affect4!(integrator) = integrator.u[iY] -= 1
        jump4 = ConstantRateJump(rate4, affect4!)
    
        rate5(u, p, t) = p[iτ]*u[iY]
        affect5!(integrator) = integrator.u[iZ] += 1
        jump5 = ConstantRateJump(rate5, affect5!)
    
        rate6(u, p, t) = p[iτ]*u[iZ]
        affect6!(integrator) = integrator.u[iZ] -= 1
        jump6 = ConstantRateJump(rate6, affect6!)
    
        rate7(u, p, t) = p[iΩ]*p[iI]
        affect7!(integrator) = (integrator.u[iX] += 1)
        jump7 = ConstantRateJump(rate7, affect7!)
    
        return jump1, jump2, jump3, jump4, jump5, jump6, jump7

    end

    # Common variables for all model types
    tspan = (0.0, 10.0)
    variable_names = ["X", "Y", "Z"]

    if problem_type == "ode"
        
        # Create an ODE model
        parameter_names = ["A", "τ", "I"]
        p = [0.1, 3.66, 0.0]
        u0 = [0.1, 0.1, 0.1]
        prob = ODEProblem(model!, u0, tspan, p)
        model = create_model(variable_names, parameter_names, prob)
        
        # Set solver parameters
        # alg = Tsit5()
        alg = DP5()
        kwargs = (saveat=0.01, reltol=1e-9, abstol=1e-9,)
        # kwargs = (saveat=0.01,)
        model = set_solver(model, alg; kwargs...)
       
    elseif problem_type == "sde"

        # Create an SDE model
        parameter_names = ["A", "τ", "I", "σ"]
        p = [0.1, 3.66, 0.0, 0.0]
        u0 = [0.1, 0.1, 0.1]
        noise_rate_prototype = zeros(3, 7)
        prob = SDEProblem(model!, noise!, u0, tspan, p;
            noise_rate_prototype=noise_rate_prototype)
        model = create_model(variable_names, parameter_names, prob)
        
        # Set solver parameters
        alg = EM()
        kwargs = (dt=0.0001, saveat=0.01,)
        model = set_solver(model, alg; kwargs...)

    elseif problem_type == "jump"

        # Create a Jump model
        parameter_names = ["A", "τ", "I", "Ω"]
        p = [0.1, 3.66, 0.0, 10.0]
        u0 = [1.0, 1.0, 1.0] .* p[end]
        dprob = DiscreteProblem(u0, tspan, p)
        prob = JumpProblem(dprob, Direct(), jumps()...;
            save_positions=(false, false))
        model = create_model(variable_names, parameter_names, prob)
        
        # Set solver parameters
        alg = SSAStepper()
        kwargs = (saveat=0.01,)
        model = set_solver(model, alg; kwargs...)

    end

    return model

end


function _load_model02(problem_type)

    function model!(du, u, p, t)

        # Variables
        x1, x2 = u
    
        # Parameters
        B, d, τ, I = p
    
        # Equations
        du[1] = τ*(x2)  # dx1
        du[2] = τ*(-(B * x1^2 - d) * x2 - x1) + I  # dx2
    
    end

    function noise!(du, u, p, t)
    
        # Parameters
        σ = p[end]
    
        # Equations
        du[1] = σ
        du[2] = σ

    end

    # Common variables for all model types
    tspan = (0.0, 10.0)
    variable_names = ["x1", "x2"]

    if problem_type == "ode"
        
        # Create an ODE model
        parameter_names = ["B", "d", "τ", "I"]
        p = [10.0, 2.0, 7.63, 0.0]
        u0 = [0.1, 0.1]
        prob = ODEProblem(model!, u0, tspan, p)
        model = create_model(variable_names, parameter_names, prob)
        
        # Set solver parameters
        alg = DP5()
        kwargs = (saveat=0.01, reltol=1e-9, abstol=1e-9,)
        model = set_solver(model, alg; kwargs...)
    
    elseif problem_type == "sde"

        # Create an SDE model
        parameter_names = ["B", "d", "τ", "I", "σ"]
        p = [10.0, 2.0, 7.63, 0.0, 0.2]
        u0 = [0.1, 0.1]
        prob = SDEProblem(model!, noise!, u0, tspan, p)
        model = create_model(variable_names, parameter_names, prob)
        
        # Set solver parameters
        alg = SOSRI()
        kwargs = (saveat=0.01,)
        model = set_solver(model, alg; kwargs...)

    elseif problem_type == "jump"

        # Create a Jump model
        error("No Jump problem for this model!")

    end

    return model

end
