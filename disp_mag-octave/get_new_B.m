function [ B, gap ] = get_new_B( Bref, rref, p, Bgrad, gapmin, NI )
% Computation of the magnetic field B in a particular point in relation to
% a the reference beam path

% IN
    % Bref: reference magnetic field [T]
    % rref: reference bending radius [m]
    % p = [px, py]: particle position
    % Bgrad: B field gradient [T/m]
    % gapmin: constaint for the aperture size [m]
    % NI: magnet ampere-turns
%
% OUT
    % B: magnetic field in p
    % gap: magnet aperture in p

% particle displacement d
p_vec = norm( [0 -rref] - p );
d = p_vec - rref ;
% disp(d)

% compute B (linearly)
B = Bref - Bgrad*d ;

% magnet aperture
u0 = 4*pi*10^(-7) ;
gap = u0*NI/B ;

% check gap condition
if gap < gapmin 
    fprintf('\n+++++++++++++++++++++ ERROR: gap size! ++++++++++++++++++++++\n')
end

% check if B is negative
if B < 0 
    fprintf('\n ^ v ^ v ^ Compute B is negative. Set to zero. ^ v ^ v ^ v \n')
    B = 0 ;
end

end

