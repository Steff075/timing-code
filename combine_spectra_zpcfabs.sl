%declare path
variable path_to_data = "/data/scratch3/steff/1H0707-495";

%variable obsid = ["0110890201","0148010301","0506200201","0506200301","0506200401","0506200501","0511580101","0511580201","0511580301","0511580401","0554710801","0653510301","0653510401","0653510501","0653510601"];

variable obsid = ["0653510601"];
variable i;

% Read in all data sets
for (i=0; i<length(obsid); i++) {
  () = chdir(path_to_data + "/" + obsid[i] + "/PROC");
  () = load_data("PN_time_0.3-10_pi_grp.fits");
} 

match_dataset_grids (all_data());
chdir(path_to_data);

% Now group and rebin the data
variable g;
g = combine_datasets(all_data());

% See which datasets have been combined
print(combination_members(g));

% Rebin to a minimum number of counts per bin
rebin_combined(g, 10);

% Then notice a specific energy range
xnotice_en(all_data(),1.0,10.0);
ignore_en(all_data(),0.1,1.0);
ignore_en(all_data(),10.0,20.0);

% Fit a model and plot the result
() = chdir("/homeb/steff075/phd_ecm/1h0707");
%open_plot("1H0707-495_spec_comb_zpcfabs_1-10KeV.gif/gif");
%fit_fun("zpcfabs*relxill*edge(1)*edge(2)");
%load_par("Conf_comb_relxill_zpcfabs.par");
%load_par("Conf_0653510301.par");

fit_fun("powerlaw");
popt.xrange=[1.0,10,1.0,10];
popt.yrange = [1.001e-5, 2.0, -10.0, 10.0];
xlog;
ylog;
%title ("1H0707-495 Combined Spectrum (Relxill*zpcfabs Model)");
%untie(3);
%thaw(3);
%tie(12,3);
%thaw(5,6);
%set_par(3,0.0411,1);
%set_par(4,1998,0);
%set_par(5,0.19,0);
%set_par(8,0.998,1);
%set_par(9,53,0);
%set_par(11,58,0);
%set_par(12,0.0411,1);
%set_par(18,7.844,0);
%set_par(19,0.90,0);
%set_par(20,7.04,0);
%set_par(21,0.7,0);
%set_fit_method("subplex");
()=fit_counts;
()=eval_counts; 
popt.dsym = 1;
popt.rsym = 1;
popt.res = 4;
popt.ccol=14;
plot_comps({{g}},popt,&plot_data);
list_par;
model_flux(1,0.5,10);


%close_plot;

%model_flux(g,0.3,10 [unit=erg, pc=174,100,000,print]);
%%charsize(1.3); %good font size
%nice_width; %good line ratios
%_pgscf(2); %make font roman
%plot_comps({{g}},popt,&plot_data);
%close_plot(pid);

%
