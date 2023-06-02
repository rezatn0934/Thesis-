function [y2] = lagrangeloop(x1,y1,x2)
%--------------------------------------------------------------------------
% LAGRANGELOOP
% This function is outer function of LAGRANGEINT.
%
% INPUTS : x1, y1, x2
% OUTPUT : y2
%
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
n = length(x1);
P = ones(length(x2),n);
y2 = NaN(length(x2),1);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for i = 1:length(x2)
    for j = 1:n
        P(i,j) = 1;
        for k = 1:n
            if k ~= j
                P(i,j) = P(i,j)*(x2(i) - x1(k))/(x1(j) - x1(k));
            end
        end
        P(i,j) = P(i,j)*y1(j);
    end
    y2(i,1) = sum(P(i,:)); 
end
%--------------------------------------------------------------------------

end

