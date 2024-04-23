@setup_workload begin
    # Putting some things in `@setup_workload` instead of `@compile_workload` can reduce the size of the
    # precompile file and potentially make loading faster.
    b = 5.0
    h = 15.0
    a = 1
    xx = [1; 2; 3]
    yy = [4; 5; 6]

    @compile_workload begin

        # Generic calc
        @handcalcs begin
            Iy = h*b^3/12; "moment of inertia y";
            Ix = b*h^3/12; "moment of inertia x";
        end

        # parameters calcs
        @handcalcs begin
            a
            bb = 2
            cc = 3
            x = 4
            y = 5
            z = 6
        end cols=3 spa=5 h_env = "align"


        calc = @handcalcs z = xx + yy

        @handcalcs x = (-5.0 + sqrt(5.0^2 - 4*2*2))/(2*2)
        
        # @handcalcs begin
        #     I_x = calc_Ix(5,15)
        # end

        # @handcalcs begin
        #     I_s = calc_Is(5,15)
        # end

        # @handcalcs begin
        #     I_s = calc_Is(5,15)
        # end not_funcs = [calc_Ix calc_Iy]

    end
end