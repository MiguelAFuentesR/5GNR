function Puntos = Reference_Points(modulacion)
% Calcula los puntos de la constelacion de referencia en el esquema de
% modulacion
switch modulacion
    case "QPSK"
        Cantidad_Puntos = 4;
    case "16QAM"
        Cantidad_Puntos = 16;
    case "64QAM"
        Cantidad_Puntos = 64;
    case "128QAM"
        Cantidad_Puntos = 128;
    case "256QAM"
        Cantidad_Puntos = 256;
end
Val = int2bit(0:Cantidad_Puntos-1,log2(Cantidad_Puntos));
Puntos = nrSymbolModulate(Val(:),modulacion);
end