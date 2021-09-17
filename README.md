# XMM-Newton timing-code

This repository includes basic code for the production of XMM-Newton data for analysis of light curves and spectra

## X-ray data from XMM-Newton

### Pre-processing example (ODF data)

heainit

setsas

setenv SAS_CCFPATH /usr/local/XMM/ccf/

setenv SAS_ODF /data/scratch3/steff/Mrk335/0306870101/ODF

cifbuild

setenv SAS_CCF ccf.cif

odfingest

### Set the SUM.SAS file by
setenv SAS_ODF /data/scratch3/steff/Mrk335/0306870101/ODF/1112_0306870101_SCX00000SUM.SAS

### Copy SUM.SAS and ccf.cif to PROC Directory

cp 1112_0306870101_SCX00000SUM.SAS /data/scratch3/steff/Mrk335/0306870101/PROC

cp ccf.cif /data/scratch3/steff/Mrk335/0306870101/PROC

### Create 10 - 12 keV lightcurves

evselect table=EPIC.fits withrateset=yes rateset=EPICflares.fits maketimecolumn=yes timebinsize=100 makeratecolumn=yes expression='#XMMEA_EP && (PI>10000&&PI<12000) && (PATTERN==0)'

### Create PN Events

epproc randomizetime=no randomizeenergy=no randomizeposition=no

### Create 10 - 12 keV lightcurves

evselect table=EPIC.fits withrateset=yes rateset=EPICflares.fits maketimecolumn=yes timebinsize=100 makeratecolumn=yes expression='#XMMEA_EP && (PI>10000&&PI<12000) && (PATTERN==0)'

dsplot table=EPICflares.fits x=TIME y=RATE &

### Remove flared region

evselect table=EPIC.fits withfilteredset=yes filteredset=EPICclean.fits filtertype=expression  expression='TIME in [252710000:252830000]' keepfilteroutput=yes updateexposure=yes

### Create the clean lightcurve

evselect table=EPICclean.fits withrateset=yes rateset=EPICclean_lc.fits maketimecolumn=yes timebinsize=100 makeratecolumn=yes timemin=252710000 timemax=252830000

### Create the image

evselect table=EPIC.fits withimageset=yes imageset=EPIC_image.fits xcolumn=X ycolumn=Y imagebinning=imageSize ximagesize=600 yimagesize=600

ds9 EPIC_image.fits &

`extract source and backrground regions and create spectra` using `sas_postproc_script.sl`

### Check for pileup

gv PN_time_epat.ps

### Group spectra 

rmfgen rmfset=PN_time_0.3-10_src_pi_rmf.fits spectrumset=PN_time_0.3-10_src_pi.fits

arfgen arfset=PN_time_0.3-10_src_pi_arf.fits spectrumset=PN_time_0.3-10_src_pi.fits withrmfset=yes rmfset=PN_time_0.3-10_src_pi_rmf.fits withbadpixcorr=yes badpixlocation=PN_time_0.3-10.fits

grppha

PN_time_0.3-10_src_pi.fits
PN_time_0.3-10_pi_grp.fits
PN_time_0.3-10_bkg_pi.fits
PN_time_0.3-10_src_pi_rmf.fits
PN_time_0.3-10_src_pi_arf.fits
group min 25
exit

## Software to perform initial data processing

| Code                       | Description                                                              |
|----------------------------|--------------------------------------------------------------------------|
| `sas_postproc_script.sl`   | creates the lightcurves and spectra from the source and backrgound image 
| `lagfreq_script.sl`        | create the time lags asa function of frequency between 2 different energy bands     |


There are more codes that listed in the above table. This will need to be tidied up.



