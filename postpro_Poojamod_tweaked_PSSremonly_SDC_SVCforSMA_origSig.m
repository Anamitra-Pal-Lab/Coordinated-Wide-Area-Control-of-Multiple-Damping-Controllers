 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% Program Name: InterfaceCreatio: DSA Tools to MATLAB %
% %
% Description:
% Author: Pooja Gupta %
% Arizona State University %
% %
% Last Modified: 04/10/2019 %
% %
% Prerequisite : Run svm_mgen for the case used for PSLF. Need details for
% C1S using C_ang obtained from svm_mgen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nInfoLMIN = [1 4 14 11 15.25 2.95;
           1 3 14 11 15.25 2.95;
           1 2 14 11 15.25 2.95;
           1 1 14 11  15.25 2.95;
           5 1 14 11 90.04 4.34;
           8 1 14 11 130.0  3.46;
           13 1 21 18 54.21 3.67;
           19 1 20 17 11.99 3.0;
           26 1 14 11 30.85 3.38;
           28 1 21 18 17.70 2.32;
           33 1 21 18 8.32  3.01;
           38 1 21 18 22.29 2.82;
           44 1 21 18 19.82 2.88;
           46 1 21 18 14.88 2.61;
           47 1 14 11 30.0  2.45;
           49 1 20 17 20.54 2.63;
           53 1 20 17 24.58 3.42;
           5699 1 20 17 9.14 2.64;
           60 1 20 17 31.17 3.83;
           62 1 20 17 35.4  3.59;
           65 1 20 17 21.04 6.07;
           67 2 20 17 9.09  3.49;
           67 1 20 17 9.09  3.49;
           72 1 14 9 30    2.75;
           76 1 20 17 90    2.82;
           81 2 20 17 12.50 3.03;
           81 1 20 17 12.50 3.03;
           91 1 20 17 68.40 3.82;
           96 1 20 17 10.6 4.39;
           102 1 20 17 8.95 4.16;
           113 1 12  9 2.70 4.13;
           119 1 20 17 1.13 3.8;
           126 1 20 17 2.5  6.41;];
nInfoLMIN(1,8)  =  nInfoLMIN(1,3);
nInfoLMIN(1,7)  = 1;
for i =2 :length(nInfoLMIN)
    nInfoLMIN(i,8) = nInfoLMIN(i,3) + nInfoLMIN(i-1,8); %%   8th column gives the total number of states till that generator 
    nInfoLMIN(i,7) = nInfoLMIN(i-1,3) + nInfoLMIN(i-1,7); %% 7th column gives the starting index of each generator 
end
%% specify number of machines and number of modes
nModeN = 657; nUnitN = length(nInfoLMIN); nSVC = 1; nWindUnit = 2; nSDC = 1; var = 0;
fName = strcat('C:\pstv3\pstv3\GriddingPoints\TrainingData\Case6VinInc\300_inc_657_12_15.sma'); %('SSAT_GriddingBase.sma'); %('SSAT_BaseCase824MW.sma')%('SSAT_IncBy220.sma');%('LoadIncbus6by25.sma'); ('SSAT_LoadBus24IncBy25.sma');%'55LoadIncby50.sma' %'LoadIncbus6by25.sma'%'SSATBase_tweak.sma'
% nModeN = 656;fName = strcat('C:\pstv3\pstv3\GriddingPoints\DampedCases\SSAT_Serrano_LoadDec_500_Damp.sma'); %('SSAT_GriddingBase.sma'); %('SSAT_BaseCase824MW.sma')%('SSAT_IncBy220.sma');%('LoadIncbus6by25.sma'); ('SSAT_LoadBus24IncBy25.sma');%'55LoadIncby50.sma' %'LoadIncbus6by25.sma'%'SSATBase_tweak.sma'

fID = fopen(fName,'r');
% skip first 21 lines
for n=1:21
 strTemp=fgets(fID);
end
% read Asys from file
for n=1:nModeN
 for m=1:nModeN
 fTemp1=fscanf(fID,'%g',1);
 A1(m,n)=fTemp1;
 end
end
fclose(fID);
% calc=eig(A1);
%% End of Read data from files
% P = load('flowinc_unprocess');
% A1 =P.A3;

%% For rearrangement of A and B matrices
nn = size(A1)*[1 0]'; % nn = Size of System
for n = 1:nUnitN %4
  nStateN = nInfoLMIN(n,3);
  nStateEnd = nInfoLMIN(n,8);
  nStateStart = nInfoLMIN(n,7);
  r2(n,1)  = nStateStart+1;                  % corresponds to deltas of machines
  r2_Ref(n,1)  = nStateStart+1;  
