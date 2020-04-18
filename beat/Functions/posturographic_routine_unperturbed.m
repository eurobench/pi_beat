function [PL_p EA_p]=posturographic_routine_unperturbed(PlatformData)
% posturographic_routine_unperturbed is a function that gives the posturographic parameters related to a specific protocol.
%Required Octave pkg: signal, statistics, linear-algebra, geometry
%[PL PL_AP PL_ML EA]=posturographic_routine_unperturbed(PlatformData)
% INPUT:
%       - PlatformData is a file containing the data extracted by the platform.
% OUTPUT:
%       - PL is the path lenght of the COP during the task. Result is a scalar (units: m)
%       - PL_AP is the path lenght of the COP during the task in the anterior-posterior direction. Result is a scalar(units: m)
%       - PL_ML is the path lenght of the COP during the task in the medio-lateral direction. Result is a scalar (units: m)
%       - EA is the area of confidence ellipse of the COP during the task in the medio-lateral direction. Result is a scalar(units: m2)
% $Author: J. TABORRI, v1 - 04/Apr/2020$ (BEAT project)


platformdata=csv2cell(PlatformData, ";");
cop=cell2mat(platformdata(:,18:19))*0.001; %column 18 and 19 contain data of COP extracted from the pressure matrix converted in m
z=chi2inv(0.95,2); %%compute the probability associated with 0.95 confidence level (chi distribution)

%%understand which is the protocol
if (platformdata{1,2}==2) %%2 represent the stepping protocol with uneven surface
event_1=cell2mat(platformdata(:,21));
event=find(event_1==1); %%21st column of platformdata represents the stride identification performed by the pressure matrix embedded in the platform 
aa=2;%%21st column of platformdata represents the stride identification performed by the pressure matrix embedded in the platform
elseif (platformdata{1,2}==3 || platformdata{1,2}==4) %%3 and 4 represent protocol of static balance
 aa=1;
else
 fprintf('You have tried to lunch posturographic_routine with a wrong protocol') 
endif

if aa==1;
PL_AP=(sqrt(sum(diff(cop(:,1)).^2))); %%path lenght in AP direction 
PL_ML=(sqrt(sum(diff(cop(:,2)).^2))); %%path lenght in ML direction
PL=sum(sqrt((diff(cop(:,1)).^2) + (diff(cop(:,2)).^2))); %%path lenght resultant
%%compute ellipse
o=mean(cop,1); %%center of the confidence ellipse
nF=size(cop,1);
x=cop(:,1)-repmat(o(:,1),nF,1);
y=cop(:,2)-repmat(o(:,2),nF,1);
Cxx=(x'*x)/(size(x,1)-1);
Cyy=(y'*y)/(size(x,1)-1);
Cxy=(x'*y)/(size(x,1)-1);
C=[Cxx Cxy;Cxy Cyy];
[V D W]=svd(C);
e0=V(:,1);
e1=V(:,2);
a=sqrt(z*D(1,1));
b=sqrt(z*D(2,2));
EA=a*b*pi;  %%ellipse area

elseif (aa==2) 
 for e=1:length(event)-1
COP=cop(event(e):event(e+1),:); %%divide COP into the events (perturbations)
PL_AP(e)=sum(sqrt(diff(COP(:,1)).^2)); %%path lenght in AP direction
PL_ML(e)=sum(sqrt(diff(COP(:,2)).^2)); %%path lenght in ML direction
PL(e)=sum(sqrt((diff(COP(:,1)).^2) + (diff(COP(:,2)).^2))); %%path lenght resultant
%%compute ellipse
o(:,:,e)=mean(COP(:,:),1); %%center of the confidence ellipse
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
EA(e)=a*b*pi;  %%ellipse area
clear COP
end
PL_AP=mean(PL_AP,2); %compute mean value across repetitions
PL_ML=mean(PL_ML,2);
PL=mean(PL,2);
EA=mean(EA,2);
else
fprintf('You have tried to lunch posturographic_routine with a wrong protocol') 
endif


%%save file
[aaa, name, extension]=fileparts(PlatformData);
name2=regexprep(name,'_PlatformData','');
file_id=fopen(strcat(pwd,"/", name2, "_PL_AP", ".yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'scalar' 'measure unit: m' \n");
plap_str="value: ";
plap_str=sprintf("%s%.3f",plap_str,PL_AP);
plap_str=sprintf("%s",plap_str);
fprintf(file_id,plap_str);
fclose(file_id)

file_id=fopen(strcat(pwd,"/", name2, "_PL_ML", ".yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'scalar' 'measure unit: m' \n");
plml_str="value: ";
plml_str=sprintf("%s%.3f",plml_str,PL_ML);
plml_str=sprintf("%s",plml_str);
fprintf(file_id,plml_str);
fclose(file_id)

file_id=fopen(strcat(pwd,"/", name2, "_PL", ".yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'scalar' 'measure unit: m' \n");
pl_str="value: ";
pl_str=sprintf("%s%.3f",pl_str,PL);
pl_str=sprintf("%s",pl_str);
fprintf(file_id,pl_str);
fclose(file_id)

file_id=fopen(strcat(pwd,"/", name2, "_EA", ".yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'scalar' 'measure unit: m^2' \n");
ea_str="value: ";
ea_str=sprintf("%s%.6f",ea_str,EA);
ea_str=sprintf("%s",ea_str);
fprintf(file_id,ea_str);
fclose(file_id)