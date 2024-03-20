function [] = Waterfall_Estimation_Slot(Parameters,Indice_Ranura,snr)
figure
Filas = 1;
Columnas = 6;
%% Gráficas con los resultados

drawnow
sgtitle([' Respuesta de magnitud de canal estimada para el Slot ' num2str(Indice_Ranura+1) ' con SNR: ' num2str(snr) ' dB'])

%///////////////////////////////////////////
subplot(Filas,Columnas,1);
imagesc(abs(Parameters.Grilla_Subframe));
xlabel('OFDM Symbol');
ylabel('Subcarrier');
title('Canal Actual')

%///////////////////////////////////////////
subplot(Filas,Columnas,2);
imagesc(abs(Parameters.Grilla_Subframe_rx));
xlabel('OFDM Symbol');
ylabel('Subcarrier');
title('Recivido')
%///////////////////////////////////////////
if Parameters.perfectEstimation
    subplot(Filas,Columnas,3);
    imagesc(abs(Parameters.Perfect_estChannelGrid));
    xlabel('OFDM Symbol');
    ylabel('Subcarrier');
    title('Estimacion Perfecta (Ideal)')
end

%///////////////////////////////////////////
subplot(Filas,Columnas,4);
imagesc(abs(Parameters.interpChannelGrid));
xlabel('OFDM Symbol');
ylabel('Subcarrier');
title({'Estimacion Interpolacion Lineal', ['MSE: ', num2str(mean(Parameters.Lineal_MSE_Slot))]});


if Parameters.CNNEstimation
    %///////////////////////////////////////////
    subplot(Filas,Columnas,5);
    imagesc(abs(Parameters.CNN_estChannelGrid));
    xlabel('OFDM Symbol');
    ylabel('Subcarrier');
    title({'Estimacion Red Neuronal', ['MSE: ', num2str(mean(Parameters.CNN_MSE_Slot))]});

end

if Parameters.EstimacionPractica
    %///////////////////////////////////////////
    subplot(Filas,Columnas,6);
    imagesc(abs(Parameters.Practical_estChannelGrid));
    xlabel('OFDM Symbol');
    ylabel('Subcarrier');
    title({'Estimacion Practica', ['MSE: ', num2str(mean(Parameters.Practical_MSE_Slot))]});

end


hcb=colorbar;
hcb.Title.String = "|H|";


end