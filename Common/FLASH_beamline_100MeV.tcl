set e_initial 0.120 ; # 120 MeV
set e0 $e_initial

set lquad 0.2
set lbend 0.8

# QFO1  : Q1, k1 := 22.18023962  ;
# QDE2  : Q1, k1 := -22.24163335  ; 
# QFO3  : Q1, k1 :=  23.39833159  ;
# QDE4  : Q1, k1 :=  -27.15654042  ;
# QFO5  : Q1, k1 :=  24.999998  ;

set deg2rad [expr acos(-1) / 180.0 ]

BeamlineNew
Girder
Drift -length 1.45
Quadrupole -length 0
Sbend -length $lbend -angle [expr -110.0 * $deg2rad ] -e0 $e0
Quadrupole -length 0
Drift -length 1.2
