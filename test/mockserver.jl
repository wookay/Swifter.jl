using Swifter
using Base.Test

import Swifter: QueryResult, ResultInfo, App

using HttpServer
using JSON

function handle(color)
    current_color = color
    HttpHandler() do req::Request, res::Response
        if ismatch(r"^/initial", req.resource)
            Response("""{"typ": "any", "value": ""}}""")
        elseif ismatch(r"^/query", req.resource)
            param = JSON.parse(utf8(req.data))
            if "Setter" == param["type"]
                current_color = first(param["rhs"])
            end
            Response("""{"typ": "any", "value": "$current_color"}""")
        else
            Response("""{"typ": "symbol", "value": "Failed"}""")
        end
    end
end


param = Dict("lhs"=>Any[(:symbol,:vc),(:symbol,:view),(:symbol,:backgroundColor)], "type"=>"Getter")
result = @query vc.view.backgroundColor
@test QueryResult(ResultInfo(:symbol, Swifter.RequireToInitial), App(""),"/query",param) == result
@test Swifter.RequireToInitial == result


server_one = Server(handle("UIDeviceRGBColorSpace 0 0 0 1"))
server_two = Server(handle("UIDeviceRGBColorSpace 0 1 0 1"))
@async run(server_one, 8000)
@async run(server_two, 8001)
sleep(0.1)

vc1 = initial("http://localhost:8000")
vc2 = initial("http://localhost:8001")

@test "UIDeviceRGBColorSpace 0 0 0 1" == @query vc1.view.backgroundColor
@test "UIDeviceRGBColorSpace 0 1 0 1" == @query vc2.view.backgroundColor

@query vc1.view.backgroundColor = vc2.view.backgroundColor

@test "UIDeviceRGBColorSpace 0 1 0 1" == @query vc1.view.backgroundColor
@test "UIDeviceRGBColorSpace 0 1 0 1" == @query vc2.view.backgroundColor

try
    close(server_one.http)
    close(server_two.http)
catch e
end
