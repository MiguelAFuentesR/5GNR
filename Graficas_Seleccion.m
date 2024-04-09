close all
rng(45);
app = [];
app.Pam_sim = [];
marks = ["o","pentagram","square","diamond","*","^","+","hexagram",".","x","_","|","v","<",">"];
lines = ["-","--",":","-."];

%% ############### CHANGE THIS SECTION ###############################
Network = "Autoencoder";
Plot_Channel = "TDL-E"; 
Plot_Vel = "15";
%% ##############################################################

aux = [];
label = [];
Styles = [];
switch Network
    case "CNN"
        interval = 1:1:8; % Number of CNN Models 
    case "Autoencoder"   
        interval = 1:1:3; % Number of CNN Models 
end


if (isunix) % working in UNIX env.
    DATA_PATH_NAME = 'Outputs/'+Network+'/';
else % working in Windows env.
    DATA_PATH_NAME = 'Outputs\'+Network+'\';
end

Files = dir(DATA_PATH_NAME+"*.mat");
numfiles = length(Files);
mydata = cell(1, numfiles);
for k = 1:numfiles
    mydata{k} = Files(k).name;
end

app.Pam_sim.models = string(interval);
app.Pam_sim = Variable_Generation(app.Pam_sim,convertStringsToChars(Network),'',false); %Create a varibles CNN_1 CNN_2

for k = interval
 app.Pam_sim.(Network+string(k)) = load(DATA_PATH_NAME+Network+"_"+string(k)+"_"+Plot_Channel+"_Vel_"+Plot_Vel+".mat").Parameters;
 aux = [aux ;app.Pam_sim.(Network+string(k))];
 label = [label, Network+string(k)];
 Styles = [Styles string(lines(randi(length(lines))))+string(marks(k))];
end

label = [label,"Perfect"];


%% Gráficas de cada cosa
figure
% lh =legend();

l = tiledlayout(2,2);
sgtitle('Condiciones de canal '+Plot_Channel+' a '+Plot_Vel+ 'km/h '+'estimado con '+Network)

for k=interval
    x = app.Pam_sim.(Network+string(k)).SNR_Recorridas;
    nexttile(l,1)
    %% MSE
    plot(x, app.Pam_sim.(Network+string(k)).("Mat_"+Network+"_MSE"),Styles(k),LineWidth=1.5);
    hold on; grid on; 
    title('Gráfica de MSE') ; xlabel('SNR (dB)'); ylabel('MSE');
    xticks([0:1:25]); yticks([0:0.01:1]); 
    %% BER
    nexttile(l,2)
    plot(x, app.Pam_sim.(Network+string(k)).("Mat_"+Network+"_BER"),Styles(k), LineWidth=1.5)
    yscale log; hold on; grid on;
    title('Gráfica de BER');xlabel('SNR (dB)');ylabel('BER');
    set(gca,'xminorgrid','on','yminorgrid','on');   
    %% EVM
    nexttile(l,3)
    plot(x, app.Pam_sim.(Network+string(k)).("Mat_"+Network+"_EVM"),Styles(k), LineWidth=1.5)
    hold on; grid on;
    title('Gráfica de EVM');xlabel('SNR (dB)');ylabel('EVM(%)');
    set(gca,'xminorgrid','on','yminorgrid','on');
    xticks([0:1:25]); yticks([0:2:50]); 
    %% Time
    nexttile(l,4)
    %(app.Pam_sim.(Network+string(k)).("Mat_"+Network+"_Time"))
    %plot(x, (app.Pam_sim.(Network+string(k)).("Mat_"+Network+"_Time")),Styles(k), LineWidth=1.5);

    plot(x, (app.Pam_sim.(Network+string(k)).("Mat_"+Network+"_Time"))./(app.Pam_sim.(Network+string(k)).Mat_Perfect_Time),Styles(k), LineWidth=1.5);
    title('Tiempo Estimacion');xlabel('SNR (dB)'); ylabel('Estimacion (ms)');
    hold on; grid on;
    xticks([0:1:25]); yticks([0:1.5:40]); 
    set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
end

%% BER
nexttile(l,2)
hold on;plot(x, app.Pam_sim.(Network+string(1)).Mat_Perfect_BER,'k', LineWidth=1.5);
%% EVM
nexttile(l,3)
hold on;plot(x, app.Pam_sim.(Network+string(1)).Mat_Perfect_EVM,'k', LineWidth=1.5);
%% Time
nexttile(l,4)
hold on;plot(x, ((app.Pam_sim.(Network+string(1)).Mat_Perfect_Time)./(app.Pam_sim.(Network+string(1)).Mat_Perfect_Time)),'k', LineWidth=1.5);
%hold on;plot(x, ((app.Pam_sim.(Network+string(1)).Mat_Perfect_Time),'k', LineWidth=1.5);

lgd = legend(label);
lgd.Layout.Tile = 'east';
