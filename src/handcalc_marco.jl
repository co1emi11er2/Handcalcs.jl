
"""
    @handcalc expression

Create `LaTeXString` representing `expression`. The expression being a vaiable followed by
an equals sign and an algebraic equation.
Any side effects of the expression, like assignments, are evaluated as well.
The RHS can be formatted or otherwise transformed by supplying a function as kwarg `post`.

# Examples
```julia-repl
julia> a = 2
2
julia> b = 5
5
julia> @handcalc c = a + b
L"\$c = a + b = 2 + 5 = 7\$"

julia> c
7
```
"""
macro handcalc(expr, kwargs...)
    expr = unblock(expr)
    expr = rmlines(expr)
    expr_og = copy(expr)

    if expr.head == :if && :(is_recursive = true) in kwargs
        expr = parse_if!(expr, kwargs)
        return esc(expr)
    end
    if @capture(expr, x_ = f_(fields__)) # Check if function call
        if f ∉ math_syms && check_not_funcs(f, kwargs)
            if f == :(|>) && get(default_h_kwargs, :parse_pipe, true)  # Check if pipe and if parse_pipe
                expr.args[2] = expr.args[2].args[2]
            else
                kwargs = kwargs..., :(is_recursive = true)
                return esc(:(@handfunc $(expr) $(kwargs...)))
            end
        end
    end

    params = _extractparam.(kwargs)
    post = :identity
    for param in params
        if param === :post
            post = :post
            break
        end
        if param isa Expr && param.args[1] === :post
            post = param.args[2]
            break
        end
    end

    # Check if the user wants a symbolic return, skip numeric calculations
    if get(default_h_kwargs, :h_render, :both) == :symbolic 
        return _handcalc_symbolic(expr_og, expr, post, kwargs)
    end

    # compute the numeric values of the expression
    expr_post = expr.head == :(=) ? expr.args[2:end] : expr
    expr_numeric = _walk_expr(expr_post, math_syms)

    # Check if the user wants a numeric return, else return both
    if get(default_h_kwargs, :h_render, :both) == :numeric
        expr_numeric = Expr(:(=), expr.args[1], expr_numeric)
        return _handcalc_numeric(expr_og, expr_numeric, post, kwargs)
    else
        return _handcalc_both(expr_og, expr, expr_numeric, post, kwargs)
    end
end

# Handcalcs - Symbolic and Numeric return
# ***************************************************
function _handcalc_both(expr_og, expr, expr_numeric, post, kwargs)
    esc(
        Expr(
            :call,
            :latexify,
            Expr(:parameters, _extractparam.(kwargs)...),
            Expr(:call, :Expr,
                QuoteNode(:(=)), Meta.quot(expr), # symbolic portion
                Expr(:call, :Expr,
                    QuoteNode(:(=)), Meta.quot(expr_numeric), # numeric portion
                    Expr(:call, post, _executable(expr_og)))), # defines variable
        ),
    )
end

# Handcalcs - Symbolic return
# ***************************************************
function _handcalc_symbolic(expr_og, expr, post, kwargs)
    esc(
        Expr(
            :call,
            :latexify,
            Expr(:parameters, _extractparam.(kwargs)...),
            Expr(:call, :Expr,
                QuoteNode(:(=)), Meta.quot(expr), # symbolic portion
                Expr(:call, post, _executable(expr_og))) # defines variable
        ),
    )
end
# ***************************************************

# Handcalcs - Numeric return
# ***************************************************
function _handcalc_numeric(expr_og, expr_numeric, post, kwargs)
    esc(
        Expr(
            :call,
            :latexify,
            Expr(:parameters, _extractparam.(kwargs)...),
            Expr(:call, :Expr,
                QuoteNode(:(=)), Meta.quot(expr_numeric), # numeric portion
                Expr(:call, post, _executable(expr_og))) # defines variable
        ),
    )
end
# ***************************************************

# Latexify Functions
# ***************************************************

function _executable(expr)
    return postwalk(expr) do ex
        if Meta.isexpr(ex, :$)
            return ex.args[1]
        end
        return ex
    end
end

_extractparam(arg::Symbol) = arg
_extractparam(arg::Expr) = Expr(:kw, arg.args[1], arg.args[2])

# ***************************************************


