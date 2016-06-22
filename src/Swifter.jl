module Swifter

__precompile__(true)


include("types.jl")

export initial, set_endpoint, valueof
include("initial.jl")

export @query
include("query.jl")

export RunSwifterREPL
include("repl.jl")
include("jupyter.jl")
include("testing.jl")


# global
current_endpoint = App("")
env = Dict()


function __init__()
    if isdefined(Base, :active_repl)
        if haskey(ENV, "SWIFTER_QUERY_MODE_KEY")
          RunSwifterREPL(key=ENV["SWIFTER_QUERY_MODE_KEY"])
        else
          RunSwifterREPL()
        end
    end
end

end # module
