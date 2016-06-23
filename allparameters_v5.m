function parameters=allparameters_v4(filename)

sheet = 1;

response=xlsread(filename, sheet);
response=response([22:end],:);

% fpathstring='0';
% fname='0';
% fextension='0';
% [fpathstring, fname, fextension]=fileparts(filename);
%%%data smoothing messes up delta Z calculation
% response(:,3)=sgolayfilt(response(:,3), 5, 7);

%%%pull out baseline values
baselinei=response(1,3);
baselinef=response(length(response),3);

deltabaseline=baselinef-baselinei;

%%%extract peak

%filter out values greater than 1e6
time=response(:,1);
impedance=response(:,3);

for n = 1:length(impedance)
    if(impedance(n)>1e6)
        count(n,1)=1;
    else
        count(n,1)=0;
    end
end

%find where impedance returns to appropriate values (after switching from
%Keithley
zfilterlocation=find(diff(count)~=0);
ztimestartindex=zfilterlocation(end)+1;

%find peak and time
[peak,peakindex]=max(impedance(ztimestartindex:end));
peaktimeindex=peakindex+zfilterlocation(end)+1;

%compute deltaZ
deltaZ=peak-baselinei;

%%%%%set return to baseline thresholds
percentdeltaZ=0.04; %%look for impedance return to arbitrary percentage
Zthreshold=baselinei+(deltaZ*percentdeltaZ);

stableZslope=1; %%look for slope <1

%find time to return to baseline

%threshold based calculation for time to return to baseline
%probably could have used a while loop :T
exitflag=0;
ztimeTHendindex=length(impedance); %initialize to last index in case the value never returns to below threshold
for n=peaktimeindex:length(impedance)
    if(impedance(n)<Zthreshold)
        ztimeTHendindex=n;
        exitflag=1;
        break;
    end
    if exitflag==1
        break;
    end
end
 
timethbased=response(ztimeTHendindex,1)-response(ztimestartindex,1);

%slope based calculation for time to return to baseline
zdiff1=diff(impedance)./diff(time); %%first derivative of impedance response
zdiff1smooth=sgolayfilt(zdiff1, 5, 7);

%find regions where slope ~0
ztimeSLOPEindex=0;
for n=peaktimeindex:(length(impedance)-1)
    if(abs(zdiff1smooth(n))<stableZslope)
        ztimeSLOPEindex=[ztimeSLOPEindex; n];
    end
end

%find LAST region where slope ~0 based on threshold value
exitflag=0;
ztimeSLOPEindexEND=length(impedance); %initialize to final index
for n=1:length(ztimeSLOPEindex)
    if(ztimeSLOPEindex(n)>ztimeTHendindex)
        ztimeSLOPEindexEND=ztimeSLOPEindex(n);
        exitflag=1;
        break;
    end
    if exitflag==1
        break;
    end
end

timeslopebased=response(ztimeSLOPEindexEND,1)-response(ztimestartindex,1);


%calculate integral
%set zero to baseline
zeroedimpedance=impedance-baselinei;
responseintegral=trapz(time(ztimestartindex:ztimeSLOPEindexEND),zeroedimpedance(ztimestartindex:ztimeSLOPEindexEND));

% parameters=zeros(2);
% parameters(:,1)={'deltaZ', 'timethbased','timeslopebased','integral'};
parameters(:,1)={deltaZ, baselinei, timethbased, timeslopebased, responseintegral, filename};


