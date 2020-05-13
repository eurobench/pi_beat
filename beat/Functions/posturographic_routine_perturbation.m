function [PL_p EA_p]=posturographic_routine_perturbation(PlatformData, outFolder)
% osturographic_routine_perturbation is a function that gives the posturographic parameters related to a specific protocol.
%Required Octave pkg: signal, statistics, linear-algebra, geometry
%[PL_p EA_p]=posturographic_routine_perturbation(PlatformData,outFolder)
% INPUT:
%       - PlatformData is a file containing the data extracted by the platform.
%	- oufFolder: folder path where result should be stored
% OUTPUT:
%       - PL_p is the path lenght of the COP during the task. Result is a labelled matrix 2xNd, where Nd is the number of perturbation direction and the first row contains direction label (unit: m)
%       - EA is the area of confidence ellipse of the COP during the task in the medio-lateral direction. Result is a labelled matrix 2xNd, where Nd is the number of perturbation direction and the first row contains direction label (units: m^2)
% $Author: J. TABORRI, v1 - 04/Apr/2020$ (BEAT project)

platformdata=csv2cell(PlatformData, ";");
platformdata_header=platformdata(1,:);
cx=find(strcmpi(platformdata_header, 'CoP_x'), 1); %% cop x component column
cy=find(strcmpi(platformdata_header, 'CoP_y'), 1); %% cop y component column
cop=cell2mat(platformdata(2:end,cx:cy))*0.001; %converted in m
z=chi2inv(0.95,2); %%compute the probability associated with 0.95 confidence level (chi distribution)
per_dir=find(strcmpi(platformdata_header, 'pert_direction'), 1); %% perturbation direction column
direction=cell2mat(platformdata(2:end,per_dir));

p=find(strcmpi(platformdata_header, 'protocol_number'), 1); %%protocol number column
%%understand which is the protocol
if (platformdata{2,p}==7) %%7 represents the sinusoidal perturbation protocol
  aa=2;
elseif (platformdata{2,p}==5 || platformdata{2,p}==6) %%5 and 6 represent protocol of step perturbation
  aa=1;
else
  fprintf('You have tried to lunch posturographic_routine_perturbation with a wrong protocol\n') 
  fprintf('Provided protocol%: only accepts protocols 5, 6 and 7\n', platformdata{2,p})
  return;
endif

if aa==1;
  for d=1:8 %%number of directions in case of step perturbations
   COP=cop(direction(:,1)==d,:);
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
 direction={'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}; %%direction label in step protocols

else aa==2
  for d=1:4 %%number of directions in case of sinusoidal perturbations
   COP=cop(direction(:,1)==d,:);
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
 direction={'AP', 'ML', 'V', 'M'}; %%direction label in sinusoidal protocols
endif

%%save file
file_id=fopen(strcat(outFolder,"/pi_plp.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'labelled_matrix\n");
fprintf(file_id, "measure unit: 'm'\n");
label_str="value: [[";
for i=1:length(direction)
  label_str=sprintf("%s '%s'",label_str,char(direction(i)));
  if i!=length(direction)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s],\n",label_str);
fprintf(file_id,label_str);

pl_str="        [";
for i=1:length(PL_i)
  pl_str=sprintf("%s%.3f",pl_str,PL_i(i));
  if i!=length(PL_i)
    pl_str=sprintf("%s, ", pl_str);
  endif
endfor
pl_str=sprintf("%s]]\n",pl_str);
fprintf(file_id,pl_str);
fclose(file_id)

file_id=fopen(strcat(outFolder,"/pi_eap.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'labelled_matrix\n");
fprintf(file_id, "measure unit: 'm^2'\n");
label_str="value: [[";
for i=1:length(direction)
  label_str=sprintf("%s '%s'",label_str,char(direction(i)));
  if i!=length(direction)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s],\n",label_str);
fprintf(file_id,label_str);

ea_str="        [";
for i=1:length(EA_i)
  ea_str=sprintf("%s%.6f",ea_str,EA_i(i));
  if i!=length(EA_i)
    ea_str=sprintf("%s, ", ea_str);
  endif
endfor
ea_str=sprintf("%s]]\n",ea_str);
fprintf(file_id,ea_str);
fclose(file_id)