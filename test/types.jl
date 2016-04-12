using Swifter
using Base.Test

import Swifter: Memory, Getter, Setter, PointChain, App, QueryResult
import Swifter: param_dict, sym_to_mem, querychainof, pointchainof
import Swifter: chains, chaining, chain_convert, wrap_json, var_request, evaluate

@test App("") == App("")
@test Memory(App(""), "") == Memory(App(""), "")
@test Getter([:vc]) == Getter([:vc])
@test Setter([:vc], [:vc]) == Setter([:vc], [:vc])
@test PointChain(:notfound, nothing, Getter([])) == PointChain(:notfound, nothing, Getter([]))

expr = :(vc.view.backgroundColor = UIColor.greenColor())
@test Setter([:vc,:view,:backgroundColor],[:UIColor,(:call,:greenColor)]) == querychainof(expr)
@test PointChain(:notfound, nothing,Setter([:vc,:view,:backgroundColor],[:UIColor,(:call,:greenColor)])) == pointchainof(expr)

params = (nothing,"/query",Dict("lhs"=>Any["symbol"=>:vc,"symbol"=>:view],"type"=>"Getter"))
@test QueryResult(:symbol, "Needs initial vc", params) == (@query vc.view)

@test Pair["address"=>"","symbol"=>:view,"symbol"=>:backgroundColor] == sym_to_mem((:vc,Memory(App(""),"")), [(:isdefined,:vc),:view,:backgroundColor])

sym = :UIApplication
@test Dict("lhs"=>Any["symbol"=>:UIApplication],"type"=>"Getter") == param_dict((nothing,nothing), Getter([sym]))
@test Dict("lhs"=>Any["symbol"=>:UIApplication],"rhs"=>Any[],"type"=>"Setter") == param_dict((nothing,nothing), Setter([sym],[]))


import Swifter: chains, chaining, chain_convert, wrap_json, var_request

@test [(:isdefined,:sym)] == chains(:sym)
@test Any["int"=>0] == chains(0)
@test Any["float"=>0.1] == chains(0.1)
@test Any["bool"=>false] == chains(false)
@test Any["string"=>""] == chains("")

expr = parse("vc.view")
@test Any[:vc,:view] == chains(expr)

@test Any[:vc,:view] == chaining(expr, 0, [])
@test Getter(Any[:vc,:view]) == querychainof(expr)
@test Setter(Any[:vc,:view,:alpha],Any["int"=>0]) == querychainof(parse("vc.view.alpha = 0"))
@test ("t", :t) == chain_convert([(:isdefined, :t)])
@test (:notfound, nothing) == chain_convert([])

@test Dict("lhs"=>JSON.json("vc")) == wrap_json(Dict("lhs"=>"vc"))
@test Dict("lhs"=>JSON.json("vc"),"rhs"=>JSON.json("t")) == wrap_json(Dict("lhs"=>"vc", "rhs"=>"t"))

verb = "/query"
dict = Dict("lhs"=>Any["symbol"=>:vc])
@test QueryResult(:symbol, "Needs initial vc", (nothing,verb,dict)) == var_request(nothing, verb, dict)

@test "3" == evaluate(Main, "$(1+2)")

expr = parse("b.g(5)")
@test Any[:b,(:call,Any[:g,Any[5]])] == chaining(expr, 0, [])
