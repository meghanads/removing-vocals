%               DSP Application Assignment                  %
%                       Group #32                           %
%                                                           %                          
%                         TEAM                              %
%                    Meghanad Shingate                      %
%                      Samir Shelke                         %
%                     Vinay Narayane                        %
%                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%                     ***  CODE STARTS HERE  ***


clear all;
close all;
myclc;
display('                  DSP-Application Assignment          ');
display('                  ^^^^^^^^^^^^^^^^^^^^^^^^^^          ');
display('                         Group # 32                   ');

display('   ');

%=========================================================================


display('>>>press ENTER key to play original music track.');
pause;




% Playing original clip:
% ^^^^^^^^^^^^^^^^^^^^^

[svalue,srate]=wavread('wake_up_sid.wav');
myclc;
display('Playing original song track...');
soundsc(svalue,srate);                      % Original track
pause(5);

channel_inf=size(svalue);


%__________________________________________________________________________




% Separating Stereo channels (i.e. Right and Left channel):
% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

display('   Reading Stereo channels...');


len= 1:channel_inf(1,1);
svalue_l(len)= svalue(len,1);           %Left channel
svalue_r(len)= svalue(len,2);           %Right channel

display('>>>Press ENTER to display left and right channel plotes...');
pause;

xlimit=500000;

%figure(1);
subplot(2,1,1);
plot(svalue_l);
title('Left Channel');
xlabel('Number of samples');
ylabel(' Normalized Amplitude ');
axis ([0 xlimit -1 1])


subplot(2,1,2);
plot(svalue_r);
title('Right Channel');
xlabel('Number of samples');
ylabel(' Normalized Amplitude ');
axis ([0 xlimit -1 1])

myclc;
display(' Displaying Plotes of left and right stereo channels...');


%__________________________________________________________________________


%Bandstop filtering:
%^^^^^^^^^^^^^^^^^^^

% it also removes most of the music instruments falling in audio range.

% Human voice range: 300Hz to 3KHz

myclc;
pause(1);

display('          *** BANDSTOP FILTERING ***                ');

display(' ');

fc_left=300;
fc_right=2500;

wc_left=fc_left/(srate*0.5);
wc_right=fc_right/(srate*0.5);

display('Firstly applying Bandstop Filtering...');
display('>>>Press ENTER to see Bandstop filter.');
pause;

% Bandpass filter of order 2000
%figure(2);
Bstop = fir1(2000, [wc_left, wc_right], 'stop');
freqz(Bstop);
title('Banbstop Filter Characterictics');

display('>>>press ENTER to hear bandstop filtered track');
pause;
display('Plotting filtered sample ....');
figure(3);
Bfilt_l = conv(svalue_l,Bstop);
soundsc(Bfilt_l,srate);
freqz(Bfilt_l);
title('Bandstop filtered left channel');

%__________________________________________________________________________

% Stereo cancellation:
%^^^^^^^^^^^^^^^^^^^^^

% It also removes insruments which are in both left and right channel

myclc;

display('            ***  STEREO CANCELLATION ***               ');
display(' ');
display(' ');

LeftFFT=fft(svalue_l);
RightFFT=fft(svalue_r);

StereoFFT= LeftFFT - RightFFT;
StereoIFFT= ifft(StereoFFT);

display('>>>press ENTER to here Stereo Cancelled Track');
pause;
soundsc(StereoIFFT,srate);

display('Plotting stereo-cancelled Samples...');
%figure(4);
subplot(2,1,1);
plot(len./srate,svalue_l);
title('Original left channel');
ylabel('Amplitude')
xlabel('Time')


subplot(2,1,2);
plot(len./srate,StereoIFFT);
title('Stereo cancelled left channel');
ylabel('Amplitude')
xlabel('Time')
pause(4);

%_________________________________________________________________________


% Audio Blind Source Separation:
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


myclc;

display('              *** AUDIO BLIND SOURCE SEPARATION ***          ');
display(' ');


fft_pts=8192;

% take it even number and also should be divisible by 4 for this program to
% work

% fft_pts is number of FFT points generated after finding fft per frame,
% more the fft points we get more resolution in frequency domain.
% so in order to mask fft co-efficients in this techneque we desire to 
% have more number of fft points.

win_sz=8192;

% win_sz is size of window used in finding STFT, type of window used is 
% hamming window. here we took window size same as fft points.

frm_sz = fft_pts/4;

% frm_sz is frame size used during STFT calculation
% it should be small in order to creat more fft points
% but small size frame may creat noise in final output.

%-----------------------------------------------------

% STFT:

% Left channel:

STFT_l= STFT(svalue_l, fft_pts, win_sz, frm_sz);

% Right channel :

