clear all
clc
close all
rng(45);
app = [];
app = [];
Paths = [];
marks = ["o","pentagram","square","diamond","*","^","+","hexagram",".","x","_","|","v","<",">"];
lines = ["-","--",":","-."];
colors = ["#FC572A","#000000","#00EEBB","#0036EE","#EE00C3","#774747","#7ECD19","#AA731B"];
Line_Width = 1.3;

%% ############### CHANGE THIS SECTION ####################################
 Channels = ["TDL-A","TDL-B","TDL-C","TDL-D","TDL-E"] % All files with this DIRECTORY tag will be read
%Channels = ["TDL-B","TDL-C"]
%% ########################################################################

% Change path in function of the O.S
if (isunix) % working in UNIX env.
    DATA_PATH_NAME_IMG = 'Outputs/Images/';
else % working in Windows env.
    DATA_PATH_NAME_IMG = 'Outputs\Images\';
end
if exist(DATA_PATH_NAME_IMG)
else
    mkdir(DATA_PATH_NAME_IMG)
end

addpath(DATA_PATH_NAME_IMG)


label = [];
Styles = [];
colors_plot = [];

% 
% %% #################### UNCOMMENT THIS SECTION FOR MULTIPLE MODEL GRAPH VELOCITY  ##########################
% 
% Model = "Denoising_2";
% Vel = "30";
% 
% Metricas = ["BER" "EVM" "MSE" "Time"];
% velocity = [5 30 100];
% Fil = 2 ;
% COl = 2 ;
% Mod = ["QPSK"];
% % Mod = ["QPSK" "64QAM" "256QAM" ];
% % Mod = ["QPSK"];
% % Mod = ["64QAM"];
% % Mod = ["256QAM" ];
% 
% 
% 
% % Plot the response of selected metric  for the model select in all
% % channels with the specified modulation and velocity
% 
% %Read Data
% 
% app.Graph_1 = tiledlayout(Fil,COl);
% sgtitle('Resultados del modelo '+Model)
% 
% for i=1:length(Channels)
%     Styles = [Styles string(lines(randi(length(lines))))+string(marks(i))];
%     colors_plot = [colors_plot string(colors(i))];
% end
% 
% 
% 
% for a = 1:1:length(Channels)
%             Path_Type = Channels(a);
%         h = strrep(Channels(a),'-','_')
%         EVM_3D.(h)=[];
%         MSE_3D.(h)=[];
%         BER_3D.(h)=[];
%         Time_3D.(h)=[];
%     for velo = velocity
%         Vel = string(velo);
%         index=[];
% 
% 
%         % For any TDL Channel
%         % Change path in function of the O.S
%         if (isunix) % working in UNIX env.
%             DATA_PATH_NAME_IMG = 'Outputs/Images/';
%             DATA_PATH_NAME = 'Outputs/'+Path_Type+'/';
%         else % working in Windows env.
%             DATA_PATH_NAME_IMG = 'Outputs\Images\';
%             DATA_PATH_NAME = 'Outputs\'+Path_Type+'\';
%         end
%         addpath(DATA_PATH_NAME)
%         %Read All filles with extension .mat
% 
%         Files = dir(DATA_PATH_NAME+"*.mat");
%         numfiles = length(Files);
%         mydata = cell(1, numfiles);
%         for i = 1:numfiles
%             Paths = [Paths string(Files(i).name)];
%         end
%         interval = 1:1:numfiles; % CNN4 CNN6 Autoencoder1  Denoising1 Denoising2 Lineal Practical Ideal
% 
%         for i = interval
% 
%             for modul= 1:length(Mod) %
%                 if Paths(i) == ("Channel_"+Path_Type+"_Mod_"+Mod(modul)+"_Vel_"+Vel+".mat")
%                     disp("Reading "+Paths(i) )
%                     index = [index i];
%                     app.("Simulation_"+string(i)) = load(Paths(i)).Parameters;
%                     label = [label (Path_Type+" "+Mod(modul))+" "+ velo + " km/h"];
%                 end
%             end
% 
%         end
% 
%         disp("Generating Plots for "+Path_Type+" Channel")
%         Number_plot=0;
%         for Metric = Metricas
%             Number_plot = Number_plot+1;
% 
%             for i = index
%                 datos = app.("Simulation_"+string(i));
% 
%                 x = datos.SNR_Recorridas;
%                 y = datos.("Mat_"+Model+"_"+Metric);
% 
%                 disp("Ploting "+Metric+" in plot "+string(Number_plot))
%                 nexttile(app.Graph_1,Number_plot)
%                 set(gcf, 'Position', get(0, 'Screensize'));
%                 [SNR,VEL] = meshgrid(x,velocity);
% 
%                 switch Metric
%                     case "EVM"
%                         EVM_3D.(h) = [EVM_3D.(h);y]
%                         plot(x,y,Styles(a), LineWidth=Line_Width)
%                         hold on
%                         xlabel('SNR (dB)');ylabel("EVM(%)");
%                         set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
%                         xticks([0:1:25]);
%                     case "BER"
%                         BER_3D.(h) = [BER_3D.(h);y];
%                         plot(x,y,Styles(a), LineWidth=Line_Width)
%                         hold on
%                         yscale log;
%                         xlabel('SNR (dB)');ylabel(Metric);
%                         set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
%                         xticks([0:1:25]);
%                     case "MSE"
%                         MSE_3D.(h) = [MSE_3D.(h);y];
%                         plot(x,y,Styles(a), LineWidth=Line_Width)
%                         hold on
%                         xlabel('SNR (dB)');ylabel(Metric);
%                         set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
%                         xticks([0:1:25]);
%                     case "Time"
%                         Time_3D.(h) = [Time_3D.(h);y];
%                         plot(x, y./datos.Mat_Perfect_Time,Styles(a), LineWidth=Line_Width);grid on;
%                         hold on
%                         title('Tiempo de Estimación');xlabel('SNR (dB)'); ylabel('Estimación (ms)');
%                         set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
%                         xticks([0:1:25]);
%                 end
%             end
%         end
% 
% 
%         %exportgraphics(app.("l_"+string(k)),DATA_PATH_NAME_IMG+datos.Channel+"_"+datos.Modulation+"_"+datos.User_Velocity+".png",'Resolution',300)
% 
%         %-----------
%         Paths = [];
%         lgd = legend(label);
%         lgd.Layout.Tile = 'east';
%     end
% end
% 
% figure
% x_3d = fliplr(VEL);
% y_3d =fliplr(EVM_3D.("TDL_C"));
% z_3d =fliplr(BER_3D.("TDL_C"));
% C = fliplr(SNR);
% surf(x_3d,y_3d,z_3d,C)
% 
% set(gca,'ZScale','log')
% shading flat
% xlabel("Velocidad (km/h)")
% ylabel("EVM(%)")
% zlabel("BER")
% 
% view([80 20])
% hcb=colorbar;
% hcb.Title.String = "SNR (dB) TDL C";
% 
% 
% hold on
% x_3d = fliplr(VEL);
% y_3d =fliplr(EVM_3D.("TDL_B"));
% z_3d =fliplr(BER_3D.("TDL_B"));
% C = fliplr(SNR);
% surf(x_3d,y_3d,z_3d,C,'FaceColor',[0.5 0.5 .5])
% hc2=colorbar;
% hcb2.Title.String = "SNR (dB) TDL B";


