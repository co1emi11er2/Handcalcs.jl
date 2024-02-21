

function calc_Ix(b, h)
    Ix = b*h^3/12
    return Ix
end

function calc_Iy(h, b=15; expo=3, denominator=12)
    Iy = h*b^expo/denominator
    return Iy
end

function calc_I()
    I = 5*15^3/12
    # return I
end

function area_sqare(side)
    area = side^2
end

function area_rectangle(l, w)
    area = l * w
end