% RP_STslope_bin = STslope;
% RP_STdev_bin = STdev;
% RP_HR_bin = HR;
% RP_DFA_bin = DFA;
% RP_ENERGY_RATIO_bin = ENERGY;
% RP_ENTROPY_CUTOFF_bin = SAMEN;
% RP_Tinv_bin = Tinv;
% RP_ToR_bin = ToR;
% score_bin = SCORE;
% HRV_std_bin = HRV_std;
% HRV_max_bin = HRV_max;
% HRV_min_bin = HRV_min;
% HRV_minmax_bin = HRV_minmax;
% HRV_DFA_bin = HRV_DFA;

aaaa = [RP_STslope_bin RP_STdev_bin RP_HR_bin RP_DFA_bin ...
        RP_ENERGY_RATIO_bin RP_ENTROPY_CUTOFF_bin ...
        RP_Tinv_bin RP_ToR_bin score_bin];

STATUS = [];
for i = 1:length(aaaa)
    if aaaa(i,9) >= 2
        STATUS(end + 1) = 1;
    else
        STATUS(end + 1) = 0;
    end;
end;
STATUS = STATUS';
aaaa = [aaaa STATUS];
%-INSERT HRV PARAMETERS----------------------------------------------------
aaaa = [aaaa HRV_std_bin HRV_max_bin HRV_min_bin ...
        HRV_minmax_bin HRV_DFA_bin];
%-SCATTER PLOT-------------------------------------------------------------
STdev1 = RP_STdev_bin(STATUS == 0);
STdev2 = RP_STdev_bin(STATUS > 0);
STslope1 = RP_STslope_bin(STATUS == 0);
STslope2 = RP_STslope_bin(STATUS > 0);
Tinv1 = RP_Tinv_bin(STATUS == 0);
Tinv2 = RP_Tinv_bin(STATUS > 0);
figure(1000);
subplot(1,2,1);scatter3(STdev1,STslope1,Tinv1);title('Score');
hold on;scatter3(STdev2,STslope2,Tinv2);
xlabel('STdev');
ylabel('STslope');
zlabel('Tinv');
STdev1 = RP_STdev_bin(RP_DFA_bin < 1);
STdev2 = RP_STdev_bin(RP_DFA_bin > 1);
STslope1 = RP_STslope_bin(RP_DFA_bin < 1);
STslope2 = RP_STslope_bin(RP_DFA_bin > 1);
Tinv1 = RP_Tinv_bin(RP_DFA_bin < 1);
Tinv2 = RP_Tinv_bin(RP_DFA_bin > 1);
subplot(1,2,2);scatter3(STdev1,STslope1,Tinv1);title('DFA');
hold on;scatter3(STdev2,STslope2,Tinv2);
xlabel('STdev');
ylabel('STslope');
zlabel('Tinv');
%-SCATTER PLOT-------------------------------------------------------------
STdev0 = RP_STdev_bin(score_bin == 0);
STdev1 = RP_STdev_bin(score_bin == 1);
STdev2 = RP_STdev_bin(score_bin == 2);
STdev3 = RP_STdev_bin(score_bin == 3);
STdev4 = RP_STdev_bin(score_bin == 4);
STdev5 = RP_STdev_bin(score_bin == 5);
STslope0 = RP_STslope_bin(score_bin == 0);
STslope1 = RP_STslope_bin(score_bin == 1);
STslope2 = RP_STslope_bin(score_bin == 2);
STslope3 = RP_STslope_bin(score_bin == 3);
STslope4 = RP_STslope_bin(score_bin == 4);
STslope5 = RP_STslope_bin(score_bin == 5);
Tinv0 = RP_Tinv_bin(score_bin == 0);
Tinv1 = RP_Tinv_bin(score_bin == 1);
Tinv2 = RP_Tinv_bin(score_bin == 2);
Tinv3 = RP_Tinv_bin(score_bin == 3);
Tinv4 = RP_Tinv_bin(score_bin == 4);
Tinv5 = RP_Tinv_bin(score_bin == 5);
figure(1001);
scatter3(STdev0,STslope0,Tinv0);
hold on;scatter3(STdev1,STslope1,Tinv1);
hold on;scatter3(STdev2,STslope2,Tinv2);
hold on;scatter3(STdev3,STslope3,Tinv3);
hold on;scatter3(STdev4,STslope4,Tinv4);
hold on;scatter3(STdev5,STslope5,Tinv5);
xlabel('STdev');
ylabel('STslope');
zlabel('Tinv');
%-SCATTER PLOT-------------------------------------------------------------
ST_dev0 = [];
ST_slope0 = [];
T_inv0 = [];
ST_dev1 = [];
ST_slope1 = [];
T_inv1 = [];
ST_dev2 = [];
ST_slope2 = [];
T_inv2 = [];
for i = 1:length(score_bin)
    if score_bin(i)  <= 1
        ST_dev0(end + 1) = RP_STdev_bin(i);
        ST_slope0(end + 1) = RP_STslope_bin(i);
        T_inv0(end + 1) = RP_Tinv_bin(i);
    elseif score_bin(i)  == 2
        ST_dev1(end + 1) = RP_STdev_bin(i);
        ST_slope1(end + 1) = RP_STslope_bin(i);
        T_inv1(end + 1) = RP_Tinv_bin(i);
    else
        ST_dev2(end + 1) = RP_STdev_bin(i);
        ST_slope2(end + 1) = RP_STslope_bin(i);
        T_inv2(end + 1) = RP_Tinv_bin(i);
    end;
end;
figure(1002);
scatter3(ST_dev0,ST_slope0,T_inv0);
hold on;scatter3(ST_dev1,ST_slope1,T_inv1,'g');
hold on;scatter3(ST_dev2,ST_slope2,T_inv2,'r');
xlabel('STdev');
ylabel('STslope');
zlabel('Tinv');