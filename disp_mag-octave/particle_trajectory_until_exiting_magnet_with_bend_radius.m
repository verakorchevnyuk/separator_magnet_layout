function [ theta, P, V, B, G, lm, R ] = particle_trajectory_until_exiting_magnet_with_bend_radius( m, b, T, rref, Bref, Bgrad, p1, v1, resol, gapMin, NI )
% Given the initial position and velocity vector of the particles, the
% following function computes the trajectory of the beam in cartesean
% coordinates (matrix P) until the limits of the magnet defined by m and b
% are reached.
% The magnetic length lm is yield as well. The magnet dipole and quadrupole
% components are defined by Bref and Bgrad, respectively. The resolution of
% the trajectory can be tuned with the variable resol. An error message
% will be displayed in the command window, in the case of non-conformity
% with the minimum apperture requirements. The magnet ampere-turns are an
% input to the function. 

% IN
    % m: slope of the magnet cut
    % b: y(x=0) of the magnet cut
    % thetaGoal: the minimum angle between the input and output v [degrees]
    % T: beam energy [eV]
    % Bref: magnet dipole component [T]
    % Bgrad: magnet quadrupole component [T/m]
    % p1 = [px,py]: particle initial position
    % v1 = [vx,vy]: particle initial velocity vector
    % resol: resolution, i.e. finess of the B field update [m]
    % gapMin: constaint for the aperture size [m]
    % NI: magnet ampere-turns
%
% OUT
    % theta: angle between input and output v [degrees]
    % P = [ p1x p1y ; p2x p2y ; ... ]: matrix with positions 
    % V = [ v1x v1y ; v2x v2y ; ... ]: matrix with velocity vectors
    % B = [ B1 ; B2 ; ... ]: columm vector with B field [T]
    % G = [ gap1 ; gap2; ... ]: column vector with apertures sizes along
    % the trajectory of the particles [m]
    % lm: magnetic length, i.e. distance travelled by the particles [m]
  
    % intialization
    theta = 0 ;
    P = [ p1 ] ;
    V = [ v1 ] ;
    B = [ Bref ] ;
        % magnet aperture
        u0 = 4*pi*10^(-7) ;
        gap1 = u0*NI/Bref ;
    G = [ gap1 ] ;
    lm = 0 ;
    newB = Bref ;
    p = p1 ;
    v = v1 ;
    R = [] ;
    
    % loop until goal angle is reached
    
    %while and( fy( m, b, p(1) ) < p(2), fx( m, b, p(2) ) > p(1) )
    while ( fy( m, b, p(1) ) < p(2) )
        if (B ~= 0)
            [ p, v, alpha, rM ] = det_particle_position( T, newB, p, v, resol ) ;
            P = [ P ; p ] ;
            V = [ V ; v ] ;
        else
            disp('/!\ B=0, beam travelling straigth /!\') ;
            V = [ V ; v ] ;
            p = p + resol*v 
            P = [ P ; p ] ;
            alpha = 0 ;
        end
        theta = theta + alpha ;
        if (theta >= 180)
            disp('/!\ Beam exit angle >= 180 /!\') ;
            return
        end
        [ newB, newGap ] = get_new_B( Bref, rref, p, Bgrad, gapMin, NI ) ;
        B = [ B ; newB ] ;
        G = [ G ; newGap ] ;
        lm = lm + resol ;
        R = [ R, rM ] ;
    end

    
end