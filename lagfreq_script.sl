%#include<stdio.h>

%declare observation ID's
%variable obs_id = ["0110890201","0148010301","0506200201","0506200301","0506200401","0506200501","0511580101",
%"0511580201","0511580301","0511580401","0554710801","0653510301","0653510401","0653510501","0653510601"];

variable obs_id = ["0110890201"];
variable i;
variable j;
variable k;

%declare frequency bins
variable n_bins = 7;
variable df_f = 1.0/1.1;
variable lo = Double_Type[n_bins];
variable hi = Double_Type[n_bins];
lo[0]=0.00008;
hi[0]=(lo[0] + lo[0]*df_f);

for(i=1;i<n_bins;i++){
    lo[i]=hi[i-1];
    hi[i]=lo[i]+lo[i]*df_f;
 }

%logarithmic frequency bin centre
variable rb_freq = 10^(0.5*(log10(lo)+log10(hi)));

%declare arrays
variable rb_n = Integer_Type[n_bins];
variable lag = Double_Type[n_bins];
variable g_a_real = Double_Type[n_bins];
variable g_a_imag = Double_Type[n_bins];
variable g_a = Double_Type[n_bins];
variable g_b = Double_Type[n_bins];
variable g_c = Double_Type[n_bins];
variable g = Double_Type[n_bins];
variable delta_phi = Double_Type[n_bins];
variable delta_lag = Double_Type[n_bins];

%loop through observarions
for(k=0; k<length(obs_id); k++){

() = chdir("/data/scratch3/steff/1H0707-495/" + obs_id[k] + "/PROC");
 
%Read data:
variable lc_soft = fits_read_table("PN_time_soft_lccorr.fits");
variable lc_hard = fits_read_table("PN_time_hard_lccorr.fits");

%exclude non-numbers:
variable ix_soft = where(not isnan(lc_soft.rate));
variable ix_hard = where(not isnan(lc_hard.rate));

%Pass to new variables:
variable time_soft = lc_soft.time[ix_soft];
variable time_hard = lc_hard.time[ix_hard];
variable rate_soft = lc_soft.rate[ix_soft];
variable rate_hard = lc_hard.rate[ix_hard];
variable error_soft = lc_soft.error[ix_soft];
variable error_hard = lc_hard.error[ix_hard];

% Compute soft dft:
variable dft_soft = fft(rate_soft,-1);
variable freq = [[0:length(dft_soft)-1]]/(double(length(dft_soft))*(time_soft[1]-time_soft[0]));
variable dft_real_soft = Real(dft_soft[[0:length(freq)-1]]);
variable dft_imag_soft = Imag(dft_soft[[0:length(freq)-1]]);

% Compute hard dft:
variable dft_hard = fft(rate_hard,-1);
variable dft_real_hard = Real(dft_hard[[0:length(freq)-1]]);
variable dft_imag_hard = Imag(dft_hard[[0:length(freq)-1]]);

%Calculate and sum CPS for each frequency bin in each observation.
for(i=0; i< n_bins; i++)
{
	for (j=0; j<length(freq); j++)
	{
		if(freq[j] > lo[i] && freq[j] <= hi[i])
		{		
			g_a_real[i] += dft_real_soft[j]*dft_real_hard[j] + dft_imag_soft[j]*dft_imag_hard[j];
			g_a_imag[i] += dft_imag_soft[j]*dft_real_hard[j] - dft_real_soft[j]*dft_imag_hard[j];
			g_b[i] += dft_real_soft[j]*dft_real_soft[j] + dft_imag_soft[j]*dft_imag_soft[j];
			g_c[i] += dft_real_hard[j]*dft_real_hard[j] + dft_imag_hard[j]*dft_imag_hard[j];
			rb_n[i] ++;
		}
	}
}
}

%Plot variables including frequency error bars
variable x = (hi+lo)/2;
variable dxp = hi-x;
variable dxm = x-lo;

%Average CPS in each frequency bin for all observations. Calculate coherence, g[i], for each frequency bin.
for(i=0;i<n_bins;i++)
{
	%Lag error
	g_a[i] = (g_a_real[i]*g_a_real[i] + g_a_imag[i]*g_a_imag[i])/(double(rb_n[i])*double(rb_n[i]));
	g_b[i] /= double(rb_n[i]);
        g_c[i] /= double(rb_n[i]);
	g[i] = g_a[i]/(g_b[i]*g_c[i]);
	delta_phi[i] = sqrt((1.0-g[i])/(2.0*g[i]))/sqrt(double(rb_n[i]));
	delta_lag[i] = delta_phi[i]/(2.0*PI*rb_freq[i]); 

	%Lag
	g_a_real[i] /= rb_n[i];
	g_a_imag[i] /= rb_n[i];
	lag[i] = atan2(g_a_imag[i] , g_a_real[i])/(2.0*PI*rb_freq[i]);
}

% Plot results:
() = chdir("/homeb/steff075/phd_ecm/1h0707"); %change to combined directory
%window(1);
open_plot("1H0707-495_OBS-0110890201_lagfreq.gif/gif"); % create a gif image
xlog;
ylin;
popt.res = 1;
%popt.ylabel = ["\fr","Time lag (s)"];
%popt.xlabel = ["\fr","Frequency (Hz)"];
ylabel("Time Lag (s)");
xlabel("Frequency (Hz)");
title("1H0707-495 Fully Combined lag-frequency >8e-5 Hz"); 
connect_points(0);
charsize(1.2); % good character size
nice_width; %good line ratios
plotxy(x,dxm,dxp,lag,delta_lag,delta_lag; dcol=1, decol=4, dsym=6,  mcol=2, xrange=[6e-5,1e-2],yrange=[-150,240]);
_pgscf(2); % set character font 1=default, 2=roman, 3=italic, 4=script
_pgsfs(3); % set fill area style
_pgsls(2); % set line style to 1=full line, 2=dashed, 3=dot-dash-dot, 4=dotted
_pgslw(1); % set line width to 1 
_pgmove(-10000,0); % move pen to point X,Y (no line is drawn)
_pgdraw(1,0); % draw a line from coordinates X,Y
%close_plot;

%Print lag values to screen
for (i=0; i<length(x); i++) {
  () = printf("%e,%e,%e\n", x[i], lag[i], delta_lag[i]);
}
%close_plot;

% Print lag freq values to csv file
fp = fopen("time_lags_0110890201.csv","w");% Create the file
for (i=0; i<length(x); i++) {
  fprintf(fp,"%e,%e,%e\n", x[i], lag[i], delta_lag[i]);
}
fclose(fp);

%Create ps image
%variable pid = open_plot("1H0707-495_lagfreq_fullycomb.ps/cps");
%charsize(1.3); %good font size
%nice_width; %good line ratios
%_pgscf(2); %make font roman
%plotxy(x,dxm,dxp,lag,delta_lag,delta_lag; dcol=1, decol=4, dsym=6, mcol=2, xrange=[6e-5,1e-2],yrange=[-50,200]);
%_pgmove(-10000,0);
%_pgsls(2);
%_pgslw(1);
%_pgdraw(1,0);
%close_plot(pid);


