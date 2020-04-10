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
platformdata=csv2cell(PlatformData, ";")
time_vector_data=cell2mat(data(2:end,1)); %%extract time vector from data
angle_matrix=cell2mat(data(2:end,2:end)); %%extract angle matrix from data
angle_label=data(1,:); %extract angle label
angle_number=size(angle_label,2);
time_vector_platform=cell2mat(platformdata(:,1)); %%extract time vector from platformdata

delta_t_angle=diff(time_vector_data,1);
fs_angle=round(1.0/mean(delta_t_angle));
delta_t_platform=diff(time_vector_platform,1);
fs_platform=round(1.0/mean(delta_t_platform))

ap1=find(angle_label='head_obliquity');
ap2=find(angle_label='thorax_obliquity');
ap3=find(angle_label='pelvic_obliquity');

ml1=find(angle_label='head_rotation');
ml2=find(angle_label='thorax_rotation');
ml3=find(angle_label='pelvic_rotation');

v1=find(angle_label='head_tilt');
v2=find(angle_label='thorax_tilt');
v3=find(angle_label='pelvic_tilt');

if (fs_angle~=fs_platform)   
for a=1:angle_number
 angle_matrix(:,a)=resample(angle_matrix(:,a),fs_platform,fs_angle);  %%make two signals with same sampling frequency
end
else
fprintf('Same sample frequency') 
endif

 if platformdata(1,2)==7 %%  7 represents the sinusoidal perturbation protocol

%%compute parameter for antero-posterior direction

sin_ap=platformdata((platformdata(:,20)==1,8);
angle_ap=angle_matrix((platformdata(:,20)==1,[ap1,ap2,ap3]);

for a=1:size(angle_ap,2)
x=fft(sin_ap)
xx=abs(x) 
[max_sin ix]=max(xx) 
y(:,a)=fft(angle_ap(:,a))
yy(:,a)=abs(y(:,a))
max_ss(:,a)=yy(ix,a)
G_ap(:,a)=(max_ss(:,a)/max_sin)*100;
phase_sin=atan2(imag(x),real(x))*180/pi; 
phase_sin_max=phase_sin(ix); 
phase_ss(:,a)=atan2(imag(y(:,a)),real(y(:,a)))*180/pi; 
phase_ss_max(:,a)=phase_ss(ix,a); 
phi_ap(:,a)=phase_ss_max(:,a)-phase_sin_max;
end

clear x xx y yy max_sin ix max_ss phase_sin phase_sin_max phase_ss phase_ss_max

%%compute parameter for medio-lateral direction

sin_ml=platformdata((platformdata(:,20)==2,8);
angle_ml=angle_matrix((platformdata(:,20)==2,[ml1,ml2,ml3]);

for a=1:size(angle_ml,2)
x=fft(sin_ml)
xx=abs(x) 
[max_sin ix]=max(xx) 
y(:,a)=fft(angle_ml(:,a))
yy(:,a)=abs(y(:,a))
max_ss(:,a)=yy(ix,a)
G_ml(:,a)=(max_ss(:,a)/max_sin)*100;
phase_sin=atan2(imag(x),real(x))*180/pi; 
phase_sin_max=phase_sin(ix); 
phase_ss(:,a)=atan2(imag(y(:,a)),real(y(:,a)))*180/pi; 
phase_ss_max(:,a)=phase_ss(ix,a); 
phi_ml(:,a)=phase_ss_max(:,a)-phase_sin_max;
end

clear x xx y yy max_sin ix max_ss phase_sin phase_sin_max phase_ss phase_ss_max

%%compute parameter for vertical direction

sin_v=platformdata((platformdata(:,20)==3,8);
angle_v=angle_matrix((platformdata(:,20)==3,[v1,v2,v3]);

for a=1:size(angle_v,2)
x=fft(sin_v)
xx=abs(x) 
[max_sin ix]=max(xx) 
y(:,a)=fft(angle_v(:,a))
yy(:,a)=abs(y(:,a))
max_ss(:,a)=yy(ix,a)
G_v(:,a)=(max_ss(:,a)/max_sin)*100;
phase_sin=atan2(imag(x),real(x))*180/pi; 
phase_sin_max=phase_sin(ix); 
phase_ss(:,a)=atan2(imag(y(:,a)),real(y(:,a)))*180/pi; 
phase_ss_max(:,a)=phase_ss(ix,a); 
phi_v(:,a)=phase_ss_max(:,a)-phase_sin_max;
end

clear x xx y yy max_sin ix max_ss phase_sin phase_sin_max phase_ss phase_ss_max
else
 fprintf('You have tried to lunch kinematic_routine_walking with a wrong protocol') 
endif


G_i=cat(2, G_ap',G_ml',G_v');
phi_i=cat(2,phi_ap',phi_ml',phi_v');
direction={'AP', 'ML', 'V'}; %%direction acronyms
G_d=cat(1,direction,num2cell(G_i)); %%add the header line with direction label
phi_d=cat(1,direction,num2cell(phi_i)); %%add the header line with direction label


angle_label2={'NaN','haed','trunk','pelvis'}';
G=cat(2,angle_label2, G_d); %%add the firts column as the angle label
phi=cat(2,angle_label2, phi_d); %%add the firts column as the angle label



