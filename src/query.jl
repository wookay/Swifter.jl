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
    for ex in expr.args
      if isa(ex, Expr)
        vals = chaining(ex, depth + 1, symbols)
        sym = isa(vals[end], QuoteNode) ? vals[end].value : vals[end]
        vals[end] = (:call, sym)
      else
        push!(symbols, (:call, ex))
      end
    end
  else
    for ex in expr.args
       if isa(ex, Expr)
         chaining(ex, depth + 1, symbols)
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

macro query(sym::Symbol)
  esc(sym)
end
macro query(expr::Expr)
  chain = query_expr(expr)
  memory = nothing
  (sym,memory) = chain_convert(chain.lhs)
  if nothing == memory
    if isa(chain, Setter)
      (sym,memory) = chain_convert(chain.rhs)
    end
  end
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


#vc = 5
#@query vc.label.text = "hello"
