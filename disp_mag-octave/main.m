%% 
clear; clc; close all

%%
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
T1 = 100e6 ; %[eV]
goalTheta1 = 120 ; %[degrees]
[ theta1, P1, V1, B1, G1, lm1 ] = particle_trajectory_for_goal_angle( goalTheta1, T1, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

% High energy beam
T2 = 140e6 ; %[eV]
goalTheta2 = 60 ; %[degrees]
[ theta2, P2, V2, B2, G2, lm2 ] = particle_trajectory_for_goal_angle( goalTheta2, T2, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

%% Plot the beams; trajectories
% close all
figure
grid on; hold on;
plot(P0(:,1), P0(:,2),'*')
plot(P1(:,1), P1(:,2),'*')
plot(P2(:,1), P2(:,2),'*')
title(['Beam trajectory. Angles: ', num2str(theta1,3), ', ',  num2str(theta0,3), ', ', num2str(theta2,3) ]) ;
xlabel('[m]')
ylabel('[m]')
daspect([1 1 1])

%% Plot evolution of gap
figure
grid on; hold on;
tmp = 1:size(G0,1) ;
tmp = resol.*tmp ;
plot(tmp,G0)
clear tmp
tmp = 1:size(G1,1) ;
tmp = resol.*tmp ;
plot(tmp,G1)
clear tmp
tmp = 1:size(G2,1) ;
tmp = resol.*tmp ;
plot(tmp,G2)
title('Gap size evolution, per step')
xlabel('lm [m]')
ylabel('[m]')

%% Plot evolution of B
figure
grid on; hold on;
tmp = 1:size(B0,1) ;
tmp = resol.*tmp ;
plot(tmp,B0)
clear tmp
tmp = 1:size(B1,1) ;
tmp = resol.*tmp ;
plot(tmp,B1)
clear tmp
tmp = 1:size(B2,1) ;
tmp = resol.*tmp ;
plot(tmp,B2)
title('Evolution of B, per step')
xlabel('lm [m]')
ylabel('[m]')

%% With magnet cut
% linear regression
E = [ P1(end,:) ; P0(end,:) ; P2(end,:) ] ; 
[ m, b, err ] = linear_regression( E, 2 ) ;

%%
% Reference beam
[ theta0_cut, P0_cut, V0_cut, B0_cut, G0_cut, lm0_cut ] = particle_trajectory_until_exiting_magnet( m, b, T0, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

% Low energy beam
[ theta1_cut, P1_cut, V1_cut, B1_cut, G1_cut, lm1_cut ] = particle_trajectory_until_exiting_magnet( m, b, T1, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

% High energy beam
[ theta2_cut, P2_cut, V2_cut, B2_cut, G2_cut, lm2_cut ] = particle_trajectory_until_exiting_magnet( m, b, T2, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

%% Plot the beams; trajectories
% close all
figure
grid on; hold on;
plot(P0_cut(:,1), P0_cut(:,2),'*')
plot(P1_cut(:,1), P1_cut(:,2),'*')
plot(P2_cut(:,1), P2_cut(:,2),'*')
title(['Beam trajectory (with magnet cut). Angles: ', num2str(theta1_cut,3), ', ',  num2str(theta0_cut,3), ', ', num2str(theta2_cut,3) ])
xlabel('[m]')
ylabel('[m]')
daspect([1 1 1])

%% Plot evolution of gap
figure
grid on; hold on;
tmp = 1:size(G0_cut,1) ;
tmp = resol.*tmp ;
plot(tmp, G0_cut)
clear tmp
tmp = 1:size(G1_cut,1) ;
tmp = resol.*tmp ;
plot(tmp, G1_cut)
clear tmp
tmp = 1:size(G2_cut,1) ;
tmp = resol.*tmp ;
plot(tmp, G2_cut)
clear tmp
title('Gap size evolution, along magnetic length (with magnet cut)')
xlabel('lm [m]')
ylabel('[m]')

%% Plot evolution of B
figure
grid on; hold on;
tmp = 1:size(B0_cut,1) ;
tmp = resol.*tmp ;
plot(tmp,B0_cut)
clear tmp
tmp = 1:size(B1_cut,1) ;
tmp = resol.*tmp ;
plot(tmp,B1_cut)
clear tmp
tmp = 1:size(B2_cut,1) ;
tmp = resol.*tmp ;
plot(tmp,B2_cut)
clear tmp
title('Evolution of B, along magnetic length (with magnet cut)')
xlabel('lm [m]')
ylabel('[m]')


