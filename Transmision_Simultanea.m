format shortEng
format compact
close all

path_x = pwd ;
addpath([path_x,'/Estimation/']);
addpath([path_x,'/Functions/']);
addpath([path_x,'/Generation/']);
addpath([path_x,'/Graph_Functions/']);
addpath([path_x,'/Models/']);
addpath([path_x,'/Outputs/']);
addpath([path_x,'/App/']);

Files = dir(fullfile("Outputs/",'**/*.mat*'));
numfiles = length(Files);
mydata = cell(1, numfiles);
for k = 1:numfiles
    mydata{k} = Files(k).folder;   
end
directory = unique(mydata);
y_1 = directory+"/";

for k = 1:length(directory)
    addpath(y_1(k));
end

rng(45)

app = [];
app.Pam_sim = [];% Parametros de la simulacion

app.Pam_sim.Modulation = "64QAM";
app.Pam_sim.Channel = "TDL-A";

%% SNR Config
app.Pam_sim.SNR_STATIC = false;
app.Pam_sim.SNR_Init = 10;
app.Pam_sim.SNR_intervalos = 2;
app.Pam_sim.SNR_max = 26; %Valor maximo que sera emulado (Se empieza en cero hasta ese valor)

if app.Pam_sim.SNR_STATIC
    app.Pam_sim.SNR_dB = app.Pam_sim.SNR_Init:1:app.Pam_sim.SNR_Init; % Relación señal/ruido lineal
else
    app.Pam_sim.SNR_dB= app.Pam_sim.SNR_Init:app.Pam_sim.SNR_intervalos:app.Pam_sim.SNR_max;
end

app.Pam_sim.Vel_sim_Estatic = true;

app.Pam_sim.Vel_init = 10;
app.Pam_sim.Vel_step = 10;
app.Pam_sim.Vel_end = 100;



if app.Pam_sim.Vel_sim_Estatic
    app.Pam_sim.Vel_values = app.Pam_sim.Vel_init ;
else
    app.Pam_sim.Vel_values = app.Pam_sim.Vel_init:app.Pam_sim.Vel_step:app.Pam_sim.Vel_end  ;
end


%% --------------- Estimation Config
app.Pam_sim.CNNmodel_1 = 6;
app.Pam_sim.CNNmodel_2 = 6;
app.Pam_sim.CNNEstimation = true;
app.Pam_sim.CNNEstimation_2 = true;
app.Pam_sim.Autoencoder_Estimation = false;
app.Pam_sim.EstimacionPractica = false;
app.Pam_sim.Denoising_Estimation = false;
app.Pam_sim.Denoising_Estimation_resta = false;


app.Pam_sim.Compensacion_Fase = false;% Realizar compensacion de fase con pilotos PT-RS para CNN

app.Pam_sim.Save_Variables  = true;

%% ------------- Data config

app.Pam_sim.Transmision_IMG = false; % Envio de una imagen
app.Pam_sim.Transmision_Bits = false;
app.Pam_sim.Bits_Deseados = 1200000;
app.Pam_sim.Num_Frames = 1; %Numero de frames deseados a enviar
app.Pam_sim.Path_IMG = '/media/miguel/Universidad/Tesis/Codigos_Finales/Chacon.png';

%%
app.Pam_sim.models = {'Lineal','Perfect'};

if app.Pam_sim.CNNEstimation
    app.Pam_sim.models = [app.Pam_sim.models 'CNN'];
    app.Pam_sim.estimacionRNA_1 = load("CNN_Modelo"+app.Pam_sim.CNNmodel_1+".mat").estimacionRNA;
end
if app.Pam_sim.CNNEstimation_2
    app.Pam_sim.models = [app.Pam_sim.models 'CNN_2'];
    app.Pam_sim.estimacionRNA_2 = load("CNN_Modelo"+app.Pam_sim.CNNmodel_2+".mat").estimacionRNA;

end
if app.Pam_sim.Autoencoder_Estimation
    app.Pam_sim.estimacionRNA_Autoencoder = load("Autoencoder.mat").estimacionRNA;
    app.Pam_sim.models = [app.Pam_sim.models 'Autoencoder'];
end
if app.Pam_sim.EstimacionPractica
    app.Pam_sim.models = [app.Pam_sim.models 'Practical'];
end
if app.Pam_sim.Denoising_Estimation

    app.Pam_sim.estimacionRNA_Denoising= load("Denoising1.mat").estimacionRNA;
    app.Pam_sim.models = [app.Pam_sim.models 'Denoising'];
end
if app.Pam_sim.Denoising_Estimation_resta
    app.Pam_sim.estimacionRNA_Denoising_2= load("Denoising2.mat").estimacionRNA;
    app.Pam_sim.models = [app.Pam_sim.models 'Denoising_2'];
end
%% Ciclo de Procesamiento (Simulacion transmision en el tiempo )




