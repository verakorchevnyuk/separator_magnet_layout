proc make_beam_particles {e0 e_spread n} {
    global match
    set sum_e 0.0
    set f [open particles.tmp w]

    Random g -type gaussian
    Random g2 -type linear

    set ex [expr $match(emitt_x)*1e-7*0.511e-3/$e0]
    set ey [expr $match(emitt_y)*1e-7*0.511e-3/$e0]
    set bx $match(beta_x)
    set by $match(beta_y)
    set alphax $match(alpha_x)
    set alphay $match(alpha_y)
    set sx [expr sqrt($ex*$bx)*1e6]
    set spx [expr sqrt($ex/$bx)*1e6]
    set sy [expr sqrt($ey*$by)*1e6]
    set spy [expr sqrt($ey/$by)*1e6]
    set st $match(sigma_z)
    set se [expr 0.01*abs($e_spread)]

    if ($e_spread<0.0) {
	for {set i 0} {$i<$n} {incr i} {
	    set e [expr (1.0+$se*([g2]-0.5))*$e0]
	    set z [g]
	    while {abs($z)>=3.0} {
		set z [g]
	    }
	    set x [expr [g]*$sx]
	    set xp [expr [g]*$spx-$alphax*$x/$sx*$spx]
	    set y [expr [g]*$sy]
	    set yp [expr [g]*$spy-$alphay*$y/$sy*$spy]
	    puts $f "$e $x $y [expr $z*$st] $xp $yp"
	}
    } {
	for {set i 0} {$i<$n} {incr i} {
	    set e [g]
	    while {abs($e)>=3.0} {
		set e [g]
	    }
	    set e [expr (1.0+$e*$se)*$e0]
	    set z [g]
	    while {abs($z)>=3.0} {
		set z [g]
	    }
	    set x [expr [g]*$sx]
	    set xp [expr [g]*$spx-$alphax*$x/$sx*$spx]
	    set y [expr [g]*$sy]
	    set yp [expr [g]*$spy-$alphay*$y/$sy*$spy]
#	    set y [expr $y+$sy]
	    puts $f "$e $x $y [expr $z*$st] $xp $yp"
	}
    }
    close $f
    exec sort -b -g -k 4,4 particles.tmp > particles.in
}

proc make_beam_many {name nslice n} {
    global charge e_initial match
    set ch {1.0}
#    calc_old beam.dat [GaussList -charge $charge -min -3 -max 3 -sigma $match(sigma_z) -n_slices $nslice]
    calc beam.dat $charge -3 3 $match(sigma_z) $nslice
    InjectorBeam $name -bunches 1 \
	    -macroparticles [expr $n] \
	    -energyspread 0.0 \
	    -ecut 3.0 \
	    -e0 $e_initial \
	    -file beam.dat \
	    -chargelist $ch \
	    -charge $charge \
	    -phase 0.0 \
	    -overlapp 0 \
	    -distance 1.49896229 \
	    -alpha_y $match(alpha_y) \
	    -beta_y $match(beta_y) \
	    -emitt_y $match(emitt_y) \
	    -alpha_x $match(alpha_x) \
	    -beta_x $match(beta_x) \
	    -emitt_x $match(emitt_x)

    set l {}
    lappend l {1.0 0.0 0.0}
    SetRfGradientSingle $name 0 $l    
    make_beam_particles $e_initial $match(e_spread) [expr $nslice*$n]
    BeamRead -file particles.in -beam $name
}

proc make_beam_train {name nbunch nslice n} {
    global charge e_initial match lambda
    set ch {1.0}
    calc beam.dat $charge -3.0 3.0 $match(sigma_z) $nslice
    InjectorBeam $name -bunches $nbunch -particle 500000 \
	    -macroparticles [expr $n] \
	    -energyspread [expr 0.01*$match(e_spread)*$e_initial] \
	    -ecut 3.0 \
	    -e0 $e_initial \
	    -file beam.dat \
	    -chargelist $ch \
	    -charge $charge \
	    -phase 0.0 \
	    -last_wgt [expr 2821.0-$nbunch] \
	    -overlapp [expr -390*$lambda] \
	    -distance [expr $lambda] \
	    -alpha_y $match(alpha_y) \
	    -beta_y $match(beta_y) \
	    -emitt_y $match(emitt_y) \
	    -alpha_x $match(alpha_x) \
	    -beta_x $match(beta_x) \
	    -emitt_x $match(emitt_x)

    set l {}
    lappend l {1.0 0.0 0.0}
    SetRfGradientSingle $name 0 $l    
}
