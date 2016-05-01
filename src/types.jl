# types.jl

import Base: ==, show

type App
    url::AbstractString
end


abstract QueryChain

type Setter <: QueryChain
    lhs::Vector
    rhs::Vector
end


type Getter <: QueryChain
    lhs::Vector
end


type ResultInfo
    typ::Symbol
    value::Any
    address::Union{Void,AbstractString}

    function ResultInfo(typ::Symbol, value::Any)
        ResultInfo(typ, value, nothing)
    end

    function ResultInfo(typ::Symbol, value::Any, address::Union{Void,AbstractString})
        if :symbol == typ && "nothing" == value
            new(typ, nothing, address)
        else
            new(typ, value, address)
        end
    end

    function ResultInfo(dict::Dict)
        if haskey(dict, "address")
           ResultInfo(symbol(dict["typ"]), dict["value"], dict["address"])
        else
           ResultInfo(symbol(dict["typ"]), dict["value"], nothing)
        end
    end
end

type QueryResult
    info::ResultInfo
    app::App
    verb::AbstractString
    param::Dict

    function QueryResult(info::ResultInfo, app::App, verb::AbstractString, param::Dict)
        new(info, app, verb, param)
    end

    function QueryResult(dict::Dict, app::App, verb::AbstractString, param::Dict)
        new(ResultInfo(dict), app, verb, param)
    end
end


type CallArg
    name::Symbol
    args::Vector
end


function ==(lhs::App, rhs::App)
    return lhs.url == rhs.url
end

function ==(lhs::Setter, rhs::Setter)
    return lhs.lhs == rhs.lhs && lhs.rhs == rhs.rhs
end

function ==(lhs::Getter, rhs::Getter)
    return lhs.lhs == rhs.lhs
end

function ==(lhs::ResultInfo, rhs::ResultInfo)
    return lhs.typ == rhs.typ && lhs.value == rhs.value && lhs.address == rhs.address
end

function ==(lhs::QueryResult, rhs::QueryResult)
    return lhs.info == rhs.info && lhs.app == rhs.app && lhs.verb == rhs.verb && lhs.param == rhs.param
end


function Base.show(io::IO, result::QueryResult)
    print(io, result.info)
end

function Base.show(io::IO, info::ResultInfo)
    if :symbol == info.typ
        if isa(info.value, Void)
            #print(io, repr(info.value))
        else
            print_with_color(:red, io, info.value)
        end
    elseif :string == info.typ
        print(io, repr(info.value))
    elseif isa(info.value, AbstractArray)
        len = length(info.value)
        for (idx,el) in enumerate(info.value)
            print_with_color(:cyan, io, string(idx-1))
            print(io, Base.color_normal)
            print(io, " ")
            print(io, el)
            idx < len && print(io, "\n")
        end
    else
        print(io, info.value)
    end
end
