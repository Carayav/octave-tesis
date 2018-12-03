close all
clear
load REF2D_exvivo_Mathilde_Radius_01mm

start_path = "/home/cl/Documents/2018-02/tesis/octave";
#data_path1 = '2018_05_16_LARIB014_by_DONATIEN_RADIUS_LEFT/11_14_32';
cd(start_path)

list_dir = ls('-d */');
class(list_dir)