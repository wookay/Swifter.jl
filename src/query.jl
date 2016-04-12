# query.jl

import JSON

include("types.jl")

chains(sym::Symbol) = Any[isdefined(sym) ? (:isdefined, sym) : "symbol"=>sym]
chains(n::Int) = Any["int"=>n]
chains(n::Float64) = Any["float"=>n]
chains(n::Bool) = Any["bool"=>n]
chains(str::AbstractString) = Any["string"=>str]
function chains(expr::Expr)
    symbols = chaining(expr, 0, [])
    sym = symbols[1]
    if isa(sym, Symbol) && isdefined(sym)
        symbols[1] = (:isdefined, sym)
    end
    symbols
end
chains(any::Any) = Any[]

function chaining(expr::Expr, depth::Int, symbols::Vector)
    if :call == expr.head
        isargs = false
        callargs = []
        for ex in expr.args
            if isa(ex, Expr)
                if :(:) == ex.head
                    lastsym = symbols[end]
                    sym = first(lastsym)
                    store = last(lastsym)
                    if isa(store, Symbol)
                        store = Any[store, []]
                    end
                    args = last(store)
                    push!(args, ex.args)
                    symbols[end] = (sym, Any[first(store), args])
                else
                    vals = chaining(ex, depth + 1, symbols)
                    sym = isa(vals[end], QuoteNode) ? vals[end].value : vals[end]
                    vals[end] = (:call, sym)
                end
            else
              if isargs
                  push!(callargs, ex)
              else
                  isargs = true
                  if isa(ex, Symbol)
                      push!(symbols, (:call, ex))
                  else
                      push!(callargs, ex)
                  end
              end
            end
        end
        if !isempty(callargs)
            sym = last(symbols[end])
            symbols[end] = (:call, Any[sym, callargs])
        end
    else
        for ex in expr.args
            if isa(ex, Expr)
                chaining(ex, depth + 1, symbols)
            elseif isa(ex, QuoteNode)
                push!(symbols, ex.value)
            else
                push!(symbols, ex)
            end
        end
    end
    symbols
end

function querychainof(expr::Expr)
    if :(=) == expr.head
        lhs,rhs = expr.args
        lsym = chains(lhs)
        rsym = chains(rhs)
        Setter(lsym, rsym)
    else
        Getter(chains(expr))
    end
end

evaluate(m::Module, e::ANY) = eval(m, e)

function sym_to_mem(symmem, vec::Vector)
    sym,mem = isa(symmem, Void) ? ("","") : symmem
    map(vec) do item
        if isa(item,Tuple)
            if :isdefined == first(item)
                if sym == last(item)
                    return "address"=>mem.address
                else
                    var = last(item)
                    val = evaluate(Main, quote
                        $(var)
                    end)
                    vals = chains(val)
                    if !isempty(vals)
                        return first(vals)
                    end
                end
            elseif :call == first(item)
                return "call"=>last(item)
            else
                return item
            end
        elseif isa(item,Pair)
            return item
        else
            return "symbol"=>item
        end
    end
end

function param_dict(symmem, setter::Setter)
    Dict("type"=>"Setter",
         "lhs"=>sym_to_mem(symmem, setter.lhs),
         "rhs"=>sym_to_mem(symmem, setter.rhs))
end

function param_dict(symmem, getter::Getter)
    Dict("type"=>"Getter",
         "lhs"=>sym_to_mem(symmem, getter.lhs))
end

function chain_convert(vec::Vector)
    for unit in vec
        if isa(unit, Tuple)
            if :isdefined == first(unit)
                return (string(last(unit)), last(unit))
            end
        end
    end
    return (:notfound, nothing)
end

function pointchainof(expr::Expr)
    chain = querychainof(expr)
    memory = nothing
    (sym,memory) = chain_convert(chain.lhs)
    if nothing == memory
        if isa(chain, Setter)
            (sym,memory) = chain_convert(chain.rhs)
        end
    end
    PointChain(sym, memory, chain)
end

function wrap_json(dict::Dict)
    params = Dict(dict) 
    params["lhs"] = JSON.json(params["lhs"])
    if haskey(dict, "rhs")
        params["rhs"] = JSON.json(params["rhs"])
    end
    return params
end

function var_request(app::Union{Void,App}, verb::AbstractString, dict::Dict)
    lhs = dict["lhs"]
    if haskey(dict, "rhs")
        rhs = dict["rhs"]
        if 1 == length(lhs)
            (name,sym) = collect(first(lhs))
            if "symbol" == name
                eval(Swifter, quote
                    $(sym) = $(dict["rhs"])
                end)
                return getfield(Swifter, sym)
            end
        elseif 1 == length(rhs)
            (name,sym) = collect(first(rhs))
            if "symbol" == name && isdefined(Swifter, sym)
                dict["rhs"] = getfield(Swifter, sym)
            end
        end
    elseif 1 == length(lhs)
        (name,sym) = collect(first(lhs))
        if "symbol" == name && isa(sym, Symbol)
            if isdefined(Swifter, sym)
                return getfield(Swifter, sym)
            elseif isdefined(Main, sym)
                return getfield(Main, sym)
            end
        end
    end
    if isa(app, App)
        info = request(app, verb, wrap_json(dict))
        return QueryResult(symbol(info["type"]), info["value"], (app,verb,dict))
    else
        return QueryResult(:symbol, "Needs initial vc", (app,verb,dict))
    end
end


# @query
macro query(sym::Symbol)
    query(sym)
end

macro query(expr::Expr)
    query(expr)
end


# query
function query(sym::Symbol)
    global current_app
    Swifter.var_request(current_app, "/query", Swifter.param_dict((nothing,nothing), Getter([sym])))
end

function query(expr::Expr)
    global current_app
    point = pointchainof(expr)
    if nothing == point.memory
        evaluate(Main, quote
            Swifter.var_request(current_app, "/query", Swifter.param_dict((nothing,nothing), $(point.chain)))
        end)
    else
        evaluate(Main, quote
            sym = $(point).name
            mem = $(Main.(point.memory))
            if isa(mem, Swifter.Memory)
                Swifter.var_request(mem.app, "/query", Swifter.param_dict((sym,mem), $(point.chain)))
            else
                Swifter.var_request(current_app, "/query", Swifter.param_dict((nothing,nothing), $(point.chain)))
            end
        end)
    end
end

query(any::Any) = any
