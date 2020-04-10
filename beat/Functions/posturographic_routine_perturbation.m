function [PL_p EA_p]=posturographic_routine_perturbation(PlatformData)
% osturographic_routine_perturbation is a function that gives the posturographic parameters related to a specific protocol.
%Required Octave pkg: signal, statistics, linear-algebra, geometry
%[PL_p EA_p]=posturographic_routine_perturbation(PlatformData)
% INPUT:
%       - PlatformData is a file containing the data extracted by the platform.
% OUTPUT:
%       - PL_p is the path lenght of the COP during the task. Result is a cell 2xNd, where Nd is the number of perturbation direction (units: m)
%       - EA is the area of confidence ellipse of the COP during the task in the medio-lateral direction. Result is a cell 2xNd, where Nd is the number of perturbation direction(units: m2)
% $Author: J. TABORRI, v1 - 04/Apr/2020$ (BEAT project)

platformdata=csv2cell(PlatformData, ";")
cop=platformdata(:,18:19)*0.001; %column 18 and 19 contain data of COP extracted from the pressure matrix converted in m
z=chi2inv(0.95,2); %%compute the probability associated with 0.95 confidence level (chi distribution)

%%understand which is the protocol
if (platformdata(1,2)==7) %%7 represents the sinusoidal perturbation protocol
a=2;
 elseif platformdata(1,2)==5 || platformdata(1,2)==6) %%5 and 6 represent protocol of step perturbation
 a=1;
else
 fprintf('You have tried to lunch posturographic_routine with a wrong protocol') 
endif

if a=1;
  for d=1:8 %%number of directions in case of step perturbations
COP=cop(platformdata((:,20)==i,:); 
COP=cop(event(e):event(e+1),:); %%divide COP into the events (perturbations)
PL_i(d)=sum(sqrt((diff(COP(:,1)).^2) + (diff(COP(:,2)).^2))); %%path lenght resultant
%%compute ellipse
o(:,:,d)=mean(COP(:,:),1); %%center of the confidence ellipse
nF=size(COP,1);
x=COP(:,1)-repmat(o(:,1),nF,1);
y=COP(:,2)-repmat(o(:,2),nF,1);
Cxx=(x'*x)/(size(x,1)-1);
Cyy=(y'*y)/(size(x,1)-1);
Cxy=(x'*y)/(size(x,1)-1);
C=[Cxx Cxy;Cxy Cyy];
[V D W]=svd(C);
e0=V(:,1);
e1=V(:,2);
a=sqrt(z*D(1,1));
b=sqrt(z*D(2,2));
EA_i(d)=a*b*pi;  %%ellipse area
clear COP x y Cxx Cyy Cxy e0 e1 V D W a b
endfor
direction={'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}; %%direction acronyms
PL_p=cat(1,direction,num2cell(PL_i)); %%add the header line with direction label
EA_p=cat(1,direction,num2cell(EA_i)); %%add the header line with direction label


else a=2 
 for d=1:4 %%number of directions in case of sinusoidal perturbations
COP=cop(platformdata((:,20)==i,:); 
PL_i(d)=sum(sqrt((diff(COP(:,1)).^2) + (diff(COP(:,2)).^2))); %%path lenght resultant
%%compute ellipse
o(:,:,d)=mean(COP(:,:),1); %%center of the confidence ellipse
nF=size(COP,1);
x=COP(:,1)-repmat(o(:,1),nF,1);
y=COP(:,2)-repmat(o(:,2),nF,1);
Cxx=(x'*x)/(size(x,1)-1);
Cyy=(y'*y)/(size(x,1)-1);
Cxy=(x'*y)/(size(x,1)-1);
C=[Cxx Cxy;Cxy Cyy];
[V D W]=svd(C);
e0=V(:,1);
e1=V(:,2);
a=sqrt(z*D(1,1));
b=sqrt(z*D(2,2));
EA_i(d)=a*b*pi;  %%ellipse area
clear COP x y Cxx Cyy Cxy e0 e1 V D W a b
endfor
direction={'AP', 'ML', 'V', 'M'}; %%direction acronyms
PL_p=cat(1,direction,num2cell(PL_i)); %%add the header line with direction label
EA_p=cat(1,direction,num2cell(EA_i)); %%add the header line with direction label

end