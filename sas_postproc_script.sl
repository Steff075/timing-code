#!/bin/tcsh

# This script is to be run after you have completed Pre-processeing up to and including producing the lightcurve (in 10-12 keV for flares) and image of the target

source $HEADAS/headas-init.csh #Initialise HEASoft software

source /usr/local/xmmsas_20160201_1833/setsas.csh #Initialise SAS tools

setenv SAS_CCFPATH /usr/local/XMM/ccf #identify location of current calibration files (CCF)

setenv SAS_CCF ccf.cif

#Apply Filters

#Soft Filter
evselect table=EPICclean.fits withfilteredset=yes filteredset=PN_time_soft.fits filtertype=expression expression='(FLAG==0)&&(PATTERN<=4)&&(PI in [300:800])&&#XMMEA_EP' keepfilteroutput=yes updateexposure=yes filterexposure=yes

#Hard Filter
evselect table=EPICclean.fits withfilteredset=yes filteredset=PN_time_hard.fits filtertype=expression expression='(FLAG==0)&&(PATTERN<=4)&&(PI in [1000:4000])&&#XMMEA_EP' keepfilteroutput=yes updateexposure=yes filterexposure=yes

#Extract Source and Background

#Extract Source from Soft Photons
evselect table=PN_time_soft.fits withfilteredset=yes filteredset=PN_time_soft_src.fits filtertype=expression expression='(X,Y) in CIRCLE(25143,23904,700)' keepfilteroutput=yes updateexposure=yes filterexposure=yes

#Extract Source from Hard Photons
evselect table=PN_time_hard.fits withfilteredset=yes filteredset=PN_time_hard_src.fits filtertype=expression expression='(X,Y) in CIRCLE(25143,23904,700)' keepfilteroutput=yes updateexposure=yes filterexposure=yes

#Extract Background from Soft Photons
evselect table=PN_time_soft.fits withfilteredset=yes filteredset=PN_time_soft_bkg.fits filtertype=expression expression='(X,Y) in CIRCLE(21707,31516,700)' keepfilteroutput=yes updateexposure=yes filterexposure=yes

#Extract Background from Hard Photons
evselect table=PN_time_hard.fits withfilteredset=yes filteredset=PN_time_hard_bkg.fits filtertype=expression expression='(X,Y) in CIRCLE(21707,31516,700)' keepfilteroutput=yes updateexposure=yes filterexposure=yes

#Create Lightcurve from source

#Create lc from soft photons
evselect table=PN_time_soft_src.fits withrateset=yes rateset=PN_time_soft_src_lc.fits maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes

#Create lc from hard photons
evselect table=PN_time_hard_src.fits withrateset=yes rateset=PN_time_hard_src_lc.fits maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes

#Create lc from Background

#Create lc from soft photons
evselect table=PN_time_soft_bkg.fits withrateset=yes rateset=PN_time_soft_bkg_lc.fits maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes

#Create lc from hard photons
evselect table=PN_time_hard_bkg.fits withrateset=yes rateset=PN_time_hard_bkg_lc.fits maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes

#Create Background Subtracted Light Curve

#from soft photons
epiclccorr srctslist=PN_time_soft_src_lc.fits eventlist=EPICclean.fits outset=PN_time_soft_lccorr.fits bkgtslist=PN_time_soft_bkg_lc.fits withbkgset=yes applyabsolutecorrections=yes

#from hard photons
epiclccorr srctslist=PN_time_hard_src_lc.fits eventlist=EPICclean.fits outset=PN_time_hard_lccorr.fits bkgtslist=PN_time_hard_bkg_lc.fits withbkgset=yes applyabsolutecorrections=yes

#Display the lightcurve

dsplot table=PN_time_soft_lccorr.fits x=TIME y=RATE &

dsplot table=PN_time_hard_lccorr.fits x=TIME y=RATE &

#Note that the above lightcurves can be chopped with the evselect timemin and timemax command

#PRODUCE SPECTRUM

#Refilter Source
evselect table=EPICclean.fits withfilteredset=yes filteredset=PN_time_0.3-10.fits filtertype=expression expression='(FLAG==0)&&(PATTERN<=4)&&(PI in [300:10000])&&#XMMEA_EP' keepfilteroutput=yes updateexposure=yes filterexposure=yes

#Extract Source and Background
evselect table=PN_time_0.3-10.fits withfilteredset=yes filteredset=PN_time_0.3-10_src.fits filtertype=expression expression='(X,Y) in CIRCLE(25143,23904,700)' keepfilteroutput=yes updateexposure=yes filterexposure=yes

evselect table=PN_time_0.3-10.fits withfilteredset=yes filteredset=PN_time_0.3-10_bkg.fits filtertype=expression expression='(X,Y) in CIRCLE(21707,31516,700)' keepfilteroutput=yes updateexposure=yes filterexposure=yes

#Create source spectrum
evselect table=PN_time_0.3-10_src.fits withspectrumset=yes spectrumset=PN_time_0.3-10_src_pi.fits energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

#Create Background Spectrum
evselect table=PN_time_0.3-10_bkg.fits withspectrumset=yes spectrumset=PN_time_0.3-10_bkg_pi.fits energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

#Calculate source & background areas
backscale spectrumset=PN_time_0.3-10_src_pi.fits badpixlocation=PN_time_0.3-10.fits
backscale spectrumset=PN_time_0.3-10_bkg_pi.fits badpixlocation=PN_time_0.3-10.fits

#Check for Pileup (soft & hard)
epatplot set=PN_time_0.3-10.fits plotfile=PN_time_epat.ps useplotfile=yes withbackgroundset=yes backgroundset=PN_time_0.3-10_bkg.fits

#View epat plots
gv PN_time_epat.ps 

#Now move onto creating the grouped spectral files using GRPPHA

##END OF SCRIPT##
