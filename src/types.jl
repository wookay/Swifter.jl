# types.jl

import Base: ==, show

type App
    url::AbstractString
    App(url) = new(url)
end

type Memory
    app::App
    address::AbstractString
end

abstract QueryChain

type Setter <: QueryChain
    lhs::Vector
    rhs::Vector
end

type Getter <: QueryChain
    lhs::Vector
end

type PointChain
    name::Symbol
    memory::Union{Symbol,Void}
    chain::QueryChain
end

type QueryResult
    name::Symbol
    value::Any
    params::Union{Void,Tuple}
end

function ==(lhs::App, rhs::App)
    return lhs.url == rhs.url
end

function ==(lhs::Memory, rhs::Memory)
    return lhs.app == rhs.app && lhs.address == rhs.address
end

function ==(lhs::Setter, rhs::Setter)
    return lhs.lhs == rhs.lhs && lhs.rhs == rhs.rhs
end

function ==(lhs::Getter, rhs::Getter)
    return lhs.lhs == rhs.lhs
end

function ==(lhs::PointChain, rhs::PointChain)
    return lhs.name == rhs.name && lhs.memory == rhs.memory && lhs.chain == rhs.chain
end

function ==(lhs::QueryResult, rhs::QueryResult)
    return lhs.name == rhs.name && lhs.value == rhs.value && lhs.params == rhs.params
end

function Base.show(io::IO, result::QueryResult)
    if :symbol == result.name
        print_with_color(:red, io, result.value)
    elseif :string == result.name
        print(io, repr(result.value))
    else
        print(io, result.value)
    end
end
