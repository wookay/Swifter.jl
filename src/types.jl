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

type Setter <: QueryChain
  lhs::Vector
  rhs::Vector
end

type Getter <: QueryChain
  lhs::Vector
end
