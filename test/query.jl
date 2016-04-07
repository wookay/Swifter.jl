using Swifter
using Base.Test

text = "Hello world"
@query vc.label.text = text

@query intext = "inside"
@query vc.label.text = intext

@query intext = text
@query vc.label.text = intext

fontcall = @query font = UIFont(name: "Courier", size: 90)
@test Any["call"=>Any[:UIFont,Any[Any[:name,"Courier"],Any[:size,90]]]] == fontcall
@test Any["call"=>Any[:UIFont,Any[Any[:name,"Courier"],Any[:size,90]]]] == Swifter.font


outrect = "{{33, 50}, {531, 200}}"
@query vc.label.frame = outrect

@query inrect = "{{33, 50}, {131, 200}}"
@test Any["string"=>"{{33, 50}, {131, 200}}"] == Swifter.inrect

@query inrect = outrect
@test Any["string"=>"{{33, 50}, {531, 200}}"] == Swifter.inrect


@query rect = CGRectMake(1,2,5,6)
@test Any["call"=>Any[:CGRectMake,Any[1,2,5,6]]] == Swifter.rect

@query vc.view.subviews[0].backgroundColor = UIColor.redColor()
