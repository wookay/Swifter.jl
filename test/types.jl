if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

using Swifter
import Swifter: Getter, Setter, App, ResultInfo, QueryResult, CallArg
import Swifter: chains, chaining, deserial, wrap_symbol, valuate, destchains
import Swifter: current_endpoint, endpointof

@test App("") == App("")
@test Getter([:vc]) == Getter([:vc])
@test Setter([:vc], [:vc]) == Setter([:vc], [:vc])

expr = :(vc.view.backgroundColor = UIColor.greenColor())

@test App("") == current_endpoint

param = Dict("lhs"=>Any[(:symbol,:vc),(:symbol,:view)], "type"=>"Getter")
info = ResultInfo(:symbol, Swifter.RequireToInitial, nothing)
result = QueryResult(info, App(""), "/query", param)
vc = nothing
@test result == (@query vc.view)


@test Any[:sym] == chains(:sym)
@test Any[0] == chains(0)
@test Any[0.1] == chains(0.1)
@test Any[false] == chains(false)
@test Any[""] == chains("")

expr = parse("vc.view")
@test Any[:vc,:view] == chains(expr)

@test Any[:vc,:view] == chaining(expr, 0, [])

expr = parse("b.g(5)")
@test Any[:b,(:call, (:g,Any[5]))] == deserial(chaining(expr, 0, []))

expr = parse("vc.tap(2, row: 1)")
@test Any[:vc,(:call, (:tap,Any[2, Any[:row, 1]]))] == deserial(chaining(expr, 0, []))

expr = parse("vc.tableView.tap(2, row: 1)")
@test Any[:vc,:tableView,(:call, (:tap,Any[2, Any[:row, 1]]))] == deserial(chaining(expr, 0, []))

@test Any[(:symbol,:vc)] == wrap_symbol(Any[:vc])

@test App("a") == endpointof(App("a"),nothing)

@test :not_found == valuate(:not_found)

expr = destchains(:(vc.view))
@test isa(expr, Expr)

expr = parse("PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)")
@test Any[(:symbol,:PHCollectionList),(:call,(:fetchTopLevelUserCollectionsWithOptions,Any[(:symbol,:nil)]))] == wrap_symbol(chains(expr))

expr = parse("PHCollectionList.fetchTopLevelUserCollectionsWithOptions(\"nil\")")
@test Any[(:symbol,:PHCollectionList),(:call,(:fetchTopLevelUserCollectionsWithOptions,Any["nil"]))] == wrap_symbol(chains(expr))


another_info = ResultInfo(:string, "hello", nothing)
another_result = QueryResult(another_info, App("another"), "/query", param)
set_endpoint(another_result)
@test App("another") == current_endpoint
set_endpoint(result)

@test "hello" == valueof(another_result)
