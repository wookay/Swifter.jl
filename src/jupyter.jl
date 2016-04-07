# jupyter.jl

import Base.Markdown: plain, Code, List, tag, htmlesc
import Base: mimewritable, writemime
import Requests: get

Base.mimewritable(::Type{MIME"text/markdown"}, result::QueryResult) = true

function path_of_image_from_dict(dict::Dict)
    lhs = dict["lhs"]
    join(map(pair->pair.second, lhs), '.')
end

function image_scale(result::QueryResult)
    m = match(r"= \(([\d\.]*) ([\d\.]*); ([\d\.]*) ([\d\.]*)\);", result.value)
    if !isa(m, RegexMatch)
        m = match(r"= {{([\d\.]*), ([\d\.]*)}, {([\d\.]*), ([\d\.]*)}};", result.value)
    end
    if isa(m, RegexMatch)
        (x,y,w,h) = map(n->parse(Float32,n), m.captures)
        scale = 1
        if w > 1000
            scale = 1/5
        elseif w > 100
            scale = 1/2
        end
        "width:$(w*scale)px; height: $(h*scale)px;"
    else
        ""
    end
end

function save_image_url_to_file(url::AbstractString, path::AbstractString, r::AbstractString)
    isempty(path) && return url
    isdir("images") || mkdir("images")
    image_path = "images/$(path)-$r.png"
    f = open(image_path, "w")
    write(f, get(url).data)
    close(f)
    image_path
end

function Base.writemime(stream::IO, mime::MIME"text/markdown", result::QueryResult; kwargs...)
    if isa(result.value, AbstractArray)
        plain(stream, List(map(htmlesc, result.value)))
    else
        plain(stream, Code(string(result.value)))
    end
    if :view == result.name
        (app,verb,dict) = result.params
        path = path_of_image_from_dict(dict)
        r = randstring(10)
        url = "$(app.url)/image?path=$path&r=$r"
        save_image = true
        if haskey(ENV, "SWIFTER_SAVE_IMAGE")
            save_image = !(ENV["SWIFTER_SAVE_IMAGE"] in ["false", "0"])
        end
        if save_image
            image_path = save_image_url_to_file(url, path, r)
            url = "$image_path?r=$r"
        end
        tag(stream, :img, :src=>url, :alt=>path, :style=>image_scale(result))
    end
end
