using Swifter
using Base.Test

using HttpServer

http = HttpHandler() do req::Request, res::Response
    # println("req ", req.resource)
    if ismatch(r"^/initial", req.resource)
        Response("""{"result": {"address": ""}}""")
    elseif ismatch(r"^/query", req.resource)
        Response("""{"result": "UIDeviceRGBColorSpace 0 1 0 1"}""")
    else
        Response("""{"failed": 0}""")
    end
end
server = Server(http)
@async run(server, 8000)
sleep(0.1)

vc = initial("http://localhost:8000")
result = @query vc.view.backgroundColor

@test QueryResult(:result, "UIDeviceRGBColorSpace 0 1 0 1") == result

try
    close(server.http)
catch e
end