# These Functions parse the original expression to
# create an expression that interplotes the variables
# ***************************************************
# ***************************************************

function numeric_sub(x)
    Expr(:($), x)
end

function _walk_expr(expr::Vector, math_syms)
    count = 0
    return prewalk(expr...) do ex
        if count > 0 # skip sections based on prewalk
            count -= 1
            return ex
        end
        if Meta.isexpr(ex, :.) # interpolates field args
            count = _det_branch_size(ex; count=3)
            return Expr(:$, ex)
        end
        if Meta.isexpr(ex, :kw) # interpolates field args
            count = 1
            return ex
        end
        if Meta.isexpr(ex, :ref)
            count = length(collect(PostOrderDFS(ex)))
            return Expr(:$, ex)
        end
        if Meta.isexpr(ex, :(=))
            count = 1
            return ex
        end
        if (ex isa Symbol) & (ex ∉ math_syms)
            count = 1
            return numeric_sub(ex)
        end
        return ex
    end
end

function _walk_expr(expr::Expr, math_syms)
    count = 0
    return prewalk(expr) do ex
        if count > 0 # skip sections based on prewalk
            count -= 1
            return ex
        end
        if Meta.isexpr(ex, :ref)
            count = length(collect(PostOrderDFS(ex)))
            return Expr(:$, ex)
        end
        if Meta.isexpr(ex, :.) # interpolates field args
            count = _det_branch_size(ex; count=3)
            return Expr(:$, ex)
        end
        if Meta.isexpr(ex, :kw) # interpolates field args
            count = 1
            return ex
        end
        if Meta.isexpr(ex, :(=))
            count = 1
            return ex
        end
        if (ex isa Symbol) & (ex ∉ math_syms)
            count = 1
            return numeric_sub(ex)
        end
        return ex
    end
end

function _det_branch_size(expr; count=3) # determines field arg depth
    arg1 = expr.args[1]
    if Meta.isexpr(arg1, :.)
        count += 1
        return _det_branch_size(arg1; count=count)
    end
    return count
end

# ***************************************************
# ***************************************************

function check_not_funcs(f, kwargs)
    not_funcs = find_not_funcs(kwargs)
    not_funcs = typeof(not_funcs) == Symbol ? [not_funcs] : not_funcs
    defaults = get(default_h_kwargs, :not_funcs, [])
    if defaults != []
        push!(not_funcs, defaults...)
    end
    if Meta.isexpr(f, :.)
        f_new = f.args[end].value
        return f_new ∉ not_funcs
    end
    return f ∉ not_funcs
end

function find_not_funcs(kwargs)
    not_funcs = []
    for kwarg in kwargs
        split_kwarg = _split_kwarg(kwarg)
        if split_kwarg == :not_funcs
            not_funcs = parse_not_funcs(kwarg.args[2])
        end
    end
    return not_funcs
end

function parse_not_funcs(value::QuoteNode)
    [value.value]
end

function parse_not_funcs(value::Symbol)
    [value]
end

function parse_not_funcs(expr::Expr)
    not_funcs = []
    if expr.head in [:vcat :hcat :vect]
        for arg in expr.args
            push!(not_funcs, parse_not_func(arg))
        end
    elseif expr.head == :.
        return [expr]
    end
    return not_funcs
end

function parse_not_func(value::QuoteNode)
    value.value
end

function parse_not_func(value)
    value
end

# ***************************************************
# ***************************************************
function parse_if!(expr, kwargs, cond_expr=:())
    count = 0
    for (i, arg) in enumerate(expr.args)
        if i == 1 # in conditional statement
            push!(cond_expr.args, unblock(arg))
        elseif i == 2 # in actual block of code
            expr.args[i] = :(@handcalcs begin
                "Since:";
                $(unblock(last(cond_expr.args)))
                $(arg.args...)
            end $(kwargs...)
            )
            continue
        elseif i == 3 # in else or ifelse statement
            if Meta.isexpr(arg, :elseif)
                arg = parse_if!(arg, kwargs, cond_expr)
            else
                expr.args[i] = :(@handcalcs begin
                    "Since:";
                    $(cond_expr.args...)
                    $(arg.args...)
                end $(kwargs...)
                )
            end
        end
    end
    return expr
end
