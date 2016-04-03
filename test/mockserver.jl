using Swifter
using Base.Test

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
@test QueryResult(:symbol, "Needs initial vc") == result

vc = initial("http://localhost:8000")

result = @query vc.view.backgroundColor
@test QueryResult(:any, "UIDeviceRGBColorSpace 0 1 0 1") == result

try
    close(server.http)
catch e
end