% %% #################### UNCOMMENT THIS SECTION FOR MULTIPLE MODEL GRAPH ##########################
% 
% Model = "Denoising_2";
% Vel = "30";
% 
% Metricas = ["BER" "EVM" "MSE" "Time"];
% Fil = 2 ;
% COl = 2 ;
% Mod = ["QPSK" "64QAM" "256QAM" ];
% 
% % Plot the response of selected metric  for the model select in all
% % channels with the specified modulation and velocity 
% 
% %Read Data 
% 
% app.Graph_1 = tiledlayout(Fil,COl);
% sgtitle('Resultados del modelo '+Model+' velocidad de '+Vel+'km/h ')
% 
% for i=1:length(Channels)
%     Styles = [Styles string(lines(randi(length(lines))))+string(marks(i))];
%     colors_plot = [colors_plot string(colors(i))];
% end
% for a = 1:1:length(Channels)
%     index=[];
%     Path_Type = Channels(a);
%     % For any TDL Channel
%     % Change path in function of the O.S
%     if (isunix) % working in UNIX env.
%         DATA_PATH_NAME_IMG = 'Outputs/Images/';
%         DATA_PATH_NAME = 'Outputs/'+Path_Type+'/';
%     else % working in Windows env.
%         DATA_PATH_NAME_IMG = 'Outputs\Images\';
%         DATA_PATH_NAME = 'Outputs\'+Path_Type+'\';
%     end
%     addpath(DATA_PATH_NAME)
%     %Read All filles with extension .mat
% 
%     Files = dir(DATA_PATH_NAME+"*.mat");
%     numfiles = length(Files);
%     mydata = cell(1, numfiles);
%     for i = 1:numfiles
%         Paths = [Paths string(Files(i).name)];
%     end
%     interval = 1:1:numfiles; % CNN4 CNN6 Autoencoder1  Denoising1 Denoising2 Lineal Practical Ideal
% 
%     for i = interval
% 
%         for modul= 1:3 % 
%             if Paths(i) == ("Channel_"+Path_Type+"_Mod_"+Mod(modul)+"_Vel_"+Vel+".mat")
%                 disp("Reading "+Paths(i) )
%                 index = [index i];
%                 app.("Simulation_"+string(i)) = load(Paths(i)).Parameters;
%                 label = [label (Path_Type+" "+Mod(modul))];
%             end
%         end
% 
%     end
% 
%     disp("Generating Plots for "+Path_Type+" Channel")
%     Number_plot=0;
%    for Metric = Metricas
%      Number_plot = Number_plot+1;
% 
%     for i = index
%         datos = app.("Simulation_"+string(i));
% 
%         x = datos.SNR_Recorridas;
%         y = datos.("Mat_"+Model+"_"+Metric);
%         disp("Ploting "+Metric+" in plot "+string(Number_plot))
%         nexttile(app.Graph_1,Number_plot)
%         set(gcf, 'Position', get(0, 'Screensize'));
% 
%         switch Metric
%             case "EVM"
%                 plot(x,y,Styles(a), LineWidth=Line_Width)
%                 hold on
%                 xlabel('SNR (dB)');ylabel("EVM(%)");
%                 set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
%                 xticks([0:1:25]);
%             case "BER"
%                 plot(x,y,Styles(a), LineWidth=Line_Width)
%                 hold on
%                 yscale log;
%                 xlabel('SNR (dB)');ylabel(Metric);
%                 set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
%                 xticks([0:1:25]);
%             case "MSE"
%                 plot(x,y,Styles(a), LineWidth=Line_Width)
%                 hold on
%                 xlabel('SNR (dB)');ylabel(Metric);
%                 set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
%                 xticks([0:1:25]);
%             case "Time"
%                 plot(x, y./datos.Mat_Perfect_Time,Styles(a), LineWidth=Line_Width);grid on;
%                 hold on
%                 title('Tiempo de Estimación');xlabel('SNR (dB)'); ylabel('Estimación (ms)');
%                 set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
%                 xticks([0:1:25]);
%         end
%     end
%    end
% 
% 
%     %exportgraphics(app.("l_"+string(k)),DATA_PATH_NAME_IMG+datos.Channel+"_"+datos.Modulation+"_"+datos.User_Velocity+".png",'Resolution',300)
% 
%     %-----------
%     Paths = [];
%     lgd = legend(label);
%     lgd.Layout.Tile = 'east';
% end



 %% #################### UNCOMMENT THIS SECTION FOR ALL CHANNELS MSE,BER,EVM,Time ##########################


