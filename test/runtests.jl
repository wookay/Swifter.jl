using Swifter
using Base.Test

if VERSION.minor < 5
    macro testset(name, block)
        println(name)
        eval(block)
    end
end

@testset "types.jl" begin
    include("types.jl")
end

@testset "query.jl" begin
    include("query.jl")
end

@testset "testing.jl" begin
    include("testing.jl")
end

@testset "jupyter.jl" begin
    include("jupyter.jl")
end

@testset "mockserver.jl" begin
    include("mockserver.jl")
end
