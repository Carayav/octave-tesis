% Date : décembre 2013
% Auteur : Quentin Vallet
% Dernière MAJ : 05/12/2013

% Fonction permettant d'ouvrir sur matlab le fichier .conf obtenu
% à partir des acquisitions par la sonde aza_v5 et de connaître les
% paramètres généraux de la mesure

%%% Input de la fonction
% FichierConf = nom du fichier conf à ouvrir
% chemin = chemin du dossier qui contient le fichier conf

%%% Output de la fonction
% data = structure des paramètres généraux des acquisitions

function [data] = LireFichierConfig_aza_v5(FichierConf,start_path,chemin1)

cd(chemin1)
%%% Ouverture du .conf
fid = fopen(FichierConf,'r') ;
%fid = fopen ('/home/qvallet/these/Matlab/sonde_AZA/2013_12_Mesures_SB_TubePlaque_testsAlthais/2013_12_03/plaque_SB_2mm_7multiple_2-7microsec_20-40dB_170V_sonde_AZA_1/13_10_54/2013_12_03__13_10_54.conf','r');

%%% Lecture Header
data.Taille = fread(fid,1,'int16') ; % taille de l'entête
data.Signature = fread(fid,1,'schar') ; % en binaire 90 => 0x5A en hexa
data.Version = fread(fid,2,'int8=>char') ; % 25, 26 ou 27
data.ChekSum = fread(fid,1,'uchar') ;
data.Commentaire = fread(fid, data.Taille-6,'uint8=>char') ;

%%% Paramètres généraux
data.PRF = fread(fid,1,'int16'); % en kHz
data.FreqAng = fread(fid,1,'float'); % en Hz fréquence angulaire (entre 2 séquences totales) float
data.Nt = fread(fid,1,'int16'); % nbre de pts
data.Moy = fread(fid,1,'int16'); % moyennage
data.NbPos_ang = fread(fid,1,'int16'); % nombre position angulaire
data.AmplExcitation = fread(fid,1,'int16'); % Amplitude du signal Excitation : 170 ou 350 V
data.type_em = fread(fid,1,'int8'); % 1 BL, valeur figée
data.mode_auscultation = fread(fid,1,'int8'); % 0 SINGLE, 1 SCANNED, 2 MULTIPLE
data.nb_deflexion = fread(fid,1,'int16') ; % Nb de déflexions en mode MULTIPLE de 1 à 10, SCANNED 5, SINGLE 1
data.Freq_centrale = fread(fid,1,'int16') ; % 500, 1000 ou 2000 kHz
data.nb_recepteur = fread(fid,1,'int16') ; % 24 ou 32

%%% Parametres émetteurs, délais, gains
if data.mode_auscultation == 0 % 'SINGLE'
    fseek(fid, 8220,0) ;% on déplace le pointeur de lecteur de la taille du tableau de configuration des modes SCANNED ou MULTIPLE
    
    for direc= 1:2
        % Recuperation des etats des emetteurs
        for num_em = 1:5
            data.zone(direc).Etat_Emetteur(num_em)=fread(fid,1,'int8');
        end
        % Recuperation des delais et des gains
        for num_rec = 1:32
            data.zone(direc).emission(1).Delai(num_rec)=fread(fid,1,'int16');
            data.zone(direc).emission(1).Gain(num_rec)=fread(fid,1,'int16');
        end
    end

elseif data.mode_auscultation == 1 %'SCANNED'
    for i_balayage = 1:5
        unused_1 = fread(fid,1,'int16');
        unused_2 = fread(fid,1,'int16');
        data.retard_deflexion = fread(fid,1,'float32') ;
        for direc = 1:2
            % Recuperation des etats des emetteurs
            for num_em = 1:5
                data.zone(direc).emission(i_balayage).Etat_Emetteur(num_em)=fread(fid,1,'int8');
            end
            % Recuperation des delais et des gains
            for num_rec = 1:32
                data.zone(direc).emission(i_balayage).Delai(num_rec) = fread(fid,1,'int16');
                data.zone(direc).emission(i_balayage).Gain(num_rec) = fread(fid,1,'int16');
            end
        end
    end
   
else % 'MULTIPLE'
    for i_deflexion = 1:data.nb_deflexion
        unused_1 = fread(fid,1,'int16') ;
        unused_2 = fread(fid,1,'int16') ;
        data.retard_deflexion(i_deflexion) = fread(fid,1,'float32') ;
        for direc = 1:2
            % Recuperation des etats des emetteurs
            for num_em = 1:5
                data.zone(direc).emission(i_deflexion).Etat_Emetteur(num_em) = fread(fid,1,'int8') ;
            end
            % Recuperation des delais et des gains
            for num_rec = 1:32
                data.zone(direc).emission(i_deflexion).Delai(num_rec) = fread(fid,1,'int16') ;
                data.zone(direc).emission(i_deflexion).Gain(num_rec) = fread(fid,1,'int16') ;
            end
        end
    end  
end

fclose(fid);
cd(start_path)
end
