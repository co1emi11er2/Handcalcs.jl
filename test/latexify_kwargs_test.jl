# using Handcalcs
# using Test

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