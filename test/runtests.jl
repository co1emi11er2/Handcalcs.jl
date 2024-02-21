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
\\Iy &= \frac{h \cdot b^{3}}{12} = \frac{10 \cdot 5^{3}}{12} = 104.16666666666667\text{  }(\text{moment of inertia y})
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

b = 5
h = 15
a = 5
c = 15

@testset "handfunc macro" begin
    expected_1 = (L"$\begin{align}
Ix &= \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{align}$")

    expected_2 = (L"$\begin{align}
I &= \frac{5 \cdot 15^{3}}{12} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{align}$")  


    expected_Iy_1 = (L"$\begin{align}
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{align}$")

    expected_Iy_2 = (L"$\begin{align}
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{15 \cdot 5^{2}}{12} = 31.25
\end{align}$")

    expected_Iy_3 = (L"$\begin{align}
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{15 \cdot 5^{2}}{10} = 37.5
\end{align}$")


    calc_1 = @handfunc x = calc_Ix(b, h) # check positional parameters with same name
    calc_2 = @handfunc x = calc_Ix(a, c) # check positional parameters with different name
    calc_3 = @handfunc x = calc_Ix(5, 15) # check numeric parameters
    calc_4 = @handfunc x = calc_I() # check no parameters
    calc_Iy_1 = @handfunc x = calc_Iy(5,) # check default positional parameters
    calc_Iy_2 = @handfunc x = calc_Iy(15,5,expo=2) # check kw arguments with ","
    calc_Iy_3 = @handfunc x = calc_Iy(15,5;expo=2, denominator=10) # check kw arguments with ";"
    @test calc_1 == expected_1
    @test calc_2 == expected_1
    @test calc_3 == expected_1
    @test calc_4 == expected_2
    @test calc_Iy_1 == expected_Iy_1
    @test calc_Iy_2 == expected_Iy_2
    @test calc_Iy_3 == expected_Iy_3

end