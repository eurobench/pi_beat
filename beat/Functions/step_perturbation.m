function [OS, theta_f, delta_theta] =step_perturbation(PlatformData)
% step_perturbation is a function that gives the overshoot of the platform angle when a step input is imposed. It can be used onlu with Protocol6
%[OS, theta_f, delta_theta] =step_perturbation(PlatformData)
% INPUT:
%       - PlatformData is a file containing the data extracted from the platform.
% OUTPUT:
%       - OS is the overshoot of the platform angle for each direction. It is a cell 2xN where N is the number directions (8). First row: direction label, second row: index values.  The eight directions are: North (N), North-East (NE), East (E), South-East (SE), South (S), South-West (SW), West (W), NorthWest (NW).
%       - theta_f is the final angular position of the platform for each direction. It is a cell 2xN where N is the number directions (8). First row: direction label, second row: index values.  The eight directions are: North (N), North-East (NE), East (E), South-East (SE), South (S), South-West (SW), West (W), NorthWest (NW).
%       - delta_theta is the range of the excursion of the angle platform during the last 1.5 s of the task for each direction. It is a cell 2xN where N is the number directions (8). First row: direction label, second row: index values.  The eight directions are: North (N), North-East (NE), East (E), South-East (SE), South (S), South-West (SW), West (W), NorthWest (NW).

% $Author: J. TABORRI, v1 - 03/Apr/2020$ (BEAT project)


platformdata=csv2cell(PlatformData, ";")
time_vector_platform=cell2mat(platformdata(:,1)); %%extract time vector from platformdata
delta_t_platform=diff(time_vector_platform,1);
fs_platform=round(1.0/mean(delta_t_platform))

t=round(1.5*fs_platform); %variable need to cut the last 1.5 s of the angle for computation of delta_theta

 if platformdata(1,2)==6 %%  6 represents the step perturbation protocol with uneven surface
dir=find(diff(platformdata(:,20)==1)); %%20th column of platformdata contains perturbation direction
else
 fprintf('You have tried to lunch kinematic_routine_walking with a wrong protocol') 
endif

for d=1:length(dir)-1
  angle_platform=acos(cos(platformdata((dir(d):dir(d+1),9))*cos(platformdata((dir(d):dir(d+1),10)))*57.3  %%column 9 and 10 contain the angle of the platform in x and y direction
 OS_i(d)= max(angle_platform)-max(platformdata((dir(d):dir(d+1),22))); %%compute overshoot for each direction with respect the imposed perturbation saved in the column 22
 theta_f_i(d)=mean(angle_platform(length(angle_platform)-50:end));
 delta_theta_i(d)=abs(max(angle_platform(length(angle_platform)-t:end))-min(angle_platform(length(angle_platform)-t:end)));
end

direction={'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}; %%direction acronyms

OS=cat(1,direction,num2cell(OS_i)); %%add the header line with direction label
theta_f=cat(1,direction,num2cell(theta_f_i)); %%add the header line with direction label
delta_theta=cat(1,direction,num2cell(delta_theta_i)); %%add the header line with direction label