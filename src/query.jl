# query.jl

export @query

include("types.jl")



# @query
macro query(sym::Symbol)
    query_request(Expr(:quote, sym))
end

macro query(expr::Expr)
    query_request(expr)
end



function query_request(expr::Expr)
    if expr.head in [:(=), :kw]
        lhs,rhs = expr.args
        lquote = destchains(lhs)
        rquote = destchains(rhs)
        lhs_issym = isa(lhs, Symbol)
        rhs_issym = isa(rhs, Symbol)
        rhs_isexpr = isa(rhs, Expr)
        lsymbol = (lhs,)
        quote
            (ldest,lsym) = $lquote
            (rdest,rsym) = $rquote
            rdestination = destinationof(rdest,ldest)
            rvalue = rsym
            if $rhs_isexpr
                param = Dict("type"=>"Getter", "lhs"=>wrap_symbol(rsym))
                verb = "/query"
                dict = request(rdestination, verb, param)
                result = QueryResult(dict, rdestination, verb, param)
                rvalue = result.info.value
            end
            if $lhs_issym
                (firstsym,) = $lsymbol
                if $rhs_isexpr
                else
                    (sym,) = rsym
                    if isa(sym, Symbol)
                        rvalue = valuate(sym, rvalue)
                    else
                        rvalue = sym
                    end
                end
                Swifter.env[firstsym] = rvalue
            else
                ldestination = destinationof(ldest,rdest)
                param = Dict("type"=>"Setter", "lhs"=>wrap_symbol(lsym), "rhs"=>wrap_symbol(rvalue))
                verb = "/query"
                dict = request(ldestination, verb, param)
                QueryResult(dict, ldestination, verb, param)
            end
        end
    else
        lquote = destchains(expr)
        (sym,) = expr.args
        if 1 == length(expr.args) && isa(expr.args[1], Symbol)
            quote
                (ldest,lsym) = $lquote
                (val,) = lsym
                val
            end
        else
            quote
                (ldest,lsym) = $lquote
                ldestination = destinationof(ldest,nothing)
                param = Dict("type"=>"Getter", "lhs"=>wrap_symbol(lsym))
                verb = "/query"
                dict = request(ldestination, verb, param)
                QueryResult(dict, ldestination, verb, param)
            end
        end
    end
end



function destinationof(a::Union{Void,App}, b::Union{Void,App})
    if isa(a, App)
        return a
    elseif isa(b, App)
        return b
    else
        return current_app
    end
end



wrap_symbol(ex::Union{QueryResult,Symbol,Int,Float64,Bool,AbstractString}) = wrap_symbol(Any[ex])

function wrap_symbol(lhs::Vector)
    vals = Any[]
    for ex in lhs
        if isa(ex, Symbol)
            push!(vals, (:symbol, ex))
        elseif isa(ex, QueryResult)
            if isa(ex.info.address, Void)
                push!(vals, ex.info.value)
            else
                push!(vals, (:address, string(ex.info.address)))
            end
        else
            push!(vals, ex)
        end
    end
    vals
end



chains(ex::Union{Symbol,Int,Float64,Bool,AbstractString}) = chains(Expr(:quote, ex))
chains(expr::Expr) = deserial(chaining(expr, 0, []))



function valuate(sym::Symbol, default)
    if haskey(Swifter.env, sym)
        Swifter.env[sym]
    elseif isdefined(Main, sym)
        getfield(Main, sym)
    else
        default
    end
end



destchains(ex::Union{Symbol,Int,Float64,Bool,AbstractString}) = destchains(Expr(:quote, ex))

function destchains(expr::Expr)
    symbols = chains(expr)
    firstsym = first(symbols)
    quote
        dest = nothing
        sym = $symbols[1]
        try
            sym = $(esc(firstsym))
        end
        if isa(sym, Symbol)
            $symbols[1] = valuate(sym, sym)
        end
        if isa(sym, QueryResult)
            dest = sym.app
            $symbols[1] = sym
        end
        (dest,$symbols)
    end
end



function chaining(expr::Expr, depth::Int, symbols::Vector)
    if :call == expr.head
        firstarg = first(expr.args)
        callarg = CallArg("", Any[])
        if isa(firstarg, Symbol)
            callarg.name = firstarg
        else
            for ex in firstarg.args
                if isa(ex, Expr)
                    for el in ex.args[1:end]
                        if isa(el, Expr)
                            chaining(el, depth+1, symbols)
                        elseif isa(el, QuoteNode)
                            push!(symbols, el.value)
                        else
                            if length(ex.args) > 1
                                push!(symbols, el)
                            else
                                callarg.name = el
                            end
                        end
                    end
                elseif isa(ex, QuoteNode)
                    callarg.name = ex.value
                else
                    push!(symbols, ex)
                end
            end
        end
        args = Any[]
        if length(expr.args) > 1
            for ex in expr.args[2:end]
                if isa(ex, Expr)
                    push!(args, chaining(ex, depth+1, Any[]))
                else
                    push!(args, ex)
                end
            end
        end
        callarg.args = args
        push!(symbols, callarg)
    else
        for ex in expr.args
            if isa(ex, Expr)
                chaining(ex, depth+1, symbols)
            elseif isa(ex, QuoteNode)
                push!(symbols, ex.value)
            else
                push!(symbols, ex)
            end
        end
    end
    symbols
end



function deserial(symbols::Vector)
    syms = Any[]
    for sym in symbols
        if isa(sym, CallArg)
            if isempty(sym.args)
                push!(syms, (:call, sym.name))
            else
                push!(syms, (:call, (sym.name, sym.args)))
            end
        else
            push!(syms, sym)
        end
    end
    syms
end
