% %%% Fonction ouverture AZA_5
% % [SIG2,fe,f0,data,temps, RSS, RSB] = ouverture_aza_v5(start_path,chemin1,indice,unite,porte)%,Nfft_t,fmin,fmax)
% 
% % Fonction permettant d'ouvrir sur matlab les fichiers .conf et .us obtenus
% % à partir des acquisitions par la sonde aza_v5
% 
% %%% Input de la fonction
% % start_path = chemin relatif du dossier mesures à partir du dossier codes
% % matlab
% % chemin1 = chemin absolu du dossier qui contient les mesures .us et .conf
% % indice = numéro du .us, si 0 tous les .us
% % unite == 0 en mV, unite == 1 en niveau echantillonnage
% % porte == 1 application d'une fenêtre TuckeyWin sur les signaux temporels
% 
% %%% Output de la fonction
% % SIG2 = Matrice de taille Nt x nb_recepteur x nb_emission x indice x direction
% % fe = freq ech (20 MHz pour AZA)
% % f0 = Frequence centrale
% % data = structure des paramètres généraux des acquisitions
% % temps = vecteur temporel associé aux signaux acquis
% % RSS rapport signal à saturation (2048) nb_recepteur x nb_emission x indice x direction
% % RSB rapport signal à bruit (2048) nb_recepteur x nb_emission x indice x direction
% 
% % Date : novembre 2013
% % Auteur : Quentin Vallet
% % Dernière MAJ : 05/12/2013
% % JGM 9 janv 2013

