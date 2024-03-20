function [Est] = Matrix_metricas(Parameters)


Parameters.Mat_Lineal_MSE = [Parameters.Mat_Lineal_MSE,Parameters.LinealMSE];
Parameters.Mat_Lineal_EVM = [Parameters.Mat_Lineal_EVM, Parameters.LinealEVM];
Parameters.Mat_Lineal_BER = [Parameters.Mat_Lineal_BER,Ber_Estimation(Parameters.txbits,Parameters.Lineal_rxbits)];
Parameters.Mat_Lineal_Time = [Parameters.Mat_Lineal_Time  mean(Parameters.Lineal_Time)];


Parameters.Mat_Perfect_EVM = [Parameters.Mat_Perfect_EVM, Parameters.PerfectEVM];
Parameters.Mat_Perfect_BER = [Parameters.Mat_Perfect_BER,Ber_Estimation(Parameters.txbits,Parameters.Perfect_rxbits)];
Parameters.Mat_Perfect_Time = [Parameters.Mat_Perfect_Time mean(Parameters.Perfect_Time)];

if Parameters.CNNEstimation
    Parameters.Mat_CNN_MSE = [Parameters.Mat_CNN_MSE,Parameters.CNNMSE];
    Parameters.Mat_CNN_EVM = [Parameters.Mat_CNN_EVM, Parameters.CNNEVM];
    Parameters.Mat_CNN_BER = [Parameters.Mat_CNN_BER,Ber_Estimation(Parameters.txbits,Parameters.CNN_rxbits)];
    Parameters.Mat_CNN_Time = [Parameters.Mat_CNN_Time  mean(Parameters.CNN_Time)];
end

if Parameters.CNNEstimation_2
    Parameters.Mat_CNN_2_MSE = [Parameters.Mat_CNN_2_MSE,Parameters.CNN_2MSE];
    Parameters.Mat_CNN_2_EVM = [Parameters.Mat_CNN_2_EVM, Parameters.CNN_2EVM];
    Parameters.Mat_CNN_2_BER = [Parameters.Mat_CNN_2_BER,Ber_Estimation(Parameters.txbits,Parameters.CNN_2_rxbits)];
    Parameters.Mat_CNN_2_Time = [Parameters.Mat_CNN_2_Time  mean(Parameters.CNN_2_Time)];
end

if Parameters.Autoencoder_Estimation
    Parameters.Mat_Autoencoder_MSE = [Parameters.Mat_Autoencoder_MSE,Parameters.AutoencoderMSE];
    Parameters.Mat_Autoencoder_EVM = [Parameters.Mat_Autoencoder_EVM, Parameters.AutoencoderEVM];
    Parameters.Mat_Autoencoder_BER = [Parameters.Mat_Autoencoder_BER,Ber_Estimation(Parameters.txbits,Parameters.Autoencoder_rxbits)];
    Parameters.Mat_Autoencoder_Time = [Parameters.Mat_Autoencoder_Time mean(Parameters.Autoencoder_Time)];
end


if Parameters.Denoising_Estimation
    Parameters.Mat_Denoising_MSE = [Parameters.Mat_Denoising_MSE,Parameters.DenoisingMSE];
    Parameters.Mat_Denoising_EVM = [Parameters.Mat_Denoising_EVM, Parameters.DenoisingEVM];
    Parameters.Mat_Denoising_BER = [Parameters.Mat_Denoising_BER,Ber_Estimation(Parameters.txbits,Parameters.Denoising_rxbits)];
    Parameters.Mat_Denoising_Time = [Parameters.Mat_Denoising_Time mean(Parameters.Denoising_Time)];
end

if Parameters.EstimacionPractica
    Parameters.Mat_Practical_MSE = [Parameters.Mat_Practical_MSE,Parameters.PracticalMSE];
    Parameters.Mat_Practical_EVM = [Parameters.Mat_Practical_EVM, Parameters.PracticalEVM];
    Parameters.Mat_Practical_BER = [Parameters.Mat_Practical_BER,Ber_Estimation(Parameters.txbits,Parameters.Practical_rxbits)];
    Parameters.Mat_Practical_Time = [Parameters.Mat_Practical_Time mean(Parameters.Practical_Time)];
end
Est = Parameters;
end