module FunctionTestModule
using Unitful

module cnv
    using Unitful
    to_L(x) = x |> u"inch"
end
    
function add_cnv(a, b)
    c = a + b |> cnv.to_L
end

function add_inch(a, b)
    c = a + b |> u"inch"
end

function foo(x, y)
    if x > 15
        if y > 5
            z = 15
        else
            z = 10
        end
    elseif x > 10
        z = 10
    else
        z = 5
    end
end   

end
