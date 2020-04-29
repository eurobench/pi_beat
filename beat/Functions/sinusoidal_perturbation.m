function [G phi]=sinusoidal_perturbation(fileName,PlatformData)
% sinusoidal_perturbation is a function that gives the gain and phase between two signals when a sinusoidal perturbation is imposed. It can be used only with Protocol7
%Required Octave pkg: signal, statistics, linear-algebra
%[G phi]=sinusoidal_perturbation(fileName,PlatformData)
% INPUT:
%       - fileName must be a .csv file with this structure containing joint angle data: 
%         1st column: time-stamp (units: milliseconds).
%         1st row: header with M+1 labels  were  M = number of angles considered.
%         From 2nd row: angle values, each corresponding to one time sample (units: degrees).
%       - PlatformData is a file containing the data extracted from the platform.
% OUTPUT:
%       - G is the gain ratio between the two signals  to understand how the segment follows the perturbation in terms of amplitude. dimension: (Na+1) x (D+1); where Na is the number of angles (3), D are the direction. THe element (1,1) is empty. First row: direction label, first column: angle label. Direction: Antero-posterior (AP), Medio-Lateral (ML), Vertical (V).
%       - phi is the phase shift between the two signals  to understand how the segment follows the perturbation in terms of phase. dimension: (Na+1) x (D+1); where Na is the number of angles (3), D are the direction. THe element (1,1) is empty. First row: direction label, first column: angle label. Direction: Antero-posterior (AP), Medio-Lateral (ML), Vertical (V).
%       
% $Author: J. TABORRI, v1 - 03/Apr/2020$ (BEAT project)


data=csv2cell(fileName,";"); 
platformdata=csv2cell(PlatformData, ";");
time_vector_data=cell2mat(data(2:end,1)); %%extract time vector from data
angle_matrix=cell2mat(data(2:end,2:end)); %%extract angle matrix from data
angle_label=data(1,2:end); %extract angle label
angle_number=size(angle_label,2);
time_vector_platform=cell2mat(platformdata(:,1)); %%extract time vector from platformdata

delta_t_angle=diff(time_vector_data,1);
fs_angle=round(1.0/mean(delta_t_angle));
delta_t_platform=diff(time_vector_platform,1);
fs_platform=round(1.0/mean(delta_t_platform))

ap1=find(strcmpi(angle_label, 'head_obliquity'), 1);
ap2=find(strcmpi(angle_label, 'thorax_obliquity'), 1);
ap3=find(strcmpi(angle_label, 'pelvic_obliquity'), 1);

ml1=find(strcmpi(angle_label, 'head_rotation'), 1);
ml2=find(strcmpi(angle_label, 'thorax_rotation'), 1);
ml3=find(strcmpi(angle_label, 'pelvic_rotation'), 1);

v1=find(strcmpi(angle_label, 'head_tilt'), 1);
v2=find(strcmpi(angle_label, 'thorax_tilt'), 1);
v3=find(strcmpi(angle_label, 'pelvic_tilt'), 1);



if (fs_angle~=fs_platform)   
for a=1:angle_number
 angle_matrix(:,a)=resample(angle_matrix(:,a),fs_platform,fs_angle);  %%make two signals with same sampling frequency
end
else
fprintf('Same sample frequency') 
endif

 if platformdata{1,2} ==7 %%  7 represents the sinusoidal perturbation protocol
interval=cell2mat(platformdata(:,20));
%%compute parameter for antero-posterior direction
sin_ap1=cell2mat(platformdata(:,9));
sin_ap=sin_ap1(interval(:,1)==1,1);
angle_ap=angle_matrix(interval(:,1)==1,[ap1,ap2,ap3]);

for a=1:size(angle_ap,2)
x=fft(sin_ap);
xx=abs(x) ;
[max_sin ix]=max(xx) ;
y(:,a)=fft(angle_ap(:,a));
yy(:,a)=abs(y(:,a));
max_ss(:,a)=yy(ix,a);
G_ap(:,a)=(max_ss(:,a)/max_sin)*100;
phase_sin=atan2(imag(x),real(x))*180/pi; 
phase_sin_max=phase_sin(ix); 
phase_ss(:,a)=atan2(imag(y(:,a)),real(y(:,a)))*180/pi; 
phase_ss_max(:,a)=phase_ss(ix,a); 
phi_ap(:,a)=phase_ss_max(:,a)-phase_sin_max;
end

clear x xx y yy max_sin ix max_ss phase_sin phase_sin_max phase_ss phase_ss_max

%%compute parameter for medio-lateral direction

sin_ml1=cell2mat(platformdata(:,10));
sin_ml=sin_ml1(interval(:,1)==2,1);
angle_ml=angle_matrix(interval(:,1)==2,[ml1,ml2,ml3]);



