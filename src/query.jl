# query.jl


"""
    @query(expr)::QueryResult

Execute a query with expression
"""
macro query(sym::Symbol)
    query_request(Expr(:block, sym))
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
        lsymbol = (lhs,)
        rsymbol = (rhs,)
        quote
            (ldest,lsym) = $lquote
            (rdest,rsym) = $rquote
            endpoint = endpointof(rdest, ldest)
            rvalue = $lhs_issym ? first(rsym) : rsym
            if $rhs_issym
                rvalue = valuate(first($rsymbol))
            end
            if isa(ldest, App) && isa(rdest, App) && (ldest.url != rdest.url)
                if $rhs_issym
                else
                    param = Dict("type"=>"Getter", "lhs"=>wrap_symbol(rsym))
                    verb = "/query"
                    dict = request(endpoint, verb, param)
                    result = QueryResult(dict, endpoint, verb, param)
                    rvalue = result.info.value
                end
            end
            if $lhs_issym
                (firstsym,) = $lsymbol
                Swifter.env[firstsym] = rvalue
            else
                endpoint = endpointof(ldest, rdest)
                param = Dict("type"=>"Setter", "lhs"=>wrap_symbol(lsym), "rhs"=>wrap_symbol(rvalue))
                verb = "/query"
                dict = request(endpoint, verb, param)
                QueryResult(dict, endpoint, verb, param)
            end
        end
    else
        lquote = destchains(expr)
        (sym,) = expr.args
        quot = quote
            (ldest,lsym) = $lquote
            endpoint = endpointof(ldest,nothing)
            param = Dict("type"=>"Getter", "lhs"=>wrap_symbol(lsym))
            verb = "/query"
            dict = request(endpoint, verb, param)
            QueryResult(dict, endpoint, verb, param)
        end
        if 1 == length(expr.args) && isa(sym, Symbol)
            quote
                (ldest,lsym) = $lquote
                (val,) = lsym
                val == sym ? $quot : val
            end
        else
            quot
        end
    end
end


function endpointof(a::Union{Void,App}, b::Union{Void,App})
    if isa(a, App)
        return a
    elseif isa(b, App)
        return b
    else
        return current_endpoint
    end
end


chains(ex::Union{Symbol,Int,Float64,Bool,AbstractString}) = chains(Expr(:block, ex))
chains(expr::Expr) = deserial(chaining(expr, 0, []))


function valuate(sym::Symbol)
    if haskey(Swifter.env, sym)
        Swifter.env[sym]
    elseif isdefined(Main, sym)
        getfield(Main, sym)
    else
        sym
    end
end


destchains(ex::Union{Symbol,Int,Float64,Bool,AbstractString}) = destchains(Expr(:block, ex))

function destchains(expr::Expr)
    symbols = chains(expr)
    firstsym = first(symbols)
    quote
        sym = $symbols[1]
        try
            sym = $(esc(firstsym))
        end
        if isa(sym, Symbol)
            $symbols[1] = isa(sym, Symbol) ? valuate(sym) : sym
        end
        if isa(sym, QueryResult)
            (sym.app, vcat(sym, $symbols[2:end]))
        else
            (nothing, $symbols)
        end
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
                push!(syms, (:call, (sym.name, wrap_symbol(sym.args))))
            end
        else
            push!(syms, sym)
        end
    end
    syms
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
