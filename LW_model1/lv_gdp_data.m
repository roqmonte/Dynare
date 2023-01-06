
  
 
% now load LV data
  [num,str]=xlsread(['Data_LV_2.xlsx'],'Data');

 % date matrix
 skipstart=100;
 skipend=3;
 Date = num(skipstart+1:end-skipend,1:2);
  
 % data matrix (num cols: 3-10)
  Ym0       = num(skipstart+1:end-skipend,3:7);
  %Date     = Date(13:end,:);
%   Label{1} = [country,': GDP'];
%   Label{2} = [country,': CTR'];
%   Label{3} = [country,': HPR'];
 seriesNames=str(1,3:7);
 
% GDP = 1; HPR = 2; Total credit=3; hh credit=4; firm credit=5;

% select log gdp data
  ym1 = Ym0(:,1);  
% plot(ym1)