for Velo = app.Pam_sim.Vel_values
    app.Pam_sim.SNR_Recorridas =[];
    app.Pam_sim.User_Velocity = Velo;
    %Inicialización y configuración de la portadora, Modulacion y canal
    % Parametros : Tipo de modulacion, Perfil de canal, Velocidad Usuario
    app.Pam_sim = Simulation_Configuration(app.Pam_sim);% Parametros de la simulacion

    for snr = app.Pam_sim.SNR_dB
        app.Pam_sim =Variables_initialization(app.Pam_sim,snr);
        app.Pam_sim.SNR_Recorridas = [app.Pam_sim.SNR_Recorridas snr];
        disp(['SNR de ',num2str(snr),' dB'])

        for Indice_Ranura = 0:app.Pam_sim.slots - 1

            disp(['Slot ',num2str(Indice_Ranura),' Enviado'])
            app.Pam_sim.Indice_Ranura = Indice_Ranura;
            %% ------------ Transmisor  ----------------------------
            tStart_trans = tic;
            app.Pam_sim = Transmitter(app.Pam_sim);
            app.Pam_sim.tEnd_trans = toc(tStart_trans);
            %% ------------ Receptor (AWGN - CANAL TDL) ---------------------------
            tStart_recep = tic;
            app.Pam_sim = Receiver(app.Pam_sim);
            app.Pam_sim.tEnd_recep = toc(tStart_recep);
            %% ------------  Estimacion de Canal Lineal ---------------------------
            tStart_Lineal = tic;
            app.Pam_sim = Lineal_Estimation(app.Pam_sim);
            app.Pam_sim.tEnd_Lineal = toc(tStart_Lineal);
            %% ----------------- Estimacion de Canal Perfecta ---------------------
            tStart_Perfect = tic;
            app.Pam_sim = Perfect_Estimation(app.Pam_sim);
            app.Pam_sim.tEnd_Perfect = toc(tStart_Perfect);
            %% ----------------- Estimacion de Canal con CNN ---------------------
            if app.Pam_sim.CNNEstimation
                tStart_CNN = tic;
                app.Pam_sim = CNN_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_1);
                app.Pam_sim.tEnd_CNN = toc(tStart_CNN);
                app.Pam_sim.CNN_pdschEq_sin = app.Pam_sim.CNN_pdschEq ;
            end
            if app.Pam_sim.CNNEstimation_2
                tStart_CNN_2 = tic;
                app.Pam_sim = CNN_2_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_2);
                app.Pam_sim.tEnd_CNN_2 = toc(tStart_CNN_2);
                app.Pam_sim.CNN_2_pdschEq_sin = app.Pam_sim.CNN_2_pdschEq ;
            end

            %% ----------------- Estimacion de Canal con AUTOENCODER --------------
            if app.Pam_sim.Autoencoder_Estimation
                tStart_Autoencoder= tic;
                app.Pam_sim = Autoencoder_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_Autoencoder);
                app.Pam_sim.tEnd_Autoencoder = toc(tStart_Autoencoder);
            end
            %% ----------------- Estimacion de Canal con Red Denoising --------------
            if app.Pam_sim.Denoising_Estimation
                tStart_Denoising= tic;
                app.Pam_sim = Denoising_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_Denoising);
                app.Pam_sim.tEnd_Denoising= toc(tStart_Denoising);
            end
            %% ----------------- Estimacion de Canal con Red Denoising 2--------------
            if app.Pam_sim.Denoising_Estimation_resta
                tStart_Denoising_2= tic;
                app.Pam_sim = Denoising_Estimation_2(app.Pam_sim,app.Pam_sim.estimacionRNA_Denoising_2);
                app.Pam_sim.tEnd_Denoising_2= toc(tStart_Denoising_2);
            end
            %% ----------------- Estimacion de Canal Practica ---------------------
            if app.Pam_sim.EstimacionPractica
                tStart_Practical = tic;
                app.Pam_sim = Practical_Estimation(app.Pam_sim);
                app.Pam_sim.tEnd_Practical = toc(tStart_Practical);
            end

            %% ----------------- Compensacion de fase de los Simbolos ----------------
            if app.Pam_sim.Compensacion_Fase
                app.Pam_sim  = Phase_Compensantion(app.Pam_sim);
            end
            %disp(['Slot ',num2str(Indice_Ranura),' Procesado'])

            app.Pam_sim = Metricas_Slot(app.Pam_sim);

            %Constelaciones(app.Pam_sim);
            %Waterfall_Estimation_Time(app.Pam_sim,Indice_Ranura,snr);
        end

        
        app.Pam_sim = Matrix_metricas(app.Pam_sim);
        
        %Graficas_Metricas(app.Pam_sim);

    end
    %Waterfall_Estimation_Slot(app.Pam_sim,Indice_Ranura,snr);
   Save_parameters(app.Pam_sim);
   disp("Velocidad de "+Velo+"km/h Terminada")
end

