if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

using Swifter
import Swifter: chains

@query vc.view

text = "Hello world"
@query vc.label.text = text

@test isdefined(Main, :text)

@query intext = "inside"
@query vc.label.text = intext

@test Any[:text] == chains(:text)

pairs = chains(:(UIFont(name: "Courier", size: 90)))
@test Any[(:call, (:UIFont,Any[Any[:name,"Courier"],Any[:size,90]]))] == pairs

outrect = "{{33, 50}, {531, 200}}"
@query vc.label.frame = outrect

@query inrect = "{{33, 50}, {131, 200}}"
@test "{{33, 50}, {131, 200}}" == Swifter.env[:inrect]

@query inrect = outrect
@test "{{33, 50}, {531, 200}}" == Swifter.env[:inrect]

@query rect = CGRectMake(1,2,5,6)
@test (:call,(:CGRectMake,Any[1,2,5,6])) == Swifter.env[:rect]

@query vc.view.subviews[0].backgroundColor = UIColor.redColor()

@test Any[(:call,:tap)] == chains(:(tap()))

@test Any[:view, (:call,:tap)] == chains(:(view.tap()))

@query vc.view.alpha = 0.3


if VERSION >= v"0.5-" @eval begin

@query intext = text
@test "Hello world" == @query intext
@query vc.label.text = intext

end end
