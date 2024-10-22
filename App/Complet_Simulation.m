function app = Complet_Simulation(app)

try
    if app.Pam_sim.Simple_sim
        if ~app.Pam_sim.Transmision_IMG
        d = uiprogressdlg(app.DLS5GUIFigure,'Title','Please Wait',...
                    'Message','Opening the application');
        end
    end
    % if ~isempty(findall(groot, 'Type', 'figure', 'Name', 'Constellations plot'))
    %    close(app.Pam_sim.const_plot)
    % end
    
  % fig_const = figure();
    
    %% ------------------- SIMULATION CONFIGURATION ----------------------------
    %%%%%%Para el valor del SNR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if app.Pam_sim.SNR_STATIC
        app.Pam_sim.SNR_Init = app.EditField_SNRValue.Value;
        app.Pam_sim.SNR_dB = app.Pam_sim.SNR_Init:1:app.Pam_sim.SNR_Init; % Relación señal/ruido lineal
    else
        aux = round(app.RangeSliderSNR.Value);
        app.Pam_sim.SNR_Init = aux(1);
        app.Pam_sim.SNR_max = aux(2);
        app.Pam_sim.SNR_dB = app.Pam_sim.SNR_Init:app.Pam_sim.SNR_intervalos:app.Pam_sim.SNR_max;
    end

    %%%%% Para la velocidad %%%%%%%%%%%%%%%%%%%%%%%%%%
    if app.Pam_sim.Vel_sim_Estatic
        app.Pam_sim.Vel_values = app.EditField_vel_init.Value;
    else
        aux2 = round(app.RangeSlider_Vel.Value);
        app.Pam_sim.Vel_init = aux2(1);
        app.Pam_sim.Vel_end = aux2(2);
        app.Pam_sim.Vel_values = app.Pam_sim.Vel_init:app.Pam_sim.Vel_step:app.Pam_sim.Vel_end;
    end

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

    %% ------------------------------- INIT SIMULATION -------------------------------------
    for Velo = app.Pam_sim.Vel_values
        app.Pam_sim.User_Velocity = Velo;
        app.Pam_sim.SNR_Recorridas  = [];
        %Inicialización y configuración de la portadora, Modulacion y canal
        % Parametros : Tipo de modulacion, Perfil de canal, Velocidad Usuario
        app.Pam_sim = Simulation_Configuration(app.Pam_sim);% Parametros de la simulacion
        for snr = app.Pam_sim.SNR_dB
            app.Pam_sim =Variables_initialization(app.Pam_sim,snr);
            app.Pam_sim.SNR_Recorridas = [app.Pam_sim.SNR_Recorridas snr];
            % Check if process is paused
            if app.Pam_sim.Simple_sim
                if ~app.Pam_sim.Transmision_IMG
                d.Message = "Starting "+snr+" dB";
                pause(.2)
                end
            end
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

                %% ----------------- Compensacion de fase de los Simbolos ----------------
                if app.Pam_sim.Compensacion_Fase
                    %app.Pam_sim.Model_Phasecomp = app.phase_comp_model.Value;
                    app.Pam_sim.Symbols_pdsch_const = app.Pam_sim.(app.Pam_sim.Model_Phasecomp+"_pdschEq");
                    app.Pam_sim  = Phase_Compensantion(app.Pam_sim,app.Pam_sim.Model_Phasecomp);
                end

                %disp(['Slot ',num2str(Indice_Ranura),' Procesado'])
                
                app.Pam_sim = Metricas_Slot(app.Pam_sim);

                if app.Pam_sim.Simple_sim
                    if ~app.Pam_sim.Transmision_IMG
                        d.Message = "Slot "+string(Indice_Ranura)+" of "+string(app.Pam_sim.slots - 1);
                        d.Value = Indice_Ranura/(app.Pam_sim.slots - 1);
                    end
                    
                end 
                if app.Pam_sim.Time_sim
                    app = App_Waterfall_Estimation_Time(app,app.Pam_sim,Indice_Ranura,snr);
                end
            end

           
            
            if app.Pam_sim.Constellations_plot
                 drawnow
                count=0;
                const = length(app.Pam_sim.Constellations_list);
                colum = 2;
                
                if app.Pam_sim.Compensacion_Fase
                    const = const+1;
                    count=count+1;
                    filas = ceil(const/colum);
                    subplot(colum,filas,count,'Parent',app.External_plots);                
                    % Get the compensed symbols
                    plot(app.Pam_sim.Symbols_pdsch_const,'.')
                    title("Constellation for "+app.Pam_sim.Model_Phasecomp+" model")
                end

                filas = ceil(const/colum);
                
                for model = app.Pam_sim.Constellations_list
                    count=count+1;
                    subplot(colum,filas,count,'Parent',app.External_plots);
                    
                    %plot(app.Pam_sim.Perfect_EVM)
                    if model == "Perfect"
                        title("Constellation Compensed for ideal model")
                        plot(app.Pam_sim.(model+"_pdschEq"),'.',"Color","red")

                    else
                        plot(app.Pam_sim.(model+"_pdschEq"),'.')
                    end

                    if app.Pam_sim.Compensacion_Fase

                        if model == string(app.Pam_sim.Model_Phasecomp)
                            title("Constellation Compensed for "+model+" model")
                        else
                            title("Constellation for "+model+" model")
                        end
                    else
                        if model == "Perfect"
                            title("Constellation ideal model")
                        else
                            title("Constellation for "+model+" model")
                        end
                    end

                    
                
                end 
                
                %sgtitle("Actual Received constellations for "+app.Pam_sim.Channel +" Using "+app.Pam_sim.Modulation+" Modulation with "+string(snr)+" dB at "+string(app.Pam_sim.User_Velocity)+" km/h")

                %Estimate the necesary plots
            end

            
            app.Pam_sim = Matrix_metricas(app.Pam_sim);

            %% PLOT RECONSTRUCTED IMAGES
            drawnow
            if app.Pam_sim.Transmision_IMG
                %figure

                orig_class = class(app.Pam_sim.Image);
                orig_size = size(app.Pam_sim.Image);
                plots = length(app.Pam_sim.models);

                colum = 2;
                filas = ceil(plots/colum)+1;
                l=1;
                drawnow
                ax=subplot(colum,filas,l,'Parent',app.External_plots);
                imshow(app.Pam_sim.Image); title('original');
                sgtitle("Results for Channel "+app.Pam_sim.Channel +" Using "+app.Pam_sim.Modulation+" Modulation with "+string(snr)+" dB at "+string(app.Pam_sim.User_Velocity)+" km/h")
                for modelo = app.Pam_sim.models
                    l=l+1;
                    img_received = app.Pam_sim.(modelo+"_rxbits");
                    img_received = img_received(1:length(app.Pam_sim.txbits)-app.Pam_sim.Complemento);
                    reconstructed = reshape(typecast(uint8(bin2dec(char(reshape(img_received, 8, [])+'0').')), orig_class), orig_size);
                    ax = subplot(colum,filas,l,'Parent',app.External_plots);
                    imshow(reconstructed);
                    if string(modelo) == "Perfect"
                        modelo = "Ideal";
                        title("Reconstructed using " + string(modelo),Color="red")

                    else
                        title("Reconstructed using " + string(modelo))
                    end
                    %xlabel(string(max(abs(double(app.Pam_sim.Image(:)) - double(reconstructed(:))))));
                    err = immse(double(reconstructed(:)), double(app.Pam_sim.Image(:)));
                    % Calcular el porcentaje de error
                    porcentaje_error = ssim(reconstructed,app.Pam_sim.Image)*100;
                    xlabel({"The similarity is : "+string(porcentaje_error)+" % ","Wrong pixels (MSE): "+string(err)})
  
                end
                disp("Fin plot")

            end

        end

        %% SAVE RESULTS
        disp("Velocidad de "+Velo+"km/h Terminada")
        if app.Pam_sim.Save_Variables
            app.Parameters = app.Pam_sim;
            Save_parameters(app.Parameters);
        end
       
        %y = uialert(app.DLS5GUIFigure,["Simulation completed"],"Simulation end","Icon","success");
        y = uiprogressdlg(app.DLS5GUIFigure,'Title','Simulation','Message',"Vel "+string(Velo)+" completed");
        pause(.2)
    end
    uialert(app.DLS5GUIFigure,["Simulation completed"],"Simulation end","Icon","success");
    if app.Pam_sim.Simple_sim
        if ~app.Pam_sim.Transmision_IMG
        close(d)
        end
    end

catch error
    x = 0 ;
    uialert(app.DLS5GUIFigure,['  There was an error! The message was:   ',error.message, ' the identifier was: ',error.identifier,],"Invalid File","Icon","error");
end
%% ------------------------------- END SIMULATION --------------------------------------


end