STFT_r = STFT(svalue_r, fft_pts, win_sz, frm_sz);

% comparing left and right channel:
%   taking dft coefficient ratio:
%   ratio= (left channel dft coeff)/(right channel dft coeff)
%   take abs for comparing perpose.

dft_coeff_ratio = abs(STFT_l./STFT_r);



display('>>>press ENTER to see DFT coefficient ratio:');
pause;
figure;
plot(dft_coeff_ratio);

display('>>> press ENTER to see spectrom of original track');

figure(6);
subplot(2,1,1);
imagesc(20*log10(abs(STFT_l))); %plotting spectogram
title('Left Channel Spectogram(Before Masking)');
ylabel('Frequency (Hz)')
xlabel('Number of Frames')
axis xy;
caxis([-90, 0]);
colorbar; % decode

subplot(2,1,2);
imagesc(20*log10(abs(STFT_r)));
title('Right Channel Spectogram(Before Masking)');
ylabel('Frequency (Hz)')
xlabel('Number of Frames')
axis xy;
caxis([-90, 0]);
colorbar;

% -------------------------------------------------------------
% Binary Time Frequency Masking (BTFM)

% calculating Masking coefficients....

display(' calculating masking coefficients......');

% calculating histogram of dft coeff ratio for range,
% 0.005 to 1.995
% by taking interval of 0.005
% it tells how the ratio is distributed

Hist=0;
a=0;
b=0.005;
lim=2;
stp=0.005;
i=1;

while(b<lim)
    Hist(i) = mean(sum((dft_coeff_ratio >a) & (dft_coeff_ratio <b))) ;
    i = i + 1;
    a=a+0.005; 
    b=a+0.005;
end

display('>>>press ENTER to see dft_coeff_ratio Histogram...');
pause;

figure(7);

range=0:0.005:1.995;
plot(range,Hist)
title('Histogram of DFT coeff ratios in the spectogram');
xlabel('DFT coeff ratio (left/right)')
ylabel('Frequency of coefficients in spectrogram(mean)')

% Binary Time Frequency masking....

display(' Applying Binary time frequency masking...');


    

% masking Logic..
%
%   if(0.65 <= ratio <= 1.35)
%       mask it,
%   else 
%       leave it,
%

[ri,cj]=size(dft_coeff_ratio);

for j=1:cj;
    for i=1:ri;
        if (dft_coeff_ratio(i,j)>0.65 & dft_coeff_ratio(i,j)<1.35);
            STFT_l(i,j)=0;
            STFT_r(i,j)=0;
        end
    end
end

display('>>>press ENTER to see spectrogram after masking...');
pause;

figure(8);
subplot(2,1,1);
imagesc(20*log10(abs(STFT_l))); %spectogram
title('Left Channel Spectogram (After Masking)');
ylabel('Frequency (Hz)')
xlabel('Number of Frames')
axis xy;
caxis([-80 0]);
colorbar; %decode of colors

subplot(2,1,2);
imagesc(20*log10(abs(STFT_r)));
title('Right Channel Spectogram (After Masking)');
ylabel('Frequency (Hz)')
xlabel('Number of Frames')
axis xy;
caxis([-80 0]);
colorbar;


%-------------------------------------------------------

% Recover back track without vocals...

display(' performing ISTFT...');

ISTFT_l = ISTFT(STFT_l, fft_pts, win_sz, frm_sz);
ISTFT_r = ISTFT(STFT_r, fft_pts, win_sz, frm_sz);

display('>>>>press ENTER to see original and recovered track...');
pause;
close all;

figure(1);
subplot(2,1,1);
plot(svalue_l);
title('original Left Channel');
xlabel ('Number of Samples');
ylabel ('Normalized Amplitude');
axis ([0 xlimit -1 1])
subplot(2,1,2);
plot(ISTFT_l);
title('Recovered Left Channel');
xlabel ('number of Samples');
ylabel ('Normalized Amplitude');
axis ([0 xlimit -1 1]);

figure(2);
subplot(2,1,1);
plot(svalue_r);
title('original Right Channel');
xlabel ('Number of Samples');
ylabel ('Normalized Amplitude');
axis ([0 xlimit -1 1])
subplot(2,1,2);
plot(ISTFT_r);
title('Recovered Right Channel');
xlabel ('number of Samples');
ylabel ('Normalized Amplitude');
axis ([0 xlimit -1 1])

%---------------------------------------------
%Done !!!

display('>>>press ENTER to hear Recovered Track...');
pause;

display('playing recovered track...');

RecTrack=[ISTFT_l;ISTFT_r];
soundsc(RecTrack.',srate);

display(' ');
display('*** DONE !!! Thank you!!! ***');


%                 *** END OF CODE ***