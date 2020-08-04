function [ROM_p]=kinematic_routine_perturbation(fileName,PlatformData, outFolder)
% kinematic_routine_perturbation is a function that gives the kinematic parameters related to step perturbations protocols.
%Required Octave pkg: signal, statistics, linear-algebra
%[ROM_p]=kinematic_routine_perturbation(fileName,PlatformData,outFolder)
% INPUT:
%       - fileName must be a .csv file with this structure containing joint angle data:
%         1st column: time-stamp (units: milliseconds).
%         1st row: header with M+1 labels  were  M = number of angles considered.
%         From 2nd row: angle values, each corresponding to one time sample (units: degrees).
%       - PlatformData is a file containing the data extracted by the platform.
%	- outFolder: folder path where result should be stored
% OUTPUT:
%       - ROM_p is the ROM value along each direction of the perturbation. Dimension 9xNa. First row: angle labes, From second to 8th row ROMp values, with each row related to one perturbation direction following the fixed sequence: North, North-East, East, South-East, South, South-West, West, North-West.
%
% $Author: J. TABORRI, v1 - 03/Apr/2020$ (BEAT project)

data=csv2cell(fileName,";");
platformdata=csv2cell(PlatformData, ";");
platformdata_header=platformdata(1,:);
time_vector_data=cell2mat(data(2:end,1)); %%extract time vector from data
angle_matrix=cell2mat(data(2:end,2:end)); %%extract angle matrix from data
angle_label=data(1,2:end); %extract angle label
angle_number=size(angle_label,2);
time_vector_platform=cell2mat(platformdata(2:end,1)); %%extract time vector from platformdata

delta_t_angle=diff(time_vector_data,1);
fs_angle=round(1.0/mean(delta_t_angle));
delta_t_platform=diff(time_vector_platform,1);
fs_platform=round(1.0/mean(delta_t_platform));

if (fs_angle~=fs_platform)
  for a=1:angle_number
    angle_matrix(:,a)=resample(angle_matrix(:,a),fs_platform,fs_angle);  %%make two signals with same sampling frequency
  end
else
  fprintf('Same sample frequency\n')
endif

p=find(strcmpi(platformdata_header, 'protocol_number'), 1); %%protocol number column
per_dir=find(strcmpi(platformdata_header, 'pert_direction'), 1); %% perturbation_direction column
el=find(strcmpi(platformdata_header, 'left_stride'), 1); %%left_stride column

%%angle partitioning
if(platformdata{2,p}==5 || platformdata {2,p}==6) %% 5 and 6 represent the step perturbation protocols
  dir_1=cell2mat(platformdata(2:end,per_dir));
  dir=find(diff(dir_1)==1);
else
  fprintf('You have tried to lunch kinematic_routine_perturbation with a wrong protocol\n')
  fprintf('Provided protocol: %d, only accepts protocols 5 and 6\n', platformdata{2,p})
  return;
endif

for d=1:length(dir)-1
  for a=1:angle_number
    dd=dir(2)-dir(1);
    angle_matrix_part(:,a,d)=eventsnormalize(angle_matrix(:,a),[round(dir(d)) round(dir(d+1))],dd); %%normalize the frames within each direction
  end
end

for i=1:size(angle_matrix_part,3)
  for a=1:angle_number
    ROM(1,a,i)=abs(max(angle_matrix_part(:,a,i))-min(angle_matrix_part(:,a,i)));  %%compute the range of motion for each stride/event during the task
  end
end

ROM_p=permute(ROM,[3,2,1]);

%%save ROMp value in .yaml file
file_id=fopen(strcat(outFolder,"/pi_romp.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'labelled_matrix'\n");
fprintf(file_id, "measure_unit: '°'\n");
label_str="value: [[";
for i=1:size(angle_label,2)
  label_str=sprintf("%s'%s'",label_str,char(angle_label(i)));
   if i!=size (angle_label,2)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s],\n",label_str);
fprintf(file_id,label_str);
rom_str="        [";
for i=1:size(ROM_p,1)
  for j=1:size(ROM_p,2)
    rom_str=sprintf("%s%.2f",rom_str,ROM_p(i,j));
      if j!=size (ROM_p,2)
        rom_str=sprintf("%s ", rom_str);
      elseif j==size (ROM_p,2) && i==size (ROM_p,1)
        rom_str=sprintf("%s]]\n",rom_str);
      else
        rom_str=sprintf("%s],\n        [", rom_str);
      endif
  endfor
endfor
fprintf(file_id,rom_str);
fclose(file_id)