
"""
    @handcalc expression

Create `LaTeXString` representing `expression`. The expression being a vaiable followed by an equals sign and an algebraic equation.
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
    math_syms = [:*, :/, :^, :+, :-, :%, :.*, :./, :.^, :.+, :.-, :.%]
    # if @capture(expr, x_ = f_(fields__) | f_(fields__)) #future recursion
    #     if f ∉ math_syms
    #         return esc(:((@macroexpand @handfunc $expr)))
    #     end
    #     # return :($esc(@handfunc $expr))
    # end
    
    expr_post = expr.head == :(=) ? expr.args[2:end] : expr
    expr_numeric = _walk_expr(expr_post, math_syms)
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
    return esc(
        Expr(
            :call,
            :latexify,
            Expr(:parameters, _extractparam.(kwargs)...),
            Expr(:call, :Expr, QuoteNode(:(=)), Meta.quot(expr), Expr(:call, :Expr, QuoteNode(:(=)), Meta.quot(expr_numeric), Expr(:call, post, _executable(expr)))),
        ),
    )
end

# function _walk_expr(expr::Vector, math_syms)
#     print("This is vector")
#     postwalk(x -> (x isa Symbol) & (x ∉ math_syms) ? numeric_sub(x) : x, expr...)
# end

# function _walk_expr(expr::Expr, math_syms)
#     print("This is expr")
#     postwalk(x -> (x isa Symbol) & (x ∉ math_syms) ? numeric_sub(x) : x, expr)
# end

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

function numeric_sub(x)
	Expr(:($), x)
end

function _walk_expr(expr::Vector, math_syms)
    count = 0
    return prewalk(expr...) do ex
        if count > 0
            count -= 1
            return ex
        end
        if Meta.isexpr(ex, :.)
            count = _det_branch_size(ex; count=3)
            return Expr(:$, ex)
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
        # println(ex)
        if count > 0
            count -= 1
            return ex
        end
        if Meta.isexpr(ex, :.)
            count = length(ex.args) + 1
            return Expr(:$, ex)
        end
        if (ex isa Symbol) & (ex ∉ math_syms)
            count = 1
            return numeric_sub(ex)
        end
            return ex
    end
end

function _det_branch_size(expr; count=3)
    arg1 = expr.args[1]
    if Meta.isexpr(arg1, :.)
        count += 1
        return _det_branch_size(arg1; count=count)
    end
    return count
end