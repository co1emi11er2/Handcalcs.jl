
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
    if @capture(expr, x_ = f_(fields__) | f_(fields__)) # Check if function call
        if f ∉ math_syms
            kwargs = kwargs..., :(is_recursive = true)
            return esc(:(@handfunc $(expr) $(kwargs...)))
        end
    end
    
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
    return _handcalc(expr, expr_numeric, post, kwargs)
end

# Handcalcs - Symbolic and Numeric return
# ***************************************************
function _handcalc(expr, expr_numeric, post, kwargs)
    esc(
        Expr(
            :call,
            :latexify,
            Expr(:parameters, _extractparam.(kwargs)...), 
            Expr(:call, :Expr, 
            QuoteNode(:(=)), Meta.quot(expr), # symbolic portion
            Expr(:call, :Expr, 
            QuoteNode(:(=)), Meta.quot(expr_numeric), # numeric portion
            Expr(:call, post, _executable(expr)))), # defines variable
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
        if Meta.isexpr(ex, :.) # interpolates field args
            count = length(ex.args) + 1
            return Expr(:$, ex)
        end
        if Meta.isexpr(ex, :kw) # interpolates field args
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

function add_recursive_kwarg(kwargs)
    l_kwargs = []

end