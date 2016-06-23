clear all;
close all;
%%%import excel info

sourcedir=uigetdir;
sourcefiles=dir(fullfile(sourcedir,'*xlsx'));

% combinedoutput=[0,0,0,0];
combinedoutput(:,1)={'deltaZ', 'baseline','timethbased','timeslopebased','integral','filename'};

for n=1:length(sourcefiles)
    combinedoutput(:,n+1)=allparameters_v5(sourcefiles(n,1).name);
end


%excel file output

[pathstr,foldername,ext]=fileparts(sourcedir);
exportfilename=[foldername '_parameters_v5.xlsx'];
xlswrite(exportfilename,combinedoutput);

% hist(combinedoutput(1,:));