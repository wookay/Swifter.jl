using Swifter
using Base.Test

import Swifter: QueryResult, App, Memory, request

using HttpServer

http = HttpHandler() do req::Request, res::Response
    # println("req ", req.resource)
    if ismatch(r"^/initial", req.resource)
        Response("""{"type": "any", "value": {"address": ""}}""")
    elseif ismatch(r"^/query", req.resource)
        Response("""{"type": "any", "value": "UIDeviceRGBColorSpace 0 1 0 1"}""")
    else
        Response("""{"type": "symbol", "value": "Failed"}""")
    end
end
server = Server(http)
@async run(server, 8000)
sleep(0.1)

result = @query vc.view.backgroundColor
@test QueryResult(:symbol, "Needs initial vc", (nothing,"/query",Dict("lhs"=>Any["symbol"=>:vc,"symbol"=>:view,"symbol"=>:backgroundColor],"type"=>"Getter"))) == result

vc = initial("http://localhost:8000")

result = @query vc.view.backgroundColor
app = App("http://localhost:8000")
@test QueryResult(:any, "UIDeviceRGBColorSpace 0 1 0 1", (app,"/query",Dict("lhs"=>Any["address"=>"","symbol"=>:view,"symbol"=>:backgroundColor],"type"=>"Getter"))) == result
@test result == query(:(vc.view.backgroundColor))

request(app, "/query", Pair(1,2))
request(Memory(app,""), "/query", Dict(1=>2))
request(app, "/query", Dict(1=>2))


try
    close(server.http)
catch e
end
