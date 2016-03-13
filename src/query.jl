# query.jl

import JSON

include("types.jl")

function chains(expr::Expr)
  symbols = chaining(expr, 0, [])
  sym = symbols[1]
  if isdefined(sym)
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
    Assign(lsym,rsym)
  else
    Property(chains(expr))
  end
end

function sym_to_mem(symmem, vec::Vector)
  sym,mem = isa(symmem, Void) ? ("","") : symmem
  map(vec) do item
    if isa(item,Tuple)
      if :isdefined == first(item)
        if sym == string(last(item))
          return mem.address
        end
      elseif :call == first(item)
        return string(last(item), "()")
      end
    else
      return string(item)
    end
  end
end

function params(symmem, assign::Assign)
  Dict("type"=>"Assign",
       "lhs"=>JSON.json(sym_to_mem(symmem, assign.lhs)),
       "rhs"=>JSON.json(sym_to_mem(symmem, assign.rhs)))
end

function params(symmem, property::Property)
  Dict("type"=>"Property",
       "lhs"=>JSON.json(sym_to_mem(symmem, property.lhs)))
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
    if isa(chain, Assign)
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