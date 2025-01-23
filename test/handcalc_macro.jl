# using Handcalcs
# using Test


# Pluto test
# ***************************************************
# ***************************************************
expected = html"""
<style>
	mjx-container {
		text-align: left !important;
	}
</style>
"""
calc = left_align_in_pluto()
@test calc == expected

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
@test x == 2.0
@test calc2 == expected
# ***************************************************


# foo with args and kwargs
# ***************************************************
# ***************************************************
let 
    expected = L"$x = \frac{ - b + \sqrt{b^{2} - 4 \cdot a \cdot c}}{2 \cdot a} = \frac{ + 5 + \sqrt{\left( -5 \right)^{2} - 4 \cdot 2 \cdot 2}}{2 \cdot 2} = 2.0$"

    function foo(x; y, z)
        return x + y + z
    end

    x = 5
    y = 3
    z = 7

    expected1 = L"$\mathrm{foo}\left( y, z, x \right) = \mathrm{foo}\left( 3, 7, 5 \right) = 15$"
    calc1 = @handcalc foo(x; y, z)
    @test calc1 == expected1

    expected2 = L"$\mathrm{foo}\left( x; y = y, z = z \right) = \mathrm{foo}\left( 5; y = 3, z = 7 \right) = 15$"
    calc2 = @handcalc foo(x; y=y, z=z)
    @test calc2 == expected2

    expected3 = L"$\mathrm{foo}\left( x, y = y, z = z \right) = \mathrm{foo}\left( 5, y = 3, z = 7 \right) = 15$"
    calc3 = @handcalc foo(x, y=y, z=z)
    @test calc3 == expected3

end
# ***************************************************


# array indexing
# ***************************************************
# ***************************************************
let 
    x = [1 2]

    expected = L"$x\left[x\left[1\right]\right] + x\left[2\right] = 1 + 2 = 3$"
    calc = @handcalc x[x[1]] + x[2]
    @test calc == expected
    
end
# ***************************************************
