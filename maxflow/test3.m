function [flow,labels] = test1()

% TEST1 Shows how to use the library to compute
%   a minimum cut on the following graph:
%
%                SOURCE
%		       /       \
%		     1/         \2
%		     /      3    \
%		   node0 -----> node1
%		     |   <-----   |
%		     |      4     |
%		     \            /
%		     5\          /6
%		       \        /
%		          SINK
%
%   (c) 2008 Michael Rubinstein, WDI R&D and IDC
%   $Revision: 140 $
%   $Date: 2008-09-15 15:35:01 -0700 (Mon, 15 Sep 2008) $
%

A = sparse(5,5);
A=gr(2:6,2:6);
T = sparse(7,2);
T(:,1)=gr(1,:);
T(:,2)=gr(7,:);

[flow,labels] = maxflow(A,T)
