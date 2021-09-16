#!  /opt/data.cluster/astrosoft/lib/python2.7/
#! alternative /usr/bin/python

# Script to create a "spectrum" corresponding to lag-frequency plots
# and a response matrix containing the frequency binning
# Spectra are usually plotted as energy on x-axis and counts / s / keV on y-axis
# Our x-axis will correspond to Frequency (Hz)
# Our y-axis will correspond to Time lag (sec)
# This means our y values need to be multiplied by the bin width
# The "exposure time" is set to one second
# Note steff's method: ##! /opt/local/bin/python3.5

from astropy.io import fits
import numpy as np
import sys, os

# Time lag values
time_lag = np.array([2.947609e+02 , 1.333415e+02 , 1.292101e+02 , 2.705473e+01 , -2.525674e+01 , -2.871260e+01 , -8.652118e+00])
time_lag_err = np.array([1.275105e+02 , 5.355345e+01 , 5.232859e+01 , 4.634820e+01 , 2.247588e+01 , 1.052060e+01 , 5.010411e+00])
# Frequency bins should be contiguous with no gaps between them
freq_low = np.array([9.771426e-05 , 0.0001473469 , 0.00025259475 , 0.00043301959999999997 , 0.00074231925 , 0.0012725472 , 0.0021815095])
freq_high = np.array([0.0001473469 , 0.00025259475 , 0.00043301959999999997 , 0.00074231925 , 0.0012725472 , 0.0021815095 , 0.0030311501000000003])

os.system("rm -f time_lags.fits")
os.system("rm -f time_lags.rsp")

# Name of output file stem (.fits and .rsp get added to this stem)
output_file = '1H0707-495-lo-cts-time-lags-fmax'

# Multiply lags and associated errors by bin widths
time_lag = time_lag * (freq_high - freq_low)
time_lag_err = time_lag_err  * (freq_high - freq_low)

# Create the "spectrum"
# See http://heasarc.gsfc.nasa.gov/docs/heasarc/ofwg/docs/spectra/ogip_92_007/ogip_92_007.html
# And the example on that site too

channels = np.arange(1, len(time_lag)+1)
zeros = np.zeros(len(time_lag))
ones = np.ones(len(time_lag))

col1 = fits.Column(name='CHANNEL', format='I', array=channels)
col2 = fits.Column(name='COUNTS', format='E', array=time_lag)
col3 = fits.Column(name='STAT_ERR', format='E', array=time_lag_err)
col4 = fits.Column(name='GROUPING', format='I', array=zeros)

spechdr = fits.Header()
spechdr['SYS_ERR'] = 0
spechdr['QUALITY'] = 0
spechdr['POISSERR'] = False
spechdr['EXPOSURE'] = 1.0
spechdr['AREASCAL'] = 1.0
spechdr['BACKSCAL'] = 1.0
spechdr['EXTNAME'] = 'SPECTRUM'
spechdr['DETCHANS'] = len(time_lag)
spechdr['HDUCLASS'] = 'OGIP'
spechdr['HDUCLAS1'] = 'SPECTRUM'
spechdr['HDUVERS'] = '1.2.1'
spechdr['BACKFILE'] = 'none'
spechdr['CORRFILE'] = 'none'
spechdr['RESPFILE'] = output_file + '.rsp'
spechdr['ANCRFILE'] = 'none'
spechdr['CHANTYPE'] = 'PI'
spechdr['TELESCOP'] = 'XMM-NEWTON'
spechdr['INSTRUME'] = 'EPIC-PN'
spechdr['FILTER'] = 'none'

cols = fits.ColDefs([col1, col2, col3, col4])

tbhdu = fits.BinTableHDU.from_columns(cols, name='SPECTRUM', header=spechdr)

prihdr = fits.Header()
prihdr['HDUCLASS'] = 'OGIP'
prihdr['HDUCLAS1'] = 'SPECTRUM'
prihdr['HDUVERS'] = '1.2.1'
prihdu = fits.PrimaryHDU(header=prihdr)

thdulist = fits.HDUList([prihdu, tbhdu])
thdulist.writeto(output_file + '.fits')

print("Created spectrum")

# Create the "response"
# See http://heasarc.gsfc.nasa.gov/docs/heasarc/caldb/docs/memos/cal_gen_92_002/cal_gen_92_002.html
# Our response matrix will be diagonal

rsp_col1 = fits.Column(name='ENERG_LO', format='E', array=freq_low)
rsp_col2 = fits.Column(name='ENERG_HI', format='E', array=freq_high)
rsp_col3 = fits.Column(name='N_GRP', format='I', array=ones)
rsp_col4 = fits.Column(name='F_CHAN', format='I', array=channels)
rsp_col5 = fits.Column(name='N_CHAN', format='I', array=ones)
rsp_col6 = fits.Column(name='MATRIX', format='E', array=ones)

rspcols = fits.ColDefs([rsp_col1, rsp_col2, rsp_col3, rsp_col4, rsp_col5, rsp_col6])

rsphdr = fits.Header()
rsphdr['EXTNAME'] = 'MATRIX'
rsphdr['TELESCOP'] = 'XMM-NEWTON'
rsphdr['INSTRUME'] = 'EPIC-PN'
rsphdr['FILTER'] = 'none'
rsphdr['CHANTYPE'] = 'PI'
rsphdr['DETCHANS'] = len(time_lag)
rsphdr['HDUCLASS'] = 'OGIP'
rsphdr['HDUCLAS1'] = 'RESPONSE'
rsphdr['HDUCLAS2'] = 'RSP_MATRIX'
rsphdr['HDUCLAS3'] = 'FULL'
rsphdr['HDUVERS'] = '1.3.0'

rsphdu = fits.BinTableHDU.from_columns(rspcols, name='MATRIX', header=rsphdr)

ebin_col1 = fits.Column(name='CHANNEL', format='I', array=channels)
ebin_col2 = fits.Column(name='E_MIN', format='E', array=freq_low)
ebin_col3 = fits.Column(name='E_MAX', format='E', array=freq_high)

ebin_cols = fits.ColDefs([ebin_col1, ebin_col2, ebin_col3])

ebin_hdr = fits.Header()
ebin_hdr['EXTNAME'] = 'EBOUNDS'
ebin_hdr['TELESCOP'] = 'XMM-NEWTON'
ebin_hdr['INSTRUME'] = 'EPIC-PN'
ebin_hdr['FILTER'] = 'none'
ebin_hdr['CHANTYPE'] = 'PI'
ebin_hdr['DETCHANS'] = len(time_lag)
ebin_hdr['HDUCLASS'] = 'OGIP'
ebin_hdr['HDUCLAS1'] = 'RESPONSE'
ebin_hdr['HDUCLAS2'] = 'EBOUNDS'
ebin_hdr['HDUVERS'] = '1.2.0'

ebin_hdu = fits.BinTableHDU.from_columns(ebin_cols, name='EBOUNDS', header=ebin_hdr)

rsp_prihdr = fits.Header()
rsp_prihdr['HDUCLASS'] = 'OGIP'
rsp_prihdr['HDUCLAS1'] = 'SPECTRUM'
rsp_prihdr['HDUVERS'] = '1.2.1'
rsp_prihdu = fits.PrimaryHDU(header=rsp_prihdr)

rsp_thdulist = fits.HDUList([rsp_prihdu, rsphdu, ebin_hdu])
rsp_thdulist.writeto(output_file + '.rsp')

print("Created response")
