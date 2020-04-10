function [NoS]=EMG_routine(fileName,PlatformData)
% EMG_routine is a function that gives the EMG parameters related to stepping protocols.
%Required Octave pkg: signal, statistics, linear-algebra
%
%[NoS]=EMG_routine(fileName,PlatformData)
% INPUT:
%       - fileName must be a .csv file with this structure containing EMG recording: 
%         1st column: time-stamp (units: milliseconds).
%         1st row: k+1 labels, with K = number of muscles.
%         From 2nd row: EMG, each corresponding to one time sample.
%       - PlatformData is a file containing the data extracted from the platform.
% OUTPUT:
%       - NoS represents the number of muscle synergy (integer number)

% $Author: J. TABORRI, v1 - 03/Apr/2020$ (BEAT project)

data=csv2cell(fileName,";"); 
platformdata=csv2cell(PlatformData, ";")

time_vector=cell2mat(data(2:end,1)); %%extract time vector from data
muscle_matrix=cell2mat(data(2:end,2:end)); %%extract muscle matrix from data
muscle_label=data(1,2:end); %extract muscle label
muscle_number=size(muscle_label,2);
time_vector_platform=cell2mat(platformdata(:,1)); %%extract time vector from platformdata

delta_t_muscle=diff(time_vector_data,1);
fs_muscle=round(1.0/mean(delta_t_angle));
delta_t_platform=diff(time_vector_platform,1);
fs_platform=round(1.0/mean(delta_t_platform))

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
fprintf('Same sample frequency') 
 end
 
for m=1:muscle_number
for i=1:length(muscle_matrix_env)
if muscle_matrix_env(i,m)<0
   muscle_matrix_env(i,m)=0; %%negative values due to overshoot of the low pass must be replaced with zero
   end
 end
 end
 


 if(platformdata(1,2)==1 || platformdata(1,2)==2) %% 1 and 2 represent the two stepping protocol
event=find(platformdata(:,21)==1); %%21st column of platformdata represents the stride identification performed by the pressure matrix embedded in the platform
else
 fprintf('You have tried to lunch kinematic_routine with a wrong protocol') 
endif


for e=1:length(event)-1
   for m=1:muscle_number
   muscle_matrix_part(:,m,e)=eventsnormalize(muscle_matrix_env(:,m),[round(event(e)) round(event(e+1))],101); %%normalize the frame within each event before concatening signals
 end
end  

muscle_matrix_conc=muscle_matrix_part(:,:,1);
for c=2:size(muscle_matrix_part,3)
  muscle_matrix_conc=cat(1,muscle_matrix_conc,muscle_matrix_part(:,:,c)); %%data to feed the NMF must be the concatation of all data related to each event
end

for m=1:muscle_number
musclemax=max(muscle_matrix_conc(:,m));
for i=1:length(muscle_matrix_conc)
   muscle_matrix_norm(i,m)= muscle_matrix_conc(i,m)/musclemax; %%obtain a matrix of muscle signals normalized for the maximum amplitude in order to have value from 0 to 1, as requested for application of nnmf
   end
 end
 muscle_matrix_norm=muscle_matrix_norm';
 sy=length(muscle_label); %%maximum number of muscle synergies
 
 for s=2:sy
   sinergia=strcat("Sy",num2str(s));
   
[W.(sinergia), H.(sinergia),iter,HIS]=nmf_bpas(muscle_matrix_norm,s,'MaxIter', 1000);  %%application of nnmf on EMGmatrix
muscle_matrix_recons.(sinergia)=W.(sinergia)*H.(sinergia);  %%EMG data reconstructed by NNMF output
VAF.(sinergia).global=corrcoef(muscle_matrix_norm,muscle_matrix_recons.(sinergia))(1,2)*100; %%compute the global VAF
   for m=1:muscle_number
     VAF.(sinergia).local(m)= corr(muscle_matrix_norm(m,:)',muscle_matrix_recons.(sinergia)(m,:)')*100; %%compute the local VAF
   end
end

for s=2:sy
   sinergia=strcat("Sy",num2str(s));
   
   if VAF.(sinergia).global>=90.0 && sum(VAF.(sinergia).local>=0.75)==muscle_number  %%select number of synergies based on threshold criteria and PI
     NoS=s;
   break
 end
end
