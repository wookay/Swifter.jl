# testing.jl

import Base: ==

# equatables for query result
#
# @test "Hello world" == @query vc.label.text

==(lhs::Int, rhs::QueryResult) = lhs == rhs.value
==(lhs::AbstractString, rhs::QueryResult) = lhs == rhs.value
==(lhs::Float64, rhs::QueryResult) = lhs == rhs.value
==(lhs::Bool, rhs::QueryResult) = lhs == rhs.value
==(lhs::Vector{ASCIIString}, rhs::QueryResult) = lhs == rhs.value
==(lhs::Vector{AbstractString}, rhs::QueryResult) = lhs == rhs.value
==(lhs::Dict, rhs::QueryResult) = lhs == rhs.value
