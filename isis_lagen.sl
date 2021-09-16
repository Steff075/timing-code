%declare observation ID's
variable obs_id = ["0110890201"];

%declare energy band edges
%variable band = [300,350,400,500,600,700,800,1000,1300,1600,2000,2400,3000,4000,5000,6000,7000,10000]; 

variable band = [300,400,500,600,800,1000,1300,2000,3000,4000,5000,7000,10000];

variable number_bands = length(band)-1;
variable i;
variable k;
variable j;

%Declare arrays
variable g_a_real = Double_Type[number_bands];
variable g_a_imag = Double_Type[number_bands];
variable g_a = Double_Type[number_bands];
variable g_b = Double_Type[number_bands];
variable g_c = Double_Type[number_bands];
variable g = Double_Type[number_bands];
variable delta_phi = Double_Type[number_bands];
variable delta_lag = Double_Type[number_bands];
variable lag = Double_Type[number_bands];

%Set frequency range interested in
variable lo = 0.00019;
variable hi = 0.00067;  


%Logarithmic centre of frequency bin
variable rb_freq = 10^(0.5*(log10(lo)+log10(hi)));

%counts CPS for each binlag_en_script.sl
variable rb_n = Integer_Type[number_bands];

%Define energy bins
variable elo = Double_Type[number_bands];
variable ehi = Double_Type[number_bands];

for(i=0; i<number_bands;i++){	
	elo[i] =  band[i]; 
	ehi[i] = band[i+1];
}


%loop through observations
for(k=0; k<length(obs_id); k++){

%change to appropriate directory for observation

variable fn_r;
variable fn_n;

%loop through energy bands
for(i=0; i<number_bands; i++){

%read in fits file - MAKE SURE FILE NAMES MATCH
fn_r = sprintf("reference_%i_%i_lccorr.fits",band[i],band[i+1]);
fn_n = sprintf("narrow_%i_%i_lccorr.fits",band[i],band[i+1]);

variable lc_reference = fits_read_table(fn_r);
variable lc_narrow = fits_read_table(fn_n);

%exclude non-numbers:
variable ix_reference = where(not isnan(lc_reference.rate));
variable ix_narrow = where(not isnan(lc_narrow.rate));

% Pass to new variables:
variable time_reference = lc_reference.time[ix_reference];
variable time_narrow = lc_narrow.time[ix_narrow];
variable rate_reference = lc_reference.rate[ix_reference];
variable rate_narrow = lc_narrow.rate[ix_narrow];
variable error_reference = lc_reference.error[ix_reference];
variable error_narrow = lc_narrow.error[ix_narrow];

% Compute reference dft:
variable dft_reference = fft(rate_reference,-1);
variable freq = [[0:length(dft_reference)-1]]/(double(length(dft_reference))*(time_reference[1]-time_reference[0]));
variable dft_real_reference = Real(dft_reference[[0:length(freq)-1]]);
variable dft_imag_reference = Imag(dft_reference[[0:length(freq)-1]]);

% Compute narrow dft:
variable dft_narrow = fft(rate_narrow,-1);
variable dft_real_narrow = Real(dft_narrow[[0:length(freq)-1]]);
variable dft_imag_narrow = Imag(dft_narrow[[0:length(freq)-1]]);

% Calculate CPS in the frequency range [lo,hi] for each energy bin [i], summing across observations.
for (j=0; j<length(freq); j++){
if(freq[j] > lo && freq[j] <= hi)
		{		
			g_a_real[i] += dft_real_reference[j]*dft_real_narrow[j] + dft_imag_reference[j]*dft_imag_narrow[j];
			g_a_imag[i] += dft_real_narrow[j]*dft_imag_reference[j]-dft_real_reference[j]*dft_imag_narrow[j];
			g_b[i] += dft_real_reference[j]*dft_real_reference[j] + dft_imag_reference[j]*dft_imag_reference[j];
			g_c[i] += dft_real_narrow[j]*dft_real_narrow[j] + dft_imag_narrow[j]*dft_imag_narrow[j];
			rb_n[i] ++;
		}

}
}
}

variable x = (ehi+elo)/2;
variable dxp = ehi-x;
variable dxm = x-elo;

%Average the CPS for each energy bin for all observations. Calculate coherence, g[i], for each energy bin.
for(i=0; i<number_bands; i++){ 
	%Lag error
	g_a[i] = (g_a_real[i]*g_a_real[i] + g_a_imag[i]*g_a_imag[i])/(double(rb_n[i])*double(rb_n[i]));
	g_b[i] /= double(rb_n[i]);
        g_c[i] /= double(rb_n[i]);
	g[i] = g_a[i]/(g_b[i]*g_c[i]);
	delta_phi[i] = sqrt((1.0-g[i])/(2.0*g[i]))/sqrt(double(rb_n[i]));
	delta_lag[i] = delta_phi[i]/(2.0*PI*rb_freq);

	%Lag
	g_a_real[i] /= rb_n[i];
	g_a_imag[i] /= rb_n[i];
	lag[i] = atan2(g_a_imag[i] , g_a_real[i])/(2.0*PI*rb_freq);

}

open_plot("lagen_1.9-6.7.gif/gif");
xlog;
ylin;
xlabel("Energy (eV)");
ylabel("Time Lag (s)");
title("1H0707-495 0110890201 lag-energy 1.9-6.7e-4 Hz");
connect_points(0);
_pgsfs(3);
fit_fun("powerlaw + gauss");
plotxy(x,dxm,dxp,lag,delta_lag,delta_lag; dcol=1, decol=2, dsym=6, xrange=[300,10000], yrange=[-600,300]);
_pgmove(300,0);
_pgsls(2);
_pgslw(1);
_pgdraw(1,0);

for (i=0; i<length(x); i++) {
  () = printf("%e,%e,%e\n", x[i], lag[i], delta_lag[i]);
}
close_plot;

