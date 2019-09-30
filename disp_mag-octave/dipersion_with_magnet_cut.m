function [alpha1, alpha2, total_alpha] = dipersion_with_magnet_cut( beta, plot_info )
% The function receives an angle beta that corresponds to the angle between
% the horizontal and the line corresponding to the cut of the magnet.
% Plotting can be (un)done by (un)commenting the last section of the 
% function.
%
% IN:
    % beta: angle of the magnet cut [degrees]
    % plot_info: 'yes' or 'no' in case you or not the plot to be displayed
%
% OUT:
    % alpha1: difference between the reference and the light exiting beam
                                                         % angles [degrees] 
    % alpha2: difference between the reference and the heavy exiting beam
                                                         % angles [degrees] 
    % total_alpha: sum of alpha1 and alpha2, i.e. difference between the
                       % light and the heavy exiting beams angles [degrees]


% Reference beam
T0 = 120e6 ; %[eV]
goalTheta0 = 90 ; %[degrees]
Bref = 1 ; %[T/m]
Bgrad = 0.3 ; %[T/m]
p = [ 0, 0 ] ;
v = [ 1, 0 ] ;
resol = 1e-3 ; %[m]
gapMin = 30e-3 ; %[m]
NI = 200*500 ; % Amp-turns
[ ~, ~, ~, rref ] = det_particle_position( T0, Bref, p, v, resol ) ;
[ theta0, P0, V0, B0, G0, lm0 ] = particle_trajectory_for_goal_angle( goalTheta0, T0, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

% Low energy beam
T1 = 100e6; %[eV]

% High energy beam
T2 = 140e6; %[eV]

% Line coefficients
exit_point = P0(end,:) ;
% M = beta ;
[ m, b ] = cartesian_coefficients_line( exit_point, beta ) ;
% Low energy trajectory
[ theta1, P1, V1, B1, G1, lm1 ] = particle_trajectory_until_exiting_magnet( m, b, T1, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
% High energy trajectory
[ theta2, P2, V2, B2, G2, lm2 ] = particle_trajectory_until_exiting_magnet( m, b, T2, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;


%% Plotting
switch plot_info
    case 'yes'
        xx_cut(:) = linspace(0,P0(end,1)*1.5,100) ;
        fy = @(m,b,x) m*x + b ;
        yy_cut(:) = fy(m,b,xx_cut(:)) ;
        
        figure
        plot(xx_cut(:),yy_cut(:),'.'); % Cutting line
        grid on;
        daspect([1 1 1])
        hold on;
        
        plot(P0(:,1),P0(:,2)); % Reference beam
        
        plot(P1(:,1),P1(:,2)); % Low energy beam
        
        plot(P2(:,1),P2(:,2)); % High energy beam
        
        title(['Beta = ', num2str(beta), ' degrees']);
    otherwise
        return
end

% alphas
alpha1 = theta1 - theta0 ;
alpha2 = theta0 - theta2 ;
total_alpha = alpha1 + alpha2 ;

%%

% Evolution of angle dispersion
% figure
% plot(betas,alpha1,'*')
% grid on
% hold on
% plot(betas,alpha2,'*')
% plot(betas,alpha,'*')
% legend('alpha1','alpha2','total alpha')



end