for i=1:8
    Styles = [Styles string(lines(randi(length(lines))))+string(marks(i))];
    colors_plot = [colors_plot string(colors(i))];
end

for a = 1:1:length(Channels)

    Path_Type = Channels(a);

    % Change path in function of the O.S
    if (isunix) % working in UNIX env.
        DATA_PATH_NAME_IMG = 'Outputs/Images/';
        DATA_PATH_NAME = 'Outputs/'+Path_Type+'/';
    else % working in Windows env.
        DATA_PATH_NAME_IMG = 'Outputs\Images\';
        DATA_PATH_NAME = 'Outputs\'+Path_Type+'\';
    end
    addpath(DATA_PATH_NAME)
    %Read All filles with extension .mat

    Files = dir(DATA_PATH_NAME+"*.mat");
    numfiles = length(Files);
    mydata = cell(1, numfiles);
    for i = 1:numfiles
        Paths = [Paths string(Files(i).name)];
    end
    interval = 1:1:numfiles; % CNN4 CNN6 Autoencoder1  Denoising1 Denoising2 Lineal Practical Ideal

    for i = interval
        app.("Simulation_"+string(i)) = load(Paths(i)).Parameters;
    end


    label = app.Simulation_1.models;
    label{1,2} = 'Ideal';
    disp("Generating Plots for "+Path_Type+" Channel")
    figure();
    for k= 1:9
        datos = app.("Simulation_"+string(k));
        x = datos.SNR_Recorridas;7

        switch datos.pdsch.Modulation
            case "QPSK"
                Maximo_EVM = 18.5;
            case "16QAM"
                Maximo_EVM = 13.5;
            case "64QAM"
                Maximo_EVM = 9;
            case "256QAM"
                Maximo_EVM = 4.5;
        end
        

        lh =legend();
        app.("l_"+string(k)) = tiledlayout(2,2);

        %sgtitle('Results of the '+datos.Channel+' channel with  '+datos.Modulation+' modulation at '+datos.User_Velocity+ 'km/h ')
        sgtitle('Resultados del canal '+datos.Channel+' con modulación '+datos.Modulation+' y velocidad de '+datos.User_Velocity+ 'km/h ')



        for j=1:length(datos.models)

            nexttile(app.("l_"+string(k)),1)
            if datos.models(j)=="Perfect"
                datos.("Mat_"+datos.models(j)+"_MSE") = zeros(1,length(x));
            end
            %% MSE
            hold on
            plot(x, datos.("Mat_"+datos.models(j)+"_MSE"),Styles(j),LineWidth=Line_Width,Color=colors_plot(j));grid on;
            title('Gráfica de MSE') ; xlabel('SNR (dB)'); ylabel('MSE');
            set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
            xticks([0:1:25]);
            %% BER
            nexttile(app.("l_"+string(k)),2)
            hold on
            plot(x, datos.("Mat_"+datos.models(j)+"_BER"),Styles(j), LineWidth=Line_Width,Color=colors_plot(j));grid on;
            yscale log;
            xticks([0:1:25]);
            title('Gráfica de BER');xlabel('SNR (dB)');ylabel('BER');hold off;
            set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
            %% EVM
            nexttile(app.("l_"+string(k)),3)
            hold on
            plot(x, datos.("Mat_"+datos.models(j)+"_EVM"),Styles(j), LineWidth=Line_Width,Color=colors_plot(j));grid on;
            %yl = yline(Maximo_EVM,'-','Requerido','color', [.5 .5 .5]);
            %yl.LabelHorizontalAlignment = "left";
            title('Gráfica de EVM');xlabel('SNR (dB)');ylabel('EVM(%)');
            set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
            xticks([0:1:25]);
            %% Time
            nexttile(app.("l_"+string(k)),4)
            hold on
            %(app.(Network+string(k)).("Mat_"+Network+"_Time"))
            %plot(x, (app.(Network+string(k)).("Mat_"+Network+"_Time")),Styles(k), LineWidth=1.5);
            plot(x, datos.("Mat_"+datos.models(j)+"_Time")./datos.Mat_Perfect_Time,Styles(j), LineWidth=Line_Width,Color=colors_plot(j));grid on;
            title('Tiempo de Estimación');xlabel('SNR (dB)'); ylabel('Estimación (ms)');
            xticks([0:1:25]); yticks([0:1.5:40]);
            set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
        end
        lgd = legend(label);
        lgd.Layout.Tile = 'east';
        set(gcf, 'Position', get(0, 'Screensize'));
       
        exportgraphics(app.("l_"+string(k)),DATA_PATH_NAME_IMG+datos.Channel+"_"+datos.Modulation+"_"+datos.User_Velocity+".png",'Resolution',300)
    
    end
    close all
    Paths = [];
