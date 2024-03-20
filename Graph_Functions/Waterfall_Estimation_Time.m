function [] = Waterfall_Estimation_Time(Parameters,Indice_Ranura,snr)

Filas = 3;
Columnas = 3;
Pos = 0;
%% Gráficas con los resultados
[~,s] = size(Parameters.Time_Grid_Lineal);
Slot = s/14;  %Numero total de slots actuales 

if mod(Indice_Ranura,10) == 0
    Frame = 1+Indice_Ranura/10;
else
    Frame = 1+floor(Indice_Ranura/10);
end

if Indice_Ranura >= 10
Indice_Ranura = mod(Indice_Ranura,10);
end

drawnow
sgtitle([' Respuesta de magnitud de canal estimada para el Frame ' num2str(Frame) ' Slot ' num2str(Indice_Ranura+1) ' con SNR: ' num2str(snr) ' dB'])

color = {'blue','green','red'};
mse_cnn ='';
mse_Lineal='' ;
mse_Practical='';

evm_cnn ='';
evm_Lineal='' ;
evm_Practical='';
%% COLOR PARA EVM
if(Parameters.CNN_EVM<Parameters.Lineal_EVM)
    %CNN better than Lineal
    if Parameters.CNN_EVM<Parameters.Practical_EVM
        %CNN better than Lineal and practical, CNN is the best 
        evm_cnn  = color{1,1};
        if Parameters.Practical_EVM < Parameters.Lineal_EVM
            % Practical better than Lineal
            evm_Practical= color{1,2};
            evm_Lineal = color{1,3};
        else
            % Lineal better than Practical
           evm_Practical= color{1,3};
           evm_Lineal = color{1,2};
        end
       
    else
        %CNN better than Lineal but practical is the best
        evm_cnn  = color{1,2};
        evm_Practical= color{1,1};
        evm_Lineal = color{1,3};
    end
else
    %Lineal better than CNN 
    if Parameters.CNN_EVM <Parameters.Practical_EVM
        %CNN better than practical
        evm_cnn  = color{1,2};
        evm_Practical= color{1,3};
        evm_Lineal = color{1,1};
    else 
        %CNN is the worst
        evm_cnn  = color{1,3};
        if Parameters.Practical_EVM > Parameters.Lineal_EVM
            % Practical better than Lineal
            disp("Aca toy ")
            evm_Practical= color{1,2};
            evm_Lineal = color{1,1};
        else
            disp("hi ")
            % Lineal better than Practical
            evm_Practical= color{1,1};
            evm_Lineal = color{1,2};
        end
    end

end

%% COLOR PARA MSE
if(Parameters.CNN_MSE<Parameters.Lineal_MSE)
    %CNN better than Lineal
    if Parameters.CNN_MSE<Parameters.Practical_MSE
        %CNN better than Lineal and practical, CNN is the best 
        mse_cnn  = color{1,1};
        if Parameters.Practical_MSE < Parameters.Lineal_MSE
            % Practical better than Lineal
            mse_Practical= color{1,2};
            mse_Lineal = color{1,3};
        else
            % Lineal better than Practical
           mse_Practical= color{1,3};
            mse_Lineal = color{1,2};
        end
       
    else
        %CNN better than Lineal but practical is the best
        mse_cnn  = color{1,2};
        mse_Practical= color{1,1};
        mse_Lineal = color{1,3};
    end
else
    %Lineal better than CNN 
    if Parameters.CNN_MSE <Parameters.Practical_MSE
        %CNN better than practical
        mse_cnn  = color{1,2};
        mse_Practical= color{1,3};
        mse_Lineal = color{1,1};
    else 
        %CNN is the worst
        mse_cnn  = color{1,3};
        if Parameters.Practical_MSE < Parameters.Lineal_MSE
            % Practical better than Lineal
            mse_Practical= color{1,1};
            mse_Lineal = color{1,2};
        else
            % Lineal better than Practical
            mse_Practical= color{1,2};
            mse_Lineal = color{1,1};
        end
    end

end



if Parameters.CNNEstimation
    %///////////////////////////////////////////
    Pos=Pos+1;
    subplot(Filas,Columnas,[1,2]);
    imagesc(abs(Parameters.Time_Grid_CNN));
    xlabel('OFDM Symbol');
    ylabel('Subcarrier');
    %title({'Estimacion Red Neuronal', [' MSE: ', num2str(mean(Parameters.CNN_EVM))]});
    title({['Estimacion Red Neuronal'],['{\color{',mse_cnn,'}MSE : ', num2str(mean(Parameters.CNN_MSE)), '  \color{',evm_cnn,'} EVM : ' num2str(mean(Parameters.CNN_EVM)) ' % }']})

    ax = gca;
    ax.TitleHorizontalAlignment = 'left';
    %///////////////////////////////////////////
    subplot(Filas,Columnas,[4,5]);
    imagesc(abs(Parameters.Time_Grid_Lineal));
    ylabel('Subcarrier');
    title({['Estimacion Interpolacion Lineal'],['{\color{',mse_Lineal,'}MSE : ', num2str(mean(Parameters.Lineal_MSE)), '  \color{',evm_Lineal,'} EVM : ' num2str(mean(Parameters.Lineal_EVM)) ' % }']})
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';

end
if Parameters.EstimacionPractica
    %///////////////////////////////////////////
    subplot(Filas,Columnas,[7,8]);
    imagesc(abs(Parameters.Time_Grid_Practical));
    ylabel('Subcarrier');
    title({['Estimacion Practica'],['{\color{',mse_Practical,'}MSE : ', num2str(mean(Parameters.Practical_MSE)), '  \color{',evm_Practical,'} EVM : ' num2str(mean(Parameters.Practical_EVM)) ' % }']})
    %title({'Estimacion Practica', ['MSE: ', num2str(mean(Parameters.Practical_EVM))]});
    
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';
end





ax = get(gca,'Position');
%// Place axis 2 below the 1st.

ax2 = axes('Position',[ax(1) ax(2)-.05 ax(3) ax(4)],'Color','none','YTick',[],'YTickLabel',[]);
%// Adjust limits
xlim([0 Slot])
xlabel('Time(ms)')
if Slot>100
    interval = 10;
elseif  Slot>30
    interval = 5;
else 
    interval = 1;
end
 
xticks((0:interval:Slot))



subplot(Filas,Columnas,[3,6,9]);
imagesc(abs(Parameters.Time_Grid_Perfect));
xlabel('OFDM Symbol');
ylabel('Subcarrier');
title('Estimacion Perfecta (Ideal)')
hcb=colorbar;
hcb.Title.String = "|H|";



end