set e_initial 0.144 ; # 60 MeV
set e0 $e_initial

set lquad 0.2
set lbend 0.8

# QFO1  : Q1, k1 := 22.18023962  ;
# QDE2  : Q1, k1 := -22.24163335  ; 
# QFO3  : Q1, k1 :=  23.39833159  ;
# QDE4  : Q1, k1 :=  -27.15654042  ;
# QFO5  : Q1, k1 :=  24.999998  ;

BeamlineNew
Girder
Drift -length 5
