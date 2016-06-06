# types.jl

import Base: ==, show

immutable App
    url::AbstractString
end


abstract QueryChain

immutable Setter <: QueryChain
    lhs::Vector
    rhs::Vector
end


immutable Getter <: QueryChain
    lhs::Vector
end


immutable ResultInfo
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
           ResultInfo(Symbol(dict["typ"]), dict["value"], dict["address"])
        else
           ResultInfo(Symbol(dict["typ"]), dict["value"], nothing)
        end
    end
end


immutable QueryResult
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
    show(io, result.info)
end

function Base.show(io::IO, info::ResultInfo)
    if :symbol == info.typ
        if isa(info.value, Void)
            #print(io, repr(info.value))
        else
            print_with_color(:red, io, info.value)
        end
    elseif :string == info.typ
        print(io, info.value)
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
        if VERSION < v"0.5-"
            write(io, info.value)
        else
            show(io, Text(info.value))
        end
    end
end
