function [NoS_r NoS_l]=EMG_routine(fileName,PlatformData, outFolder)
% EMG_routine is a function that gives the number of synergies for both right and left body side in stepping protocols.
%Required Octave pkg: signal, statistics, linear-algebra
%
%[NoS_r NoS_l]=EMG_routine(fileName,PlatformData,outFolder)
% INPUT:
%       - fileName must be a .csv file with this structure containing EMG recording:
%         1st column: time-stamp (units: milliseconds).
%         1st row: k+1 labels, with K = number of muscles.
%         From 2nd row: EMG, each corresponding to one time sample.
%       - PlatformData is a file containing the data extracted from the platform.
%	- outFolder: folder path where result should be stored
% OUTPUT:
%       - NoS_r represents the number of muscle synergies (integer number) for right side
%	- NoS_l represents the number of muscle synergies (integer number) for left side
%
% $Author: J. TABORRI, v1 - 03/Apr/2020$ (BEAT project)

data=csv2cell(fileName,";");
platformdata=csv2cell(PlatformData, ";");
platformdata_header=platformdata(1,:);
time_vector=cell2mat(data(2:end,1)); %%extract time vector from data
muscle_matrix=cell2mat(data(2:end,2:end)); %%extract muscle matrix from data
muscle_label=data(1,2:end); %extract muscle label
muscle_number=size(muscle_label,2);
time_vector_platform=cell2mat(platformdata(2:end,1)); %%extract time vector from platformdata

delta_t_muscle=diff(time_vector,1);
fs_muscle=round(1.0/mean(delta_t_muscle));
delta_t_platform=diff(time_vector_platform,1);
fs_platform=round(1.0/mean(delta_t_platform));

hp_freq=35; %%cut-off high-oass filter
hp_order=5; %%filter order
[b_high a_high]=butter(hp_order,hp_freq/(fs_muscle/2), 'high'); %%extract parameters for hp application, fs must be fs2 if a resmaple is needed
[b_notch a_notch]=pei_tseng_notch(50/fs_muscle, 2/fs_muscle); %%extract parameters for notch filter, fs must be fs2 if a resmaple is needed
lp_freq=4; %%cut-off low-pass filter
lp_order=5; %%filter order
[b_low a_low]=butter(lp_order,lp_freq/(fs_muscle/2), 'low'); %%extract parameters for lp application, fs must be fs2 if a resmaple is needed

for m=1:muscle_number
  muscle_matrix_deamened(:,m)=detrend(muscle_matrix(:,m),'constant'); %%remove constant signal
  muscle_matrix_hp(:,m)=filtfilt(b_high,a_high, muscle_matrix_deamened(:,m)); %%application of high pass filter to remove noise
  muscle_matrix_notch(:,m)=filtfilt(b_notch,a_notch, muscle_matrix_hp(:,m)); %%application of notch filter to remove 50 Hz
  muscle_matrix_rect(:,m)=abs(muscle_matrix_notch(:,m)); %%recticleafication of signals
  muscle_matrix_env(:,m)=filtfilt(b_low,a_low, muscle_matrix_rect(:,m)); %%envelope extraction
end

if (fs_muscle~=fs_platform)
  muscle_matrix_env=resample(muscle_matrix_env,fs_platform,fs_muscle);
else
  fprintf('Same sample frequency\n')
end

for m=1:muscle_number
  for i=1:length(muscle_matrix_env)
    if muscle_matrix_env(i,m)<0
     muscle_matrix_env(i,m)=0; %%negative values due to overshoot of the low pass must be replaced with zero
    end
  end
end

p=find(strcmpi(platformdata_header, 'protocol_number'), 1); %%protocol number column
er=find(strcmpi(platformdata_header, 'right_stride'), 1); %% right_stride column
el=find(strcmpi(platformdata_header, 'left_stride'), 1); %%left_stride column


if(platformdata{2,p}==1 || platformdata{2,p}==2) %% 1 and 2 represent the two stepping protocol
  event_1r=cell2mat(platformdata(2:end,er));
  event_r=find(event_1r==1);
  event_1l=cell2mat(platformdata(2:end,el));
  event_l=find(event_1l==1);
else
  fprintf('You have tried to lunch EMG_routine with a wrong protocol\n')
  fprintf('Provided protocol %d: only accepts protocols 1 and 2\n', platformdata{2,p})
  return;
endif

muscle_r=find(~cellfun(@isempty,strfind(muscle_label,'_r')));
muscle_l=find(~cellfun(@isempty,strfind(muscle_label,'_l')));

for e=1:length(event_r)-1
  for m=1:length(muscle_r)
    muscle_matrix_part_r(:,m,e)=eventsnormalize(muscle_matrix_env(:,muscle_r(m)),[round(event_r(e)) round(event_r(e+1))],101); %%normalize the frame within each event before concatening signals
  end
end

