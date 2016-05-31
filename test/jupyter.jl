using Swifter
using Base.Test

import Swifter: QueryResult, ResultInfo, App
import Swifter: path_of_image_from_param, image_scale, save_image_url_to_file

result = QueryResult(ResultInfo(:view,""),App(""),"/query",Dict("lhs"=>[]))
@test true == mimewritable(MIME"text/markdown", result)
buf = IOBuffer()
show(buf, MIME"text/markdown"(), result)
@test contains(takebuf_string(buf), "<img src=\"/image")

(path,simple) = path_of_image_from_param(Dict("lhs"=>Any[(:symbol,:vc),(:symbol,:view)]))
@test path == "%5B%5B%22symbol%22%2C%22vc%22%5D%2C%5B%22symbol%22%2C%22view%22%5D%5D"
@test simple == "vc.view"
@test "" == image_scale(result)

ENV["SWIFTER_SAVE_IMAGE"] = false
@test "" == save_image_url_to_file("", "", "")
