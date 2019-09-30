function [ m, b, err ] = linear_regression( P, Opt )
% Fitting of a line to the exit points of the beam from the magnet. The
% slope m and the ordinate b. The mean square error in yield
%
% IN:
    % P = [ p1; p2; p3]: matrix with the exit point of the beam
    % Opt: method option
            % 1 - fitting method to data, w/o any constraints
            % 2 - fitting method to data, w/ constaint - curve-fit must
            %                   pass through the point p2 (reference beam)
%
% OUT:
    % m: slope of the fitting curve
    % b: ordinate y, for x = 0
    % err: mean square error of the fitting. Measure of the fitting quality

%%
b = 0 ;
m = 0 ;
l = 0 ;
err = 0 ;
f = @(m,b,x) m*x + b ;
switch Opt
    % w/o constraints
    case 1
        a = [ b; m ] ;
        y = [ P(:,2) ] ;
        X = [ ones(size(P,1),1) P(:,1) ] ;
        a = X\y ;
        b = a(1) ;
        m = a(2) ;
        for i = 1:size(P,1)
            err = err + (norm( P(i,:) - f(m,b,P(i,1) ) ) )^2 ;
        end
        err = err / i ;
        err = sqrt(err) ;
    % passing through p2
    case 2
        a = [ b; m ] ;
        y = [ P(:,2) ] ;
        X = [ ones(size(P,1),1) P(:,1) ] ;
        A = [ 1 P(2,1) ] ;
        c = P(2,2) ;
        S = [ 2*X.'*X A.' ; A 0 ] ;
        Q = [ a ; l ] ;
        R = [ 2*X.'*y ; c ] ;
        Q = S\R ;
        b = Q(1) ;
        m = Q(2) ;
        for i = 1:size(P,1)
            err = err + (norm( P(i,:) - f(m,b,P(i,1) ) ) )^2 ;
        end
        err = err / i ;
        err = sqrt(err) ;
end


end

