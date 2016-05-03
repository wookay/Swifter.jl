module Swifter

#FIXME
__precompile__(true)
#__precompile__(true)

import Requests: post
using JSON

export initial

include("query.jl")
include("repl.jl")
include("jupyter.jl")
include("testing.jl")

current_app = App("")
env = Dict()
const RequireToInitial = "You need to initial"

request(app::App, verb::AbstractString, pair::Pair) = request(app, verb, Dict(pair))
function request(app::App, verb::AbstractString, param::Dict)
    if isempty(app.url)
        Dict("typ"=>"symbol", "value"=>RequireToInitial)
    else
        resp = post("$(app.url)$(verb)"; json = param)
        JSON.parse(utf8(resp.data))
    end
end

initial(url::AbstractString) = initial(App(url))
function initial(app::App)
    verb = "/initial"
    param = Dict()
    dict = request(app, verb, param)
    global current_app
    current_app = app
    QueryResult(dict, app, verb, param)
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
