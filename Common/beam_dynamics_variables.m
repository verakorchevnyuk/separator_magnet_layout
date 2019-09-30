function [ lm, R, Bgrad, Gamma, P0, P1, P2 ] = beam_dynamics_variables( beta1, beta2, Bref, Bgrad, T0, T1, T2, plot_info )
% IN:
%   beta: angle of the magnet cut [degrees]
%   Bref: magnetic field of the reference beam [T]
%   Bgrad: gradient of the magnet [T/m]
%   T0: energy of the reference beam [eV]
%   T1: energy of the lightest beam [eV]
%   T2: energy of the heaviest beam [eV]
%   plot_info: 'y' or 'n' in case you want or not the plot to be displayed
%
% OUT:
%   lm = [ lm0; lm1; lm2 ]: column vector of magnetic lengths of the
%                               reference, lightest and heaviest beams [m]
%   R = { r0_1 r0_2 r0_3 ... ;
%       r1_1 r1_2 r1_3 ... ;
%       r2_1 r2_r2 r2_3 ... }: matrix(cells) describing the evolution of 
%                                 the bending radius with a step of 1e-3 m.
%                                 Each row corresponds to a beam. [m]
%                                       r0: reference beam;
%                                       r1: lightest beam;
%                                       r2: heaviest beam.
%   Bgrad: the magnet gradient [T/m]
%   Gamma = [ gamma0; gamma1; gamma2 ]: column vector of the angles between
%                                       the normal of the exiting beam and
%                                       the magnet cut


% Reference beam
goalTheta0 = 90 ; %[degrees]
p = [ 0, 0 ] ;
v = [ 1, 0 ] ;
resol = 1e-3 ; %[m]
gapMin = 30e-3 ; %[m]
NI = 200*500 ; % Amp-turns
[ ~, ~, ~, rref ] = det_particle_position( T0, Bref, p, v, resol ) ;
[ theta0, P0, ~, ~, ~, lm0 ] = particle_trajectory_for_goal_angle( goalTheta0, T0, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
R0 = rref*ones(1,round(lm0/resol)) ;

% Line coefficients
exit_point = P0(size(P0,1),:) ;
% M = beta ;
[ m1, b1 ] = cartesian_coefficients_line( exit_point, beta1 ) ;
[ m2, b2 ] = cartesian_coefficients_line( exit_point, beta2 ) ;
% Low energy trajectory
% [ theta1, P1, V1, B1, G1, lm1 ] = particle_trajectory_until_exiting_magnet( m, b, T1, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
[ theta1, P1, ~, ~, ~, lm1, R1 ] = particle_trajectory_until_exiting_magnet_with_bend_radius( m1, b1, T1, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

% High energy trajectory
% [ theta2, P2, V2, B2, G2, lm2 ] = particle_trajectory_until_exiting_magnet( m, b, T2, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
[ theta2, P2, ~, ~, ~, lm2, R2 ] = particle_trajectory_until_exiting_magnet_with_bend_radius( m2, b2, T2, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

beta = beta1 ;

% angles
alpha1 = theta1 - theta0 ;
alpha2 = theta0 - theta2 ;
gamma0 = beta ;
gamma1 = alpha1 + beta1 ;
gamma2 = beta2 - alpha2 ;
total_alpha = alpha1 + alpha2 ;

% outputs
lm = [ lm0; lm1; lm2 ] ;
R = { R0; R1; R2 } ;
Gamma = [ gamma0; gamma1; gamma2 ] ;

%% Plotting
if (char(plot_info) == 'y')
        xx_cut1 = linspace(0,P0(size(P0,1),1)*1.5,100) ;
        yy_cut1 = fy(m1,b1,xx_cut1) ;
        
        xx_cut2 = linspace(0,P0(size(P0,1),1)*1.5,100) ;
        yy_cut2 = fy(m2,b2,xx_cut2) ;
        
        figure
        plot(xx_cut1',yy_cut1','.'); % Cutting line
        grid on;
        daspect([1 1 1])
        hold on;
        plot(xx_cut2',yy_cut2','.'); % Cutting line
        
        plot(P0(:,1),P0(:,2)); % Reference beam
        
        plot(P1(:,1),P1(:,2)); % Low energy beam
        
        plot(P2(:,1),P2(:,2)); % High energy beam
        
        title({['\beta = ', num2str(beta,'%.1f'), ' degrees | dB/dr = ', num2str(Bgrad), ' T/m'],... 
            ['\theta_1 = ' num2str(alpha1,'%.1f') ' degrees; ' '\theta_2 = ' num2str(alpha2,'%.1f') ' degrees; ' '\alpha = ' num2str(total_alpha,'%.1f') ' degrees' ]}, "fontsize", 15);
end

end

