# jupyter.jl

import Base.Markdown: plain, Code, List, tag, htmlesc
import Base: mimewritable
import Requests: get
import JSON: print
import URIParser: escape

Base.mimewritable(::Type{MIME"text/markdown"}, result::QueryResult) = true

function path_of_image_from_param(param::Dict)
    lhs = param["lhs"]
    simpler(t::Tuple) = last(t)
    simpler(a::Any) = a
    simple = join(map(simpler, lhs), '.')
    (escape(sprint(print,lhs)), simple)
end

function image_scale(result::QueryResult)
    m = match(r"= \(([\d\.]*) ([\d\.]*); ([\d\.]*) ([\d\.]*)\);", result.info.value)
    if !isa(m, RegexMatch)
        m = match(r"= {{([\d\.]*), ([\d\.]*)}, {([\d\.]*), ([\d\.]*)}};", result.info.value)
    end
    if isa(m, RegexMatch)
        (x,y,w,h) = map(n->parse(Float32,n), m.captures)
        scale = 1
        if w > 1000 && h > 500
            scale = 1/5
        elseif w > 100 && h > 50
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

function Base.show(stream::IO, mime::MIME"text/markdown", result::QueryResult; kwargs...)
    if isa(result.info.value, AbstractArray)
        plain(stream, List(map(htmlesc, result.info.value)))
    elseif isa(result.info.value, Void)
        # nothing
    else
        plain(stream, Code(string(result.info.value)))
    end
    if :view == result.info.typ
        (path,simple) = path_of_image_from_param(result.param)
        r = randstring(10)
        url = "$(result.app.url)/image?path=$path&r=$r"
        save_image = true
        if haskey(ENV, "SWIFTER_SAVE_IMAGE")
            save_image = !(ENV["SWIFTER_SAVE_IMAGE"] in [false, "false", "0"])
        end
        if save_image && !isempty(result.app.url)
            image_path = save_image_url_to_file(url, simple, r)
            url = "$image_path?r=$r"
        end
        tag(stream, :img, :src=>url, :alt=>simple, :style=>image_scale(result))
    end
end
