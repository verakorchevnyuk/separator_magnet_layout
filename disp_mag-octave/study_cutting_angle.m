clear; close all; clc

% Exit angle for different cuts

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

% Cutting angles
all_beta = linspace( -44, 44, 1000 );
% all_beta = linspace( -89, 89, 100 );
exit_point = P0(end,:) ;
j = 1 ;

for i = 1:length(all_beta)
    % Get line coeffs
    [ m, b ] = cartesian_coefficients_line( exit_point, all_beta(i) ) ;

    if b<0
        % Cutting line
        xx_cut(:,j) = linspace(0,P0(end,1)*1.25,100) ;
        fy = @(m,b,x) m*x + b ;
        yy_cut(:,j) = fy(m,b,xx_cut(:,j)) ;
        
        % betas
        betas(j) = all_beta(i) ;
        
        % Low energy trajectory
        [ theta1, P1, V1, B1, G1, lm1 ] = particle_trajectory_until_exiting_magnet( m, b, T1, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
        
        % High energy trajectory
        [ theta2, P2, V2, B2, G2, lm2 ] = particle_trajectory_until_exiting_magnet( m, b, T2, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
        
        alpha1(j) = theta1 - theta0 ;
        alpha2(j) = theta0 - theta2 ;
        alpha(j) = alpha1(j) + alpha2(j) ;
        j = j + 1 ;
    end
    
end

%% Selection of parameters for bigger dispersion
% Best data
sel = 'max'; % a number ]-45,45[ degrees, or 'max'
switch sel
    case 'max'
        [~, M] = max(alpha) ;
    otherwise
        [~,sel] = min(abs(betas-sel)) ;
        M = sel ;   
end
[ m, b ] = cartesian_coefficients_line( exit_point, betas(M) ) ;
% Low energy trajectory
[ theta1, P1, V1, B1, G1, lm1 ] = particle_trajectory_until_exiting_magnet( m, b, T1, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
% High energy trajectory
[ theta2, P2, V2, B2, G2, lm2 ] = particle_trajectory_until_exiting_magnet( m, b, T2, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

%% Plotting
figure
plot(xx_cut(:,M),yy_cut(:,M),'.'); % Cutting line
grid on; 
daspect([1 1 1])
hold on; 

plot(P0(:,1),P0(:,2)); % Reference beam

plot(P1(:,1),P1(:,2)); % Low energy beam

plot(P2(:,1),P2(:,2)); % High energy beam

title(['Beta = ', num2str(betas(M)), ' degrees']);

%%
% Evolution of angle dispersion
figure
plot(betas,alpha1,'*')
grid on
hold on
plot(betas,alpha2,'*')
plot(betas,alpha,'*')
legend('alpha1','alpha2','total alpha')