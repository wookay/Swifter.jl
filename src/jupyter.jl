# jupyter.jl

import Base.Markdown: plain, Code, List, tag, htmlesc
import Base: mimewritable, writemime

Base.mimewritable(::Type{MIME"text/markdown"}, result::QueryResult) = true

function image_path(dict::Dict)
    lhs = dict["lhs"]
    join(map(pair->pair.second, lhs), '.')
end

function Base.writemime(stream::IO, mime::MIME"text/markdown", result::QueryResult; kwargs...)
    if isa(result.value, AbstractArray)
        plain(stream, List(map(htmlesc, result.value)))
    else
        plain(stream, Code(string(result.value)))
    end
    if :view == result.name
        m = match(r"frame = \(([\d\.]*) ([\d\.]*); ([\d\.]*) ([\d\.]*)\);", result.value)
        style = ""
        if isa(m, RegexMatch)
            (x,y,w,h) = map(n->parse(Float32,n), m.captures)
            if w > 1000
                (w,h) = (w/5, h/5)
            elseif w > 100
                (w,h) = (w/1.5, h/1.5)
            end
            style = "width:$(w)px; height: $(h)px;"
        end
        (app,verb,dict) = result.params
        path = image_path(dict)
        url = "$(app.url)/image?path=$path&rand=$(randstring(10))"
        tag(stream, :img, :src=>url, :alt=>path, :style=>style)
    end
end
