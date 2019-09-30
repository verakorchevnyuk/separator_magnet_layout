set scripts [pwd]/Common

# CREATE OUTPUT DIRECTORY AND ENTER IT
set outdir Results
exec mkdir -p $outdir
cd $outdir

set EL 100
set EO 120
set ER 140

Octave {
    addpath([ pwd '/../disp_mag-octave' ]);
    global B${EL} B${ER} D${EL} D${EO} D${ER} P0 P1 P2
}

# CREATE BEAMLINES
foreach energy "${EL} ${EO} ${ER}" {
    source $scripts/FLASH_beamline_${energy}MeV.tcl
    BeamlineSet -name ${energy}
    Octave {
	B${energy} = placet_get_number_list("${energy}", "sbend");;
	D${energy} = placet_get_number_list("${energy}", "drift");
    }
}

Octave {
    addpath('$scripts');
    
    # GET INITIAL DRIFT LENGTHS
    DL${EL} = placet_element_get_attribute("${EL}", D${EL}, "length");
    DL${EO} = placet_element_get_attribute("${EO}", D${EO}, "length");
    DL${ER} = placet_element_get_attribute("${ER}", D${ER}, "length");

    # DEGREES OF FREEDOM:
    # B${EL}
    # B${ER}
    D${EL} = D${EL}(DL${EL} > 0.4)(1:end-1); # all but the last drift of beamline, longer than 0.4 m
    D${EO} = D${EO}(DL${EO} > 0.4)(1:end-1);
    D${ER} = D${ER}(DL${ER} > 0.4)(1:end-1);
}

Octave {
	
    # MERIT FUNCTION
    function M = merit_function(X)
    H = 7; # m, target height
    ALd = 60; # target angle for L beamline
    ARd = 30; # target angle for R beamline
    global B${EL} B${ER} D${EL} D${EO} D${ER} P0 P1 P2
    DL${EL} = constrain(X(1:2), 0.3, 2); % m
    DL${EO} = constrain(X(3:4), 0.3, 2); % m
    DL${ER} = constrain(X(5:6), 0.3, 2); % m
    BAL = constrain(X(7), 0, 0) % deg
    BAR = constrain(X(8), 0, 0) % deg
    beta1 = constrain(X(9), 35, 45) % deg
    beta2 = constrain(X(10), 0, 90) % deg
    Bref = 1; #constrain(X(10), 1, 1) % T
    Bgrad = constrain(X(11), 0, 1.5) # % T/m 43028

    [lm, R, Bgrad, Gamma, P0, P1, P2 ] = beam_dynamics_variables( beta1, beta2, Bref, Bgrad, $EO * 1e6, $EL * 1e6, $ER * 1e6, 'n');
    %[lm, R, Bgrad, Gamma, P0, P1, P2 ] = beam_dynamics_variables( beta1, beta2, Bref, Bgrad, 120 * 1e6, 105 * 1e6, 135 * 1e6, 'n');


	magnetic_lengths = lm'
    
    VO = diff(P0,1,1)(end,:);
    VL = diff(P1,1,1)(end,:);
    VR = diff(P2,1,1)(end,:);
    
    # SET THE MAIN BENDING ANGLES AND LENGTHS

    AO = atan2d(VO(2), VO(1));
    AL = atan2d(VL(2), VL(1));
    AR = atan2d(VR(2), VR(1));

    BAL(2) = (-AO - ALd) + (AL - BAL(1));
    BAR(2) = (-AO + ARd) + (AR - BAR(1));


    placet_element_set_attribute("${EL}", D${EL}, "length", DL${EL});
    placet_element_set_attribute("${EO}", D${EO}, "length", DL${EO});
    placet_element_set_attribute("${ER}", D${ER}, "length", DL${ER});
    placet_element_set_attribute("${EL}", B${EL}, "angle", deg2rad(BAL));
    placet_element_set_attribute("${ER}", B${ER}, "angle", deg2rad(BAR));

    # 
    Tcl_Eval(sprintf("BeamlineSaveFootprint -beamline ${EL} -x0 %g -y0 %d -zangle %g -file footprint_${EL}MeV.dat", P1(end,1), P1(end,2), deg2rad(AL)));
    Tcl_Eval(sprintf("BeamlineSaveFootprint -beamline ${EO} -x0 %g -y0 %d -zangle %g -file footprint_${EO}MeV.dat", P0(end,1), P0(end,2), deg2rad(AO)));
    Tcl_Eval(sprintf("BeamlineSaveFootprint -beamline ${ER} -x0 %g -y0 %d -zangle %g -file footprint_${ER}MeV.dat", P2(end,1), P2(end,2), deg2rad(AR)));
    
    FL = dlmread('footprint_${EL}MeV.dat')(12:end,1:2);
    FO = dlmread('footprint_${EO}MeV.dat')(12:end,1:2);
    FR = dlmread('footprint_${ER}MeV.dat')(12:end,1:2);

    clf
    hold on
    plot(P0(:,1),P0(:,2),'k-'); % Reference beam
    plot(P1(:,1),P1(:,2),'b-'); % Low energy beam
    plot(P2(:,1),P2(:,2),'r-'); % High energy beam
    plot(FL(:,1), FL(:,2), 'b*-',
	FO(:,1), FO(:,2), 'k*-',
	FR(:,1), FR(:,2), 'r*-');
    xlabel('m');
    ylabel('m');
    daspect ([1 1]);
    axis([ FO(end,1)-H/2 FO(end,1)+H/2 -(H+1) 0 ]);
    drawnow
    
    M = hypot(FL(end,1) - FO(end,1), FL(end,2) - FO(end,2)) + ...
        hypot(FR(end,1) - FO(end,1), FR(end,2) - FO(end,2));% + ...
        %0.1 * abs(FO(end,2));
    end

    X = fminsearch(@merit_function, zeros(1,11))

    print -dpng plot_layout.png
}

foreach energy "${EL} ${EO} ${ER}" {
    BeamlineUse -name "${energy}"
    BeamlineList -file FLASH_beamline_${energy}MeV_flat.tcl
}
