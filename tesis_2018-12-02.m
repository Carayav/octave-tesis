close all
start_path= "/home/cl/Documents/2018-02/tesis/octave";
chemin1= '2018_05_16_LARIB014_by_DONATIEN_RADIUS_LEFT/11_14_32';
indice= 1;unite=0;porte=1;
cd(start_path)

[SIG2,fe,f0,data,temps, RSS, RSB] = ouverture_aza_v5(start_path,chemin1,indice,unite,porte);\
##########################################################################################
## SIG2 = Matriz de tamaño Nt x nb_receptor x nb_emission x índice x dirección
## fe = freq ech (20 MHz para AZA)
## f0 = frecuencia central
## data = estructura de los parámetros generales de las adquisiciones.
## temps = vector de tiempo asociado con señales adquiridas
## Relación señal RSS a saturación (2048) nb_receptor x nb_emission x índice x dirección
## Relación señal / ruido SNR (2048) número_receptor x número_misión x índice x dirección
##############################################################################################
size(SIG2)