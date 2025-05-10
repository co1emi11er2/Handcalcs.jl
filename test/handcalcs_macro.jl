# using Handcalcs
# using LaTeXStrings, Unitful, UnitfulLatexify
# using Test

# Single Expression - General
# ***************************************************
# ***************************************************
expected =  L"$\begin{aligned}
x &= \frac{ - b + \sqrt{b^{2} - 4 \cdot a \cdot c}}{2 \cdot a} = \frac{ + 5 + \sqrt{\left( -5 \right)^{2} - 4 \cdot 2 \cdot 2}}{2 \cdot 2} = 2.0
\end{aligned}$"
a = 2
b = -5
c = 2
calc = @handcalcs x = (-b + sqrt(b^2 - 4*a*c))/(2*a)
calc2 = @handcalcs begin x = (-b + sqrt(b^2 - 4*a*c))/(2*a) end
@test calc == expected
@test x == 2.0
@test calc2 == expected
# ***************************************************


# Multiple Expressions - General
# ***************************************************
# ***************************************************
expected = (L"$\begin{aligned}
Iy &= \frac{h \cdot b^{3}}{12} = \frac{10 \cdot 5^{3}}{12} = 104.16666666666667\;\text{  }(\text{moment of inertia y})
\\[10pt]
Ix &= \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 10^{3}}{12} = 416.6666666666667\;\text{  }(\text{moment of inertia x})
\end{aligned}$")
b = 5
h = 10
comment1 = "moment of inertia"
calc = @handcalcs begin
    Iy = h*b^3/12; "moment of inertia y";
    Ix = b*h^3/12; "moment of inertia x";
end
@test calc == expected
@test Iy == 104.16666666666667
# ***************************************************


# Formatting check
# ***************************************************
# ***************************************************
#TODO: Fix default to 4 decimals
expected = (L"$\begin{aligned}\\Iy = \frac{h \cdot b^{3}}{12} = \frac{10 \cdot 5^{3}}{12} = 104.1667\text{  }(\text{moment of inertia y})\\Ix = \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 10^{3}}{12} = 416.6667\text{  }(\text{moment of inertia x})\end{aligned}$")
@test_broken calc == expected
# ***************************************************


