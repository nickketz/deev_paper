function [y] = ste(x,varargin)

% function [y] = ste(x,dim)
%
% matlab doesn't have a standard error function, but it's easy
% enough to calculate. ste(x) = std(x)/sqrt(n) where n is the
% number of samples
%
% this is just a wrapper function that calls std, and then divides
% by sqrt(size(x,1))
%
% if dim is provided the std is calculated on the specific dimension
%
mydim = 1;
if nargin==2
  if varargin{1}==2 && length(size(x))<3
    x = x';
  else
      mydim = varargin{1};
  end
end

n = size(x,mydim);
y = std(x,0,mydim) / sqrt(n);