end
nInfoLMIN(5,11) = 1; nInfoLMIN(5,12) = 14;
var1 = nInfoLMIN(5,11); var2 = nInfoLMIN(5,12);
for n = 6:nUnitN %4
  if (nInfoLMIN(n,1) ~=1) & (nInfoLMIN(n,1) ~=19) & (nInfoLMIN(n,1) ~=33) & (nInfoLMIN(n,1) ~=96) & (nInfoLMIN(n,1) ~=102) & (nInfoLMIN(n,1) ~=113) & (nInfoLMIN(n,1) ~=119) & (nInfoLMIN(n,1) ~=126)
%    if (nInfoLMIN(n,1) ~=1) & (nInfoLMIN(n,1) ~=19) & (nInfoLMIN(n,1) ~=33) & (nInfoLMIN(n,1) ~=81)& (nInfoLMIN(n,1) ~=96) & (nInfoLMIN(n,1) ~=102) & (nInfoLMIN(n,1) ~=113) & (nInfoLMIN(n,1) ~=119) 
      nInfoLMIN(n,11) = var2 + 1;
      nInfoLMIN(n,12) = var2 + nInfoLMIN(n,3);
      var1 = nInfoLMIN(n,11);
      var2 = nInfoLMIN(n,12);
  end
end

%% transformation of A matrix by removing del of reference machine
Atrans= A1;
for i =1:length(r2)
    if r2(i) ~= 86  %% if reference mc is included first,all machines after ref will not have  two non-zero entries for their del
        Atrans(r2(i),:)= Atrans(r2(7),:) - Atrans(r2(i),:); %% row modification   7th machine is the refernce machine
        Atrans(:,r2(i))= Atrans(:,r2(7)) - Atrans(:,r2(i)); %% column modification       
    end
end
Atrans(r2(7),:)= Atrans(r2(7),:) - Atrans(r2(7),:); %% row modification   3rd machine is the refernce machine
Atrans(:,r2(7))= Atrans(:,r2(7)) - Atrans(:,r2(7)); %% column modification
% remove non-zero row and column of refernce machine
Atrans(r2(7),:) = [];     %3rd machine is the refernce machine
Atrans(:,r2(7)) = [];
% B_PSS_SVC_SDC(r2(7),:) = [];
r2=[];

r3 =[]; r4 =[]; r5 =[];r_link2_1311_1313_comp =[];rOmeg =[];rDel =[];c1=1;r_storPSS_ind_rPSS =[];r_storPSS_ind_rPSS_nz=[];
r3_1 =[]; r4_1 =[]; r5_1 =[];r_link2_1311_1313_comp_1 =[];rOmeg_1 =[];rDel_1 =[]; r_stor_Del=[];r_stor_Omg=[];Locb2=[];Locb3=[];

for n = 1:nUnitN %4
      nStateN = nInfoLMIN(n,3);
      nStateEnd = nInfoLMIN(n,8);
      nStateStart = nInfoLMIN(n,7);
      nStateStart_1 = nInfoLMIN(n,11);
      nStateEnd_1 = nInfoLMIN(n,12);
   if nInfoLMIN(n,1) ~=13 & var == 0
      r1  = nStateStart;                  % corresponds to omegas of machines
      r2  = nStateStart+1;                  % corresponds to deltas of machines
      r   = nStateStart+2:nStateStart+8;  % corresponds to remaining states of generators and exciters
      r1_1  = nStateStart_1;                  % corresponds to omegas of machines
      r2_1  = nStateStart_1+1;                  % corresponds to deltas of machines
      r_1   = nStateStart_1+2:nStateStart_1+8;  % corresponds to remaining states of generators and exciters

      if nInfoLMIN(n,1) ~=72
          r_PSS    = nStateStart+9;% corresponds to PSS states
          r_PSS_nz = nStateStart+10:nStateStart+11;
         if (nInfoLMIN(n,1) ==1) || (nInfoLMIN(n,1) ==19) || (nInfoLMIN(n,1) ==33) || (nInfoLMIN(n,1) ==96) || (nInfoLMIN(n,1) ==102) || (nInfoLMIN(n,1) ==113) || (nInfoLMIN(n,1) ==119) || (nInfoLMIN(n,1) ==126)
