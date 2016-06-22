# initial.jl

import Requests: post, json


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


"""
    valueof(result)

Return the value of result
"""
function valueof(result::QueryResult)
    return result.info.value
end
