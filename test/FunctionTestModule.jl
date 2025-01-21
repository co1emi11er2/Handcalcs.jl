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

end
