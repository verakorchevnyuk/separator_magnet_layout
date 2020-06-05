set scripts [pwd]/Common

# CREATE OUTPUT DIRECTORY AND ENTER IT
set outdir Results
exec mkdir -p $outdir
cd $outdir

# CREATE BEAMLINES
foreach energy "100 120 140" {
    source $scripts/FLASH_beamline_${energy}MeV.tcl
    BeamlineSet -name ${energy}
    Octave {
	global B${energy} D${energy}
	B${energy} = placet_get_number_list("${energy}", "sbend");
	D${energy} = placet_get_number_list("${energy}", "drift");
    }
}

Octave {
    addpath('$scripts');
	
    # MERIT FUNCTION
    function M = merit_function(X)
    H = 6; # m, target height
    ALd = 60; # target angle for L beamline
    ARd = 30; # target angle for R beamline
    global B100 B120 B140 D100 D120 D140
    DL100 = constrain(X(1:2), 1.2, 10); % m
    DL120 = constrain(X(3),   1.2, 10); % m
    DL140 = constrain(X(4:5), 1.2, 10); % m

    lm = [ 0.99998694425935408  ; 0.99999093345924772 ; 0.99999333884400476 ] ;

    AO = -90.058697687489115 ;
    AL = -115.86546804164304 ;
    AR = -71.528778310901089 ;
    
    P0 = [ 524.66980412173018, -677.60953638218894 ]/1000 ; 
    P1 = [ 320.59393079582719, -699.89468503429543 ]/1000 ;
    P2 = [ 666.38034744499737, -617.39155831973233 ]/1000 ;

    BAL = (-AO - ALd) + (AL);
    BAR = (-AO + ARd) + (AR);
    
    placet_element_set_attribute("100", D100, "length", DL100);
    placet_element_set_attribute("120", D120, "length", DL120);
    placet_element_set_attribute("140", D140, "length", DL140);

    placet_element_set_attribute("100", B100, "angle", deg2rad(BAL));
    placet_element_set_attribute("140", B140, "angle", deg2rad(BAR));

    # 
    Tcl_Eval(sprintf("BeamlineSaveFootprint -beamline 100 -x0 %g -y0 %d -zangle %g -file footprint_100MeV.dat", P1(end,1), P1(end,2), deg2rad(AL)));
    Tcl_Eval(sprintf("BeamlineSaveFootprint -beamline 120 -x0 %g -y0 %d -zangle %g -file footprint_120MeV.dat", P0(end,1), P0(end,2), deg2rad(AO)));
    Tcl_Eval(sprintf("BeamlineSaveFootprint -beamline 140 -x0 %g -y0 %d -zangle %g -file footprint_140MeV.dat", P2(end,1), P2(end,2), deg2rad(AR)));
    
    FL = dlmread('footprint_100MeV.dat')(12:end,1:2);
    FO = dlmread('footprint_120MeV.dat')(12:end,1:2)
    FR = dlmread('footprint_140MeV.dat')(12:end,1:2);

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
    axis([ FO(end,1)-H/2 FO(end,1)+H/2 -(H+1)-2 0 ]);
    drawnow
    
    M = hypot(FL(end,1) - FO(end,1), FL(end,2) - FO(end,2)) + ...
        hypot(FR(end,1) - FO(end,1), FR(end,2) - FO(end,2)) + ...
        abs(abs(FO(end,2)) - H)
    end

    X = fminsearch(@merit_function, zeros(5,1));

    print -dpng plot_layout.png
}

foreach energy "100 120 140" {
    BeamlineUse -name "${energy}"
    BeamlineList -file FLASH_beamline_${energy}MeV_flat.tcl
}
