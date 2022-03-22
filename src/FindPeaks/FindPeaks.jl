module FindPeaks

import Base.isempty, Base.length, Base.getindex, Base.sort

export findindices, findprominences, findwidthbounds
export findpeaks

export PeakResults
export peakheights, peaklocations, peakprominences, peakwidths
export isempty, length, getindex, sort

include("functions.jl")
include("PeakResults.jl")

end  # module
