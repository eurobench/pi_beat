function [OS, theta_f, delta_theta] =step_perturbation(PlatformData,outFolder)
% step_perturbation is a function that gives information on how subject reacts under step perturbation with uneven surface. It can be used only with Protocol6
%[OS, theta_f, delta_theta] =step_perturbation(PlatformData,outFolder)
% INPUT:
%       - PlatformData is a file containing the data extracted from the platform.
%	- outFolder: folder path where results should be stored
% OUTPUT:
%       - OS is the overshoot of the platform angle for each direction. It is a labelled matrix 2xN where N is the number directions (8). First row: direction label, second row: index values.
%       - theta_f is the final angular position of the platform for each direction. It is a labelled matrix 2xN where N is the number directions (8). First row: direction label, second row: index values.
%       - delta_theta is the range of the excursion of the angle platform during the last 1.5 s of the task for each direction. It is a labelled matrix 2xN where N is the number directions (8). First row: direction label, second row: index values.

% $Author: J. TABORRI, v1 - 03/Apr/2020$ (BEAT project)


platformdata=csv2cell(PlatformData, ";");
time_vector_platform=cell2mat(platformdata(:,1)); %%extract time vector from platformdata
platform_angle=cell2mat(platformdata(:,[9,10])); %%column 9 and 10 contain the angle of the platform in x and y direction
imposed_angle=cell2mat(platformdata(:,22)); %%column 22 contains the value of the imposed perturbation
delta_t_platform=diff(time_vector_platform,1);
fs_platform=round(1.0/mean(delta_t_platform));
t=round(1.5*fs_platform); %variable need to cut the last 1.5 s of the angle for computation of delta_theta

if platformdata{1,2} ==6 %%6 represents the step perturbation protocol with uneven surface
  dir_1=cell2mat(platformdata(:,20)); %%20th column of platformdata contains perturbation direction
  dir=find(diff(dir_1)==1);
else
  fprintf('You have tried to lunch step_perturbation with a wrong protocol') 
endif

for d=1:length(dir)-1
  angle_platform=acos(cos(platform_angle(dir(d):dir(d+1),1)).*cos(platform_angle(dir(d):dir(d+1),2)))*57.3;
  OS_i(d)= max(angle_platform)-max(imposed_angle(dir(d):dir(d+1),1)); %%compute overshoot for each direction with respect the imposed perturbation
  theta_f_i(d)=mean(angle_platform(length(angle_platform)-50:end));
  delta_theta_i(d)=abs(max(angle_platform(length(angle_platform)-t:end))-min(angle_platform(length(angle_platform)-t:end)));
endfor
direction={'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}; %%direction label

%save file
file_id=fopen(strcat(outFolder,"/pi_os.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'labelled_matrix'\n");
fprintf(file_id, "measure unit: '°\'\n");
label_str="value: [[";
for i=1:length(direction)
  label_str=sprintf("%s '%s'",label_str,char(direction(i)));
  if i!=length(direction)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s],\n",label_str);
fprintf(file_id,label_str);
os_str="        [";
for i=1:length(OS_i)
  os_str=sprintf("%s%.3f",os_str,OS_i(i));
  if i!=length(OS_i)
    os_str=sprintf("%s, ", os_str);
  endif
endfor
os_str=sprintf("%s]]\n",os_str);
fprintf(file_id,os_str);
fclose(file_id)

file_id=fopen(strcat(outFolder,"/pi_thetaf.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'labelled_matrix'\n");
fprintf(file_id, "measure unit: '°\'\n");
label_str="value: [[";
for i=1:length(direction)
  label_str=sprintf("%s '%s'",label_str,char(direction(i)));
  if i!=length(direction)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s],\n",label_str);
fprintf(file_id,label_str);
theta_f_str="        [";
for i=1:length(theta_f_i)
  theta_f_str=sprintf("%s%.3f",theta_f_str,theta_f_i(i));
  if i!=length(theta_f_i)
    theta_f_str=sprintf("%s, ", theta_f_str);
  endif
endfor
theta_f_str=sprintf("%s]]\n",theta_f_str);
fprintf(file_id,theta_f_str);
fclose(file_id)

file_id=fopen(strcat(outFolder,"/pi_deltatheta.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'labelled_matrix'\n");
fprintf(file_id, "measure unit: '°\'\n");
label_str="value: [[";
for i=1:length(direction)
  label_str=sprintf("%s '%s'",label_str,char(direction(i)));
  if i!=length(direction)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s],\n",label_str);
fprintf(file_id,label_str);
delta_theta_str="        [";
for i=1:length(delta_theta_i)
  delta_theta_str=sprintf("%s%.3f",delta_theta_str,delta_theta_i(i));
  if i!=length(delta_theta_i)
    delta_theta_str=sprintf("%s, ", delta_theta_str);
  endif
endfor
delta_theta_str=sprintf("%s]]\n",delta_theta_str);
fprintf(file_id,delta_theta_str);
fclose(file_id)