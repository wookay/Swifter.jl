module Swifter

__precompile__(true)

import Requests: post, json

export current_app, initial, @query, query

include("query.jl")
include("repl.jl")
include("jupyter.jl")

current_app = nothing

request(app::App, verb::AbstractString, pair::Pair) = request(app, verb, Dict(pair))
request(memory::Memory, verb::AbstractString, dict::Dict) = request(memory.app, verb, dict)
function request(app::App, verb::AbstractString, dict::Dict)
    resp = post("$(app.url)$(verb)"; json = dict)
    json(resp)
end

initial(url::AbstractString) = initial(App(url))
function initial(app::App)
    dict = request(app, "/initial", Dict())
    global current_app
    current_app = app
    Memory(app, dict["value"]["address"])
end

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
