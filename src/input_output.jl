"""
`save_data(df::DataFrame, args...)`

Save a DataFrame as a csv file into the `data` folder. `args...` specify the
subdirecotires in `data`.
"""
function save_data(df::DataFrame, args...)

    # Build a path starting with "data" and continuig based on the passed args
    filename = joinpath("data", args...)
    
    # If a file with the same name already exists, throw an error
    if isfile(filename)
        error("File already exists!")
    end

    # Create all subdirecotires that do not yet exist
    dir, _ = splitdir(filename)
    if !isdir(dir)
        mkpath(dir)
    end

    # Save the dataframe
    return CSV.write(filename, df)
    
end


"""
`load_data(args...)`

Load a DataFrame from a csv file located in the `data` folder. `args...` specify
the subdirecotires in `data`.
"""
function load_data(args...)

    # Build a path starting with "data" and continuig based on the passed args
    filename = joinpath(@__DIR__, "..", "data", args...)

    # Load a csv file
    file = CSV.File(filename)

    # Convert the file into a dataframe
    df = DataFrame(file)

    return df

end


"""
`save_figure(fig, args...; kwargs...)`

Save a figure into the `figures` folder. `args...` specify the subdirecotires in
`figures` and `kwargs...` are passed to `fig.savefig`.
"""
function save_figure(fig, args...; kwargs...)
    
    # Build a path starting with "figures" and continuig based on the passed args
    filename = joinpath("figures", args...)
    
    # If a file with the same name already exists, throw an error
    if isfile(filename)
        error("File already exists!")
    end

    # Create all subdirecotires that do not yet exist
    dir, _ = splitdir(filename)
    if !isdir(dir)
        mkpath(dir)
    end

    # Save the figure
    return fig.savefig(filename; kwargs...)

end
