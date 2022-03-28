# stoosc
Code for our publication.

## Installation
To install necessery dependencies, start Julia in the project folder and then instantiate the project's package enviroment by running `] activate .` and `] instantiate`.

## Data
Folder `data` contains generated data used to generate figures and results presented in the paper. The saved data contain Arnold tongues (`arnold_tongues`), phase response curves (`prcs`), and jet lag (`jet_lags`) for three models: the Kim-Forger model (`model01`), limit cycle Van der Pol model (`model02`), and noise-induced Van der Pol model (`model02b`).

## Scripts
All scripts (folder `scripts`) starting with `script_` can be used to generate Arnold tongues (`script_arnold_tongues.jl`), phase response curves (`script_prcs.jl`), and jet lag experiments (`script_jet_lag.jl`) for the models from the paper.

## Figures
All scripts (folder `scripts`) starting with `figure_` generate figures from the paper. The generated figures are automatically stored in folder `figures` as SVG files.
- `figure01.jl`: Figure 1.
- `figure_arnold_tongues_model01.jl`: Figure 2. SI Figures 8, 9, 10.
- `figure_prcs.jl`: Figure 3. SI Figures 13, 16.
- `figure_jet_lags.jl`: Figure 4. SI Figure 14.
- `figure05A.jl`: Figure 5A.
- `figure_arnold_tongues_model02.jl`: Figure 5B, C. SI Figures 12, 15.
- `figure_scan_A.jl`: SI Figure 1.
- `figure_varying_dt.jl`: SI Figure 2.
- `figure_phase_space_histograms.jl`: SI Figure 3.
- `figure_arnold_tongues_sde_jump.jl`: SI Figure 4.
- `figure_arnold_tongues_traces.jl`: SI Figure 5, 6, 7.
