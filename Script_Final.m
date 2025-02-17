format shortEng
format compact
close all

addpath('Estimation');
addpath('Functions');
addpath('Generation');
addpath('Graph_Functions');
addpath('Models');
addpath('Outputs');

rng(45)


app = [];
app.Pam_sim = [];% Parametros de la simulacion


mod = ["QPSK","64QAM","256QAM"];
canales = ["TDL-A","TDL-B","TDL-E","TDL-C"];
velocidades = [5 30 100];



%% SNR Config
app.Pam_sim.SNR_STATIC = false;
app.Pam_sim.SNR_Init = 0;
app.Pam_sim.SNR_intervalos = 1;
app.Pam_sim.SNR_max = 25; %Valor maximo que sera emulado (Se empieza en cero hasta ese valor)

app.Pam_sim.SNR_dB = 0:1:25;
app.Pam_sim.Compensacion_Fase = false;% Realizar compensacion de fase con pilotos PT-RS para CNN

app.Pam_sim.Save_Variables  = true;


%% --------------- Estimation Config

app.Pam_sim.CNNmodel_1 = 4;
app.Pam_sim.CNNmodel_2 = 6;

app.Pam_sim.CNNEstimation = true;
app.Pam_sim.CNNEstimation_2 = true;

app.Pam_sim.Autoencoder_Estimation = true;

app.Pam_sim.Denoising_Estimation = true;
app.Pam_sim.Denoising_Estimation_resta = true; % Estimadora de ruido 

app.Pam_sim.EstimacionPractica = true;



%% ------------- Data config

app.Pam_sim.Transmision_IMG = false; % Envio de una imagen
app.Pam_sim.Transmision_Bits = false;
app.Pam_sim.Bits_Deseados = 1200000;
app.Pam_sim.Num_Frames = 7; %Numero de frames deseados a enviar
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
    app.Pam_sim.estimacionRNA_Autoencoder = load("Autoencoder1.mat").estimacionRNA;
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
for canal = canales
    app.Pam_sim.Channel = canal;
    for modulaciones = mod
        app.Pam_sim.Modulation = modulaciones;
        for Velo = velocidades
            app.Pam_sim.SNR_Recorridas =[];
            app.Pam_sim.User_Velocity = Velo;
            %Inicialización y configuración de la portadora, Modulacion y canal
            % Parametros : Tipo de modulacion, Perfil de canal, Velocidad Usuario
            app.Pam_sim = Simulation_Configuration(app.Pam_sim);% Parametros de la simulacion
            disp(["CANAL ",canal," MOD ",modulaciones," Vel de ",Velo," km/h"])
            
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
                   %% ----------------- Estimacion de Canal con CNN_2 ---------------------
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
                   app.Pam_sim = Metricas_Slot(app.Pam_sim);
               end
                app.Pam_sim = Matrix_metricas(app.Pam_sim);
            end
            Save_parameters_ScriptFinal(app.Pam_sim);
        end
    end
end
