function [ p2, v2, alpha, rM ] = det_particle_position( T, B, p1, v1, resol )
% Given the position and velocity vector of a particle with T energy and
% under influence of a B magnetic field, determine its new position after
% travelling resol. m (defined resolution)
%
% IN: 
    % T: particle energy [eV]
    % B: local magnetic field [T]
    % p1 = (px,py): input position of the particle
    % v1 = (vx,vy): input velocity vector of the particle
    % resol: resolution, i.e. finess of the B field update [m]
%
% OUT:
    % p2: output position of the particle
    % v2: output vel. vector of the particle
    % angle: angle between v1 and v2 [degrees]
    % rM: bending radius [m]
    
%%
% Magnetic rigidity
c = 299792458 ; %[m/s]
q = 1 ; % Note: do not forget these are electrons, i.e. bending is in the other direction !
E0 = 0.51e6 ; %[eV]
% get Bp
Bp = 1/(q*c)*sqrt( T^2 +2*T*E0 ) ;

% bending radius
rM = Bp / B ;
    
% normalize velocity vector
v1 = [ v1(1)/norm(v1), v1(2)/norm(v1) ] ;

% get radial vector for p1
rM_vector_1 = [ v1(2), -v1(1) ] ;
rM_vector_1 = -rM*rM_vector_1 ;

% get bending angle
beta = resol / rM ; %[radians]

% get radial vector for p2
R = [cos(beta) -sin(beta); sin(beta) cos(beta)]; % rotation applied
rM_vector_2 = rM_vector_1*R ;
rM_vector_2 = rM*[ rM_vector_2(1)/norm(rM_vector_2), rM_vector_2(2)/norm(rM_vector_2) ] ; % normalization

% transformation for getting p2
p2 = p1 - rM_vector_1 + rM_vector_2 ;
v2 = [ rM_vector_2(2)/norm(rM_vector_2), -rM_vector_2(1)/norm(rM_vector_2) ] ;

% exit angle alpha
alpha = (-atan2d(v2(2),v2(1))+360) - (-atan2d(v1(2),v1(1))+360) ;
if alpha < 0 
    alpha = alpha + 360 ;
end
    
end

