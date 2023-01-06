% Load data.
[num,str]=xlsread('Data.xlsx','dat');
data = num(83:end,:);
labels = str(1,:);

% Dates
Date = num(:,2:3);
  
% Labels
seriesNames = labels(1,[5,7,9]);
 
% Data fin
ym   = data(:,4);
real = data(:,6);
pi   = data(:,8);
clear num  num str labels
save lw_data;
