function [ theta, P, V, B, G, lm ] = particle_trajectory_for_goal_angle( thetaGoal, T, rref, Bref, Bgrad, p1, v1, resol, gapMin, NI )
% Given the initial position and velocity vector of the particles, the
% following function computes the trajectory of the beam in cartesean
% coordinates (matrix P) until it the goal output angle alpha is reached.
% The magnetic length lm is yield as well. The magnet dipole and quadrupole
% components are defined by Bref and Bgrad, respectively. The resolution of
% the trajectory can be tuned with the variable resol. An error message
% will be displayed in the command window, in the case of non-conformity
% with the minimum apperture requirements. The magnet ampere-turns are an
% input to the function. 

% IN
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
    % alpha: angle between input and output v [degrees]
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
 
    % loop until goal angle is reached
    while theta < thetaGoal
        [ p, v, alpha, ~ ] = det_particle_position( T, newB, p, v, resol ) ;
        P = [ P ; p ] ;
        V = [ V ; v ] ;
        theta = theta + alpha ;
        [ newB, newGap ] = get_new_B( Bref, rref, p, Bgrad, gapMin, NI ) ;
        B = [ B ; newB ] ;
        G = [ G ; newGap ] ;
        lm = lm + resol ;
    end
    
end

