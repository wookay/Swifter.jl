# jupyter.jl

import Base: mimewritable
import Base.Markdown: plain, Code, List, tag, htmlesc
import Requests: get
import URIParser: escape
import JSON: print


Base.mimewritable(::Type{MIME"text/markdown"}, result::QueryResult) = true


function path_of_image_from_param(param::Dict)
    lhs = param["lhs"]
    simpler(t::Tuple) = last(t)
    simpler(a::Any) = a
    simple = join(map(simpler, lhs), '.')
    (escape(sprint(print,lhs)), simple)
end


function look_like_view(str::AbstractString)
    m = match(r"(0x[\dabcdef]*); frame = \(([\d\.]*) ([\d\.]*); ([\d\.]*) ([\d\.]*)\);", str)
    if !isa(m, RegexMatch)
        m = match(r"(0x[\dabcdef]*); frame = {{([\d\.]*), ([\d\.]*)}, {([\d\.]*), ([\d\.]*)}};", str)
    end
    if isa(m, RegexMatch)
        (address, xywh) = (m.captures[1], m.captures[2:end])
        (true, address, map(n->parse(Float32,n), xywh))
    else
        (false, nothing, nothing)
    end
end


function image_scale(str::AbstractString)
    (isview, address, xywh) = look_like_view(str)
    if isview
        (x,y,w,h) = xywh
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


function escape_html(str::AbstractString)
    s = replace(str, "&", "&amp;")
    s = replace(s, ">", "&gt;")
    replace(s, "<", "&lt;")
end


function save_image(url::AbstractString, alt::AbstractString)
    randhash = randstring(10)
    src = "$url&r=$randhash"
    save_to_local = true
    if haskey(ENV, "SWIFTER_SAVE_IMAGE")
        save_to_local = !(ENV["SWIFTER_SAVE_IMAGE"] in [false, "false", "0"])
    end
    if save_to_local # && !isempty(el)
        image_path = save_image_url_to_file(src, alt, randhash)
        src = "$image_path?r=$randhash"
    end
    src
end


function show_view_vector(stream::IO, mime::MIME"text/markdown", appvec::Vector{App}, vec::Vector)
    for (idx,el) in enumerate(vec)
        isa(el, Void) && continue
        (isview, address, xywh) = look_like_view(el)
        if isview
            write(stream, escape_html(el))
            app = appvec[idx]
            url = "$(app.url)/image?address=$address"
            tag(stream, :img, :src=>save_image(url, address), :alt=>address, :style=>image_scale(el))
        else
            plain(stream, escape_html(el))
        end
    end
end


function Base.show(stream::IO, mime::MIME"text/markdown", vec::AbstractArray{QueryResult,1})
    show_view_vector(stream, mime, map(v->v.app, vec), map(v->v.info.value, vec))
end


function Base.show(stream::IO, mime::MIME"text/markdown", result::QueryResult; kwargs...)
    if isa(result.info.value, AbstractArray)
        show_view_vector(stream, mime, [result.app for x in 1:length(result.info.value)], result.info.value)
    elseif isa(result.info.value, Void)
        # nothing
    else
        plain(stream, Code(string(result.info.value)))
    end
    if :view == result.info.typ
        (path,simple) = path_of_image_from_param(result.param)
        app = result.app
        url = "$(app.url)/image?path=$path"
        tag(stream, :img, :src=>save_image(url, simple), :alt=>simple, :style=>image_scale(result.info.value))
    end
end


# #14052  ae62bf0b813afbf32402874451e55d16de909bd4
if VERSION < v"0.5-dev+4341"
    function Base.writemime(stream::IO, mime::MIME"text/markdown", vec::AbstractArray{QueryResult,1}; kwargs...)
        Base.show(stream, mime, vec)
    end

    function Base.writemime(stream::IO, mime::MIME"text/markdown", result::QueryResult; kwargs...)
        Base.show(stream, mime, result)
    end
end
