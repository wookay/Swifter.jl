if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

import Swifter: QueryResult, ResultInfo, App
import Swifter: path_of_image_from_param, save_image_url_to_file
import Swifter: look_like_view, image_scale

result = QueryResult(ResultInfo(:view,""),App(""),"/query",Dict("lhs"=>[]))
@test true == mimewritable(MIME"text/markdown", result)
buf = IOBuffer()
show(buf, MIME"text/markdown"(), result)
@test contains(takebuf_string(buf), "<img src=\"/image")

(path,simple) = path_of_image_from_param(Dict("lhs"=>Any[(:symbol,:vc),(:symbol,:view)]))
@test path == "%5B%5B%22symbol%22%2C%22vc%22%5D%2C%5B%22symbol%22%2C%22view%22%5D%5D"
@test simple == "vc.view"

ENV["SWIFTER_SAVE_IMAGE"] = false
@test "" == save_image_url_to_file("", "", "")

str = "<UILabel: 0x7fe29d447580; frame = (10 100; 500 200); "
(isview, address, xywh) = look_like_view(str)
@test (true, "0x7fe29d447580", [10,100,500,200]) == (isview, address, xywh)
@test "width:250.0px; height: 100.0px;" == image_scale(str)

str = "<UILabel: 0x7fe29d447580; frame = {{10, 100}, {500, 200}}; "
(isview, address, xywh) = look_like_view(str)
@test (true, "0x7fe29d447580", [10,100,500,200]) == (isview, address, xywh)
@test "width:250.0px; height: 100.0px;" == image_scale(str)

str = "string"
(isview, address, xywh) = look_like_view(str)
@test (false, nothing, nothing)== (isview, address, xywh)
@test "" == image_scale(str)