# Array type - General and broadcasting
# ***************************************************
# ***************************************************
expected = (L"$\begin{aligned}
z &= x + y = \left[
\begin{array}{c}
1 \\
2 \\
3 \\
\end{array}
\right] + \left[
\begin{array}{c}
4 \\
5 \\
6 \\
\end{array}
\right] = \left[
\begin{array}{c}
5 \\
7 \\
9 \\
\end{array}
\right]
\end{aligned}$")

expected2 = (L"$\begin{aligned}
z &= x \cdot y = \left[
\begin{array}{c}
1 \\
2 \\
3 \\
\end{array}
\right] \cdot \left[
\begin{array}{c}
4 \\
5 \\
6 \\
\end{array}
\right] = \left[
\begin{array}{c}
4 \\
10 \\
18 \\
\end{array}
\right]
\end{aligned}$")
x = [1; 2; 3]
y = [4; 5; 6]
calc = @handcalcs z = x + y

calc2 = @handcalcs z = x .* y
@test calc == replace(expected, "\r" => "") # for whatever reason the expected had addittional carriage returns (\r)
@test calc2 == replace(expected2, "\r" => "")
# ***************************************************


# cols, spa, color, and len kwargs test
# ***************************************************
# ***************************************************
expected = L"$\color{blue} \begin{aligned}
a &= 1&
b &= 2&
c &= 3
\\[5pt]
x &= 4&
y &= 5&
z &= 6
\end{aligned}$"

calc = @handcalcs begin
    a = 1
    b = 2
    c = 3
    x = 4
    y = 5
    z = 6
end cols=3 spa=5 color=:blue

@test calc == expected

a = 2
b = -5
c = 2
expected = L"$\begin{aligned}
x1 &= \frac{ - b + \sqrt{b^{2} - 4 \cdot a \cdot c}}{2 \cdot a}
\\[10pt]
&= \frac{ + 5 + \sqrt{\left( -5 \right)^{2} - 4 \cdot 2 \cdot 2}}{2 \cdot 2}
\\[10pt]
&= 2.0\;\text{  }(\text{moment})
\\[10pt]
x2 &= \frac{ - b - \sqrt{b^{2} - 4 \cdot a \cdot c}}{2 \cdot a}
\\[10pt]
&= \frac{ + 5 - \sqrt{\left( -5 \right)^{2} - 4 \cdot 2 \cdot 2}}{2 \cdot 2}
\\[10pt]
&= 0.5
\end{aligned}$"

calc = @handcalcs begin
    x1 = (-b + sqrt(b^2 - 4*a*c))/(2*a); "moment";
    x2 = (-b - sqrt(b^2 - 4*a*c))/(2*a)
end len = :long

calc2 = @handcalcs begin
    x1 = (-b + sqrt(b^2 - 4*a*c))/(2*a); "moment";
    x2 = (-b - sqrt(b^2 - 4*a*c))/(2*a)
end len=:long cols=3 

@test calc == expected
@test calc2 == expected
# ***************************************************


# parameters test
# ***************************************************
# ***************************************************
expected = L"$\begin{aligned}
a &= 5
\\[10pt]
b &= 6
\end{aligned}$"

a = 5

calc = @handcalcs begin # check mix of symbol and variable
    a
    b = 6
end
@test calc == expected

expected = L"$\begin{aligned}
a &= 5
\end{aligned}$"

calc = @handcalcs a   # check single symbol
@test calc == expected

calc = @handcalcs begin a end
@test calc == expected
# ***************************************************


# not_funcs test
# ***************************************************
# ***************************************************
expected = L"$\begin{aligned}
I_{x} &= \mathrm{calc}_{Ix}\left( 5, 15 \right) = 1406.25
\end{aligned}$"

calc1 = @handcalcs begin
    I_x = calc_Ix(5,15)
end not_funcs = calc_Ix

calc2 = @handcalcs begin
    I_x = calc_Ix(5,15)
end not_funcs = :calc_Ix

@test calc1 == expected
@test calc2 == expected

expected = L"$\begin{aligned}
Ix &= \mathrm{calc}_{Ix}\left( b, h \right) = \mathrm{calc}_{Ix}\left( 5, 15 \right) = 1406.25
\\[10pt]
Iy &= \mathrm{calc}_{Iy}\left( h, b \right) = \mathrm{calc}_{Iy}\left( 15, 5 \right) = 156.25
\end{aligned}$"

calc1 = @handcalcs begin
    I_s = calc_Is(5,15)
end not_funcs = [calc_Ix calc_Iy]

calc2 = @handcalcs begin
    I_s = calc_Is(5,15)
end not_funcs = [:calc_Ix :calc_Iy]

calc3 = @handcalcs begin
    I_s = calc_Is(5,15)
end not_funcs = [calc_Ix, calc_Iy]

calc4 = @handcalcs begin
    I_s = calc_Is(5,15)
end not_funcs = [calc_Ix; calc_Iy]

@test calc1 == expected
@test calc2 == expected
@test calc3 == expected
@test calc4 == expected
# ***************************************************

# if statement test
# ***************************************************
# ***************************************************
expected = L"$\begin{aligned}
I &= \begin{cases}
\frac{5 \cdot 15^{3}}{12} & \text{if } type = Ix\\
\frac{15 \cdot 5^{3}}{12} & \text{otherwise}
\end{cases} = \begin{cases}
\frac{5 \cdot 15^{3}}{12} & \text{if } Ix = Ix\\
\frac{15 \cdot 5^{3}}{12} & \text{otherwise}
\end{cases} = 1406.25
\end{aligned}$"
type = :Ix
calc = @handcalcs I= if type == :Ix
    5 * 15^3/12
else
    15 * 5^3/12
end

@test calc == replace(expected, "\r" => "") # for whatever reason the expected had addittional carriage returns (\r)

expected = L"$\begin{aligned}
I &= \begin{cases}
\frac{5 \cdot 15^{3}}{12} & \text{if } Ix = Ix\\
\frac{15 \cdot 5^{3}}{12} & \text{otherwise}
\end{cases} = 1406.25
\end{aligned}$"

calc = @handcalcs I= if :Ix == :Ix
    5 * 15^3/12
else
    15 * 5^3/12
end
@test calc == replace(expected, "\r" => "") # for whatever reason the expected had addittional carriage returns (\r)
# ***************************************************

# if parsing test
# ***************************************************
# ***************************************************
x = 16
y = 6
expected = L"$\begin{aligned}
\text{Since: }x > 15 &= 16 > 15 = true
\\[10pt]
\text{Since: }y > 5 &= 6 > 5 = true
\\[10pt]
z &= 15
\end{aligned}$"
calc = @handcalcs z = FunctionTestModule.foo(x, y)
@test calc == expected

y = 4
expected = L"$\begin{aligned}
\text{Since: }x > 15 &= 16 > 15 = true
\\[10pt]
\text{Since: }y > 5 &= 4 > 5 = false
\\[10pt]
z &= 10
\end{aligned}$"
calc = @handcalcs z = FunctionTestModule.foo(x, y)
@test calc == expected

x = 14
expected = L"$\begin{aligned}
\text{Since: }x > 10 &= 14 > 10 = true
\\[10pt]
z &= 10
\end{aligned}$"
calc = @handcalcs z = FunctionTestModule.foo(x, y)
@test calc == expected

x = 9
expected = L"$\begin{aligned}
\text{Since: }x > 15 &= 9 > 15 = false
\\[10pt]
x > 10 &= 9 > 10 = false
\\[10pt]
z &= 5
\end{aligned}$"
calc = @handcalcs z = FunctionTestModule.foo(x, y)
@test calc == expected

x = 6
inch = u"inch"
expected = L"$\begin{aligned}
\text{Since: }x > 15 &= 6 > 15 = false
\\[10pt]
c &= a + b = 4\;\mathrm{inch} + 6\;\mathrm{inch} = 10\;\mathrm{inch}
\\[10pt]
d &= 6
\end{aligned}$"
calc = @handcalcs begin
    if x > 15
        c = 1inch
    else
        c = FunctionTestModule.add_inch(4inch, 6inch)
        d = 6
    end
end
@test calc == expected
# ***************************************************

# string interpolation test
# ***************************************************
# ***************************************************
expected = L"$\begin{aligned}
\text{Part 15: }b &= 2\;\text{  }(\text{hello 15})
\end{aligned}$"

a = 15
calc = @handcalcs begin
    "Part $a: "; b = 2; "hello $a"
end

@test calc == expected
# ***************************************************
