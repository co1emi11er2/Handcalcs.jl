# using Handcalcs
# using Test


# Quadratic formula test
# ***************************************************
# ***************************************************
expected = L"$x = \frac{ - b + \sqrt{b^{2} - 4 \cdot a \cdot c}}{2 \cdot a} = \frac{ + 5 + \sqrt{\left( -5 \right)^{2} - 4 \cdot 2 \cdot 2}}{2 \cdot 2} = 2.0$"

a = 2
b = -5
c = 2

calc = @handcalc x = (-b + sqrt(b^2 - 4*a*c))/(2*a)
calc2 = @handcalc begin x = (-b + sqrt(b^2 - 4*a*c))/(2*a) end

@test calc == expected
@test calc2 == expected
# ***************************************************
# ***************************************************
