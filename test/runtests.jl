using Swifter
using Base.Test
using HttpServer

if VERSION.minor < 5
    macro testset(name, block)
        eval(block)
    end
end

http = HttpHandler() do req::Request, res::Response
    println("req ", req.resource)
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

@testset "Swifter.jl" begin
    @testset "query" begin
        include("query.jl")
    end
end

try
    close(server.http.sock)
catch e
end
