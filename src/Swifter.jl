module Swifter

__precompile__(true)

import Requests: post, json

export initial, request, current_app

include("query.jl")
include("repl.jl")

current_app = nothing

request(app::App, verb::AbstractString, pair::Pair) = request(app, verb, Dict(pair))
request(memory::Memory, verb::AbstractString, dict::Dict) = request(memory.app, verb, dict)
function request(app::App, verb::AbstractString, dict::Dict)
    resp = post("$(app.url)$(verb)"; json = dict)
    info = json(resp)
    haskey(info, "symbol") ? Symbol(info["symbol"]) : info["result"]
end

initial(url::AbstractString) = initial(App(url))
function initial(app::App)
    dict = request(app, "/initial", Dict())
    global current_app
    if isa(current_app, Void)
        current_app = app
    end
    Memory(app, dict["address"]) 
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
