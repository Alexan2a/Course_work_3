clc
close all
clear all

[s, Fs] = audioread("samples/es03_m48.wav");
L = 7;
beta = 0.987;

s = s';
N = length(s);
n = 1/Fs:1/Fs:N/Fs;

noise = 0.041*randn(1,N); %change coefficient

x = s + noise;
y = RACE(x, L, beta);

f = (0:N-1)*(Fs/N);
X = fft(x, 4096);
Y = fft(y, 4096);
S = fft(s, 4096);
N = fft(noise, 4096);

P_signal = mean(s.^2);
P_noise_in = mean((x - s).^2);

SNR_in_dB = 10 * log10(P_signal / P_noise_in)

wi = 0:1/4096*Fs:(0.5-1/4096)*Fs;
       
figure;
plot(wi, 20*log10(abs(X(1:2048))),'k');
hold on;
plot(wi, 20*log10(abs(Y(1:2048))),'b');
hold on;
plot(wi, 20*log10(abs(S(1:2048))),'r');
hold off;
title('Signal spectrum');
legend('sine wave corrupted with white noise', 'sine wave after RACE algorithm', 'sine wave')
xlabel('Frequency(Hz)');
ylabel('dB');

figure;
subplot(3,1,1);
plot(n(900:end), s(900:end),'k');
title('Signal');
xlabel('Time(s)');
ylabel('Magnitude');
subplot(3,1,2);
plot(n(900:end), x(900:end),'k');
title('Signal corrupted witn noise');
xlabel('Time(s)');
ylabel('Magnitude');
subplot(3,1,3);
plot(n(900:end), y(900:end),'k');
title('Signal after RACE algorithm');
xlabel('Time(s)');
ylabel('Magnitude');
soundsc([x'; y;], Fs);