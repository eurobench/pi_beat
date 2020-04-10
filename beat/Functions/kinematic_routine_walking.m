function [mROM CoV]=kinematic_routine_walking(fileName,PlatformData)
% kinematic_routine_walking is a function that gives the kinematic parameters related to the stepping protocols
%Required Octave pkg: signal, statistics, linear-algebra
%[mROM CoV]=kinematic_routine_walking(fileName,PlatformData)
% INPUT:
%       - fileName must be a .csv file with this structure containing joint angle data: 
%         1st column: time-stamp (units: milliseconds).
%         1st row: header with M+1 labels  were  M = number of angles considered.
%         From 2nd row: angle values, each corresponding to one time sample (units: degrees).
%       - PlatformData is a file containing the data extracted by the platform.
% OUTPUT:
%       - mROM is the average ROM across repetitions of the same task or across strides based on the type of protocol. Dimension 2xNa. First line: name of angles, Second line: mROM values
%       - CoV is the variability coefficienty related to the ROM values. Dimension 2xNa. First line: name of angles, Second line: mROM values
%       
% $Author: J. TABORRI, v1 - 03/Apr/2020$ (BEAT project)


data=csv2cell(fileName,";"); 
platformdata=csv2cell(PlatformData, ";")
time_vector_data=cell2mat(data(2:end,1)); %%extract time vector from data
angle_matrix=cell2mat(data(2:end,2:end)); %%extract angle matrix from data
angle_label=data(1,2:end); %extract angle label
angle_number=size(angle_label,2);
time_vector_platform=cell2mat(platformdata(:,1)); %%extract time vector from platformdata

delta_t_angle=diff(time_vector_data,1);
fs_angle=round(1.0/mean(delta_t_angle));
delta_t_platform=diff(time_vector_platform,1);
fs_platform=round(1.0/mean(delta_t_platform))

if (fs_angle~=fs_platform)   
for a=1:angle_number
 angle_matrix(:,a)=resample(angle_matrix(:,a),fs_platform,fs_angle);  %%make two signals with same sampling frequency
end
else
fprintf('Same sample frequency') 
end

%%angle partitioning
 if(platformdata(1,2)==1 || platformdata(1,2)==2) %% 1 and 2 represent the two stepping protocol
event=find(platformdata(:,21)==1); %%21st column of platformdata represents the stride identification performed by the pressure matrix embedded in the platform
else
 fprintf('You have tried to lunch kinematic_routine_walking with a wrong protocol') 
endif

 for e=1:length(event)-1
   for a=1:angle_number
   angle_matrix_part(:,a,e)=eventsnormalize(angle_matrix(:,a),[round(event(e)) round(event(e+1))],101); %%normalize the frames within each event
 end
end  

for i=1:size(angle_matrix_part,3)
  for a=1:angle_number
  ROM(i,a)=abs(max(angle_matrix_part(:,a,i))-min(angle_matrix_part(:,a,i)));  %%compute the range of motion for each stride during the task
  end
end

for a=1:angle_number
  mROM_i(1,a)=mean(ROM(:,a),1); %%mean value of the ROM for each angle across the repetitions of strides or perturbations
  CoV_i(1,a)=std(ROM(:,a))/mean(ROM(:,a),1); %%variability of the ROM across the repetitions of strides or perturbations
end



mROM=cat(1,angle_label,num2cell(mROM_i)); %%add the header line with angle labels
CoV=cat(1,angle_label,num2cell(CoV_i));