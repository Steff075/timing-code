import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from astropy.io import fits as pyfits

# Prepare to write the data to a CSV file by reading the fits header line using pyfits
data = pyfits.getdata('/data/scratch3/steff/1H0707-495/0110890201/PROC/0110890201_0.3-10keV.fits')
#print (data)

# Create the csv file
with open('0110890201_0.3-10keV.csv', 'w') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(data)
