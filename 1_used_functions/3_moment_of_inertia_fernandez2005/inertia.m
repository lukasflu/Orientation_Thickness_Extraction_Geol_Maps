function [Dir,M,K] = inertia(points)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              INERTIA                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find best fitting plane through x,y,z points and calculate quality      %
% metrics using moment of inertia analysis (Fernandez 2005). The best fit %
% plane is assumed to pass throught the points centre of mass:            %
% i.e. cent = [mean(points(:,1)) mean(points(:,2)) mean(points(:,3))]     %
%                                                                         %
% INPUT: points - nx3 xyz vertex list                                     %
%                                                                         %
% OUTPUT: Dir - directional cosine corresponding to the pole to the best  %
%               fit plane                                                 %
%         M - vertex coplanarity                                          %
%         K - vertex colinearity                                          %
%                                                                         %
% USAGE: [Dir,M,K] = inertia(points);                                     %
%                                                                         %
% REFERENCES: Fernández, O., 2005. Obtaining a best fitting plane through %
%             3D georeferenced data. Journal of Structural Geology, 27,   %
%             855–858                                                     %
%                                                                         %
% COPYRIGHT: Thomas Seers 03/06/2014                                      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Move points to the origin
points = bsxfun(@minus,points,mean(points)); %shift centroid to zero

% Calculate orientation tensor
T = [sum((points(:,1)).*(points(:,1)))  sum((points(:,1)).*(points(:,2)))  sum((points(:,1)).*(points(:,3)));
     sum((points(:,2)).*(points(:,1))) sum((points(:,2)).*(points(:,2))) sum((points(:,2)).*(points(:,3)));
     sum((points(:,3)).*(points(:,1))) sum((points(:,3)).*(points(:,2))) sum((points(:,3)).*(points(:,3)))];

% Find eigenvalues and vectors of T
[V,D] = eig(T);

% Find Lamda 1, 2 and 3 with corresponding eigenvectors
EV = sortrows([horzcat(D(1,1)),V(:,1)'; horzcat(D(2,2),V(:,2)'); horzcat(D(3,3),V(:,3)')],1);

M = log(EV(3,1)/EV(1,1)); % M = ln(Lamda1/Lambda3) : coplanarity

K = log(EV(3,1)/EV(2,1))/log(EV(2,1)/EV(1,1)); % K = ln(Lamda1/Lambda2)/ln(Lambda2/Lambda3): colinearity

Dir = EV(1,2:end); % v3 is the pole to the best fit plane
end
