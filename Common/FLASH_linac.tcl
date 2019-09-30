proc put_linac { CAV_gradient } {

    set e0 0.005

    set RF_units 1

    # set CAV_gradient 0.035 ; # GV/m
    set CAV_freq 11.4992   ; # GHz
    set CAV_len 0.5        ; # m
    set Q_len  0.4         ; # m

    set FODO_mu [expr 90.0 * acos(-1.0) / 180.0 ]
    set FODO_len [expr $Q_len * 2.0 + $CAV_len * 2.0]

    set Qf_k1l [expr -4.0 * sin($FODO_mu / 2.0) / $FODO_len]
    set Qd_k1l [expr +4.0 * sin($FODO_mu / 2.0) / $FODO_len]

    array set FODO_twiss [MatchFodo -l1 $Q_len -l2 $Q_len -K1 $Qf_k1l -K2 $Qd_k1l -L [expr $FODO_len / 2.0 ] ]

    foreach {key value} [array get FODO_twiss] {
	if [string match "beta*" $key ] {
	    puts "LINAC::$key = $value m"
	}
    }

    proc my_Cavity { CAV_len CAV_gradient CAV_freq } {
	set CAV_nsteps 100
	if { $CAV_nsteps == 1 } {
	    Cavity\
		-length $CAV_len \
		-gradient $CAV_gradient \
		-frequency $CAV_freq
	} else {	
	    for { set j 0 } {$j < $CAV_nsteps} {incr j } {
		Cavity\
		    -length [expr double($CAV_len) / $CAV_nsteps ] \
		    -gradient [expr 2 * double($CAV_gradient) * ($CAV_nsteps - 1 - $j) / ($CAV_nsteps - 1) ] \
		    -frequency $CAV_freq
	    }
	}
    }

    Girder
    SetReferenceEnergy $e0
    Bpm
    Dipole
    Quadrupole -len [expr $Q_len / 2.0] -strength [expr $Qf_k1l * $e0 / 2.0]
    Bpm
    for {set i 0} {$i < $RF_units} {incr i} {
	for {set ii 0} {$ii < 2} {incr ii} {
	    my_Cavity $CAV_len $CAV_gradient $CAV_freq
	    set e0 [expr $e0 + $CAV_gradient * $CAV_len ]
	    SetReferenceEnergy $e0

	    Dipole
	    Quadrupole -len [expr $Q_len] -strength [expr $Qd_k1l * $e0]
	    Bpm
	    
	    my_Cavity $CAV_len $CAV_gradient $CAV_freq
	    set e0 [expr $e0 + $CAV_gradient * $CAV_len ]
	    SetReferenceEnergy $e0

	    Dipole
	    Quadrupole -len [expr $Q_len] -strength [expr $Qf_k1l * $e0]
	    Bpm
	    
	    my_Cavity $CAV_len $CAV_gradient $CAV_freq
	    set e0 [expr $e0 + $CAV_gradient * $CAV_len ]
	    SetReferenceEnergy $e0

	    Dipole
	    Quadrupole -len [expr $Q_len] -strength [expr $Qd_k1l * $e0]
	    Bpm
	    
	    my_Cavity $CAV_len $CAV_gradient $CAV_freq
	    set e0 [expr $e0 + $CAV_gradient * $CAV_len ]
	    SetReferenceEnergy $e0

	    Dipole
	    Quadrupole -len [expr $Q_len] -strength [expr $Qf_k1l * $e0]
	    Bpm
	}
    }

    puts "LINAC FINAL ENERGY = $e0"
    
    return [array get FODO_twiss]
}
