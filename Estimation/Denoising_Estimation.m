function [Est] = Denoising_Estimation(Parameters,estimacionRNA)

%% ----------------- Estimacion de Canal Denoising -----------------------
nnInput = cat(4,real(Parameters.interpChannelGrid),imag(Parameters.interpChannelGrid));
size(nnInput);
% Use the neural network to estimate the channel
time_prediction = tic;
Parameters.Denoising_estChannelGrid = predict(estimacionRNA,nnInput);
Parameters.t_estimation_Denoising = toc(time_prediction);

% Convert results to complex
Parameters.Denoising_estChannelGrid = complex(Parameters.Denoising_estChannelGrid(:,:,:,1),Parameters.Denoising_estChannelGrid(:,:,:,2));
if Parameters.Denoising_Estimation_resta
    Parameters.Denoising_estChannelGrid = Parameters.interpChannelGrid-Parameters.Denoising_estChannelGrid;
end


Parameters.Denoising_Mape = mape(double(Parameters.Denoising_estChannelGrid(:)), Parameters.Perfect_estChannelGrid(:));
Parameters.Denoising_MSE = [Parameters.Denoising_MSE immse(Parameters.Perfect_estChannelGrid(:,:,:), double(Parameters.Denoising_estChannelGrid(:,:,:)))];

[Denoising_pdschRx,Denoising_pdschHes] = nrExtractResources(Parameters.Indices_Pdsch,Parameters.Grilla_Subframe_rx,Parameters.Denoising_estChannelGrid);
[Parameters.Denoising_pdschEq,Denoising_csi] = nrEqualizeMMSE(Denoising_pdschRx,Denoising_pdschHes,Parameters.noiseEst);

[Denoising_bits_received,Denoising_rxSymbols] = nrPDSCHDecode(Parameters.portadora,Parameters.pdsch,Parameters.Denoising_pdschEq,Parameters.noiseEst);
Parameters.Denoising_rxbits = [Parameters.Denoising_rxbits;Denoising_bits_received{1,1}<0]; % Bits decodificados
Est = Parameters;
end