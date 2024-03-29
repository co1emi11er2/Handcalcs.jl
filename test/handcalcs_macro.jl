# using Handcalcs
# using LaTeXStrings, Unitful, UnitfulLatexify
# using Test

# Single Expression - General
expected =  L"$\begin{align}
x &= \frac{ - b + \sqrt{b^{2} - 4 \cdot a \cdot c}}{2 \cdot a} = \frac{ + 5 + \sqrt{\left( -5 \right)^{2} - 4 \cdot 2 \cdot 2}}{2 \cdot 2} = 2.0
\end{align}$"
a = 2
b = -5
c = 2
calc = @handcalcs x = (-b + sqrt(b^2 - 4*a*c))/(2*a)
calc2 = @handcalcs begin x = (-b + sqrt(b^2 - 4*a*c))/(2*a) end
@test calc == expected
@test calc2 == expected    

# Multiple Expressions - General
expected = (L"$\begin{align}
Iy &= \frac{h \cdot b^{3}}{12} = \frac{10 \cdot 5^{3}}{12} = 104.16666666666667\text{  }(\text{moment of inertia y})
\\[10pt]
Ix &= \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 10^{3}}{12} = 416.6666666666667\text{  }(\text{moment of inertia x})
\end{align}$")
b = 5
h = 10
comment1 = "moment of inertia"
calc = @handcalcs begin
    Iy = h*b^3/12; "moment of inertia y";
    Ix = b*h^3/12; "moment of inertia x";
end
@test calc == expected

# Formatting check
#TODO: Fix default to 4 decimals
expected = (L"$\begin{align}\\Iy = \frac{h \cdot b^{3}}{12} = \frac{10 \cdot 5^{3}}{12} = 104.1667\text{  }(\text{moment of inertia y})\\Ix = \frac{b \cdot h^{3}}{12} = \frac{5 \cdot 10^{3}}{12} = 416.6667\text{  }(\text{moment of inertia x})\end{align}$")
@test_broken calc == expected

# Array type - General and broadcasting
expected = (L"$\begin{align}
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
\end{align}$")

expected2 = (L"$\begin{align}
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
\end{align}$")
x = [1; 2; 3]
y = [4; 5; 6]
calc = @handcalcs z = x + y

calc2 = @handcalcs z = x .* y
@test calc == replace(expected, "\r" => "") # for whatever reason the expected had addittional carriage returns (\r) 
@test calc2 == replace(expected2, "\r" => "")