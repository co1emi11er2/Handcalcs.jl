# using Handcalcs
# using LaTeXStrings, Unitful, UnitfulLatexify
# using Test
# include("test_functions.jl")
# using .TestFunctions

b = 5
h = 15
a = 5
c = 15

# Check only positional arguments
expected_1 = (L"$\begin{align}
Ix &= \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{align}$")
calc_1 = @handfunc x = calc_Ix(b, h) # check positional parameters with same name
calc_2 = @handfunc x = calc_Ix(a, c) # check positional parameters with different name
calc_3 = @handfunc x = calc_Ix(5, 15) # check numeric parameters
@test calc_1 == expected_1
@test calc_2 == expected_1
@test calc_3 == expected_1

# Check no parameters
expected_2 = (L"$\begin{align}
I &= \frac{5 \cdot 15^{3}}{12} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{align}$")  
calc_4 = @handfunc x = Handcalcs.calc_I() # check no parameters
@test calc_4 == expected_2


# Check keyword arguments
expected_Iy_1 = (L"$\begin{align}
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{5 \cdot 15^{3}}{12} = 1406.25
\end{align}$")
calc_Iy_1 = @handfunc x = Handcalcs.calc_Iy(5,) # check default positional parameters
@test calc_Iy_1 == expected_Iy_1

expected_Iy_2 = (L"$\begin{align}
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{15 \cdot 5^{2}}{12} = 31.25
\end{align}$")
calc_Iy_2 = @handfunc x = Handcalcs.calc_Iy(15,5,expo=2) # check kw arguments with ","
@test calc_Iy_2 == expected_Iy_2

expected_Iy_3 = (L"$\begin{align}
Iy &= \frac{h \cdot b^{expo}}{denominator} = \frac{15 \cdot 5^{2}}{10} = 37.5
\end{align}$")
calc_Iy_3 = @handfunc x = Handcalcs.calc_Iy(15,5;expo=2, denominator=10) # check kw arguments with ";"
@test calc_Iy_3 == expected_Iy_3