# query.jl

import JSON

include("types.jl")

chains(sym::Symbol) = Any["symbol"=>sym]
chains(n::Int) = Any["int"=>n]
chains(n::Float64) = Any["float"=>n]
chains(str::AbstractString) = Any["string"=>str]
function chains(expr::Expr)
    symbols = chaining(expr, 0, [])
    sym = symbols[1]
    if isa(sym, Symbol) && isdefined(sym)
        symbols[1] = (:isdefined, sym)
    end
    symbols
end

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
                  push!(symbols, (:call, ex))
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

function query_expr(expr::Expr)
    if :(=) == expr.head
        lhs,rhs = expr.args
        lsym = chains(lhs)
        rsym = chains(rhs)
        Setter(lsym, rsym)
    else
        Getter(chains(expr))
    end
end

function sym_to_mem(symmem, vec::Vector)
    sym,mem = isa(symmem, Void) ? ("","") : symmem
    map(vec) do item
        if isa(item,Tuple)
            if :isdefined == first(item)
                if sym == string(last(item))
                    return "address"=>mem.address
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

function params(symmem, setter::Setter)
    Dict("type"=>"Setter",
         "lhs"=>JSON.json(sym_to_mem(symmem, setter.lhs)),
         "rhs"=>JSON.json(sym_to_mem(symmem, setter.rhs)))
end

function params(symmem, getter::Getter)
    Dict("type"=>"Getter",
         "lhs"=>JSON.json(sym_to_mem(symmem, getter.lhs)))
end

function query_params(app::App, str::AbstractString)
    params(nothing, query_expr(Expr(:block, parse(str))))
end

function chain_convert(vec::Vector)
    for unit in vec
        if isa(unit, Tuple)
            if :isdefined == first(unit)
                return (string(last(unit)), last(unit))
            end
        end
    end
    return (nothing, nothing)
end

function query_chain(expr::Expr)
    chain = query_expr(expr)
    memory = nothing
    (sym,memory) = chain_convert(chain.lhs)
    if nothing == memory
        if isa(chain, Setter)
            (sym,memory) = chain_convert(chain.rhs)
        end
    end
    (chain,sym,memory)
end

# @query
macro query(sym::Symbol)
    esc(sym)
end
macro query(expr::Expr)
    (chain,sym,memory) = query_chain(expr)
    if nothing == memory
        quote
            $chain
        end
    else
        quote
            mem = $(esc(memory))
            request(mem.app, "/query", params(($sym,mem), $chain))
        end
    end
end

# query_request
function query_request(sym::Symbol)
    if isdefined(sym)
        eval(parse("Main.$sym"))
    else
        sym
    end
end
function query_request(expr::Expr)
    (chain,sym,memory) = query_chain(expr)
    if nothing == memory
        chain
    else
        if isdefined(memory)
            mem = eval(parse("Main.$memory"))
            request(mem.app, "/query", params((sym,mem), chain))
        end
    end
end
