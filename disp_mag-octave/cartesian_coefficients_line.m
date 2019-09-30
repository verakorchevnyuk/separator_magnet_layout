function [ m, b ] = cartesian_coefficients_line( p, beta )
% A line passing through the point p with a angle beta with relation to the
% horizontal line (x axis) can be defined by its m and b coefficients. The
% present function bridges one representation to the other.
%
% IN:
    % p = (px, py): point in cartesian coordinates
    % beta: angle in degrees between the line and the x axis [degrees].
    %                   Defined for [-90,+90]
%
% OUT:
    % m: slope of line
    % b: y for x=0

% general fucntion
y = @(beta, x) tand(beta)*(x-p(1))+p(2) ;

% compute b
b = y(beta,0) ;

% compute m
aux_x = p(1)+10 ;
m = (y(beta,aux_x)-b) / aux_x ;
    
end

