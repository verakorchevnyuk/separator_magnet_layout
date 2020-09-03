function [ lm, rref, Bgrad, Gamma, P0, P1, P2, V0, V1, V2, total_alpha ] = ...
    trajectories_simulation( beta1, beta2, Bref, Bgrad, T0, T1, T2, plot_info )
% v2: introduction of two beta cuts
%
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
resol = 1e-3; %[m]
gapMin = 30e-3 ; %[m]
NI = 200*500 ; % Amp-turns
[ ~, ~, ~, rref ] = det_particle_position( T0, Bref, p, v, resol ) ;
[ theta0, P0, V0, B0, ~, lm0 ] = particle_trajectory_for_goal_angle( goalTheta0, T0, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
R0 = rref*ones(1,round(lm0/resol)) ;

% Line coefficients
exit_point = P0(size(P0,1),:) ;
% M = beta ;
[ m1, b1 ] = cartesian_coefficients_line( exit_point, beta1 ) ;
[ m2, b2 ] = cartesian_coefficients_line( exit_point, beta2 ) ;
% Low energy trajectory
% [ theta1, P1, V1, B1, G1, lm1 ] = particle_trajectory_until_exiting_magnet( m, b, T1, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
[ theta1, P1, V1, B1, ~, lm1, R1 ] = ...
    particle_trajectory_until_exiting_magnet_with_bend_radius( m1, b1, T1, ...
    rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

% High energy trajectory
% [ theta2, P2, V2, B2, G2, lm2 ] = particle_trajectory_until_exiting_magnet( m, b, T2, rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;
[ theta2, P2, V2, B2, ~, lm2, R2 ] = ...
    particle_trajectory_until_exiting_magnet_with_bend_radius( m2, b2, T2, ...
    rref, Bref, Bgrad, p, v, resol, gapMin, NI ) ;

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
        
        h = figure ;
%         plot(xx_cut1',yy_cut1','.'); % Cutting line
        grid on;
        daspect([1 1 1])
        hold on;
%         plot(xx_cut2',yy_cut2','-.'); % Cutting line
        
        plot(P0(:,1),P0(:,2), 'LineWidth', 3); % Reference beam
        
        plot(P1(:,1),P1(:,2), 'LineWidth', 3); % Low energy beam
        
        plot(P2(:,1),P2(:,2), 'LineWidth', 3); % High energy beam
        
        title({['\beta_1 = ', num2str(beta1,'%.1f'), ' degrees;  \beta_2 = ', num2str(beta2,'%.1f'), ' degrees' ],...
            [ 'B_{ref} = ', num2str(Bref), ' T;  dB/dr = ', num2str(Bgrad), ' T/m;  \alpha = ' num2str(total_alpha,'%.1f') ' degrees' ], ...
            [ 'H1 = ', num2str(P1(end,2), '%.3f'), ' m;  H0 = ', num2str(P0(end,2), '%.3f'), ' m;  H2 = ', num2str(P2(end,2), '%.3f'), ' m' ] }, "fontsize", 15);
%            ['\theta_1 = ' num2str(alpha1,'%.1f') ' degrees; ' '\theta_2 = ' num2str(alpha2,'%.1f') ' degrees; ' '\alpha = ' num2str(total_alpha,'%.1f') ' degrees' ]}, "fontsize", 15);
%         title('Expected trajectories', "fontsize", 15)
        xlabel('[m]')
        ylabel('[m]')
       % axis([-0.2 0.7 -0.7 0]) %%%%%%%%%%%%%%%%%%%%%%%%%% - CHECK HERE
        % set(h, 'Position', get(0, 'Screensize'));

        % pic_location = 'C:\Users\vkorchev\Downloads\separator_magnet_layout-master\separator_magnet_layout-master\Common\schematics' ;
        % pic_name = ['beta1-', num2str(beta1,'%.0f'), '_beta2-',num2str(beta2,'%.0f'), '_Bref-', num2str(Bref,'%.0f'), '_gradB-', num2str(Bgrad,'%.0f'), '_', datestr(now,'mm-dd-yyyy_HH-MM') ];
        % saveas(h, [pic_location '\' pic_name], 'png' ) ;
        % close (h)
end

% % pole face
% lineAux = [];
% lineAux2= lineAux;
% lineAux3 = lineAux ;
% k=linspace(-1, 1, 10000);
% for i=1:length(k)
% lineAux = [ lineAux; P0(end,:)+[-V0(end,2) V0(end,1)]*k(i)];
% lineAux2 = [lineAux2; P1(end,:)+[-V1(end,2) V1(end,1)]*k(i)];
% lineAux3 = [lineAux3; P2(end,:)+[-V2(end,2) V2(end,1)]*k(i) ];
% end
% plot(lineAux(:,1), lineAux(:,2),'LineStyle','--', 'Color', [0.211 0.211 0.211])
% hold on
% plot(lineAux2(:,1), lineAux2(:,2),'LineStyle','--', 'Color', [0.211 0.211 0.211])
% plot(lineAux3(:,1), lineAux3(:,2),'LineStyle','--', 'Color', [0.211 0.211 0.211])
% grid on
% 
% tangent
lineAux = [];
lineAux2= lineAux;
lineAux3 = lineAux ;
k=linspace(-1, 1, 10000);
for i=1:length(k)
lineAux = [ lineAux; P0(end,:)+V0(end,:)*k(i)];
lineAux2 = [lineAux2; P1(end,:)+V1(end,:)*k(i)];
lineAux3 = [lineAux3; P2(end,:)+V2(end,:)*k(i) ];
end
if (char(plot_info) == 'y')
    plot(lineAux(:,1), lineAux(:,2),'LineStyle',':', 'Color', [0.211 0.211 0.211])
    hold on
    plot(lineAux2(:,1), lineAux2(:,2),'LineStyle',':', 'Color', [0.211 0.211 0.211])
    plot(lineAux3(:,1), lineAux3(:,2),'LineStyle',':', 'Color', [0.211 0.211 0.211])
    grid on
end

end

