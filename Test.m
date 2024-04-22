clc
clear


b_256_ve5 = load("Channel_TDL-B_Mod_256QAM_Vel_5.mat");
b_256_ve30  = load("Channel_TDL-B_Mod_256QAM_Vel_30.mat");
b_256_ve100 = load("Channel_TDL-B_Mod_256QAM_Vel_100.mat");

b_64_ve5 = load("Channel_TDL-B_Mod_64QAM_Vel_5.mat");
b_64_ve30  = load("Channel_TDL-B_Mod_64QAM_Vel_30.mat");
b_64_ve100 = load("Channel_TDL-B_Mod_64QAM_Vel_100.mat");

b_qpsk_ve5 = load("Channel_TDL-B_Mod_QPSK_Vel_5.mat");
b_qpsk_ve30  = load("Channel_TDL-B_Mod_QPSK_Vel_30.mat");
b_qpsk_ve100 = load("Channel_TDL-B_Mod_QPSK_Vel_100.mat");


d_256_ve5 = load("Channel_TDL-D_Mod_256QAM_Vel_5.mat");
d_256_ve30  = load("Channel_TDL-D_Mod_256QAM_Vel_30.mat");
d_256_ve100 = load("Channel_TDL-D_Mod_256QAM_Vel_100.mat");

d_64_ve5 = load("Channel_TDL-D_Mod_64QAM_Vel_5.mat");
d_64_ve30  = load("Channel_TDL-D_Mod_64QAM_Vel_30.mat");
d_64_ve100 = load("Channel_TDL-D_Mod_64QAM_Vel_100.mat");

d_qpsk_ve5 = load("Channel_TDL-D_Mod_QPSK_Vel_5.mat");
d_qpsk_ve30  = load("Channel_TDL-D_Mod_QPSK_Vel_30.mat");
d_qpsk_ve100 = load("Channel_TDL-D_Mod_QPSK_Vel_100.mat");






% Files = dir(fullfile("Outputs/",'**/*.mat*'));
% numfiles = length(Files);
% mydata = cell(1, numfiles);
% Paths = [];
% Files_read = [];
% Coincidencias = [];
% app.Pam_sim.Simulations = [];
% for k = 1:numfiles
%     mydata{k} = Files(k).name;
%     Paths = [Paths string(mydata{k})];
% end
% 
% [~,name,ext] = fileparts(Paths);
% [~,c] = size(name)
% for k = 1:c
%     if find(strfind(name(k),"Channel_TDL-E"))
%         Coincidencias = [Coincidencias k];
%         Files_read = [Files_read Paths(k)];
%     end
% end
% for k = 1:length(Files_read)
%     app.Pam_sim.Simulations = [app.Pam_sim.Simulations load(Files_read(k)).Parameters];
% end
% 
% 


% 
% Files = dir(fullfile("Outputs/",'**/*.mat*'));
% numfiles = length(Files);
% mydata = cell(1, numfiles);
% for k = 1:numfiles
%     mydata{k} = Files(k).folder+"/"+Files(k).name;
% end
% mydata
% app.SelectFileDropDown.Visible = "on";
% app.SelectFileLabel.Visible = "on";
% app.SelectFileDropDown.Items = mydata;
