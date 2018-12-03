close all

start_path= "/home/cl/Documents/2018-02/Tesis/octave";
chemin1= '2018_05_16_LARIB014_by_DONATIEN_RADIUS_LEFT/11_14_32';
indice= 1;unite=0;porte=1;


[SIG2,fe,f0,data,temps, RSS, RSB] = ouverture_aza_v5(start_path,chemin1,indice,unite,porte);%  

##########################################################################################
## SIG2 = Matriz de tamaño Nt x nb_receptor x nb_emission x índice x dirección
## fe = freq ech (20 MHz para AZA)
## f0 = frecuencia central
## data = estructura de los parámetros generales de las adquisiciones.
## temps = vector de tiempo asociado con señales adquiridas
## Relación señal RSS a saturación (2048) nb_receptor x nb_emission x índice x dirección
## Relación señal / ruido SNR (2048) número_receptor x número_misión x índice x dirección
##############################################################################################


## ts: Tiempo de Sampĺing en [µs]
ts = 1/fe; 

## p: Espacio entre sensores [mm]
p = 0.8; 

## Nt: Numero de puntos de tiempo
Nt = size(SIG2,1); 

## NR: Numero de receptores
NR = size(SIG2, 2); 

## s: Señal s en tiempo s(t)
s = squeeze(SIG2(:,:,1,1,1)); 

## t: arreglo de tiempos [µs]
t =[0:Nt-1]*ts;

## x: arreglo de posiciones [mm]
x = [0:NR-1]*p;

## Nf: Numero de frecuencias
Nf = 2048;

## f: Arreglo de frecuencias 
f = [0:Nf-1]*fe/Nf;
## s → S 
S = fft(s,Nf);