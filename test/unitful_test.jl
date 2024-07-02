# using Handcalcs
# using Unitful, UnitfulLatexify
# using Test

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

expected = L"$\begin{aligned}
area &= b \cdot h = 5\;\mathrm{ft} \cdot 120\;\mathrm{inch} = 50\;\mathrm{ft}^{2}
\end{aligned}$"
b = 5u"ft"
h = 120u"inch"
calc = @handcalcs area = b*h |> u"ft^2"
@test calc == expected