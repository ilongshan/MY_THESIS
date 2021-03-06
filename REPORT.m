QRS_std_thres = 1;
span = 10;
fraction = 1/2;
%% ======================== CALCULATE SOLOOP ==============================
total_length = length(sig1);
window_length = fs * span;
%number_of_loop = floor(total_length * fraction / window_length);
number_of_loop = 10;

for soloop = 1:number_of_loop
%% ================ DISPLAY SOME TEXT ON THE SCREEN =======================
    clc;
    percent = soloop / number_of_loop;
    disp([num2str(record) '/' num2str(length(recordings)) '. ' filename ': ' num2str(floor(percent * 100)) '%']);
    inputloop = soloop;
%% ========================= DELINEATION ==================================
    % ====== READ SIGNAL ======
    data_length = span * fs;
    startpoint = (inputloop - 1) * data_length + 1;
    endpoint = inputloop * data_length;
    seg = sig1(startpoint:endpoint);
        
%% ======================== PREPROCESSING =================================
    % ====== BASELINE REMOVAL ======
    [approx, detail] = wavelet_decompose(seg, 8, 'db4');
    seg = seg - approx(:,8);
    
    % ====== CLEAN SIGNAL WITH BANDPASS 0.5 - 40Hz filter ======
    filt = fir1(24, [.5/(fs/2) 40/(fs/2)],'bandpass');
    seg = conv(filt,seg);
    seg = seg(12:end,1);
    
    % ====== QRS DETECTION ======
    signal = seg;
    
    % ======= USE ENHANCED PAN THOMPKIN ======
    QRST_detect;

    % ====== USE MY OWN CODE ======
    %[QRS_amps, QRS_locs, T_amps, T_locs, signal_filtered] = np_QRSTdetect(signal,fs);

    % ====== CHANGING AMPLITUDE TO PLOT ======
    for qrsloc = 1:length(QRS_locs)
        QRS_amps(qrsloc) = signal(QRS_locs(qrsloc));
    end;
    for tloc = 1:length(T_locs)
        T_amps(tloc) = signal(T_locs(tloc));
    end;
    
    % then 'signal_filtered' variable created but UNUSABLE!!!!!--------
    % ====== REJECTION CRITERIA ======
    for rjloop = 2:length(QRS_locs)
        condition = QRS_locs(rjloop) - QRS_locs(rjloop - 1);
        if condition > 450
            rejected = rejected + 1;
            continue;
        end;
    end;
    for rjloop = 2:length(T_locs)
        condition = T_locs(rjloop) - T_locs(rjloop - 1);
        if condition > 450
            rejected = rejected + 1;
            continue;
        end;
    end;
    for rjloop = 1:length(T_locs)
        condition = T_locs(rjloop) - QRS_locs(rjloop);
        if condition > 250 || condition < 25
            rejected = rejected + 1;
            continue;
        end;
    end;
    % ====== END OF REJECTION CRITERIA ======
    % ====== END OF DELENIATION ======
    beat_start = 1;
    beat_end = length(QRS_locs);
    
    % ====== PARAMETERS ======
    HR = [];
    FFT = [];
    LFHF = [];
    DFA = [];
    FBAND = [];
    ENTROPY = []; % Correlate good with DFA, con giu
    STDeviation = [];
    FFT_app = [];
    FFT_det = [];
    Tinv = [];
    ToR = [];
    % Cut off frequency = 40Hz, can be changed
    ENERGY_RATIO = [];
    ENTROPY_CUTOFF = [];
    ST_on_locs = [];
    ST_off_locs = [];
    ST_on_amps = [];
    ST_off_amps = [];
    %----------------------------------------------------------------------
    number_of_samples = span * fs;
    index2start = (inputloop - 1) * number_of_samples + 1;
    index2end = inputloop * number_of_samples;
    % ====== CALCULATE NUMBER OF BEATS COVERED ======
    number_of_beat_covered = beat_end - beat_start;
    mean_HR = floor(number_of_beat_covered / (span / 60));
    beat_end = beat_start + number_of_beat_covered - 1;
    
    %% ==================== CALDULATE STslope =============================
    STslope = [];
    for km = beat_start:beat_end
        if ~isnan(QRS_locs(km)) && ~isnan(T_locs(km))
            leng = floor((T_locs(km) - QRS_locs(km))/4);
            pheight = (seg(QRS_locs(km) + floor(2.6 * leng)) - seg(QRS_locs(km) + floor(1.6 * leng))) / seg(QRS_locs(km)) * 100;
            width = floor(2.6 * leng) - floor(1.6 * leng);
            STslope(end + 1) = pheight / width * 10;
            Tinv(end + 1) = seg(T_locs(km));
            ToR(end + 1) = abs(seg(T_locs(km))) / abs(seg(QRS_locs(km))) * 100;
            ST_on_locs(end + 1) = QRS_locs(km) + floor(1.6 * leng);
            ST_on_amps(end + 1) = seg(QRS_locs(km) + floor(1.6 * leng));
            ST_off_locs(end + 1) = QRS_locs(km) + floor(2.6 * leng);
            ST_off_amps(end + 1) = seg(QRS_locs(km) + floor(2.6 * leng));
        end;
    end;
    
    % ====== CALDULATE STDeviation ======
    for km = beat_start:beat_end
        if ~isnan(QRS_locs(km)) && ~isnan(T_locs(km))
            leng = floor((T_locs(km) - QRS_locs(km))/4);
            pdata = seg((QRS_locs(km) + floor(1.6 * leng)):(QRS_locs(km) + floor(2.6 * leng)));
            %reference = seg((QRS_locs(km)-25):(QRS_locs(km)+25));
            RRinterval = QRS_locs(km + 1) - QRS_locs(km);
            iso = ones(length(pdata),1) * seg(QRS_locs(km) + floor(0.5 * RRinterval));
            %Normalize STD with its data length
            STDeviation(end + 1) = (trapz(pdata) - trapz(iso)) / length(pdata) * 100 * 10;
            %STDeviation(end + 1) = (trapz(pdata));
        end;
    end;
    
    % ====== CALCULATE HR ======
    for i = beat_start:beat_end
       step_size = QRS_locs(i+1) - QRS_locs(i);
       hr = 60 / (step_size / 250);
       HR(end + 1) = hr;
    end;
    
    % ====== CALCULATE DFA ======
    for i = beat_start:beat_end
       data = seg(QRS_locs(i):QRS_locs(i+1));
       dfa = DetrendedFluctuation(data);
       DFA(end + 1) = dfa;
    end;
    
    % ====== CALCULATING THE SCORE ======
    score = 0;
    mean_STD = mean(STDeviation);
    mean_STS = mean(STslope);
    mean_HR = mean(HR);
    mean_ToR = mean(ToR);
    mean_Tinv = mean(Tinv);
    mean_DFA = mean(DFA);
    
    if mean_STD > 30 || mean_STD < -20
        score = score + 2;
    elseif mean_STD > 20 || mean_STD < -10
        score = score + 1;
    end;
    %if mean_STD > 20 || mean_STD < -20
    %    score = score + 1;
    %end;
    if mean_STS > 8 || mean_STS < -4
        score = score + 1;
    end;
    if mean_Tinv < 0.02
        score = score + 1;
    end;
    %if mean_HR > 100 || mean_HR < 50
    %    score = score + 1;
    %end;
    %if mean_DFA > 1
    %    score = score + 1;
    %end;
    
    % ====== MAKING THE DIAGNOSIS ======
    if mean_STD > 100 || mean_STS > 11
        diagnosis = 'Transient ST Elevate';
    elseif mean_STD < -40 && mean_STS < -4
        diagnosis = 'Transient ST Depress';
    elseif mean_Tinv < -0
        diagnosis = 'T wave inverted';
    elseif mean_Tinv < 0.02
        diagnosis = 'T wave absence';
    elseif mean_DFA > 1 && mean_STD > 20
        diagnosis = 'Minor positive STD';
    elseif mean_DFA > 1 && mean_STD < -10
        diagnosis = 'Minor negative STD';
    elseif mean_STD > 20
        diagnosis = 'Minor positive STD without DFA';
    elseif mean_STD < -10
        diagnosis = 'Minor negative STD without DFA';
    elseif mean_DFA > 1
        diagnosis = 'STD spotted by DFA without MF';
    else
        diagnosis = 'Normal ECG';
    end;
    
    %disp(diagnosis);
    %-CALCULATE ENERGY_RATIO-----------------------------------------------
    for i = beat_start:beat_end
       data = seg(QRS_locs(i):QRS_locs(i+1));
       L = length(data);
       f = fs*(0:(floor(L/2)))/L;
       Y = fft(data);
       P2 = abs(Y/L);
       P1 = P2(1:floor(L/2)+1);
       P1(2:end-1) = 2*P1(2:end-1);
       %P1 = smooth(P1,0.1,'rloess');
       temp = P1(find(f>=40));
       ENERGY_RATIO(end + 1) = trapz(temp) / trapz(P1);
       temp2 = SampEn(2, 0.15*std(temp), temp, 1);
       %temp2 = DetrendedFluctuation(temp);
       ENTROPY_CUTOFF(end + 1) = temp2;
    end;
    %-PLOTTING SECTION-----------------------------------------------------
    figure2 = figure;set(figure2,'name',[filename ': ' diagnosis],'numbertitle','off');
    subplot(2,1,1);plot(signal);title(['STD: ' num2str(mean(STDeviation)) ' - slope: ' num2str(mean(STslope)) ' - Tinv: ' num2str(mean(Tinv)) ' - ToR: ' num2str(mean(ToR))]);hold on;plot(QRS_locs,QRS_amps,'o');
    subplot(2,1,2);plot(signal);hold on;plot(T_locs,T_amps,'^');hold on;plot(ST_on_locs,ST_on_amps,'*');hold on;plot(ST_off_locs,ST_off_amps,'*');