for ee=1:length(event_l)-1
  for mm=1:length(muscle_l)
    muscle_matrix_part_l(:,mm,ee)=eventsnormalize(muscle_matrix_env(:,muscle_l(mm)),[round(event_l(ee)) round(event_l(ee+1))],101); %%normalize the frame within each event before concatening signals
  end
end

muscle_matrix_conc_r=muscle_matrix_part_r(:,:,1);
muscle_matrix_conc_l=muscle_matrix_part_l(:,:,1);

for c=2:size(muscle_matrix_part_r,3)
   muscle_matrix_conc_r=cat(1,muscle_matrix_conc_r,muscle_matrix_part_r(:,:,c)); %%data to feed the NMF must be the concatation of all data related to each event
end

for c=2:size(muscle_matrix_part_l,3)
   muscle_matrix_conc_l=cat(1,muscle_matrix_conc_l,muscle_matrix_part_l(:,:,c)); %%data to feed the NMF must be the concatation of all data related to each event
end

for m=1:length(muscle_r)
  musclemax=max(muscle_matrix_conc_r(:,m));
   for i=1:length(muscle_matrix_conc_r)
     muscle_matrix_norm_r(i,m)= muscle_matrix_conc_r(i,m)/musclemax; %%obtain a matrix of muscle signals normalized for the maximum amplitude in order to have value from 0 to 1, as requested for application of nnmf
   end
end
muscle_matrix_norm_r=muscle_matrix_norm_r';

for mm=1:length(muscle_l)
  musclemax=max(muscle_matrix_conc_l(:,mm));
   for ii=1:length(muscle_matrix_conc_l)
    muscle_matrix_norm_l(ii,mm)= muscle_matrix_conc_l(ii,mm)/musclemax; %%obtain a matrix of muscle signals normalized for the maximum amplitude in order to have value from 0 to 1, as requested for application of nnmf
   end
end
muscle_matrix_norm_l=muscle_matrix_norm_l';

sy_r=length(muscle_r); %%maximum number of muscle synergies
sy_l=length(muscle_l); %%maximum number of muscle synergies

for s=2:sy_r
  sinergia=strcat("Sy",num2str(s));
  [W.(sinergia), H.(sinergia),iter,HIS]=nmf_bpas(muscle_matrix_norm_r,s,'MaxIter', 1000);  %%application of nnmf on EMGmatrix
  muscle_matrix_recons_r.(sinergia)=W.(sinergia)*H.(sinergia);  %%EMG data reconstructed by NNMF output
  VAF.(sinergia).global=corrcoef(muscle_matrix_norm_r,muscle_matrix_recons_r.(sinergia))(1,2)*100; %%compute the global VAF
    for m=1:length(muscle_r)
      VAF.(sinergia).local(m)= corr(muscle_matrix_norm_r(m,:)',muscle_matrix_recons_r.(sinergia)(m,:)')*100; %%compute the local VAF
    end
     if VAF.(sinergia).global>=90.0 && sum(VAF.(sinergia).local>=0.75)==length(muscle_r)  %%select number of synergies based on threshold criteria and PI
      NoS_r=s;
      break
     end
end

for ss=2:sy_l
  sinergia=strcat("Sy",num2str(ss));
  [W.(sinergia), H.(sinergia),iter,HIS]=nmf_bpas(muscle_matrix_norm_l,ss,'MaxIter', 1000);  %%application of nnmf on EMGmatrix
  muscle_matrix_recons_l.(sinergia)=W.(sinergia)*H.(sinergia);  %%EMG data reconstructed by NNMF output
  VAF.(sinergia).global=corrcoef(muscle_matrix_norm_l,muscle_matrix_recons_l.(sinergia))(1,2)*100; %%compute the global VAF
    for mm=1:length(muscle_l)
      VAF.(sinergia).local(mm)= corr(muscle_matrix_norm_l(mm,:)',muscle_matrix_recons_l.(sinergia)(mm,:)')*100; %%compute the local VAF
   end
    if VAF.(sinergia).global>=90.0 && sum(VAF.(sinergia).local>=0.75)==length(muscle_l)  %%select number of synergies based on threshold criteria and PI
     NoS_l=ss;
     break
    end
end

%%save NoS value in .yaml file
file_id=fopen(strcat(outFolder,"/pi_rnos.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'scalar'\n");
fprintf(file_id, "measure_unit: 'adim'\n");
NoS_str="value: ";
NoS_str=sprintf("%s%.f\n",NoS_str,NoS_r);
fprintf(file_id,NoS_str);
fclose(file_id)

file_id=fopen(strcat(outFolder,"/pi_lnos.yaml"),'w'); %%open file to write into
fprintf(file_id, "type: 'scalar'\n");
fprintf(file_id, "measure_unit: 'adim'\n");
NoSl_str="value: ";
NoSl_str=sprintf("%s%.f\n",NoSl_str,NoS_l);
fprintf(file_id,NoSl_str);
fclose(file_id)