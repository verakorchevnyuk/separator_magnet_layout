#
# Define wavelength
#

set lambda 0.02607022423739632 ; # 0.02607022423739632 m = c / 11.49942 GHz
set gradient 0.066 ; # GV/m

Octave {
    load('$scripts/A1.mat'); % V/pC/mm/m
    load('$scripts/f1.mat'); % GHz
    Q = 5000;
    A1 = A1 * 1000; % V/pC/m**2, V/pC/mm/m = 1000 V/pC/m**2
    lambda = 0.299792458 ./ f1; % m, c / GHz = 0.299792458 m
    Tcl_SetVar("cav_modes", sprintf("%g ", [ lambda(:) A1(:) Q*ones(length(lambda),1) ]'));
}

#
# Use this list to create fields
#

WakeSet wakelong $cav_modes

#
# Define accelerating structure
#

InjectorCavityDefine -lambda $lambda -wakelong wakelong