%     subplot(3,4,[9,10]);yyaxis left;plot(STDeviation);title(['STD: ' num2str(mean(STDeviation)) ' - slope: ' num2str(mean(STslope)) ' - Tinv: ' num2str(mean(Tinv)) ' - ToR: ' num2str(mean(ToR))]);yyaxis right;plot(STslope);
    %-THEN PLOT THE SIGNAL---------------------
    subplot(3,4,[1,2]);plot(signal);title(['ECG' ' - ' num2str(mean_HR) ' bpm - score: ' num2str(score)]);axis([0 500 min(seg) max(seg)]);hold on;plot(QRS_locs,QRS_amps,'o');hold on;plot(T_locs,T_amps,'^');hold on;plot(ST_on_locs,ST_on_amps,'*');hold on;plot(ST_off_locs,ST_off_amps,'*');
    subplot(3,4,[3,4]);yyaxis left;plot(HR);title(['HR: ' num2str(mean(HR)) ' - DFA: ' num2str(mean(DFA))]);yyaxis right;plot(DFA);
    %-CALCULATE FFT--------------------------------------------------------
    %-beat-to-beat FFT------------------------
    data = seg(QRS_locs(beat_start):QRS_locs(beat_start + 1));
    L = length(data);
    f = fs*(0:(floor(L/2)))/L;
    Y = fft(data);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    sss = find(f>=40 & f<=(fs/2));
    P40 = P1(sss);
    aloha = SampEn(2, 0.15*std(P40), P40, 1);
    aloho = DetrendedFluctuation(P40);
    %subplot(3,4,5);plot(f,P1);title(['SE = ' num2str(aloha) ', DFA = ' num2str(aloho)]);axis([40 fs/2 0 max(P40)]);
    [app, det] = wavelet_decompose(P40, 3, 'db4');
    FFT_app = app(:,3);
    FFT_det = P40 - FFT_app;
    FFT_app_DFA = DetrendedFluctuation(FFT_app);
    %subplot(3,4,7);plot(FFT_app);title(['DFA = ' num2str(FFT_app_DFA)]);axis([1 length(FFT_app) 0 max(FFT_app)]);
    FFT_det_SA = SampEn(2, 0.15*std(FFT_det), FFT_det, 1);
    %subplot(3,4,8);plot(FFT_det);title(['SE = ' num2str(FFT_det_SA)]);
    %-series-FFT--------------------------------
    data = seg(QRS_locs(beat_start):QRS_locs(beat_end));
    L = length(data);
    f = fs*(0:(floor(L/2)))/L;
    Y = fft(data);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    P1_smooth = P1;
    %P1_smooth = smooth(P1,20/L,'rloess');
    %P1_smooth = resample(P1_smooth,length(P1_smooth),length(f));
    aloha = SampEn(2, 0.15*std(P1_smooth), P1_smooth, 1);
    aloho = DetrendedFluctuation(P1_smooth);
    %subplot(3,4,6);plot(P1(find(f >= 60)));title(['SE = ' num2str(aloha) ', DFA = ' num2str(aloho)]);
    %-CALCULATE LFHF-------------------------------------------------------
    %for i = beat_start:beat_end
    %   data = seg(QRS_locs(i-15):QRS_locs(i+15));
    %   L = length(data);
    %   f = fs*(0:(floor(L/2)))/L;
    %   Y = fft(data);
    %   P2 = abs(Y/L);
    %   P1 = P2(1:floor(L/2)+1);
    %   P1(2:end-1) = 2*P1(2:end-1);        
    %   [lfhf, lf, hf] = calc_lfhf(f,P1);
    %   LFHF(end + 1) = lfhf;
    %end;
    %LFHF = LFHF';
    %LFHF_bin = [LFHF_bin; LFHF];
    %%subplot(3,4,[7,8]);plot(LFHF);title(['LFHF / DFA']);hold on;
    %%subplot(3,4,[11,12]);yyaxis left;plot(FBAND);title(['FBAND / ENTROPY']);
    %yyaxis right;plot(ENTROPY);
    %subplot(3,4,[11,12]);yyaxis left;plot(ENERGY_RATIO);title(['ENERY: ' num2str(mean(ENERGY_RATIO)) ' - ENTROPY: ' num2str(mean(ENTROPY_CUTOFF(~isinf(ENTROPY_CUTOFF))))]);axis([0 inf 0.02 0.12]);yyaxis right;plot(ENTROPY_CUTOFF);axis([0 inf 0.3 2.6]);maxfig(figure2,1);
    %-DATA SAVING SeCTION--------------------------------------------------

    STslope = STslope';
    RP_STslope_bin = [RP_STslope_bin; mean(STslope)];

    STDeviation = STDeviation';
    RP_STdev_bin = [RP_STdev_bin; mean(STDeviation)];

    HR = HR';
    RP_HR_bin = [RP_HR_bin; mean(HR)];

    DFA = DFA';
    RP_DFA_bin = [RP_DFA_bin; mean(DFA)];

    ENERGY_RATIO = ENERGY_RATIO';
    RP_ENERGY_RATIO_bin = [RP_ENERGY_RATIO_bin; mean(ENERGY_RATIO)];

    ENTROPY_CUTOFF = ENTROPY_CUTOFF';
    RP_ENTROPY_CUTOFF_bin = [RP_ENTROPY_CUTOFF_bin; mean(ENTROPY_CUTOFF)];

    Tinv = Tinv';
    RP_Tinv_bin = [RP_Tinv_bin; mean(Tinv)];

    ToR = ToR';
    RP_ToR_bin = [RP_ToR_bin; mean(ToR)];
           
    score_bin = [score_bin; score];
    
    %-HRV PARAMETERES CALCULATION AND SAVING-------------------------------
    
    HRV_std_bin = [HRV_std_bin; std(HR)];
    
    HRV_min_bin = [HRV_min_bin; min(HR)];
    
    HRV_max_bin = [HRV_max_bin; max(HR)];
    
    HRV_minmax_bin = [HRV_minmax_bin; max(HR) - min(HR)];
    
    HRV_DFA_bin = [HRV_DFA_bin; DetrendedFluctuation(HR)];
    
    %-update criteria------------------------------------------------------
    
    accepted = accepted + 1;
    
    
end;

