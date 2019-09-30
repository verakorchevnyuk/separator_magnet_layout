set e_initial 0.144 ; # 144 MeV
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
Sbend -length 0.6 -angle [expr (40.0) * $deg2rad ] -e0 $e0
Drift -length 1.1

Quadrupole -length $lquad -strength [expr 22.18023962 * $lquad * $e0]
Drift -length 0.3
Quadrupole -length $lquad -strength [expr -22.24163335 * $lquad * $e0]

Drift -length 0.3
Sbend -length $lbend -angle [expr +110.0 * $deg2rad ] -e0 $e0
Drift -length 0.3

Quadrupole -length $lquad -strength [expr 23.39833159 * $lquad * $e0]
Drift -length 0.3
Quadrupole -length $lquad -strength [expr -27.15654042 * $lquad * $e0]
Drift -length 0.3
Quadrupole -length $lquad -strength [expr 24.999998 * $lquad * $e0]
Drift -length 1.2

