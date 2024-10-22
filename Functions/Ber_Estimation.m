function [Ber,Est] = Ber_Estimation(Bits_Tx,Bits_Rx,Parameters)
%Compara posicion por posicion los bits de 2 vectores columna, realiza un
%conteo de los bits que son diferentes
Bits_errados=0;
Parameters.Wrong_Bits = 0;
for i=1:length(Bits_Tx)
    if Bits_Tx(i)~=Bits_Rx(i)
        Bits_errados=Bits_errados+1;
    end
end

if Bits_errados==0
    Ber = 1/length(Bits_Tx);
else
    Ber = Bits_errados/length(Bits_Tx);
end
Parameters.Wrong_Bits = Bits_errados;

Est = Parameters;
end