%          if (nInfoLMIN(n,1) ~=1) & (nInfoLMIN(n,1) ~=19) & (nInfoLMIN(n,1) ~=33) & (nInfoLMIN(n,1) ~=81)& (nInfoLMIN(n,1) ~=96) & (nInfoLMIN(n,1) ~=102) & (nInfoLMIN(n,1) ~=113) & (nInfoLMIN(n,1) ~=119) 

             r_storPSS_ind_rPSS = [r_storPSS_ind_rPSS; r_PSS'];
              r_storPSS_ind_rPSS_nz = [r_storPSS_ind_rPSS_nz; r_PSS_nz'];
              r_stor_Del =[r_stor_Del;r2'];
              r_stor_Omg =[r_stor_Omg;r1'];
          end
          r_gov    = nStateStart+12:nStateEnd;% corresponds to governor states   
          r_PSS_1    = nStateStart_1+9;% corresponds to PSS states -changed 
          r_PSS_nz_1 = nStateStart_1+10:nStateStart_1+11;
          r_gov_1    = nStateStart_1+12:nStateEnd_1;% corresponds to governor states   
 
      else
         r_PSS    = nStateStart+9-1:nStateStart+11-1;% corresponds to PSS states of Miraloma(72) which has 5 PSS states and no governor
              % 113 also has no governor,but not included specially since it has 3 PSS states like otherswhich is covered in logicitself                   
          r_PSS_nz = nStateStart+12-1:nStateStart+13-1;
           if (nInfoLMIN(n,1) ==1) || (nInfoLMIN(n,1) ==19) || (nInfoLMIN(n,1) ==33) || (nInfoLMIN(n,1) ==96) || (nInfoLMIN(n,1) ==102) || (nInfoLMIN(n,1) ==113) || (nInfoLMIN(n,1) ==119) || (nInfoLMIN(n,1) ==126)
%           if (nInfoLMIN(n,1) ~=1) & (nInfoLMIN(n,1) ~=19) & (nInfoLMIN(n,1) ~=33) & (nInfoLMIN(n,1) ~=81)& (nInfoLMIN(n,1) ~=96) & (nInfoLMIN(n,1) ~=102) & (nInfoLMIN(n,1) ~=113) & (nInfoLMIN(n,1) ~=119) 

              r_storPSS_ind_rPSS = [r_storPSS_ind_rPSS; r_PSS'];
              r_storPSS_ind_rPSS_nz = [r_storPSS_ind_rPSS_nz; r_PSS_nz'];
              r_stor_Del =[r_stor_Del;r2'];
              r_stor_Omg =[r_stor_Omg;r1'];
          end
          r_gov    = [];                   % addition of number of governor states to information matrix of generators
          r_PSS_1    = nStateStart_1+9;% corresponds to PSS states of Miraloma(72) which has 5 PSS states and no governor
          r_PSS_nz_1 = nStateStart_1+10:nStateStart_1+13;
          r_gov_1   =[];
      end
      rOmeg    = [rOmeg;r1'];
      rDel     = [rDel; r2'];
      r3       = [r3;r';r_gov'];  %% corresponds to rem states of generators, exciters and governors
      r4       = [r4; r_PSS_nz'];  %% corresponds to nz states of PSS
      r5       = [r5;r_PSS'];     %% corresponds to zero states of PSS
      rOmeg_1    = [rOmeg_1;r1_1'];
      rDel_1     = [rDel_1; r2_1'];
      r3_1       = [r3_1;r_1';r_gov_1'];  %% corresponds to rem states of generators, exciters and governors
      r4_1       = [r4_1; r_PSS_nz_1'];  %% corresponds to nz states of PSS
      r5_1       = [r5_1;r_PSS_1'];     %% corresponds to zero states of PSS

   else
      var = 1;
      if nInfoLMIN(n,1) ~=13
         r1  = nStateStart - 1;                  % corresponds to omegas of machines
         r2  = nStateStart+1-1;
         rDel     = [rDel; r2'];
         r1_1  = nStateStart_1 - 1;                  % corresponds to omegas of machines
         r2_1  = nStateStart_1+1-1;
         rDel_1     = [rDel_1; r2_1'];
      else
          r1  = nStateStart;                  % corresponds to omegas of machines
          r1_1  = nStateStart_1;
      end
      r   = nStateStart+2-1:nStateStart+8-1;  % corresponds to remaining states of generators and exciters
      r_1   = nStateStart_1+2-1:nStateStart_1+8-1;  % corresponds to remaining states of generators and exciters

      if nInfoLMIN(n,1) ~=72
         r_PSS    = nStateStart+9-1;% corresponds to PSS states
         r_PSS_nz = nStateStart+10-1:nStateStart+11-1;
         if (nInfoLMIN(n,1) ==1) || (nInfoLMIN(n,1) ==19) || (nInfoLMIN(n,1) ==33) || (nInfoLMIN(n,1) ==96) || (nInfoLMIN(n,1) ==102) || (nInfoLMIN(n,1) ==113) || (nInfoLMIN(n,1) ==119) || (nInfoLMIN(n,1) ==126)
%            if (nInfoLMIN(n,1) ~=1) & (nInfoLMIN(n,1) ~=19) & (nInfoLMIN(n,1) ~=33) & (nInfoLMIN(n,1) ~=81)& (nInfoLMIN(n,1) ~=96) & (nInfoLMIN(n,1) ~=102) & (nInfoLMIN(n,1) ~=113) & (nInfoLMIN(n,1) ~=119) 
              r_storPSS_ind_rPSS = [r_storPSS_ind_rPSS; r_PSS'];
              r_storPSS_ind_rPSS_nz = [r_storPSS_ind_rPSS_nz; r_PSS_nz'];
              r_stor_Del =[r_stor_Del;r2'];
              r_stor_Omg =[r_stor_Omg;r1'];
         end 
          r_gov    = nStateStart+12-1:nStateEnd-1;% corresponds to governor states   
          r_PSS_1    = nStateStart_1+9-1;% corresponds to PSS states
          r_PSS_nz_1 = nStateStart_1+10-1:nStateStart_1+11-1;
          r_gov_1    = nStateStart_1+12-1:nStateEnd_1-1;% corresponds to governor states   

      else
          r_PSS    = nStateStart+10-1:nStateStart+12-1;% corresponds to PSS states of Miraloma(72) which has 5 PSS states and no governor
              % 113 also has no governor,but not included specially since it has 3 PSS states like otherswhich is covered in logicitself                   
          r_PSS_nz = nStateStart+13-1:nStateStart+14-1;
         if (nInfoLMIN(n,1) ==1) || (nInfoLMIN(n,1) ==19) || (nInfoLMIN(n,1) ==33) || (nInfoLMIN(n,1) ==96) || (nInfoLMIN(n,1) ==102) || (nInfoLMIN(n,1) ==113) || (nInfoLMIN(n,1) ==119) || (nInfoLMIN(n,1) ==126)
%            if (nInfoLMIN(n,1) ~=1) & (nInfoLMIN(n,1) ~=19) & (nInfoLMIN(n,1) ~=33) & (nInfoLMIN(n,1) ~=81)& (nInfoLMIN(n,1) ~=96) & (nInfoLMIN(n,1) ~=102) & (nInfoLMIN(n,1) ~=113) & (nInfoLMIN(n,1) ~=119) 
               r_storPSS_ind_rPSS = [r_storPSS_ind_rPSS; r_PSS'];
               r_storPSS_ind_rPSS_nz = [r_storPSS_ind_rPSS_nz; r_PSS_nz'];
               r_stor_Del =[r_stor_Del;r2'];
               r_stor_Omg =[r_stor_Omg;r1'];
          end
          r_gov    = [];   
          r_PSS_1    = nStateStart_1+9-1;% corresponds to PSS states of Miraloma(72) which has 5 PSS states and no governor
          r_PSS_nz_1 = nStateStart_1+10-1:nStateStart_1+13-1;
          r_gov_1    = []; 
      end
      rOmeg    = [rOmeg;r1'];
      r3       = [r3;r';r_gov'];  %% corresponds to rem states of generators, exciters and governors
      r4       = [r4; r_PSS_nz'];  %% corresponds to nz states of PSS
      r5       = [r5;r_PSS'];     %% corresponds to zero states of PSS
      rOmeg_1    = [rOmeg_1;r1_1'];
      r3_1       = [r3_1;r_1';r_gov_1'];  %% corresponds to rem states of generators, exciters and governors
      r4_1       = [r4_1; r_PSS_nz_1'];  %% corresponds to nz states of PSS
      r5_1       = [r5_1;r_PSS_1'];     %% corresponds to zero states of PSS

  end
  nInfoLMIN(n,9) = length([r_PSS';r_PSS_nz']);   % addition of number of governor states to information matrix of generators
  nInfoLMIN(n,10) = length(r_gov);   % addition of number of governor states to information matrix of generators
end
r_SVC = (nInfoLMIN(nUnitN,8))+1-1:(nInfoLMIN(nUnitN,8))-1+(3*nSVC);  %nModeN;  % corresponds to SVCs states
r_wind = r_SVC(1,end)+1:r_SVC(1,end)+(9*nWindUnit);  %corresponds to wind turbines states
r_SVC1 = (nInfoLMIN(28,11))+1-1:(nInfoLMIN(28,11))-1+(3*nSVC);  %nModeN;  % corresponds to SVCs states
r_wind1 = r_SVC1(1,end)+1:r_SVC1(1,end)+(9*nWindUnit);  %corresponds to wind turbines states

%% DC link 1 
%   r_link1_1312_1314  = r_wind(1,end)+1:r_wind(1,end)+9; %%  with 9 states for DC link 1 -with 656 states
%   r_link1_1312_1314  = r_wind(1,end)+1:r_wind(1,end)+13; %%  with 13 states for DC link 1
r_link1_1312_1314  = r_wind(1,end)+1:r_wind(1,end)+12; %%  with 12 states for DC link 1
% r_link1_1312_1314  = r_wind(1,end)+1:r_wind(1,end)+6;    %% for 653 states with only 6 states for DC link 1
% r_link1_1312_1314  = r_wind(1,end)+1:r_wind(1,end)+10;    %% for 653 states with only 6 states for DC link 1
%   r_link1_1312_1314_1  = r_wind1(1,end)+1:r_wind1(1,end)+9; %%  with 9 states for DC link 1 -with 656 states
%  r_link1_1312_1314_1  = r_wind1(1,end)+1:r_wind1(1,end)+13; %%  with 13 states for DC link 1
r_link1_1312_1314_1  = r_wind1(1,end)+1:r_wind1(1,end)+12; %%  with 12 states for DC link 1
% r_link1_1312_1314_1  = r_wind1(1,end)+1:r_wind1(1,end)+6;    %% for 653 states with only 6 states for DC link 1
% r_link1_1312_1314_1  = r_wind1(1,end)+1:r_wind1(1,end)+10;    %% for 653 states with only 6 states for DC link 1

%% DC Link 2
% r_link2_1311_1313_nonSDC  = [r_link1_1312_1314(1,end)+1:r_link1_1312_1314(1,end)+4  r_link1_1312_1314(1,end)+6:r_link1_1312_1314(1,end)+8 r_link1_1312_1314(1,end)+10];
% r_link2_1311_1313_nonSDC_rem  = [r_link1_1312_1314(1,end)+12:r_link1_1312_1314(1,end)+15 r_link1_1312_1314(1,end)+17];
% r_link2_1311_1313_nonSDC_1  = [r_link1_1312_1314_1(1,end)+1:r_link1_1312_1314_1(1,end)+4  r_link1_1312_1314_1(1,end)+6:r_link1_1312_1314_1(1,end)+8 r_link1_1312_1314_1(1,end)+10];
% r_link2_1311_1313_nonSDC_rem_1  = [r_link1_1312_1314_1(1,end)+12:r_link1_1312_1314_1(1,end)+15 r_link1_1312_1314_1(1,end)+17];

%%modified for 15 states for DC link2
r_link2_1311_1313_nonSDC  = [r_link1_1312_1314(1,end)+1:r_link1_1312_1314(1,end)+4  r_link1_1312_1314(1,end)+6:r_link1_1312_1314(1,end)+7 r_link1_1312_1314(1,end)+9:r_link1_1312_1314(1,end)+13];
r_link2_1311_1313_nonSDC_rem  = r_link1_1312_1314(1,end)+15;
r_link2_1311_1313_nonSDC_1  = [r_link1_1312_1314_1(1,end)+1:r_link1_1312_1314_1(1,end)+4  r_link1_1312_1314_1(1,end)+6:r_link1_1312_1314_1(1,end)+7 r_link1_1312_1314_1(1,end)+9:r_link1_1312_1314_1(1,end)+13];
r_link2_1311_1313_nonSDC_rem_1  = r_link1_1312_1314_1(1,end)+15;

%% SDC states in DC link appears at positions 13, 14 and 15 in A matrix, but their impact on rectifiers (position 5 and 16),master control (position 11) and inverters (position 11) appears at different positions
% r_link2_1311_1313_SDC  = r_link1_1312_1314(1,end)+13:r_link1_1312_1314(1,end)+15;
%  r_link2_1311_1313_SDC  = [r_link1_1312_1314(1,end)+5 r_link1_1312_1314(1,end)+9 r_link1_1312_1314(1,end)+11 r_link1_1312_1314(1,end)+16];
%  r_link2_1311_1313_comp = [r_link2_1311_1313_nonSDC'; r_link2_1311_1313_nonSDC_rem'; r_link2_1311_1313_SDC']
% r_link2_1311_1313_SDC_1  = r_link1_1312_1314_1(1,end)+13:r_link1_1312_1314_1(1,end)+15;
%  r_link2_1311_1313_SDC_1  = [r_link1_1312_1314_1(1,end)+5 r_link1_1312_1314_1(1,end)+9 r_link1_1312_1314_1(1,end)+11 r_link1_1312_1314_1(1,end)+16];
%  r_link2_1311_1313_comp_1 = [r_link2_1311_1313_nonSDC_1'; r_link2_1311_1313_nonSDC_rem_1'; r_link2_1311_1313_SDC_1']


%%modified for 15 states for DC link2
%% SDC states in DC link appears at positions 13, 14 and 15 in A matrix, but their impact on rectifiers (position 5 and 14),master control (missing) and inverters (position 8) appears at different positions
% r_link2_1311_1313_SDC  = r_link1_1312_1314(1,end)+13:r_link1_1312_1314(1,end)+15;
r_link2_1311_1313_SDC  = [r_link1_1312_1314(1,end)+5 r_link1_1312_1314(1,end)+8 r_link1_1312_1314(1,end)+14];
r_link2_1311_1313_comp = [r_link2_1311_1313_nonSDC'; r_link2_1311_1313_nonSDC_rem'; r_link2_1311_1313_SDC']
% r_link2_1311_1313_SDC_1  = r_link1_1312_1314_1(1,end)+13:r_link1_1312_1314_1(1,end)+15;
r_link2_1311_1313_SDC_1  = [r_link1_1312_1314_1(1,end)+5 r_link1_1312_1314_1(1,end)+8 r_link1_1312_1314_1(1,end)+14];
r_link2_1311_1313_comp_1 = [r_link2_1311_1313_nonSDC_1'; r_link2_1311_1313_nonSDC_rem_1'; r_link2_1311_1313_SDC_1']

%% DC link 3
r_link3_INT_ADL  = r_link2_1311_1313_nonSDC_rem(1,end)+1:r_link2_1311_1313_nonSDC_rem(1,end)+5;
r_link3_INT_ADL_1  = r_link2_1311_1313_nonSDC_rem_1(1,end)+1:r_link2_1311_1313_nonSDC_rem_1(1,end)+5;

%% Rearranging the indices
% r =  [r2' r1' r3' r5' r4' r_wind' r_link1_1312_1314' r_link3_INT_ADL' r_link2_1311_1313_nonSDC' r_link2_1311_1313_nonSDC_rem' r_SVC' r_link2_1311_1313_SDC];
% Arrangement done such that all other states apart for main controls come
% first followed by wind and DC links, then non-zero states of PSS and SVC, finally all controllers
% r_stor_Omg(9,1) = 378; r_stor_Omg(12,1) = 398;
% r_stor_Del(9,1) = 379; r_stor_Del(12,1) = 399;
% r_storPSS_ind_rPSS(9,1) = 378 + 9; r_storPSS_ind_rPSS(12,1) = 398 + 9;
% r_storPSS_ind_rPSS_nz(17,1) = 378 + 10; r_storPSS_ind_rPSS_nz(18,1) = 378 + 11;
% r_storPSS_ind_rPSS_nz(23,1) = 398 + 10; r_storPSS_ind_rPSS_nz(24,1) = 398 + 11;
% r_stor_Omg(13,1) = 378; r_stor_Omg(12,1) = 398;
% r_stor_Del(13,1) = 379; r_stor_Del(12,1) = 399;
% r_storPSS_ind_rPSS(13,1) = 378 + 9; r_storPSS_ind_rPSS(12,1) = 398 + 9;
% r_storPSS_ind_rPSS_nz(25,1) = 378 + 10; r_storPSS_ind_rPSS_nz(26,1) = 378 + 11;
% r_storPSS_ind_rPSS_nz(23,1) = 398 + 10; r_storPSS_ind_rPSS_nz(24,1) = 398 + 11;
% r_stor_Omg(14,1) = 125; r_stor_Del(14,1) = 126; r_storPSS_ind_rPSS(14,1) = 125 + 9;
% r_storPSS_ind_rPSS_nz(27,1) = 125+10; r_storPSS_ind_rPSS_nz(28,1)=125+11;
[Lia,Locb] = ismember(r_storPSS_ind_rPSS,r5);
[Lia1,Locb1] = ismember(r_storPSS_ind_rPSS_nz,r4);
r5(Locb,:)=[];
r4(Locb1,:)=[];
[Lia2,Locb2] = ismember(r_stor_Del,rDel);
[Lia3,Locb3] = ismember(r_stor_Omg,rOmeg);
rDel(Locb2,:)=[];
rOmeg(Locb3,:)=[];
% r =  [ rDel'  rOmeg' r_stor_Del' r_stor_Omg' r_link2_1311_1313_SDC r_SVC(1,2):r_SVC(1,3) r5' r3' r_wind r_link1_1312_1314 r_link3_INT_ADL r_stor_Del' r_stor_Omg' r_link2_1311_1313_nonSDC r_link2_1311_1313_nonSDC_rem  r_SVC(1,1) r4' ];
r =  [ rDel'  rOmeg' r_SVC(1,2):r_SVC(1,3) r5' r3' r_wind r_link1_1312_1314 r_link3_INT_ADL r_link2_1311_1313_nonSDC r_link2_1311_1313_nonSDC_rem  r4' r_SVC(1,1) r_link2_1311_1313_SDC ];

rB =  [ rDel_1'  rOmeg_1' r_SVC1(1,2):r_SVC1(1,3) r5_1' r3_1' r_wind1 r_link1_1312_1314_1 r_link3_INT_ADL_1 r_link2_1311_1313_nonSDC_1 r_link2_1311_1313_nonSDC_rem_1 r4_1' r_SVC1(1,1) r_link2_1311_1313_SDC_1 ];

%% Rearranging A matrix
A = zeros(length(r),length(r));
nn = size(A)*[1 0]'; % nn = Size of System
A(1:nn,1:nn) = Atrans(r,r);


%% specify number of controls
% nStatesControl = length(nInfoLMIN)+ 2*nSVC + 4*nSDC ; % Number of states per Control ; here 2 corresponds to non-zero states per svc and 4 non-zero states per SDC 
% noOfControl =  length(nInfoLMIN)+ nSVC + nSDC ; 
SDCstates=length(r_link2_1311_1313_SDC);
nStatesControl = 1*nSVC + SDCstates +  (22*2) ; % Number of states per Control ; here 2 corresponds to non-zero states per svc and 4 non-zero states per SDC 
noOfControl = nSVC + nSDC +  22; 
n4 = nn - nStatesControl; 

%%%% Begin to set B, C, D matrix
%% B matrix formed only using non-zero states of all controls 
%%%%%%%%%%% --------------Not Rearranged B --------------------%%%%%%%%%%% 
% B_PSS_SVC_SDC = zeros(nModeN,nUnitN+(nSVC*2)+(nSDC*4));  %% number of non-zero states associated with each SVC is 2 for svswsc and SDC is 4
% B_PSS_SVC_SDC = zeros(size(r,2)+1,(2*22+2)+(nSVC*2)+(nSDC*4));  %% number of non-zero states associated with each SVC is 2 for svswsc and SDC is 4
B_PSS_SVC_SDC = zeros(size(Atrans,1),(nSVC*1)+(nSDC*4)+ (2*22)) ;  %% number of non-zero states associated with each SVC is 2 for svswsc and SDC is 4
d = 1;q=1;
for n = 1:22
%    if (nInfoLMIN(n,1) ~=1) & (nInfoLMIN(n,1) ~=19) & (nInfoLMIN(n,1) ~=33) & (nInfoLMIN(n,1) ~=96) & (nInfoLMIN(n,1) ~=102) & (nInfoLMIN(n,1) ~=113) & (nInfoLMIN(n,1) ~=119) & (nInfoLMIN(n,1) ~=126)   

%         if nInfoLMIN(n,1) ~=72
%             B_PSS_SVC_SDC(nInfoLMIN(n,7)+10,d) = 0.1;
%             B_PSS_SVC_SDC(nInfoLMIN(n,7)+11,d) = 1/0.2;  %% 11th index because index starts from 1,not 0
%         else
%              B_PSS_SVC_SDC(nInfoLMIN(n,7)+13,d) = 0.1;
%              B_PSS_SVC_SDC(nInfoLMIN(n,7)+14,d) = 1/0.2;
%         end 
            B_PSS_SVC_SDC(r4(q),d) = 0.1;
            B_PSS_SVC_SDC(r4(q+1),d+1) = 1/0.2;
        d = d + 2;
        q = q + 2;
%    end
end

% for n = 1:nUnitN 
%     if n== 7  % corresponds to removal of row corresponding to ref machine
%            B_PSS_SVC_SDC((r2_Ref(n,1)),:) = [];
%     end 
% end

% adding svc states apart from generators-adding at all non-zero positions
% Here assumed that all SVCs are placed one after other
r_PSSrem = [r_storPSS_ind_rPSS;r_storPSS_ind_rPSS_nz];
startIndSVC =nInfoLMIN(end,8) - length(r_PSSrem);
for n = 1:nSVC 
    %chnaged in PSSrem
%     B_PSS_SVC_SDC(nInfoLMIN(end,11)+2,(2*n-1)) =16.6666679;  % 2n corresponds to 2non-zero svc states in B
%     B_PSS_SVC_SDC(nInfoLMIN(end,11),(2*n -0)) =4232.8041992;
    B_PSS_SVC_SDC(r_SVC(1,1),d) =16.6666679;  % 2n corresponds to 2non-zero svc states in B
%     B_PSS_SVC_SDC(nInfoLMIN(end,8),d) =4232.8041992;
    indB_SDC = 2*n;
     d = d + 1;
end

% adding sdc states apart from generators-adding at all non-zero positions
% Here assumed that all SDCs are placed one after other
for n = 1:nSDC 
    if length(r_link2_1311_1313_SDC) == 4
        B_PSS_SVC_SDC(r_link2_1311_1313_SDC(1,1),d) = -0.0487427;  %4n corresponds to 4 non-zero sdc states in B
        B_PSS_SVC_SDC(r_link2_1311_1313_SDC(1,2),d+1) =  0.0487427;
        B_PSS_SVC_SDC(r_link2_1311_1313_SDC(1,3),d+2) = -0.1799416;  
        B_PSS_SVC_SDC(r_link2_1311_1313_SDC(1,4),d+3) =  0.0487427;
    elseif length(r_link2_1311_1313_SDC) == 3
        B_PSS_SVC_SDC(r_link2_1311_1313_SDC(1,1),d) = -0.0487427;  %4n corresponds to 4 non-zero sdc states in B
        B_PSS_SVC_SDC(r_link2_1311_1313_SDC(1,2),d+1) =  0.0487427;
        B_PSS_SVC_SDC(r_link2_1311_1313_SDC(1,3),d+2) =  0.0487427;
    end
     d = d + 1;
end

%% Rearranged B controls
%  BB = 0*ones(655,nStatesControl); %all nc raw controls
% BB(1:size(r,2),1:nStatesControl) = B_PSS_SVC_SDC(r,1:nStatesControl);
for i =1:length(r)
    BB(i,1:nStatesControl) = B_PSS_SVC_SDC(r(i),1:nStatesControl);
end

% %% Transformation matrix to reduce the number of controls
% % each row corresponds to a single control; 
% % each column refers to number of non-zero states in a control
% gamma_PSS = eye(length(nInfoLMIN));
% gamma_RHS = zeros(length(nInfoLMIN),nStatesControl - length(nInfoLMIN));                                  
% gamma_PSS_RHS = horzcat(gamma_PSS,gamma_RHS);  %% defines the exact number of columns in gamma
% gamma_PSS = eye(22);
% gamma_RHS = zeros(22,nStatesControl - 22);  
% for i = 1:length(gamma_PSS)-1
%     gamma_PSS(i,i+1) = 1;
% end
% gamma_PSS(end,1) = 1;
% gamma_PSS_RHS = horzcat(gamma_PSS,gamma_RHS);  %% defines the exact number of columns in gamma

gamma_RHS = zeros(1,nStatesControl); 
%% PSS states
s=1;
gamma_pss = zeros(1,length(gamma_RHS));
for i =1:22
    gamma_pss(i,s) = 1;
    gamma_pss(i,s+1) = 1;
    s = s + 2;
end
% %% SVC states
gamma_svc = zeros(1,length(gamma_RHS));
% gamma_svc = zeros(1,length(gamma_PSS_RHS));
% gamma_svc(1,length(nInfoLMIN)+1) = 1;
% gamma_svc(1,length(nInfoLMIN)+2) = 1;
gamma_svc(1,end) = 1;
% gamma_svc(1,2) = 1; % considered one nonzero state only for SVC

% 
% %% SDC states
gamma_sdc = zeros(1,length(gamma_RHS));
% gamma_sdc(1,length(nInfoLMIN)+3) = 1;
% gamma_sdc(1,length(nInfoLMIN)+4) = 1;
% gamma_sdc(1,length(nInfoLMIN)+5) = 1;
% gamma_sdc(1,length(nInfoLMIN)+6) = 1;
gamma_sdc(1,45:45+length(r_link2_1311_1313_SDC)-1) = 1;
% gamma_sdc(1,4) = 1;
% gamma_sdc(1,22+5) = 1;
% gamma_sdc(1,22+6) = 1;
% 
% gamma = vertcat(gamma_PSS_RHS,gamma_svc,gamma_sdc); %% defines the exact number of rows in gamma
gamma = vertcat(gamma_pss,gamma_sdc,gamma_svc); %% defines the exact number of rows in gamma


% gamma = [1 0 0 0 0 0 0 0 0;  
%          0 1 0 0 0 0 0 0 0;
%          0 0 1 0 0 0 0 0 0;
%          0 0 0 1 0 0 0 0 0;
%          0 0 0 0 0 0 0 1 1];  % last row corresponds to svc with two non-zero states; first three states are zero
      
nnc = size(gamma)*[1 0]'; % Number of reduced controls
% 
% % Transforming the A-matrix
An(1:n4,1:n4) = A(1:n4,1:n4);
An(n4+1:n4+nnc,n4+1:n4+nnc) = gamma*A(n4+1:n4+nStatesControl,n4+1:n4+nStatesControl)*gamma';
AA = An;
% 
Bnn = gamma*BB(n4+1:nn,1:nStatesControl)*gamma';
Bn = [ 0*ones(nnc,n4) Bnn ]';
% Bn(595,1) = 0.1;
% Bn(643,1) = 0.1;
% Bn(600,1) = 0.1;
BB = [ Bn Bn ];
% BB = [ BB BB];
% after removal of delta
nModeN =nModeN-1;
%% C matrix
% C2S = zeros (nUnitN+6,nModeN); %%added 6 to make it compatible to D

save A_C6_300  AA%S_GridPoint_MiralomaCOI_case
save B_C6_300 BB 