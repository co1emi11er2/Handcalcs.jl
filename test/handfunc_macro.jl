# using Handcalcs
# using LaTeXStrings, Unitful, UnitfulLatexify
# using Test


b = 5
h = 15
a = 5
c = 15

# Check only positional arguments
# ***************************************************
# ***************************************************
expected_1 = (L"$\begin{aligned}
Ix &= \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{aligned}$")
calc_1 = @handfunc x = calc_Ix(b, h) # check positional parameters with same name
calc_2 = @handfunc x = calc_Ix(a, c) # check positional parameters with different name
calc_3 = @handfunc x = calc_Ix(5, 15) # check numeric parameters
@test calc_1 == expected_1
@test calc_2 == expected_1
@test calc_3 == expected_1

a = 5
b = 15
calc_4 = @handfunc x = calc_Ix(a, b) # check positional parameters with b = a and h = b. Make sure b is not redfined
@test calc_4 == expected_1
@test x == 1406.25
# ***************************************************


# Check no parameters
# ***************************************************
# ***************************************************
expected_2 = (L"$\begin{aligned}
I &= \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{aligned}$")  
calc_4 = @handfunc x = TestHandcalcFunctions.calc_I() # check no parameters
@test calc_4 == expected_2
# ***************************************************



# Check keyword arguments
# ***************************************************
# ***************************************************
expected_Iy_1 = (L"$\begin{aligned}
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{aligned}$")
calc_Iy_1 = @handfunc x = TestHandcalcFunctions.calc_Iy(5,) # check default positional parameters
@test calc_Iy_1 == expected_Iy_1

expected_Iy_2 = (L"$\begin{aligned}
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{15 \cdot 5^{2}}{12} = 31.25
\end{aligned}$")
calc_Iy_2 = @handfunc x = TestHandcalcFunctions.calc_Iy(15,5,expo=2) # check kw arguments with ","
@test calc_Iy_2 == expected_Iy_2

expected_Iy_3 = (L"$\begin{aligned}
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{15 \cdot 5^{2}}{10} = 37.5
\end{aligned}$")
calc_Iy_3 = @handfunc x = TestHandcalcFunctions.calc_Iy(15,5;expo=2, denominator=10) # check kw arguments with ";"
calc_Iy_4 = @handfunc x = TestHandcalcFunctions.calc_Iy(10+5,5;expo=2, denominator=5+5) # check expressions
@test calc_Iy_3 == expected_Iy_3
@test calc_Iy_4 == expected_Iy_3

b = 5
h = 15
a = 5
c = 15
expected_1 = (L"$\begin{aligned}
Ix &= \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{aligned}$")
calc_1 = @handfunc x = calc_Ix(;b=b, h=h) # check kw parameters with same name
#calc_2 = @handfunc x = calc_Ix(;b, h) # check kw parameters with same name
calc_3 = @handfunc x = calc_Ix(;b=a, h=c) # check kw parameters with different name
calc_4 = @handfunc x = calc_Ix(;b=5, h=15) # check numeric parameters
@test calc_1 == expected_1
# @test calc_2 == expected_1
@test calc_3 == expected_1
@test calc_4 == expected_1

# ***************************************************


# Check within local scope
# ***************************************************
# ***************************************************
let (u, v) = (5, 15)
    expected_1 = (L"$\begin{aligned}
Ix &= \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{aligned}$")
calc_1 = @handfunc x = calc_Ix(u, v)
@test calc_1 == expected_1
end
# ***************************************************


# Check field args
# ***************************************************
# ***************************************************
expected = L"$\begin{aligned}
area &= l \cdot w = 5 \cdot 15 = 75
\end{aligned}$"

struct myRec
    b
    h
end
rec = myRec(5, 15)
calc = @handfunc area = TestHandcalcFunctions.area_rectangle(rec.b, rec.h)
@test calc == expected
# ***************************************************

# Check recursion and other functions within function body
# ***************************************************
# ***************************************************
expected = L"$\begin{aligned}
Ix &= \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\\[10pt]
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{15 \cdot 5^{3}}{12} = 156.25
\end{aligned}$"
b = 5
h = 15
calc = @handfunc Is = TestHandcalcFunctions.calc_Is(b, h)
@test calc == expected
# ***************************************************

# Check with symbol variabels
# ***************************************************
# ***************************************************
expected_1 = (L"$\begin{aligned}
y &= x = hello
\end{aligned}$")
x = :hello
calc_1 = @handcalcs y = sym_function(x)
@test calc_1 == expected_1
# ***************************************************

# Check submodules
# ***************************************************
# ***************************************************
expected = L"$\begin{aligned}
c &= a + b = 4 + 5 = 9
\end{aligned}$"
a = 4
b = 5
calc = @handcalcs c = TestHandcalcFunctions.SubA.SubB.sub_module_func(a, b)
@test calc == expected
# ***************************************************

# Check parametric functions
# ***************************************************
# ***************************************************
expected = L"$\begin{aligned}
c &= a + b = 4 + 5 = 9
\end{aligned}$"
a = 4
b = 5
calc = @handcalcs c = TestHandcalcFunctions.where_func(a, b)
@test calc == expected
# ***************************************************

# Check single call
# ***************************************************
# ***************************************************
expected = L"$\begin{aligned}
5 + 6 + 7 &= 5 + 6 + 7 = 18
\end{aligned}$"
calc = @handcalcs 5 + 6 + 7
@test calc == expected
# ***************************************************
