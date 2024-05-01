close all
rng(45);
app = [];
app.Pam_sim = [];
marks = ["o","pentagram","square","diamond","*","^","+","hexagram",".","x","_","|","v","<",">"];
lines = ["-","--",":","-."];

if (isunix) % working in UNIX env.
    DATA_PATH_NAME = 'Outputs/CNN/';
else % working in Windows env.
    DATA_PATH_NAME = 'Outputs\CNN\';
end

Files = dir(DATA_PATH_NAME+"*.mat");
numfiles = length(Files);
mydata = cell(1, numfiles);
for k = 1:numfiles
    mydata{k} = Files(k).name;
end

interval = 1:1:8; % Number of CNN Models 
app.Pam_sim.models = string(interval);
app.Pam_sim = Variable_Generation(app.Pam_sim,'CNN','',false); %Create a varibles CNN_1 CNN_2

Plot_Channel = "TDL-B"; 
Plot_Vel = "30";
aux = [];
label = [];
Styles = [];

for k = interval
 app.Pam_sim.("CNN"+string(k)) = load(DATA_PATH_NAME+"CNN_"+string(k)+"_"+Plot_Channel+"_Vel_"+Plot_Vel+".mat").Parameters;
 aux = [aux ;app.Pam_sim.("CNN"+string(k))];
 label = [label, "CNN"+string(k)];
 Styles = [Styles string(lines(randi(length(lines))))+string(marks(k))];
end

label = [label,"Perfect"];


%% Gráficas de cada cosa
figure
% lh =legend();
x = app.Pam_sim.CNN1.SNR_Recorridas;
l = tiledlayout(2,2);
sgtitle('Condiciones de canal '+Plot_Channel+' a '+Plot_Vel+ 'km/h')

for k=interval
    
    nexttile(l,1)
    %% MSE
    plot(x, app.Pam_sim.("CNN"+string(k)).Mat_CNN_MSE,Styles(k),LineWidth=1.5);
    hold on; grid on; 
    title('Gráfica de MSE') ; xlabel('SNR (dB)'); ylabel('MSE');
    xticks([0:1:25]); yticks([0:0.01:1]); 
    %% BER
    nexttile(l,2)
    plot(x, app.Pam_sim.("CNN"+string(k)).Mat_CNN_BER,Styles(k), LineWidth=1.5)
    yscale log; hold on; grid on;
    title('Gráfica de BER');xlabel('SNR (dB)');ylabel('BER');
    set(gca,'xminorgrid','on','yminorgrid','on');
    
    %% EVM
    nexttile(l,3)
    plot(x, app.Pam_sim.("CNN"+string(k)).Mat_CNN_EVM,Styles(k), LineWidth=1.5)
    hold on; grid on;
    title('Gráfica de EVM');xlabel('SNR (dB)');ylabel('EVM(%)');
    set(gca,'xminorgrid','on','yminorgrid','on');
    xticks([0:1:25]); yticks([0:2:50]); 
    %% Time
    nexttile(l,4)
    plot(x, (app.Pam_sim.("CNN"+string(k)).Mat_CNN_Time)./(app.Pam_sim.CNN1.Mat_Perfect_Time),Styles(k), LineWidth=1.5);
    title('Tiempo Estimacion');xlabel('SNR (dB)'); ylabel('Estimacion (ms)');
    hold on; grid on;
    xticks([0:1:25]); yticks([0:1:21]); 
    set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
end

%% BER
nexttile(l,2)
hold on;plot(x, app.Pam_sim.CNN1.Mat_Perfect_BER,'k', LineWidth=1.5);
%% EVM
nexttile(l,3)
hold on;plot(x, app.Pam_sim.CNN1.Mat_Perfect_EVM,'k', LineWidth=1.5);
%% Time
nexttile(l,4)
hold on;plot(x, ((app.Pam_sim.CNN1.Mat_Perfect_Time)./(app.Pam_sim.CNN1.Mat_Perfect_Time)),'k', LineWidth=1.5);

lgd = legend(label);
lgd.Layout.Tile = 'east';
