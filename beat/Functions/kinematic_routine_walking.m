function [mROM CoV]=kinematic_routine_walking(fileName, PlatformData, outFolder)
% kinematic_routine_walking is a function that gives the kinematic parameters related to the stepping protocols
%Required Octave pkg: signal, statistics, linear-algebra
%[mROM CoV]=kinematic_routine_walking(fileName,PlatformData, outFolder)
% INPUT:
%       - fileName must be a .csv file with this structure containing joint angle data:
%         1st column: time-stamp (units: milliseconds).
%         1st row: header with M+1 labels  were  M = number of angles considered.
%         From 2nd row: angle values, each corresponding to one time sample (units: degrees).
%       - PlatformData is a file containing the data extracted by the platform.
%       - outFolder: folder path where result should be stored
% OUTPUT:
%       - mROM is the average ROM across repetitions of the same task or across strides based on the type of protocol. Labelled matric 2xNa. First row: angle label, Second row: mROM values
%       - CoV is the variability coefficienty related to the ROM values. Labelled matrix 2xNa. First row: angle label, Second row: mROM values
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
fs_platform=round(1.0/mean(delta_t_platform))

if (fs_angle~=fs_platform)
  for a=1:angle_number
    angle_matrix(:,a)=resample(angle_matrix(:,a),fs_platform,fs_angle);  %%make two signals with same sampling frequency
  end
else
  fprintf('Same sample frequency\n')
end

p=find(strcmpi(platformdata_header, 'protocol_number'), 1); %%protocol number column
er=find(strcmpi(platformdata_header, 'right_stride'), 1); %% right_stride column
el=find(strcmpi(platformdata_header, 'left_stride'), 1); %%left_stride column

%%angle partitioning
if(platformdata{2,p}==1 || platformdata{2,p}==2) %% 1 and 2 represent the two stepping protocol
  event_1r=cell2mat(platformdata(2:end,er));
  event_r=find(event_1r==1);
  event_1l=cell2mat(platformdata(2:end,el));
  event_l=find(event_1l==1);
else
  fprintf('You have tried to lunch EMG_routine with a wrong protocol\n')
  fprintf('Provided protocol %d: only accepts protocols 1 and 2\n', platformdata{2,p})
  return;
end

angle_r=find(~cellfun(@isempty,strfind(angle_label,'r_')));
angle_l=find(~cellfun(@isempty,strfind(angle_label,'l_')));

for e=1:length(event_r)-1
  for a=1:length(angle_r)
    angle_matrix_part_r(:,a,e)=eventsnormalize(angle_matrix(:,angle_r(a)),[round(event_r(e)) round(event_r(e+1))],101); %%normalize the frames within each event
  end
end

for ee=1:length(event_l)-1
  for aa=1:length(angle_l)
    angle_matrix_part_l(:,aa,ee)=eventsnormalize(angle_matrix(:,angle_l(aa)),[round(event_l(ee)) round(event_l(ee+1))],101); %%normalize the frames within each event
 end
end

for i=1:size(angle_matrix_part_r,3)
  for a=1:length(angle_r)
    ROM_r(i,a)=abs(max(angle_matrix_part_r(:,a,i))-min(angle_matrix_part_r(:,a,i)));  %%compute the range of motion of right joints for each stride during the task
  end
end

for ii=1:size(angle_matrix_part_l,3)
  for aa=1:length(angle_l)
    ROM_l(ii,aa)=abs(max(angle_matrix_part_l(:,aa,ii))-min(angle_matrix_part_r(:,aa,ii)));  %%compute the range of motion of left joints for each stride during the task
  end
end

for a=1:length(angle_r)
  mROM_i_r(1,a)=mean(ROM_r(:,a),1); %%mean value of the ROM for each angle across the repetitions of strides
  CoV_i_r(1,a)=std(ROM_r(:,a))/mean(ROM_r(:,a),1); %%variability of the ROM across the repetitions of strides
end

for aa=1:length(angle_l)
  mROM_i_l(1,aa)=mean(ROM_l(:,aa),1); %%mean value of the ROM for each angle across the repetitions of strides
  CoV_i_l(1,aa)=std(ROM_l(:,aa))/mean(ROM_l(:,aa),1)*100; %%variability of the ROM across the repetitions of strides
end

mROM=cat(2,mROM_i_r,mROM_i_l);
CoV=cat(2,CoV_i_r,CoV_i_l);
angle_label2=cat(2,angle_label(angle_r),angle_label(angle_l));

%%save mROM value in .yaml file
file_id = fopen(strcat(outFolder, "/pi_mrom.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'labelled_matrix'\n");
fprintf(file_id, "measure_unit: '°\'\n");
label_str="value: [[";
for i=1:size(angle_label2,2)
  label_str=sprintf("%s'%s'",label_str,char(angle_label2(i)));
  if i!=size (angle_label2,2)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s],\n",label_str);
fprintf(file_id,label_str);
rom_str="        [";
for i=1:size(mROM,2)
  rom_str=sprintf("%s%.1f",rom_str,mROM(i));
  if i!=size (mROM,2)
    rom_str=sprintf("%s, ", rom_str);
  endif
endfor
rom_str=sprintf("%s]]\n",rom_str);
fprintf(file_id,rom_str);
fclose(file_id);


%%save CoV value in .yaml file
file_id=fopen(strcat(outFolder,"/pi_cov.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'labelled_matrix'\n");
fprintf(file_id, "measure_unit: '%%'\n");
label_str="value: [[";
for i=1:size(angle_label2,2)
  label_str=sprintf("%s'%s'",label_str,char(angle_label2(i)));
  if i!=size (angle_label2,2)
    label_str=sprintf("%s, ", label_str);
  endif
endfor
label_str=sprintf("%s],\n",label_str);
fprintf(file_id,label_str);
cov_str="        [";
for i=1:size(CoV,2)
  cov_str=sprintf("%s%.1f",cov_str,CoV(i));
  if i!=size (CoV,2)
    cov_str=sprintf("%s, ", cov_str);
  endif
endfor
cov_str=sprintf("%s]]\n",cov_str);
fprintf(file_id,cov_str);
fclose(file_id);