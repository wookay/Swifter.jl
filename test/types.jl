using Swifter
using Base.Test

import Swifter: Memory, Getter, Setter, PointChain, App, QueryResult
import Swifter: params, sym_to_mem, querychainof, pointchainof

@test App("") == App("")
@test Memory(App(""), "") == Memory(App(""), "")
@test Getter([:vc]) == Getter([:vc])
@test Setter([:vc], [:vc]) == Setter([:vc], [:vc])
@test PointChain(:notfound, nothing, Getter([])) == PointChain(:notfound, nothing, Getter([]))

expr = :(vc.view.backgroundColor = UIColor.greenColor())
@test Setter([:vc,:view,:backgroundColor],[:UIColor,(:call,:greenColor)]) == querychainof(expr)
@test PointChain(:notfound, nothing,Setter([:vc,:view,:backgroundColor],[:UIColor,(:call,:greenColor)])) == pointchainof(expr)

@test QueryResult(:symbol, "Needs initial vc") == (@query vc.view)

@test Pair["address"=>"","symbol"=>:view,"symbol"=>:backgroundColor] == sym_to_mem((:vc,Memory(App(""),"")), [(:isdefined,:vc),:view,:backgroundColor])

sym = :UIApplication
@test Dict("lhs"=>Any["symbol"=>:UIApplication],"type"=>"Getter") == params((nothing,nothing), Getter([sym]))
