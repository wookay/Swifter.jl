using Swifter
using Base.Test

import Swifter: image_path, QueryResult, App

result = QueryResult(:view,"",(App(""),"/query",Dict("lhs"=>[])))
@test "vc.view" == image_path(Dict("lhs"=>Any["symbol"=>:vc, "symbol"=>:view]))
@test true == mimewritable(MIME"text/markdown", result)
buf = IOBuffer()
writemime(buf, "text/markdown", result)
@test startswith(takebuf_string(buf), "```\n\n```\n<img src=\"/image?path&#61;&amp;")
