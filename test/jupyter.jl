using Swifter
using Base.Test

import Swifter: QueryResult, App
import Swifter: path_of_image_from_dict, image_scale, save_image_url_to_file

result = QueryResult(:view,"",(App(""),"/query",Dict("lhs"=>[])))
@test true == mimewritable(MIME"text/markdown", result)
buf = IOBuffer()
writemime(buf, "text/markdown", result)
@test startswith(takebuf_string(buf), "```\n\n```\n<img src=\"/image?path&#61;&amp;")

@test "vc.view" == path_of_image_from_dict(Dict("lhs"=>Any["symbol"=>:vc, "symbol"=>:view]))
@test "" == image_scale(result)
@test "" == save_image_url_to_file("", "", "")
