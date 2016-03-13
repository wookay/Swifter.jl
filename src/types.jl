# types.jl

type App
  url::AbstractString
  App(url) = new(url)
end

type Memory
  app::App
  address::AbstractString
end

abstract QueryChain

type Assign <: QueryChain
  lhs::Vector
  rhs::Vector
end

type Property <: QueryChain
  lhs::Vector
end
