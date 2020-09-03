% Setting variables
margin_in = 0.1 ;
margin_out = 0.5 ;
p = [-margin_in 0] ;
v = [1 0] ;
Bref = 1 ;
lm0 = 1.9/Bref ; 
lm1 = 1.8/Bref ;
lm2 = 2/Bref ;
resol = 1e-3 ;

%% Computing beam paths

% 120 MeV beam - Reference
T0 = 120e6 ;
[ mtxP0, mtxV0, theta0 ] = alpha_magnet_simulation( p, v, lm0,...
    T0, Bref, resol, margin_in, margin_out ) ;

% 100 MeV beam
T1 = 100e6 ;
[ mtxP1, mtxV1, theta1 ] = alpha_magnet_simulation( p, v, lm1,...
    T1, Bref, resol, margin_in, margin_out ) ;

% 140 MeV beam
T2 = 140e6 ;
[ mtxP2, mtxV2, theta2 ] = alpha_magnet_simulation( p, v, lm2,...
    T2, Bref, resol, margin_in, margin_out ) ;

%% Calculation of separation angle 
alpha1 = theta1 - theta0 ;
alpha2 = theta0 - theta2 ;
total_alpha = alpha1 + alpha2 ;
disp(['Total angle is ' num2str(total_alpha) ' degrees.'])

%% Plotting

P0 = mtxP0;
P1 = mtxP1;
P2 = mtxP2;
V0 = mtxV0;
V1 = mtxV1;
V2 = mtxV2;

h = figure ;
%         plot(xx_cut1',yy_cut1','.'); % Cutting line
grid on;
daspect([1 1 1])
hold on;
%         plot(xx_cut2',yy_cut2','-.'); % Cutting line

plot(P0(:,1),-P0(:,2), 'LineWidth', 3); % Reference beam

plot(P1(:,1),-P1(:,2), 'LineWidth', 3); % Low energy beam

plot(P2(:,1),-P2(:,2), 'LineWidth', 3); % High energy beam

plot(P0(end-1,1),-P0(end-1,2), '*', 'LineWidth', 9) ;
plot(P1(end-1,1),-P1(end-1,2), '*', 'LineWidth', 9) ;
plot(P2(end-1,1),-P2(end-1,2), '*', 'LineWidth', 9) ;
plot(P0(2,1),-P0(2,2), 'x', 'LineWidth', 2) ;

%title({['\beta_1 = ', num2str(beta1,'%.1f'), ' degrees;  \beta_2 = ', num2str(beta2,'%.1f'), ' degrees' ],...
%     title({[ 'B_{ref} = ', num2str(Bref), ' T;  dB/dr = ', num2str(Bgrad), ' T/m;  \alpha = ' num2str(total_alpha,'%.1f') ' degrees' ], ...
%     [ 'H1 = ', num2str(P1(end,2), '%.3f'), ' m;  H0 = ', num2str(P0(end,2), '%.3f'), ' m;  H2 = ', num2str(P2(end,2), '%.3f'), ' m' ] }, "fontsize", 15);
title ({['Trajectories of an alpha magnet'];['Separation angles: ' num2str(total_alpha) ' deg.']})
xlabel('[m]')
ylabel('[m]')
%axis([-0.2 0.7 -0.7 0])


