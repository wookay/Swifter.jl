module Swifter

import Requests: get, json

export App, follow, unfollow, capture, upload, initial, query, @query

include("query.jl")

function request(app::App, verb::AbstractString, dict::Dict)
  resp = get("$(app.url)$(verb)"; query = dict)
  info = json(resp)
  haskey(info, "failed") ? Symbol(info["failed"]) : info["result"]
end

function request(app::App, verb::AbstractString, pair::Pair)
  request(app, verb, Dict(pair))
end

function request(memory::Memory, verb::AbstractString, dict::Dict)
  request(memory.app, verb, dict)
end

function initial(app::App)
  dict = request(app, "/initial", Dict())
  Memory(app, dict["address"]) 
end

function query(app::App, str::AbstractString)
  request(app, "/query", query_params(app, str))
end

end # module
