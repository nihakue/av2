function [Ricp, Ticp, xyzlist2] = alignPoints(isolated)
%% 
% TODO - accept edge points separately, and give their contribution greater
% weight, and use it to initialize the main ICP
% Ricp{i} and Ticp{i} are the rotation and translation matrices, that aim to transform the points
% in xyzlist{i} to the points in xyzlist{i+1}
% xyzlist2 comprises all of the points in xyzlist{1:20}, transformed and
% placed in a single 3D image
% Code adapted from the icp demo on www.mathworks.com/matlabcentral/fileexchange/27804-iterative-closest-point
[~,numFrames]=size(isolated);
totalPoints=0;
for i=1:numFrames
    fprintf('preparing frame %d\n',i);
    xyzlist{i} = reshape(isolated{i}(:,:,:),640*480,6);
    xyzlist{i}=unique(xyzlist{i},'rows')';
    xyzlist{i}(:,all(xyzlist{i}(1:3,:)==0,1))=[];
    [~,n{i}]=size(xyzlist{i});
    totalPoints=totalPoints+n{i};
end
%find the necessary rotation and transform matrices between each frame.
for i=1:(numFrames-1)
    fprintf('integrating frame %d\n',i+1)
    j=1;
    [Ricp{i} Ticp{i} ER{i} t{i}] = icp(xyzlist{i}(1:3,:), xyzlist{i+1}(1:3,:), 'Matching', 'Delaunay');
end
xyzlist2=zeros(6,totalPoints);
%transform the points so as to create a single 3D image containing all the
%points
a=1;
for i=1:numFrames    
    fprintf('transforming frame %d\n',i)
    b=a+n{i}-1;
    xyzlist2(:,a:b)=xyzlist{i}(:,:);
    for j=1:(i-1)
        fprintf('\tusing the transform from frame %d\n',j);
        xyzlist2(1:3,a:b)=Ricp{j}*xyzlist2(1:3,a:b) + repmat(Ticp{j}, 1, n{i});
    end
    a=a+n{i};
end
end