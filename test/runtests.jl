using Handcalcs
using LaTeXStrings, Unitful, UnitfulLatexify
using Test

@testset "handcalc macro" begin
    # Quadratic formula test
    expected = L"$x = \frac{ - b + \sqrt{b^{2} - 4 \cdot a \cdot c}}{2 \cdot a} = \frac{ + 5 + \sqrt{\left( -5 \right)^{2} - 4 \cdot 2 \cdot 2}}{2 \cdot 2} = 2.0$"
    a = 2
    b = -5
    c = 2
    calc = @handcalc x = (-b + sqrt(b^2 - 4*a*c))/(2*a)
    calc2 = @handcalc begin x = (-b + sqrt(b^2 - 4*a*c))/(2*a) end
    @test calc == expected
    @test calc2 == expected
end

@testset "Latexify kwargs" begin
    # testing post kwarg
    expected = L"$c = a + b = 1.234 + 5.678 = 7.0$"
    a = 1.234
    b = 5.678
    calc = @handcalc c = a + b post = round
    @test calc == expected

    # testing fmt kwarg
    expected = L"$c = a + b = 1.2340 + 5.6780 = 6.9120$"
    a = 1.234
    b = 5.678
    calc = @handcalc c = a + b fmt = "%.4f"
    @test calc == expected
end

@testset "UnitfulLatexify" begin
    # Simple test
    expected = L"$x = a + b = 2\;\mathrm{inch} -5\;\mathrm{inch} = -3\;\mathrm{inch}$"
    a = 2u"inch"
    b = -5u"inch"
    calc = @handcalc x = a + b
    @test calc == expected
    
    #TODO: Fix exponent issue
    # Unitful and UnitfulLatexify exponent test
    expected = L"$x = (a)^{2} = (2\;\mathrm{inch})^{2} = 4\;\mathrm{inch}^{2}$"
    a = 2u"inch"
    calc = @handcalc x = a^2
    @test_broken calc == expected
end

@testset "handcalcs macro" begin
    #TODO: Figure out way to write expected better and get it to pass
    expected = (L"$\begin{align}
Iy &= \frac{h \cdot b^{3}}{12} = \frac{10 \cdot 5^{3}}{12} = 104.16666666666667\text{  }(\text{moment of inertia y})
\\Ix &= \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 10^{3}}{12} = 416.6666666666667\text{  }(\text{moment of inertia x})
\end{align}$")
    # expected = (L"$\begin{align}\\Iy = \frac{h \cdot b^{3}}{12} = \frac{10 \cdot 5^{3}}{12} = 104.16666666666667\text{  }(\text{moment of inertia y})\\Ix = \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 10^{3}}{12} = 416.6666666666667\text{  }(\text{moment of inertia x})\end{align}$")
    b = 5
    h = 10
    comment1 = "moment of inertia"
    calc = @handcalcs begin
        Iy = h*b^3/12; "moment of inertia y";
	    Ix = b*h^3/12; "moment of inertia x";
    end
    @test calc == expected
    #TODO: Fix default to 4 decimals
    expected = (L"$\begin{align}\\Iy = \frac{h \cdot b^{3}}{12} = \frac{10 \cdot 5^{3}}{12} = 104.1667\text{  }(\text{moment of inertia y})\\Ix = \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 10^{3}}{12} = 416.6667\text{  }(\text{moment of inertia x})\end{align}$")
    @test_broken calc == expected

end
