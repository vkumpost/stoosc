# stoosc
Code for our publication Noise facilitates entrainment of a population of uncoupled limit cycle oscillators.

## Installation
To install necessery dependencies, start [Julia](https://julialang.org/) in the project folder and then instantiate the project's package enviroment by running `] activate .` and `] instantiate`. For details on the implemented methods see [OscillatorPopulation](https://github.com/vkumpost/OscillatorPopulation) package.

## Data
Folder `outputs` contains generated data used to create figures and results presented in the paper. The saved data contain Arnold tongues (`arnold_tongues`), phase response curves (`phase_response_curves`), and jet lags (`jet_lags`).

## Scripts
All scripts starting with `estimate_` can be used to estimate Arnold tongues (`estimate_arnold_tongues.jl`), phase response curves (`estimate_phase_response_curves.jl`), and jet lag experiments (`estimate_jet_lags.jl`) for the models from the paper.

## Figures
All scripts starting with `figure_` or `si_figure_` generate figures from the paper. The generated figures are automatically stored in folder `figures` as SVG files.
- `figure_population_size.jl`: Figure 1C.
- `figure_arnold_tongues.jl`: Figures 2A, 2B; SI Figure 3.
- `figure_arnold_tongues_population_phase_coherence.jl`: Figure 2C; SI Figure 5.
- `figure_arnold_tongues_constant_volume.jl`: Figure 2D; SI Figure 6.
- `figure_phase_response_curves.jl`: Figure 3; SI Figures 11, 14, 18.
- `figure_jet_lags.jl`: Figure 4; SI Figure 12.
- `figure_generic_model_traces.jl`: Figure 5A; SI Figure 15.
- `figure_arnold_tongues_limit_cycle.jl`: Figure 5B; SI Figure 10.
- `figure_arnold_tongues_noise_induced.jl`: Figure 5C; SI Figure 13.
- `si_figure_parameter_scan.jl`: SI Figure 1.
- `si_figure_phase_coherence.jl`: SI Figure 2.
- `si_figure_population_phase_coherence.jl`: SI Figure 4.
- `si_figure_arnold_tongues_heterogeneity.jl`: SI Figures 7, 8.
- `si_figure_arnold_tongues_amplitude_phase.jl`: SI Figures 16, 17.
- `si_figure_sde_vs_jump_benchmark.jl`: SI Figure 19.
- `si_figure_integration_step.jl`: SI Figure 20.
- `si_figure_sde_vs_jump_arnold_tongues.jl`: SI Figure 21.
