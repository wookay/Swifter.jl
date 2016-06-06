module Swifter

__precompile__(true)

import Requests: post, json
export initial, set_endpoint

include("query.jl")
include("repl.jl")
include("jupyter.jl")
include("testing.jl")

current_endpoint = App("")
env = Dict()
const RequireToInitial = "You need to initial"


request(app::App, verb::AbstractString, pair::Pair) = request(app, verb, Dict(pair))
function request(app::App, verb::AbstractString, param::Dict)
    if isempty(app.url)
        Dict("typ"=>"symbol", "value"=>RequireToInitial)
    else
        json(post("$(app.url)$(verb)"; json = param))
    end
end


"""
    initial(url)::QueryResult

Create an endpoint by connecting to the AppConsole Server
"""
initial(url::AbstractString) = initial(App(url))
function initial(app::App)
    verb = "/initial"
    param = Dict()
    dict = request(app, verb, param)
    result = QueryResult(dict, app, verb, param)
    set_endpoint(result)
    result
end


"""
    set_endpoint(result)

Set the global variable ``current_endpoint`` using the query result
"""
function set_endpoint(result::QueryResult)
    global current_endpoint
    current_endpoint = result.app
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
