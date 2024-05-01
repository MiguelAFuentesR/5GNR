function Graficas_Metricas(Parameters)

marks = ["o","pentagram","square","diamond","^","+","hexagram",".","x","_","|","square","diamond","^","v","<",">","*"];
lines = ["-","--",":","-.","-","--",":","-."];
%% ----------------------- BER Real Time----------------------------------
Parameters.SNR_Recorridas = Parameters.SNR_Recorridas(2:end);
drawnow
%BER = subplot(2,2,1);
BER = figure;
for i = 1:length(Parameters.models)
    semilogy(Parameters.SNR_Recorridas,Parameters.("Mat_"+string(Parameters.models{1,i})+"_BER"),LineWidth=1.5)
    hold on
    %semilogy(Parameters.SNR_Recorridas,Parameters.("Mat_CNN_MSE"))
    set(gca,'yscale','log')
    grid on
end

% BER.Title.String = "Bit Error Rate"
% BER.XLabel.String ="SNR (dB)"
% BER.YLabel.String = "BER"
legend(Parameters.models)
%% ----------------------- MSE Real Time----------------------------------
drawnow
%MSE = subplot(2,2,2);
MSE = figure;
%semilogy(Parameters.SNR_dB,Parameters.CNN_BER,lines(1)+marks(1))
hold on
for i = 1:length(Parameters.models)
    if strcmp(Parameters.models{1,i},"Perfect")
        Parameters.("Mat_"+string(Parameters.models{1,i})+"_MSE") = zeros(size(Parameters.("Mat_"+string(Parameters.models{1,1})+"_MSE")));
    end
    semilogy(Parameters.SNR_Recorridas,Parameters.("Mat_"+string(Parameters.models{1,i})+"_MSE"))
    hold on
    grid on
end
% MSE.Title.String="Mean Square Error"
% MSE.XLabel.String="SNR (dB)"
% MSE.YLabel.String="MSE"
legend(Parameters.models)
%% ----------------------- EVM Real Time----------------------------------
% EVM = subplot(2,2,3);
EVM = figure;
hold on
for i = 1:length(Parameters.models)
    semilogy(Parameters.SNR_Recorridas,Parameters.("Mat_"+string(Parameters.models{1,i})+"_EVM"))
    hold on
    grid on
end
% EVM.Title.String="Error vector Machine"
% EVM.XLabel.String="SNR (dB)"
% EVM.YLabel.String="EVM (%)"
legend(Parameters.models)


end