for a=1:size(angle_ml,2)
x=fft(sin_ml);
xx=abs(x) ;
[max_sin ix]=max(xx) ;
y(:,a)=fft(angle_ml(:,a));
yy(:,a)=abs(y(:,a));
max_ss(:,a)=yy(ix,a);
G_ml(:,a)=(max_ss(:,a)/max_sin)*100;
phase_sin=atan2(imag(x),real(x))*180/pi; 
phase_sin_max=phase_sin(ix); 
phase_ss(:,a)=atan2(imag(y(:,a)),real(y(:,a)))*180/pi; 
phase_ss_max(:,a)=phase_ss(ix,a); 
phi_ml(:,a)=phase_ss_max(:,a)-phase_sin_max;
end

clear x xx y yy max_sin ix max_ss phase_sin phase_sin_max phase_ss phase_ss_max

%%compute parameter for vertical direction

sin_v1=cell2mat(platformdata(:,11));
sin_v=sin_v1(interval(:,1)==3,1);
angle_v=angle_matrix(interval(:,1)==3,[v1,v2,v3]);

for a=1:size(angle_v,2)
x=fft(sin_v);
xx=abs(x) ;
[max_sin ix]=max(xx) ;
y(:,a)=fft(angle_v(:,a));
yy(:,a)=abs(y(:,a));
max_ss(:,a)=yy(ix,a);
G_v(:,a)=(max_ss(:,a)/max_sin)*100;
phase_sin=atan2(imag(x),real(x))*180/pi; 
phase_sin_max=phase_sin(ix); 
phase_ss(:,a)=atan2(imag(y(:,a)),real(y(:,a)))*180/pi; 
phase_ss_max(:,a)=phase_ss(ix,a); 
phi_v(:,a)=phase_ss_max(:,a)-phase_sin_max;
end

clear x xx y yy max_sin ix max_ss phase_sin phase_sin_max phase_ss phase_ss_max
else
 fprintf('You have tried to lunch sinusoidal_routine with a wrong protocol') 
endif


G_i=cat(2, G_ap',G_ml',G_v');
phi_i=cat(2,phi_ap',phi_ml',phi_v');
direction={'AP', 'ML', 'V'}; %%direction acronyms
angle_label2={'haed','trunk','pelvis'}';

[aaa, name, extension]=fileparts(PlatformData);
name2=regexprep(name,'_PlatformData','');
file_id=fopen(strcat(pwd,"/", name2, "_G", ".yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'vector' 'measure unit: %%' \n");
label_str="direction_column: [";
for i=1:length(direction)
  label_str=sprintf("%s",label_str,char(direction(i)));
  if i!=length(direction)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s];\n",label_str);
fprintf(file_id,label_str);

label_str="angle row: [";
for i=1:length(angle_label2)
  label_str=sprintf("%s",label_str,char(angle_label2(i)));
  if i!=length(direction)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s];\n",label_str);
fprintf(file_id,label_str);

g_str="value: [";
for i=1:size(G_i,1)
  for j=1:size(G_i,2)
  g_str=sprintf("%s%.2f",g_str,G_i(i,j));
  if j!=size (G_i,2)
    g_str=sprintf("%s ", g_str);
  elseif j==size (G_i,2) && i==size (G_i,1)
    g_str=sprintf("%s]",g_str);
    else
    g_str=sprintf("%s;\n", g_str);
  endif
endfor
endfor
fprintf(file_id,g_str);
fclose(file_id)


file_id=fopen(strcat(pwd,"/", name2, "_phi", ".yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'vector' 'measure unit: °\' \n");
label_str="direction_column: [";
for i=1:length(direction)
  label_str=sprintf("%s",label_str,char(direction(i)));
  if i!=length(direction)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s];\n",label_str);
fprintf(file_id,label_str);

label_str="angle row: [";
for i=1:length(angle_label2)
  label_str=sprintf("%s",label_str,char(angle_label2(i)));
  if i!=length(direction)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s];\n",label_str);
fprintf(file_id,label_str);

phi_str="value: [";
for i=1:size(phi_i,1)
  for j=1:size(phi_i,2)
  phi_str=sprintf("%s%.2f",phi_str,phi_i(i,j));
  if j!=size (phi_i,2)
    phi_str=sprintf("%s ", phi_str);
  elseif j==size (phi_i,2) && i==size (phi_i,1)
    phi_str=sprintf("%s]",phi_str);
    else
    phi_str=sprintf("%s;\n", phi_str);
  endif
endfor
endfor
fprintf(file_id,phi_str);
fclose(file_id)







