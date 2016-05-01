using Swifter
using Base.Test

import Swifter: Getter, Setter, App, ResultInfo, QueryResult, CallArg
import Swifter: chains, chaining, deserial, wrap_symbol, destinationof, valuate, destchains

@test App("") == App("")
@test Getter([:vc]) == Getter([:vc])
@test Setter([:vc], [:vc]) == Setter([:vc], [:vc])

expr = :(vc.view.backgroundColor = UIColor.greenColor())

@test App("") == current_app

param = Dict("lhs"=>Any[(:symbol,:vc),(:symbol,:view)], "type"=>"Getter")
info = ResultInfo(:symbol, Swifter.RequireToInitial, nothing)
@test QueryResult(info, App(""), "/query", param) == (@query vc.view)


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

@test App("a") == destinationof(App("a"),nothing)

@test :default == valuate(:vc, :default)

q = destchains(:(vc.view))
@test isa(q, Expr)
