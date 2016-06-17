if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
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
