function [ mtxP, mtxV, theta ] = alpha_magnet_simulation(p1, v1, lm,...
    T, Bref, resol, margin_in, margin_out )
% IN:
    % p1 = [px,py]: particle initial position [m]
    % v1 = [vx,vy]: particle initial velocity vector [m]
    % lm: magnetic length of the beam [m]
    % T: kinetic enegy of the beam [eV]
    % Bref: central B field [T]
    % resol: resolution, i.e. finess of the B field update [m]
    % margin_in: distance w/o magnetic field influence at input [m]
    % margin_out: distance w/o magnetic field influence at output [m]
% OUT:
    % mtxP = [ p1x p1y ; p2x p2y ; ... ]: matrix with positions [m]
    % mtxV = [ v1x v1y ; v2x v2y ; ... ]: matrix with velocity vectors [m]
    % theta: exit angle between the input and output beams [deg.]
    
%% Magnet input
% velocity vector normalization
v1 = v1/norm(v1) ;
mtxV = [v1 ; v1 ] ;
% filling first points in positions matrix
mtxP = [ p1 ; p1+margin_in*v1 ] ;

%% Inside magnet

% loop for retrieving the path inside the magnet
n = 1; % look aux var
theta = 0 ; % angle between the beam in and out
p = mtxP(end,:) ;
v = mtxV(end,:) ;
newB = Bref ;

while ( n*resol < lm )
%     if (B ~= 0)
        [ p, v, alpha, ~ ] = det_particle_position_alpha_magnet( T, newB, p, v, resol ) ;
        mtxP = [ mtxP ; p ] ;
        mtxV = [ mtxV ; v ] ;
%     else
%         disp('/!\ B=0, beam travelling straigth /!\') ;
%         mtxV = [ mtxV ; v ] ;
%         p = p + resol*v ;
%         P = [ P ; p ] ;
%         alpha = 0 ;
%     end
    theta = theta + alpha ;
    %         [ newB, newGap ] = get_new_B( Bref, rref, p, Bgrad, gapMin, NI ) ;
    %         B = [ B ; newB ] ;
    %         G = [ G ; newGap ] ;
     newB = Bref ;
    %R = [ R, rM ] ;
    n = n+1 ;
end
    mtxP = mtxP(1:end-1, :) ;
    mtxV = mtxV(1:end-1, :) ;

    
%% Outside magnet
vf = mtxV(end,:)/norm(mtxV(end,:)) ;
pf = mtxP(end,:) ;
mtxP(end+1, :) = pf+margin_out*vf  ;



end

