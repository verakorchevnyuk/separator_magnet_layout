## constants
set clight 299792458.0
set Z0 376.730313461771

## wake length and number of points
set wake_params(length) 15e3 ; # [um]
set wake_params(Npoints) 512    ; #  

## SPARC X-band structure parameters
set structure(a) 0.00320   ; # [m]
set structure(g) 0.006495  ; # [m]
set structure(l) 0.00832   ; # [m]
set structure(freq) 11.9942 ; # [GHz]

Octave {
    function p = pow(x,a)
        p = x**a;
    endfunction

    function Wt = W_transv(s) % V/pC/m/m
        a = $structure(a);
        g = $structure(g);
        l = $structure(l);
        s0 = 0.169 * pow(a,1.79) * pow(g,0.38) / pow(l,1.17);
        sqrt_s_s0 = sqrt(s/s0);
        Wt = 4 * $Z0 * s0 * $clight / pi / (a**4) * (1 - (1 + sqrt_s_s0) .* exp(-sqrt_s_s0)) / 1e12;
    endfunction

    function Wl = W_long(s) % V/pC/m
        a = $structure(a);
        g = $structure(g);
        l = $structure(l);
        s0 = 0.41 * pow(a,1.8) * pow(g,1.6) / pow(l,2.4);
        Wl = $Z0 * $clight / pi / (a**2) * exp(-sqrt(s/s0)) / 1e12;
    endfunction

    Z = linspace(0, $wake_params(length) * 1e-6, $wake_params(Npoints));
    Wt = W_transv(Z);
    Wl = W_long(Z);

    filet = fopen('sparc_cav_Wt.dat', 'w');
    filel = fopen('sparc_cav_Wl.dat', 'w');
    
    fprintf(filet, ' %.15g %.15g\n', [ Z ; Wt ] );
    fprintf(filel, ' %.15g %.15g\n', [ Z ; Wl ] );

    fclose(filet);
    fclose(filel);
}

SplineCreate "SPARC_cav_Wt" -file "sparc_cav_Wt.dat"
SplineCreate "SPARC_cav_Wl" -file "sparc_cav_Wl.dat"

ShortRangeWake "SPARC_cav_SR" -type 2 \
    -wx "SPARC_cav_Wt" \
    -wy "SPARC_cav_Wt" \
    -wz "SPARC_cav_Wl"

proc w_transv {s} {
    return 0.0
}

proc w_long {s} {
    return 0.0
}

source $scripts/wake_calc.tcl
