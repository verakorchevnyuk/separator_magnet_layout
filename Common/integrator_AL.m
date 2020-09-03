global q E Bz

q = -1; % e, charge of the electron
P = 100; % MeV/c, total momentum
Bz = -0.5; % T
m = 0.5109989499985809; % MeV/c^2, rest mass of the electron
E = hypot(m, P); % MeV, total energy (constant of motion)
v = P/E; % c, electron velocity

t_max = 1000; % mm/c
nsteps = 10000; % number of steps
t = linspace (0, t_max, nsteps); % mm/c, time axis

% initial conditions
x = 0;
y = 0;
Px = P;
Py = 0;
% X = lsode (@f_det_Xdot, [ x y Px Py ], t);
X = sde(f_det_Xdot([ x y Px Py ], t)) ;

figure(1)
plot(X(:,1), X(:,2))
xlabel('X [mm]');
ylabel('Y [mm]');
grid

