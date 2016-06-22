import Base: LineEdit, REPL


# original code from
# https://github.com/Keno/Cxx.jl/blob/master/src/CxxREPL/replpane.jl

function AddSwifterMode(key, repl)
    panel = LineEdit.Prompt("Swifter> ";
        prompt_prefix = "\e[0;3;5m",
        prompt_suffix = Base.text_colors[:white],
        on_enter = s->true)

    mirepl = isdefined(Base.active_repl,:mi) ? Base.active_repl.mi : Base.active_repl
    function linecall(line)
        try
            expr = parse(line)
            ex = isa(expr, Symbol) ? Expr(:block, expr) : expr
            Expr(:macrocall, Symbol("@query"), ex)
        catch e_
        end
    end
    panel.on_done = REPL.respond(linecall, repl, panel)

    main_mode = repl.interface.modes[1]
    push!(mirepl.interface.modes,panel)

    hp = main_mode.hist
    hp.mode_mapping[:Swifter] = panel
    panel.hist = hp

    const keymap = Dict{Any,Any}(
        key => function (s,args...)
            if isempty(s) || position(LineEdit.buffer(s)) == 0
                buf = copy(LineEdit.buffer(s))
                LineEdit.transition(s, panel) do
                    LineEdit.state(s, panel).input_buffer = buf
                end
            else
                LineEdit.edit_insert(s, key)
            end
        end
    )
    repl.interface = REPL.setup_interface(repl; extra_repl_keymap = keymap)

    search_prompt, skeymap = LineEdit.setup_search_keymap(hp)
    main_keymap = REPL.mode_keymap(main_mode)

    b = Dict{Any,Any}[skeymap, main_keymap, LineEdit.history_keymap, LineEdit.default_keymap, LineEdit.escape_defaults]
    panel.keymap_dict = LineEdit.keymap(b)

    main_mode.keymap_dict = LineEdit.keymap_merge(main_mode.keymap_dict, keymap)
    nothing
end

function RunSwifterREPL(; key=">")
    AddSwifterMode(key, Base.active_repl)
end
