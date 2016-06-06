# testing.jl

import Base: ==

==(lhs::Int, rhs::QueryResult) = lhs == rhs.info.value
==(lhs::AbstractString, rhs::QueryResult) = lhs == rhs.info.value
==(lhs::Float64, rhs::QueryResult) = lhs == rhs.info.value
==(lhs::Bool, rhs::QueryResult) = lhs == rhs.info.value
==(lhs::Vector{AbstractString}, rhs::QueryResult) = lhs == rhs.info.value
==(lhs::Dict, rhs::QueryResult) = lhs == rhs.info.value
==(lhs::Void, rhs::QueryResult) = lhs == rhs.info.value