end


% %% #################### UNCOMMENT THIS SECTION FOR SIMPLE MODEL GRAPH ##########################
% 
% Model = "Autoencoder";
% Metric = "BER";
% Vel = "30";
% Mod = "QPSK";
% 
% % Plot the response of selected metric  for the model select in all
% % channels with the specified modulation and velocity 
% 
% %Read Data 
% 
% app.Graph_1 = tiledlayout(1,1);
% sgtitle('Resultados de '+Metric+' del modelo '+Model+' con modulación '+Mod+' y velocidad de '+Vel+'km/h ')
% 
% for i=1:length(Channels)
%     Styles = [Styles string(lines(randi(length(lines))))+string(marks(i))];
%     colors_plot = [colors_plot string(colors(i))];
% end
% for a = 1:1:length(Channels)
%     Path_Type = Channels(a);
%     % For any TDL Channel
%     % Change path in function of the O.S
%     if (isunix) % working in UNIX env.
%         DATA_PATH_NAME_IMG = 'Outputs/Images/';
%         DATA_PATH_NAME = 'Outputs/'+Path_Type+'/';
%     else % working in Windows env.
%         DATA_PATH_NAME_IMG = 'Outputs\Images\';
%         DATA_PATH_NAME = 'Outputs\'+Path_Type+'\';
%     end
%     addpath(DATA_PATH_NAME)
%     %Read All filles with extension .mat
% 
%     Files = dir(DATA_PATH_NAME+"*.mat");
%     numfiles = length(Files);
%     mydata = cell(1, numfiles);
%     for i = 1:numfiles
%         Paths = [Paths string(Files(i).name)];
%     end
%     interval = 1:1:numfiles; % CNN4 CNN6 Autoencoder1  Denoising1 Denoising2 Lineal Practical Ideal
% 
%     for i = interval
%         if Paths(i) == ("Channel_"+Path_Type+"_Mod_"+Mod+"_Vel_"+Vel+".mat")
%             disp("Reading "+Paths(i) )
%             app.("Simulation_"+string(i)) = load(Paths(i)).Parameters;
% 
%             datos = app.("Simulation_"+string(i));
%         end
%     end
% 
% 
%     label = [label Path_Type]
%     disp("Generating Plots for "+Path_Type+" Channel")
% 
%     x = datos.SNR_Recorridas;
%     y = datos.("Mat_"+Model+"_"+Metric)
% 
% 
%     set(gcf, 'Position', get(0, 'Screensize'));
%     %exportgraphics(app.("l_"+string(k)),DATA_PATH_NAME_IMG+datos.Channel+"_"+datos.Modulation+"_"+datos.User_Velocity+".png",'Resolution',300)
%     nexttile(app.Graph_1,1)
% 
% 
% 
%     set(gca,'xminorgrid','on','yminorgrid','on','XMinorTick','on','YMinorTick','on');
%     switch Metric
%         case "EVM"
%             plot(x,y,Styles(a), LineWidth=Line_Width)
%             hold on
%             xlabel('SNR (dB)');ylabel("EVM(%)");
%         case "BER"
%             plot(x,y,Styles(a), LineWidth=Line_Width)
%             hold on
%             yscale log;
%             xlabel('SNR (dB)');ylabel(Metric);
%         case "MSE"
%             plot(x,y,Styles(a), LineWidth=Line_Width)
%             hold on
%             xlabel('SNR (dB)');ylabel(Metric);
%         case "Time"
%             plot(x, y./datos.Mat_Perfect_Time,Styles(a), LineWidth=Line_Width);grid on;
%             hold on
%             title('Tiempo de Estimación');xlabel('SNR (dB)'); ylabel('Estimación (ms)');
%     end
%     xticks([0:1:25]);
% 
%     %-----------
%     Paths = [];
%     lgd = legend(label);
%     lgd.Layout.Tile = 'east';
% end