function [SIG2,fe,f0,data,temps, niveauS,niveauB,niveauSat] = ouverture_aza_v5(start_path,chemin1,indice,unite,porte)%,Nfft_t,fmin,fmax)
% 
% if e ~= 0
%     Nom = [date,'/v3_',objet,'_',num2str(e),'mm'];%_',num2str(f0),'MHz'];
% elseif e == 0 %& metal ~='air'
%     Nom = [chemin1];
%     %Nom = [date,'/',objet,'/',heure];
%     NomFichierConf = [date,'__',heure,'.conf'] %
% end
% 
% if  strcmp(computer,'PCWIN64') == 1%computer == 'PCWIN'
%     Nom_sortie = [Nom,'\'];
% else
%     Nom_sortie = [Nom,'/'] ;
% end
%Nom_sortie = chemin1;

cd(chemin1);

if  strcmp(computer,'PCWIN64') == 1%computer == 'PCWIN'
NomFichierConf = ls('*.conf')
else
    d_Pconf = dir('*.conf');
   NomFichierConf = d_Pconf.name;
end

cd(start_path);

%%% Sortie des paramètres généraux (Etats émetteurs, gains, délais...)
[data] = LireFichierConfig_aza_v5(NomFichierConf,start_path,chemin1);



%%% Definition des parametres generaux
f0 = data.Freq_centrale/1000 ; % Frequence centrale (kHz)
fe = 20 ;
nb_recepteur = data.nb_recepteur ; % Nombre de recepteurs
Nt = data.Nt ; % Nombre de points
nb_emission = data.nb_deflexion ; % Nombre d'emissions : 1 SINGLE, 5 SCANNED, 1 à 10 MULTIPLE


%%% Chargement des délais et gains
delai = zeros(nb_recepteur,nb_emission,2);
gain = zeros(nb_recepteur,nb_emission,2);

% Chargement des gains et des délais
for direc = 1:2 % zone d'émission
    for num_em = 1 : nb_emission % numéro d'émission
        delai(1:nb_recepteur,num_em,direc) = data.zone(direc).emission(num_em).Delai(1:nb_recepteur) ;
        gain(1:nb_recepteur,num_em,direc) = data.zone(direc).emission(num_em).Gain(1:nb_recepteur) ;
    end
end


%%% Liste des .us
cd(chemin1)

if  strcmp(computer,'PCWIN64') == 1
    list = ls('*.us');
N1 = str2double(list(1,1:4));
N2 = str2double(list(end,1:4));
    
else
    liste_complete = dir('*.us');
    nchar = find(liste_complete(1).name =='.')-1;
    N1=str2double(liste_complete(1).name(1:nchar));
    N2=str2double(liste_complete(end).name(1:nchar));
end

%%% Nombre de .us ou cycle
%N_cycle = N2-N1+1;

%%% Initialisation de la matrice signal SIG
SIG = zeros(Nt,nb_recepteur,nb_emission,length(indice),2);

data1 = zeros(Nt,nb_recepteur);
data2 = zeros(Nt,nb_recepteur);

DureeTransition=2/f0;
DureeSignal=Nt/fe;
Gate=tukeywin(Nt,2*DureeTransition/DureeSignal)*ones(1,nb_recepteur);
if porte == 0
    Gate(1:round(Nt/2),1:nb_recepteur)=ones(round(Nt/2),nb_recepteur);
end

if indice == 0
    indice = N1:N2;%1:N_cycle;
end

%%% Définition de la matrice signal SIG
for n_c = indice;% 1:N_cycle   
    %%% Chargement du .us
    if n_c <= 9
        filename = ['000',num2str(n_c),'.us'];
    elseif n_c >= 10 && n_c <=99
        filename = ['00',num2str(n_c),'.us'];
    else n_c >= 100 ;
        filename = ['0',num2str(n_c),'.us'];
    end
    eval(['raw_file=fopen(''' filename ''',''r'');']);
    
    Taille = fread(raw_file,1,'int16');
    Signature = fread(raw_file,1,'schar'); % en binaire 90 => 0x5A en hexa
    Version = fread(raw_file,2,'int8=>char'); % 25, 26 ou 27
    ChekSum = fread(raw_file,1,'uchar');
    Commentaire = fread(raw_file, Taille-6,'uint8=>char');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%% Lecture des parametres utiles de l'entete %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % LECTURE des SIGNAUX
    data_tot = fread(raw_file,nb_recepteur*2*(Nt)*nb_emission,'uint16');    
    fclose('all');
    for num_em = 1:nb_emission
        N1 = nb_recepteur*Nt;
        ind1 = 2*(num_em-1)*N1;
        ind2 = 2*(num_em-1)*N1+N1;
        
        data1(1:Nt,1:nb_recepteur) = reshape(data_tot(ind1+1:ind1+N1),Nt,nb_recepteur);
        data2(1:Nt,1:nb_recepteur) = reshape(data_tot(ind2+1:ind2 + N1),Nt,nb_recepteur);
        
        % Moyenne retirée 
        SIG(:,:,num_em,n_c-indice(1)+1, 1) = (data1 - ones(Nt,1)*mean(data1,1)).*Gate;%squeeze(SIG(:,:,num_em, 1)) ;%+
        SIG(:,:,num_em,n_c-indice(1)+1 ,2) = (data2 - ones(Nt,1)*mean(data2,1)).*Gate;%squeeze(SIG(:,:,num_em, 2)) ;%+
        
        % Moyenne pas retirée
        %SIG(:,:,num_em,n_c-indice(1)+1, 1)= (data1 ).*Gate;%squeeze(SIG(:,:,num_em, 1)) ;%+
        %SIG(:,:,num_em,n_c-indice(1)+1 ,2) =  (data2 ).*Gate;%squeeze(SIG(:,:,num_em, 2)) ;%+

%         m = max(max(squeeze(SIG(:,:,num_em,n_c-indice(1)+1,1))));
%         figure(10)
%         for nn = 1:nb_recepteur
%             plot(nn+squeeze(SIG(:,nn,num_em,n_c-indice(1)+1, 1))/50)
%             hold on
%         end
%         hold off
%         pause
    end
    

    clear data_tot  
end

%%% Rapports dynamique verticale
niveauS = zeros(nb_recepteur,nb_emission,length(indice),2) ;
niveauB = zeros(nb_recepteur,nb_emission,length(indice),2) ;
niveauSat = zeros(nb_recepteur,nb_emission,length(indice),2) ;

 nb_seuil = 2048 ;
n_bruit = 30 ;
% 
% for nn = indice
%     for nr = 1:nb_recepteur
%         for ne = 1:nb_emission
%             for dir = 1:2
%                 niveauS(nr,ne,nn,dir) = max(abs(SIG(:,nr,ne,nn,dir)));%/nb_seuil ;
%                 niveauB(nr,ne,nn,dir) = (max(SIG(1:n_bruit,nr,ne,nn,dir)) - min(SIG(1:n_bruit,nr,ne,nn,dir)));%/...
%                    % max(abs(SIG(:,nr,ne,nn,dir))) ;
%             end
%         end
%     end
% end


cd(start_path);

% temps = (1:2*Nt)/fe;
DN = zeros(1,nb_emission) ;

for num_em = 1 : nb_emission
    Nmax_delai = max(max(max(round(delai(:,num_em,:)*fe))));
    Nmin_delai = min(min(min(round(delai(:,num_em,:)*fe))));
    DN(num_em) = Nmax_delai - Nmin_delai ;
end

DNmax = max(DN) ;

%%% Initialisation de la matrice signal SIG2
SIG2 = zeros(Nt+DNmax,nb_recepteur,nb_emission,length(indice),2);
temps = zeros(Nt+DNmax,nb_emission,2);

%%% Définition de la matrice signal SIG2 avec la prise en compte du gain
for direc = 1:2
    for num_em = 1:nb_emission
        temps(:,num_em,direc) = (0:size(SIG2,1)-1)/fe+min(delai(:,num_em,direc));
        for n_c = 1:length(indice)% 1:N_cycle
            for num_rec = 1:nb_recepteur

                n_delai = round(delai(num_rec,num_em,direc)*fe)-round(min(delai(:,num_em,direc))*fe)+1;

                if unite == 0
                    gain_lin = exp(-gain(num_rec,num_em,direc)*log(10)/20);
                elseif unite == 1
                    gain_lin = 1;
                end

                SIG2(n_delai:n_delai+Nt-1,num_rec,num_em,n_c,direc) = gain_lin*SIG(1:Nt,num_rec,num_em,n_c,direc);
                
                niveauS(num_rec,num_em,n_c,direc) = gain_lin* max(abs(SIG(:,num_rec,num_em,n_c,direc)));%/nb_seuil ;
                niveauB(num_rec,num_em,n_c,direc) = gain_lin*(max(abs(diff(squeeze(SIG(1:n_bruit,num_rec,num_em,n_c,direc))))))   ;%(1/2*(max(SIG(1:n_bruit,num_rec,num_em,n_c,direc)) - min(SIG(1:n_bruit,num_rec,num_em,n_c,direc))));%/...
                niveauSat(num_rec,num_em,n_c,direc) = gain_lin*nb_seuil ;
           end
        end
    end
end
end