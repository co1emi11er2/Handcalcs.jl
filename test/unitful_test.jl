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