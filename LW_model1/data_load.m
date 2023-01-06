% Load data.
[num,str]=xlsread('Data2.xlsx','dat');
labels = str(1,:);

% Dates
%Date = num(:,2:3);
  
% Labels
seriesNames = labels(3);
 
% Data fin
ym   = num(:,2);
clear num  num str labels
save lw_data;




% [num,str]=xlsread('Data.xlsx','dat');
% %data = num(83:end,:);
% labels = str(1,:);
% 
% % Dates
% Date = num(:,2:3);
%   
% % Labels
% seriesNames = labels(1,[5,7,9]);
%  
% % Data fin
% ym   = data(1:end-3,4);
% real = data(1:end-3,6);
% pi   = data(1:end-3,8);
% clear num  num str labels
% save lw_data;
