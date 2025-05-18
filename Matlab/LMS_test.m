clc
close all
clear all

ar = [1, 1/2];
ARfilt = dsp.IIRFilter('Numerator',1,'Denominator',ar);

ma = [1, -0.8, 0.4, -0.2];
MAfilt = dsp.FIRFilter('Numerator',ma);

SNR_levels = [-5 5 15 30 40];
filenames = ["samples/sm03_m48.wav", "samples/sm02_m48.wav", "samples/sm01_m48.wav", "samples/si03_m48.wav", "samples/si02_m48.wav", "samples/si01_m48.wav", "samples/sc03_m48.wav", "samples/sc02_m48.wav", "samples/sc01_m48.wav", "samples/es03_m48.wav", "samples/es02_m48.wav", "samples/es01_m48.wav"];

mu = 0.109;
L = 7;

SNRs = zeros(5,12);
choose_SNR = 2;
choose_filtename = 2;
for f = 1:12

    [s, Fs] = audioread(filenames(f));

    for i = 1:length(SNR_levels)

        N = length(s);
        noise_power = mean(s.^2) ./ (10.^((SNR_levels(i)-8.45)/10));
        ref_noise_power = mean(s.^2) ./ (10.^((SNR_levels(i)-9.06)/10));

        v = 0.8*rand(N, 1);
        noise = ARfilt(v);
        ref_noise = sqrt(ref_noise_power)*MAfilt(v);
        release(ARfilt);
        release(MAfilt);

        x = s + sqrt(noise_power)*noise;

        P_signal = mean(s.^2);
        P_noise_in = mean((x - s).^2);
        SNR_in_dB = 10 * log10(P_signal / P_noise_in);

        [w, y, s_est] = LMS(L, mu, ref_noise, x);

        if ((f == choose_filtename) && (i == choose_SNR))

            %Построение спектра сигналов
            wi = 0:1/4096*Fs:(0.5-1/4096)*Fs;
            X = fft(x, 4096);
            S_est = fft(s_est, 4096);
            S = fft(s, 4096);

            figure;
            plot(wi, 20*log10(abs(X(1:2048))),'k');
            hold on;
            plot(wi, 20*log10(abs(S_est(1:2048))),'b');
            plot(wi, 20*log10(abs(S(1:2048))),'r');
            hold off;
            title('Signal spectrum');
            legend('sample corrupted with noise', 'sample after LMS algorithm', 'clear sample')
            xlabel('Frequency(Hz)');
            ylabel('dB');

            %Построение амплитуд сигналов по времени
            figure;
            plot(1:N, x, 'Color', 'k');
            hold on;
            plot(1:N, s_est,'Color', 'b');
            plot(1:N, s, 'o', 'MarkerSize', 0.5, 'Color', 'red');
            hold off;
            title('Signals');
            legend('sample corrupted with noise', 'sample after LMS algorithm', 'clear sample')
            xlabel('n');
            ylabel('Magnitude');

            %Построение изменения среднеквадратичной ошибки между исходным
            %шумом и полученным при помощи алгоритма
            mselms = zeros(ceil(N*0.05),1);
            for n = 20:20:N
                mselms(n/20) = mean((s(1:n)-s_est(1:n)).^2);
            end
            figure;
            plot(1:20:N-20, mselms(1:end-1), 'k'); 
            xlabel('n');
            ylabel('MSE');
            grid on;
            title('LMS Learning Curve');

            soundsc([x; s_est], Fs);
        end

        P_signal = mean(s.^2);
        P_noise_out = mean((s_est-s).^2);
        SNR_out_dB = 10 * log10(P_signal / P_noise_out);
        SNRs(i,f) = SNR_out_dB;
        fprintf('%s: SNR_in = %.2f dB, SNR_out = %.2f dB \n',filenames(f), SNR_in_dB, SNR_out_dB);
   end
end

%Построение столбчатой диаграммы
figure;
bar(f, SNRs(1,:));
xlabel('Образцы'); 
ylabel('Значение SNR (дБ)'); 
title('Значения SNR сигнала после фильтрации при входном SNR = -5');
grid on;

figure;
bar(f, SNRs(2,:));
xlabel('Образцы'); 
ylabel('Значение SNR (дБ)'); 
title('Значения SNR сигнала после фильтрации при входном SNR = 5');
grid on;

figure;
bar(f, SNRs(3,:));
xlabel('Образцы'); 
ylabel('Значение SNR (дБ)'); 
title('Значения SNR сигнала после фильтрации при входном SNR = 15');
grid on;

figure;
bar(f, SNRs(4,:));
xlabel('Образцы'); 
ylabel('Значение SNR (дБ)'); 
title('Значения SNR сигнала после фильтрации при входном SNR = 30');
grid on;

figure;
bar(f, SNRs(5,:));
xlabel('Образцы'); 
ylabel('Значение SNR (дБ)'); 
title('Значения SNR сигнала после фильтрации при входном SNR = 40');
grid on;

reset(ARfilt);
reset(MAfilt);